import 'dart:async';
import 'dart:math';

import 'package:serverpod/serverpod.dart';

import '../generated/protocol.dart';
import 'cut_logic.dart';
import 'question_bank.dart';

/// Answers that arrive this long after the deadline are still accepted, to
/// absorb network latency. The server clock is the only clock that counts.
const answerGrace = Duration(milliseconds: 500);

/// After a finalist buzzes they get at least this long to answer.
const buzzAnswerWindow = Duration(seconds: 8);

/// Points for a correct buzzer-final answer.
const finalPointsPerQuestion = 1000;

const _codeAlphabet = 'ABCDEFGHJKLMNPQRSTUVWXYZ23456789';
final _random = Random.secure();

String _randomToken() =>
    List.generate(32, (_) => _random.nextInt(16).toRadixString(16)).join();

String _randomCode(int length) => List.generate(
  length,
  (_) => _codeAlphabet[_random.nextInt(_codeAlphabet.length)],
).join();

String channelFor(String code) => 'room-$code';

QuizException _error(QuizErrorCode code, String message) =>
    QuizException(code: code, message: message);

/// Game logic for a room. Endpoints are thin wrappers around this.
class RoomService {
  /// When true, the server reveals questions on its own once their deadline
  /// passes, so a host whose tab goes to sleep cannot stall the game.
  /// Enabled in `server.dart`; off in tests.
  static bool autoRevealEnabled = false;

  // ---------------------------------------------------------------- lookup

  static Future<Room> _roomByCode(
    Session session,
    String code, {
    Transaction? tx,
    bool lock = false,
  }) async {
    final room = await Room.db.findFirstRow(
      session,
      where: (t) => t.code.equals(code.trim().toUpperCase()),
      transaction: tx,
      lockMode: lock ? LockMode.forUpdate : null,
    );
    if (room == null) {
      throw _error(QuizErrorCode.roomNotFound, 'Room not found');
    }
    return room;
  }

  static Future<Room> _hostRoom(
    Session session,
    String code,
    String hostToken, {
    Transaction? tx,
    bool lock = false,
  }) async {
    final room = await _roomByCode(session, code, tx: tx, lock: lock);
    if (room.hostToken != hostToken) {
      throw _error(QuizErrorCode.notHost, 'Only the host can do that');
    }
    return room;
  }

  static Future<Player> _playerByToken(
    Session session,
    String token, {
    Transaction? tx,
    bool lock = false,
  }) async {
    final player = await Player.db.findFirstRow(
      session,
      where: (t) => t.token.equals(token),
      transaction: tx,
      lockMode: lock ? LockMode.forUpdate : null,
    );
    if (player == null) {
      throw _error(QuizErrorCode.playerNotFound, 'Player not found');
    }
    return player;
  }

  // ----------------------------------------------------------------- lobby

  static Future<CreateRoomResult> createRoom(
    Session session,
    RoomConfig config,
  ) async {
    _validateConfig(config);
    final hostToken = _randomToken();
    for (var attempt = 0; attempt < 20; attempt++) {
      // Grow the code if short ones keep colliding.
      final code = _randomCode(attempt < 10 ? 4 : 5);
      final exists =
          await Room.db.count(session, where: (t) => t.code.equals(code)) > 0;
      if (exists) continue;
      await Room.db.insertRow(
        session,
        Room(
          code: code,
          hostToken: hostToken,
          questionsPerRound: config.questionsPerRound,
          eliminationRule: config.eliminationRule,
          eliminationPercent: config.eliminationPercent,
          finalistTarget: config.finalistTarget,
          roundsBeforeFinal: config.roundsBeforeFinal,
          tiebreakMode: config.tiebreakMode,
          finalQuestionCount: config.finalQuestionCount,
          timeLimitSeconds: config.timeLimitSeconds,
        ),
      );
      return CreateRoomResult(roomCode: code, hostToken: hostToken);
    }
    throw _error(QuizErrorCode.invalidState, 'Could not allocate a room code');
  }

  static void _validateConfig(RoomConfig c) {
    void check(bool ok, String message) {
      if (!ok) throw _error(QuizErrorCode.invalidInput, message);
    }

    check(
      c.questionsPerRound >= 1 && c.questionsPerRound <= 20,
      'questionsPerRound must be 1-20',
    );
    check(
      c.eliminationPercent > 0 && c.eliminationPercent < 1,
      'eliminationPercent must be between 0 and 1',
    );
    check(
      c.finalistTarget >= 2 && c.finalistTarget <= 10,
      'finalistTarget must be 2-10',
    );
    check(
      c.roundsBeforeFinal >= 1 && c.roundsBeforeFinal <= 10,
      'roundsBeforeFinal must be 1-10',
    );
    check(
      c.finalQuestionCount >= 1 && c.finalQuestionCount <= 12,
      'finalQuestionCount must be 1-12',
    );
    check(
      c.timeLimitSeconds >= 5 && c.timeLimitSeconds <= 120,
      'timeLimitSeconds must be 5-120',
    );
  }

  static Future<JoinResult> joinRoom(
    Session session,
    String code,
    String nickname,
  ) async {
    final name = nickname.trim();
    if (name.isEmpty || name.length > 20) {
      throw _error(
        QuizErrorCode.invalidInput,
        'Nickname must be 1-20 characters',
      );
    }
    final result = await session.db.transaction((tx) async {
      final room = await _roomByCode(session, code, tx: tx, lock: true);
      if (room.status != RoomStatus.lobby) {
        throw _error(
          QuizErrorCode.invalidState,
          'The game has already started',
        );
      }
      final players = await Player.db.find(
        session,
        where: (t) => t.roomId.equals(room.id!),
        transaction: tx,
      );
      if (players.any((p) => p.nickname.toLowerCase() == name.toLowerCase())) {
        throw _error(QuizErrorCode.nicknameTaken, 'That nickname is taken');
      }
      final token = _randomToken();
      final player = await Player.db.insertRow(
        session,
        Player(roomId: room.id!, nickname: name, token: token),
        transaction: tx,
      );
      return (
        room,
        JoinResult(
          roomCode: room.code,
          playerId: player.id!,
          playerToken: token,
        ),
      );
    });
    await _broadcast(session, result.$1.id!);
    return result.$2;
  }

  /// Lets a player whose tab reloaded or reconnected recover their identity.
  static Future<JoinResult> rejoin(
    Session session,
    String code,
    String playerToken,
  ) async {
    final room = await _roomByCode(session, code);
    final player = await _playerByToken(session, playerToken);
    if (player.roomId != room.id) {
      throw _error(QuizErrorCode.playerNotFound, 'Player not in this room');
    }
    return JoinResult(
      roomCode: room.code,
      playerId: player.id!,
      playerToken: playerToken,
    );
  }

  // ------------------------------------------------------------ host flow

  static Future<void> startGame(
    Session session,
    String code,
    String hostToken,
  ) async {
    final room = await session.db.transaction((tx) async {
      var room = await _hostRoom(session, code, hostToken, tx: tx, lock: true);
      if (room.status != RoomStatus.lobby) {
        throw _error(QuizErrorCode.invalidState, 'Game already started');
      }
      final count = await Player.db.count(
        session,
        where: (t) => t.roomId.equals(room.id!),
        transaction: tx,
      );
      if (count < 2) {
        throw _error(QuizErrorCode.invalidState, 'Need at least 2 players');
      }
      room = room.copyWith(startingPlayerCount: count, currentRound: 1);
      return _startQuestion(session, tx, room, isFinal: false);
    });
    await _afterQuestionStarted(session, room);
  }

  /// Advances to the next question: within a round, into the next round after
  /// a cut, into the buzzer final, or to the podium after the last final
  /// question.
  static Future<void> nextQuestion(
    Session session,
    String code,
    String hostToken,
  ) async {
    final room = await session.db.transaction((tx) async {
      var room = await _hostRoom(session, code, hostToken, tx: tx, lock: true);
      final current = await _currentQuestion(session, room, tx: tx);
      final inFinal = current?.isFinal ?? false;

      if (room.status == RoomStatus.reveal && inFinal) {
        if (room.finalQuestionsPlayed >= room.finalQuestionCount) {
          return Room.db.updateRow(
            session,
            room.copyWith(status: RoomStatus.finished),
            transaction: tx,
          );
        }
        return _startQuestion(session, tx, room, isFinal: true);
      }
      if (room.status == RoomStatus.reveal) {
        if (await _finalistsDecided(session, room, tx)) {
          throw _error(
            QuizErrorCode.invalidState,
            'Finalists are decided; end the round to reveal them',
          );
        }
        if (room.currentQuestionIndex >= room.questionsPerRound) {
          throw _error(QuizErrorCode.invalidState, 'Round over; end the round');
        }
        return _startQuestion(session, tx, room, isFinal: false);
      }
      if (room.status == RoomStatus.elimination) {
        if (room.lastElimination?.finalistsDecided ?? false) {
          return _startQuestion(session, tx, room, isFinal: true);
        }
        room = room.copyWith(
          currentRound: room.currentRound + 1,
          currentQuestionIndex: 0,
        );
        return _startQuestion(session, tx, room, isFinal: false);
      }
      throw _error(
        QuizErrorCode.invalidState,
        'Cannot advance from ${room.status.name}',
      );
    });
    if (room.status == RoomStatus.finished) {
      await _broadcast(session, room.id!);
    } else {
      await _afterQuestionStarted(session, room);
    }
  }

  static Future<void> reveal(
    Session session,
    String code,
    String hostToken,
  ) async {
    final room = await _hostRoom(session, code, hostToken);
    final questionId = room.currentQuestionId;
    if (questionId == null) {
      throw _error(QuizErrorCode.invalidState, 'No question to reveal');
    }
    final changed = await _revealIfCurrent(session, room.id!, questionId);
    if (!changed && room.status != RoomStatus.reveal) {
      throw _error(
        QuizErrorCode.invalidState,
        'Cannot reveal from ${room.status.name}',
      );
    }
  }

  /// Ends the current round and runs the cut. Idempotent: a second call for
  /// the same round changes nothing.
  static Future<void> endRound(
    Session session,
    String code,
    String hostToken,
  ) async {
    final roomId = await session.db.transaction((tx) async {
      final room = await _hostRoom(
        session,
        code,
        hostToken,
        tx: tx,
        lock: true,
      );
      if (room.lastCutRound >= room.currentRound) return room.id!;
      if (room.status != RoomStatus.reveal) {
        throw _error(
          QuizErrorCode.invalidState,
          'Can only end a round after a reveal',
        );
      }
      final current = await _currentQuestion(session, room, tx: tx);
      if (current?.isFinal ?? false) {
        throw _error(QuizErrorCode.invalidState, 'The final has no rounds');
      }

      final active = await Player.db.find(
        session,
        where: (t) =>
            t.roomId.equals(room.id!) & t.status.equals(PlayerStatus.active),
        transaction: tx,
      );
      final cut = computeRoundCut(
        active: active.map(_candidate).toList(),
        rule: room.eliminationRule,
        eliminationPercent: room.eliminationPercent,
        finalistTarget: room.finalistTarget,
        startingPlayers: room.startingPlayerCount ?? active.length,
        roundsBeforeFinal: room.roundsBeforeFinal,
        round: room.currentRound,
      );
      final finalists = cut.survivorIds.length <= room.finalistTarget;

      final eliminated = cut.eliminatedIds.toSet();
      final updates = [
        for (final p in active)
          if (eliminated.contains(p.id))
            p.copyWith(
              status: PlayerStatus.eliminated,
              eliminatedInRound: room.currentRound,
            )
          else if (finalists)
            p.copyWith(status: PlayerStatus.finalist),
      ];
      if (updates.isNotEmpty) {
        await Player.db.update(session, updates, transaction: tx);
      }
      await Room.db.updateRow(
        session,
        room.copyWith(
          status: RoomStatus.elimination,
          lastCutRound: room.currentRound,
          lastElimination: EliminationEvent(
            round: room.currentRound,
            eliminatedPlayerIds: cut.eliminatedIds,
            survivorsCount: cut.survivorIds.length,
            tieBrokenBySpeed: cut.tieBrokenBySpeed,
            finalistsDecided: finalists,
          ),
        ),
        transaction: tx,
      );
      return room.id!;
    });
    await _broadcast(session, roomId);
  }

  /// Rescues one eliminated player, once per game, before the final starts.
  static Future<void> useWildcard(
    Session session,
    String code,
    String hostToken,
    int playerId,
  ) async {
    final roomId = await session.db.transaction((tx) async {
      final room = await _hostRoom(
        session,
        code,
        hostToken,
        tx: tx,
        lock: true,
      );
      if (room.wildcardUsed) {
        throw _error(QuizErrorCode.notAllowed, 'Wildcard already used');
      }
      if (room.finalQuestionsPlayed > 0 || room.status == RoomStatus.finished) {
        throw _error(QuizErrorCode.invalidState, 'The final has started');
      }
      final player = await Player.db.findById(
        session,
        playerId,
        transaction: tx,
        lockMode: LockMode.forUpdate,
      );
      if (player == null || player.roomId != room.id) {
        throw _error(QuizErrorCode.playerNotFound, 'Player not found');
      }
      if (player.status != PlayerStatus.eliminated) {
        throw _error(QuizErrorCode.notAllowed, 'Player is not eliminated');
      }
      final finalsDecided = room.lastElimination?.finalistsDecided ?? false;
      await Player.db.updateRow(
        session,
        player.copyWith(
          status: finalsDecided ? PlayerStatus.finalist : PlayerStatus.active,
          eliminatedInRound: null,
          backedPlayerId: null,
        ),
        transaction: tx,
      );
      // Anyone who backed the rescued player keeps their pick: still valid.
      await Room.db.updateRow(
        session,
        room.copyWith(wildcardUsed: true),
        transaction: tx,
      );
      return room.id!;
    });
    await _broadcast(session, roomId);
  }

  // --------------------------------------------------------------- players

  static Future<AnswerResult> submitAnswer(
    Session session,
    String playerToken,
    int questionId,
    int choiceIndex,
  ) async {
    final now = DateTime.now().toUtc();
    final (roomId, isShadow) = await session.db.transaction((tx) async {
      // Locking the player row serialises answers per player, so "one
      // answer per question" holds even under double taps.
      final player = await _playerByToken(
        session,
        playerToken,
        tx: tx,
        lock: true,
      );
      final room = await Room.db.findById(
        session,
        player.roomId,
        transaction: tx,
      );
      if (room == null) {
        throw _error(QuizErrorCode.roomNotFound, 'Room not found');
      }
      if (room.status != RoomStatus.question ||
          room.currentQuestionId != questionId) {
        throw _error(QuizErrorCode.tooLate, 'This question is closed');
      }
      if (now.isAfter(room.questionEndsAt!.add(answerGrace))) {
        throw _error(QuizErrorCode.tooLate, 'Time is up');
      }
      final question = await Question.db.findById(
        session,
        questionId,
        transaction: tx,
      );
      if (question == null) {
        throw _error(QuizErrorCode.invalidState, 'Question not found');
      }
      if (choiceIndex < 0 || choiceIndex >= question.options.length) {
        throw _error(QuizErrorCode.invalidInput, 'Invalid choice');
      }
      final existing = await Answer.db.count(
        session,
        where: (t) =>
            t.playerId.equals(player.id!) & t.questionId.equals(questionId),
        transaction: tx,
      );
      if (existing > 0) {
        throw _error(QuizErrorCode.alreadyAnswered, 'Already answered');
      }

      final isShadow = player.status != PlayerStatus.active;
      final correct = choiceIndex == question.correctIndex;
      final elapsed = now
          .difference(room.questionStartedAt!)
          .inMilliseconds
          .clamp(0, 1 << 31);
      final points = pointsForAnswer(
        correct: correct,
        elapsedMs: elapsed,
        timeLimitSeconds: question.timeLimitSeconds,
      );

      await Answer.db.insertRow(
        session,
        Answer(
          playerId: player.id!,
          questionId: questionId,
          choiceIndex: choiceIndex,
          answeredAt: now,
          elapsedMs: elapsed,
          isCorrect: correct,
          pointsAwarded: points,
          isShadow: isShadow,
        ),
        transaction: tx,
      );
      await Player.db.updateRow(
        session,
        isShadow
            ? player.copyWith(shadowScore: player.shadowScore + points)
            : player.copyWith(
                score: player.score + points,
                totalCorrectAnswerMs:
                    player.totalCorrectAnswerMs + (correct ? elapsed : 0),
              ),
        transaction: tx,
      );
      return (room.id!, isShadow);
    });

    // Reveal early once every active player has answered.
    final revealed =
        !isShadow && await _revealIfAllAnswered(session, roomId, questionId);
    if (!revealed) await _broadcast(session, roomId);
    return AnswerResult(accepted: true, isShadow: isShadow);
  }

  /// An eliminated player picks the finalist they think will win.
  static Future<void> backFinalist(
    Session session,
    String playerToken,
    int finalistId,
  ) async {
    final player = await _playerByToken(session, playerToken);
    final room = await Room.db.findById(session, player.roomId);
    if (room == null) {
      throw _error(QuizErrorCode.roomNotFound, 'Room not found');
    }
    if (player.status != PlayerStatus.eliminated) {
      throw _error(QuizErrorCode.notAllowed, 'Only spectators back a finalist');
    }
    if (room.finalQuestionsPlayed > 0) {
      throw _error(QuizErrorCode.invalidState, 'The final has started');
    }
    final finalist = await Player.db.findById(session, finalistId);
    if (finalist == null ||
        finalist.roomId != room.id ||
        finalist.status != PlayerStatus.finalist) {
      throw _error(QuizErrorCode.invalidInput, 'Not a finalist');
    }
    await Player.db.updateRow(
      session,
      player.copyWith(backedPlayerId: finalistId),
    );
    await _broadcast(session, room.id!);
  }

  // ----------------------------------------------------------- buzzer final

  /// The first valid buzz wins. The room row is locked, so two simultaneous
  /// buzzes are serialised and only one can find the buzzer free.
  static Future<BuzzResult> buzz(
    Session session,
    String playerToken,
    int questionId,
  ) async {
    final now = DateTime.now().toUtc();
    final result = await session.db.transaction((tx) async {
      final player = await _playerByToken(session, playerToken, tx: tx);
      final room = await Room.db.findById(
        session,
        player.roomId,
        transaction: tx,
        lockMode: LockMode.forUpdate,
      );
      if (room == null) {
        throw _error(QuizErrorCode.roomNotFound, 'Room not found');
      }
      if (player.status != PlayerStatus.finalist) {
        return (
          null,
          BuzzResult(gotBuzzer: false, reason: 'Only finalists can buzz'),
        );
      }
      if (room.status != RoomStatus.buzzerFinal ||
          room.currentQuestionId != questionId ||
          now.isAfter(room.questionEndsAt!)) {
        return (null, BuzzResult(gotBuzzer: false, reason: 'Question closed'));
      }
      final previous = await Buzz.db.count(
        session,
        where: (t) =>
            t.playerId.equals(player.id!) & t.questionId.equals(questionId),
        transaction: tx,
      );
      if (previous > 0) {
        return (null, BuzzResult(gotBuzzer: false, reason: 'Locked out'));
      }
      if (room.buzzerHolderId != null) {
        return (null, BuzzResult(gotBuzzer: false, reason: 'Too slow'));
      }
      await Buzz.db.insertRow(
        session,
        Buzz(playerId: player.id!, questionId: questionId, buzzedAt: now),
        transaction: tx,
      );
      final minEnd = now.add(buzzAnswerWindow);
      final updated = await Room.db.updateRow(
        session,
        room.copyWith(
          buzzerHolderId: player.id,
          questionEndsAt: room.questionEndsAt!.isBefore(minEnd)
              ? minEnd
              : room.questionEndsAt,
        ),
        transaction: tx,
      );
      return (updated, BuzzResult(gotBuzzer: true));
    });
    final room = result.$1;
    if (room != null) await _afterQuestionStarted(session, room);
    return result.$2;
  }

  static Future<bool> submitBuzzAnswer(
    Session session,
    String playerToken,
    int questionId,
    int choiceIndex,
  ) async {
    final (roomId, correct) = await session.db.transaction((tx) async {
      final player = await _playerByToken(
        session,
        playerToken,
        tx: tx,
        lock: true,
      );
      final room = await Room.db.findById(
        session,
        player.roomId,
        transaction: tx,
        lockMode: LockMode.forUpdate,
      );
      if (room == null) {
        throw _error(QuizErrorCode.roomNotFound, 'Room not found');
      }
      if (room.status != RoomStatus.buzzerFinal ||
          room.currentQuestionId != questionId ||
          room.buzzerHolderId != player.id) {
        throw _error(QuizErrorCode.notAllowed, 'You do not hold the buzzer');
      }
      final question = await Question.db.findById(
        session,
        questionId,
        transaction: tx,
      );
      if (question == null ||
          choiceIndex < 0 ||
          choiceIndex >= question.options.length) {
        throw _error(QuizErrorCode.invalidInput, 'Invalid choice');
      }
      final buzz = await Buzz.db.findFirstRow(
        session,
        where: (t) =>
            t.playerId.equals(player.id!) & t.questionId.equals(questionId),
        transaction: tx,
      );
      final correct = choiceIndex == question.correctIndex;
      await Buzz.db.updateRow(
        session,
        buzz!.copyWith(wasCorrect: correct, lockedOut: !correct),
        transaction: tx,
      );
      if (correct) {
        await Player.db.updateRow(
          session,
          player.copyWith(
            finalScore: player.finalScore + finalPointsPerQuestion,
          ),
          transaction: tx,
        );
        await Room.db.updateRow(
          session,
          room.copyWith(status: RoomStatus.reveal, buzzerHolderId: null),
          transaction: tx,
        );
        return (room.id!, true);
      }
      final finalists = await Player.db.count(
        session,
        where: (t) =>
            t.roomId.equals(room.id!) & t.status.equals(PlayerStatus.finalist),
        transaction: tx,
      );
      final buzzed = await Buzz.db.count(
        session,
        where: (t) => t.questionId.equals(questionId),
        transaction: tx,
      );
      final allOut = buzzed >= finalists;
      await Room.db.updateRow(
        session,
        room.copyWith(
          buzzerHolderId: null,
          status: allOut ? RoomStatus.reveal : room.status,
        ),
        transaction: tx,
      );
      return (room.id!, false);
    });
    await _broadcast(session, roomId);
    return correct;
  }

  // ------------------------------------------------------------- internals

  static CutCandidate _candidate(Player p) => CutCandidate(
    id: p.id!,
    score: p.score,
    totalCorrectAnswerMs: p.totalCorrectAnswerMs,
  );

  static Future<Question?> _currentQuestion(
    Session session,
    Room room, {
    Transaction? tx,
  }) async {
    final id = room.currentQuestionId;
    if (id == null) return null;
    return Question.db.findById(session, id, transaction: tx);
  }

  static Future<bool> _finalistsDecided(
    Session session,
    Room room,
    Transaction tx,
  ) async {
    if (room.eliminationRule != EliminationRule.suddenDeath) return false;
    final active = await Player.db.count(
      session,
      where: (t) =>
          t.roomId.equals(room.id!) & t.status.equals(PlayerStatus.active),
      transaction: tx,
    );
    return active <= room.finalistTarget;
  }

  /// Inserts the next question and puts the room into answering state.
  static Future<Room> _startQuestion(
    Session session,
    Transaction tx,
    Room room, {
    required bool isFinal,
  }) async {
    final used = await Question.db.find(
      session,
      where: (t) => t.roomId.equals(room.id!),
      transaction: tx,
    );
    final usedTexts = used.map((q) => q.text).toSet();
    final bank = isFinal ? finalQuestions : roundQuestions;
    var fresh = bank.where((q) => !usedTexts.contains(q.text)).toList();
    if (fresh.isEmpty) fresh = bank.toList();
    final pick = fresh[_random.nextInt(fresh.length)];

    final indexInRound = isFinal
        ? room.finalQuestionsPlayed + 1
        : room.currentQuestionIndex + 1;
    final question = await Question.db.insertRow(
      session,
      Question(
        roomId: room.id!,
        orderIndex: used.length + 1,
        round: isFinal ? 0 : room.currentRound,
        isFinal: isFinal,
        text: pick.text,
        options: pick.options,
        correctIndex: pick.correctIndex,
        timeLimitSeconds: room.timeLimitSeconds,
      ),
      transaction: tx,
    );
    final now = DateTime.now().toUtc();
    return Room.db.updateRow(
      session,
      room.copyWith(
        status: isFinal ? RoomStatus.buzzerFinal : RoomStatus.question,
        currentQuestionId: question.id,
        currentQuestionIndex: isFinal
            ? room.currentQuestionIndex
            : indexInRound,
        finalQuestionsPlayed: isFinal
            ? indexInRound
            : room.finalQuestionsPlayed,
        questionStartedAt: now,
        questionEndsAt: now.add(Duration(seconds: room.timeLimitSeconds)),
        buzzerHolderId: null,
      ),
      transaction: tx,
    );
  }

  static Future<void> _afterQuestionStarted(Session session, Room room) async {
    await _broadcast(session, room.id!);
    if (autoRevealEnabled) {
      _scheduleDeadline(
        room.id!,
        room.currentQuestionId!,
        room.questionEndsAt!,
      );
    }
  }

  static void _scheduleDeadline(int roomId, int questionId, DateTime endsAt) {
    final delay = endsAt.difference(DateTime.now().toUtc()) + answerGrace;
    Timer(delay.isNegative ? Duration.zero : delay, () async {
      final session = await Serverpod.instance.createSession(
        enableLogging: false,
      );
      try {
        final room = await Room.db.findById(session, roomId);
        if (room == null || room.currentQuestionId != questionId) return;
        final pending = DateTime.now().toUtc().isBefore(room.questionEndsAt!);
        if (pending) {
          // The deadline moved (a buzz extended it); check again later.
          _scheduleDeadline(roomId, questionId, room.questionEndsAt!);
        } else {
          await _revealIfCurrent(session, roomId, questionId);
        }
      } catch (e, s) {
        session.log(
          'Auto-reveal failed: $e',
          level: LogLevel.error,
          stackTrace: s,
        );
      } finally {
        await session.close();
      }
    });
  }

  /// Reveals [questionId] if it is still open. Returns whether it changed.
  static Future<bool> _revealIfCurrent(
    Session session,
    int roomId,
    int questionId,
  ) async {
    final changed = await session.db.transaction((tx) async {
      final room = await Room.db.findById(
        session,
        roomId,
        transaction: tx,
        lockMode: LockMode.forUpdate,
      );
      if (room == null ||
          room.currentQuestionId != questionId ||
          (room.status != RoomStatus.question &&
              room.status != RoomStatus.buzzerFinal)) {
        return false;
      }
      var updated = room.copyWith(
        status: RoomStatus.reveal,
        buzzerHolderId: null,
      );
      if (room.status == RoomStatus.question &&
          room.eliminationRule == EliminationRule.suddenDeath) {
        updated = await _applySuddenDeath(session, tx, updated, questionId);
      }
      await Room.db.updateRow(session, updated, transaction: tx);
      return true;
    });
    if (changed) await _broadcast(session, roomId);
    return changed;
  }

  static Future<Room> _applySuddenDeath(
    Session session,
    Transaction tx,
    Room room,
    int questionId,
  ) async {
    final active = await Player.db.find(
      session,
      where: (t) =>
          t.roomId.equals(room.id!) & t.status.equals(PlayerStatus.active),
      transaction: tx,
    );
    final correct = await Answer.db.find(
      session,
      where: (t) =>
          t.questionId.equals(questionId) &
          t.isCorrect.equals(true) &
          t.isShadow.equals(false),
      transaction: tx,
    );
    final cut = computeSuddenDeathCut(
      active: active.map(_candidate).toList(),
      correctIds: correct.map((a) => a.playerId).toSet(),
    );
    if (cut.eliminatedIds.isEmpty) return room;
    final out = cut.eliminatedIds.toSet();
    await Player.db.update(
      session,
      [
        for (final p in active)
          if (out.contains(p.id))
            p.copyWith(
              status: PlayerStatus.eliminated,
              eliminatedInRound: room.currentRound,
            ),
      ],
      transaction: tx,
    );
    return room.copyWith(
      lastElimination: EliminationEvent(
        round: room.currentRound,
        eliminatedPlayerIds: cut.eliminatedIds,
        survivorsCount: cut.survivorIds.length,
        tieBrokenBySpeed: false,
        finalistsDecided: false,
      ),
    );
  }

  static Future<bool> _revealIfAllAnswered(
    Session session,
    int roomId,
    int questionId,
  ) async {
    final active = await Player.db.count(
      session,
      where: (t) =>
          t.roomId.equals(roomId) & t.status.equals(PlayerStatus.active),
    );
    final answered = await Answer.db.count(
      session,
      where: (t) => t.questionId.equals(questionId) & t.isShadow.equals(false),
    );
    if (answered < active) return false;
    return _revealIfCurrent(session, roomId, questionId);
  }

  // ----------------------------------------------------------------- state

  static Future<RoomState> buildState(Session session, Room room) async {
    final players = await Player.db.find(
      session,
      where: (t) => t.roomId.equals(room.id!),
    );
    final question = await _currentQuestion(session, room);
    final open =
        room.status == RoomStatus.question ||
        room.status == RoomStatus.buzzerFinal;
    final finished = room.status == RoomStatus.finished;

    final answers = question == null
        ? <Answer>[]
        : await Answer.db.find(
            session,
            where: (t) => t.questionId.equals(question.id!),
          );
    final buzzes = question == null || !question.isFinal
        ? <Buzz>[]
        : await Buzz.db.find(
            session,
            where: (t) => t.questionId.equals(question.id!),
          );
    final answerBy = {for (final a in answers) a.playerId: a};
    final lockedOut = {
      for (final b in buzzes)
        if (b.lockedOut) b.playerId,
    };

    List<int>? counts;
    if (question != null && !open && !question.isFinal) {
      counts = List.filled(question.options.length, 0);
      for (final a in answers.where((a) => !a.isShadow)) {
        counts[a.choiceIndex]++;
      }
    }

    final views =
        [
          for (final p in players)
            PlayerView(
              id: p.id!,
              nickname: p.nickname,
              score: p.score,
              shadowScore: p.shadowScore,
              finalScore: p.finalScore,
              status: p.status,
              eliminatedInRound: p.eliminatedInRound,
              backedPlayerId: finished ? p.backedPlayerId : null,
              hasAnswered: answerBy.containsKey(p.id),
              lastPoints: open ? null : answerBy[p.id]?.pointsAwarded,
              lockedOut: lockedOut.contains(p.id),
            ),
        ]..sort((a, b) {
          final byFinal = b.finalScore.compareTo(a.finalScore);
          if (byFinal != 0) return byFinal;
          final byScore = b.score.compareTo(a.score);
          return byScore != 0 ? byScore : a.id.compareTo(b.id);
        });

    return RoomState(
      code: room.code,
      status: room.status,
      round: room.currentRound,
      questionsPerRound: room.questionsPerRound,
      finalistTarget: room.finalistTarget,
      finalQuestionCount: room.finalQuestionCount,
      finalQuestionsPlayed: room.finalQuestionsPlayed,
      eliminationRule: room.eliminationRule,
      wildcardUsed: room.wildcardUsed,
      question: question == null
          ? null
          : QuestionView(
              id: question.id!,
              round: question.round,
              indexInRound: question.isFinal
                  ? room.finalQuestionsPlayed
                  : room.currentQuestionIndex,
              isFinal: question.isFinal,
              text: question.text,
              options: question.options,
              timeLimitSeconds: question.timeLimitSeconds,
              correctIndex: open ? null : question.correctIndex,
              answerCounts: counts,
            ),
      questionEndsAt: open ? room.questionEndsAt : null,
      serverTime: DateTime.now().toUtc(),
      players: views,
      lastElimination: room.lastElimination,
      buzzerHolderId: room.buzzerHolderId,
    );
  }

  static Future<void> _broadcast(Session session, int roomId) async {
    final room = await Room.db.findById(session, roomId);
    if (room == null) return;
    await session.messages.postMessage(
      channelFor(room.code),
      await buildState(session, room),
    );
  }

  static Stream<RoomState> watchRoom(Session session, String code) async* {
    final room = await _roomByCode(session, code);
    // Subscribe before taking the snapshot so no update slips in between.
    final updates = session.messages.createStream<RoomState>(
      channelFor(room.code),
    );
    yield await buildState(session, room);
    yield* updates;
  }
}
