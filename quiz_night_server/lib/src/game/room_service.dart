import 'dart:async';
import 'dart:math';

import 'package:serverpod/serverpod.dart';

import '../ai/host_lines.dart';
import '../ai/question_packs.dart';
import '../generated/protocol.dart';
import '../security/tokens.dart';
import 'cut_logic.dart';
import 'nickname.dart';
import 'question_bank.dart';

/// Grace after the deadline to absorb network latency; server clock only.
const answerGrace = Duration(milliseconds: 500);

/// After a finalist buzzes they get at least this long to answer.
const buzzAnswerWindow = Duration(seconds: 8);

/// Points for a correct buzzer-final answer.
const finalPointsPerQuestion = 1000;

/// Digits only: phones open the number keypad, and codes read well projected.
const _codeAlphabet = '0123456789';
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
  /// Auto-reveal at the deadline, so a sleeping host tab can't stall the game.
  /// Enabled in `server.dart`; off in tests.
  static bool autoRevealEnabled = false;

  /// The 3-2-1 before each question: answers and buzzes open after it.
  /// `server.dart` sets 3 s; tests keep 0 so they need not wait.
  static Duration getReady = Duration.zero;

  /// MVP room size; traffic grows with its square, so batch updates first.
  static const maxPlayers = 20;

  /// How long a game may run, from the host pressing Start.
  static const sessionLength = Duration(minutes: 30);

  /// A room with no activity for this long is closed.
  static const idleLimit = Duration(minutes: 30);

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
    if (!tokensMatch(room.hostToken, hostToken)) {
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
    // Only the host who generated a pack holds its token.
    final packId = await QuestionPacks.verifyForRoom(
      session,
      config.packId,
      config.packToken,
    );
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
          // With no shared screen, the phone is where the question is.
          showQuestionOnPhones: config.remote || config.showQuestionOnPhones,
          remote: config.remote,
          packId: packId,
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
    final name = Nickname.clean(nickname);
    if (name.isEmpty || name.length > Nickname.maxLength) {
      throw _error(
        QuizErrorCode.invalidInput,
        'Nickname must be 1-${Nickname.maxLength} characters',
      );
    }
    if (Nickname.isOffensive(name)) {
      throw _error(
        QuizErrorCode.invalidInput,
        'Pick a different nickname: it shows on the big screen.',
      );
    }
    final result = await session.db.transaction((tx) async {
      final room = await _roomByCode(session, code, tx: tx, lock: true);
      // A finished room no longer exists to someone holding its code.
      if (room.status == RoomStatus.finished) {
        throw _error(QuizErrorCode.roomNotFound, 'This game session has ended');
      }

      final players = await Player.db.find(
        session,
        where: (t) => t.roomId.equals(room.id!),
        transaction: tx,
      );
      if (room.locked) {
        throw _error(
          QuizErrorCode.roomLocked,
          'The host has locked this room. Ask them to unlock it.',
        );
      }
      if (players.length >= maxPlayers) {
        throw _error(
          QuizErrorCode.roomFull,
          'This room is full ($maxPlayers players). Ask the host for another '
          'room.',
        );
      }
      if (players.any((p) => p.nickname.toLowerCase() == name.toLowerCase())) {
        throw _error(QuizErrorCode.nicknameTaken, 'That nickname is taken');
      }
      // Late joiners play until the first cut; after it (or in the final)
      // they would be cut at once, so they watch as spectators instead.
      // eliminatedInRound 0 marks "joined late", not "knocked out".
      final spectator =
          room.status != RoomStatus.lobby &&
          (room.lastCutRound > 0 || room.finalQuestionsPlayed > 0);
      final token = _randomToken();
      final player = await Player.db.insertRow(
        session,
        Player(
          roomId: room.id!,
          nickname: name,
          token: token,
          status: spectator ? PlayerStatus.eliminated : PlayerStatus.active,
          eliminatedInRound: spectator ? 0 : null,
        ),
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
    if (player.leftAt != null) {
      // Back after tapping Leave: in the game again.
      await Player.db.updateRow(
        session,
        player.copyWith(leftAt: null),
        columns: (t) => [t.leftAt],
      );
      await _broadcast(session, room.id!);
    }
    return JoinResult(
      roomCode: room.code,
      playerId: player.id!,
      playerToken: playerToken,
    );
  }

  /// A player tapped Leave: they stop counting as someone to wait for.
  static Future<void> leaveRoom(
    Session session,
    String code,
    String playerToken,
  ) async {
    final room = await _roomByCode(session, code);
    final player = await _playerByToken(session, playerToken);
    if (player.roomId != room.id || player.leftAt != null) return;
    await Player.db.updateRow(
      session,
      player.copyWith(leftAt: DateTime.now().toUtc()),
      columns: (t) => [t.leftAt],
    );
    await _broadcast(session, room.id!);
    // They may have been the last answer the question waited for.
    if (room.status == RoomStatus.question && room.currentQuestionId != null) {
      await _revealIfAllAnswered(session, room.id!, room.currentQuestionId!);
    }
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
      room = room.copyWith(
        startingPlayerCount: count,
        currentRound: 1,
        startedAt: DateTime.now().toUtc(),
      );
      return _startQuestion(session, tx, room, isFinal: false);
    });
    await _afterQuestionStarted(session, room);
  }

  /// Advances within a round, to the next round, the final, or the podium.
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
            room.copyWith(
              status: RoomStatus.finished,
              endReason: RoomEndReason.completed,
            ),
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

  /// Ends the round and runs the cut. Idempotent: a repeat call is a no-op.
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
    // After the broadcast, so the reveal starts while the lines are written.
    await _writeExitLines(session, roomId);
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
          exitLine: null,
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

  /// Ends games past [sessionLength] and rooms idle past [idleLimit], keeping
  /// scores for the podium. Returns the count; run by `RoomExpiry`.
  static Future<int> endExpired(Session session, {DateTime? now}) async {
    final at = now ?? DateTime.now().toUtc();
    final due = await Room.db.find(
      session,
      where: (t) =>
          t.status.notEquals(RoomStatus.finished) &
          ((t.startedAt < at.subtract(sessionLength)) |
              (t.lastActivityAt < at.subtract(idleLimit))),
    );
    var ended = 0;
    for (final candidate in due) {
      final roomId = await session.db.transaction((tx) async {
        final room = await Room.db.findById(
          session,
          candidate.id!,
          transaction: tx,
          lockMode: LockMode.forUpdate,
        );
        if (room == null || room.status == RoomStatus.finished) return null;
        final timeUp =
            room.startedAt != null &&
            !room.startedAt!.isAfter(at.subtract(sessionLength));
        final idle = !room.lastActivityAt.isAfter(at.subtract(idleLimit));
        if (!timeUp && !idle) return null;
        await Room.db.updateRow(
          session,
          room.copyWith(
            status: RoomStatus.finished,
            endReason: timeUp ? RoomEndReason.timeUp : RoomEndReason.inactive,
            questionEndsAt: null,
            buzzerHolderId: null,
          ),
          transaction: tx,
        );
        return room.id;
      });
      if (roomId != null) {
        ended++;
        await _broadcast(session, roomId);
      }
    }
    return ended;
  }

  /// Host: stops or reopens joining, so nobody else joins via the code shown.
  static Future<void> setLocked(
    Session session,
    String code,
    String hostToken,
    bool locked,
  ) async {
    final roomId = await session.db.transaction((tx) async {
      final room = await _hostRoom(
        session,
        code,
        hostToken,
        tx: tx,
        lock: true,
      );
      await Room.db.updateRow(
        session,
        room.copyWith(locked: locked),
        transaction: tx,
      );
      return room.id!;
    });
    await _broadcast(session, roomId);
  }

  /// Host: removes a lobby player and revokes their token. Lobby only, since
  /// mid-game removals would change the cut for everyone else.
  static Future<void> removePlayer(
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
      if (room.status != RoomStatus.lobby) {
        throw _error(
          QuizErrorCode.invalidState,
          'Players can only be removed before the game starts',
        );
      }
      final player = await Player.db.findById(
        session,
        playerId,
        transaction: tx,
      );
      if (player == null || player.roomId != room.id) {
        throw _error(QuizErrorCode.playerNotFound, 'Player not found');
      }
      await Player.db.deleteRow(session, player, transaction: tx);
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
      // Row lock serialises answers, so double taps can't answer twice.
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
      if (now.isBefore(room.questionStartedAt!)) {
        throw _error(QuizErrorCode.tooEarly, 'Wait for the countdown');
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

  /// First valid buzz wins; the room row lock serialises simultaneous buzzes.
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
      if (now.isBefore(room.questionStartedAt!)) {
        return (null, BuzzResult(gotBuzzer: false, reason: 'Not yet'));
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

  /// The next unplayed question of the right kind from the room's pack.
  static Future<BankQuestion?> _nextPackQuestion(
    Session session,
    Transaction tx,
    Room room,
    Set<String> usedTexts, {
    required bool isFinal,
  }) async {
    final packId = room.packId;
    if (packId == null) return null;
    final candidates = await PackQuestion.db.find(
      session,
      where: (t) => t.packId.equals(packId) & t.isFinal.equals(isFinal),
      orderBy: (t) => t.orderIndex,
      transaction: tx,
    );
    final next = candidates
        .where((q) => !usedTexts.contains(q.text))
        .firstOrNull;
    return next == null
        ? null
        : BankQuestion(next.text, next.options, next.correctIndex);
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
    // The host's AI-written pack first, in its order; then the bank.
    final fromPack = await _nextPackQuestion(
      session,
      tx,
      room,
      usedTexts,
      isFinal: isFinal,
    );
    final BankQuestion pick;
    if (fromPack != null) {
      pick = fromPack;
    } else {
      final bank = isFinal ? finalQuestions : roundQuestions;
      var fresh = bank.where((q) => !usedTexts.contains(q.text)).toList();
      if (fresh.isEmpty) fresh = bank.toList();
      pick = fresh[_random.nextInt(fresh.length)];
    }

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
        questionStartedAt: now.add(getReady),
        questionEndsAt: now.add(
          getReady + Duration(seconds: room.timeLimitSeconds),
        ),
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
        return null;
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
      return updated;
    });
    if (changed == null) return false;
    await _broadcast(session, roomId);
    if (changed.eliminationRule == EliminationRule.suddenDeath) {
      await _writeExitLines(session, roomId);
    }
    return true;
  }

  /// Gives this room's newly eliminated players their host line, then
  /// broadcasts. Safe to repeat: players who have a line keep it.
  static Future<void> _writeExitLines(Session session, int roomId) async {
    final room = await Room.db.findById(session, roomId);
    if (room == null) return;
    final out = await Player.db.find(
      session,
      where: (t) =>
          t.roomId.equals(roomId) &
          t.status.equals(PlayerStatus.eliminated) &
          t.eliminatedInRound.equals(room.currentRound) &
          t.exitLine.equals(null),
    );
    if (out.isEmpty) return;
    final questions = await Question.db.find(
      session,
      where: (t) =>
          t.roomId.equals(roomId) &
          t.round.equals(room.currentRound) &
          t.isFinal.equals(false),
      orderBy: (t) => t.orderIndex,
    );
    final answers = await Answer.db.find(
      session,
      where: (t) =>
          t.playerId.inSet(out.map((p) => p.id!).toSet()) &
          t.questionId.inSet(questions.map((q) => q.id!).toSet()),
    );
    final correct = {
      for (final a in answers)
        if (a.isCorrect) (a.playerId, a.questionId),
    };
    // In reveal order, so the built-in lines vary down the cut.
    final order = room.lastElimination?.eliminatedPlayerIds ?? const <int>[];
    out.sort((a, b) => order.indexOf(a.id!).compareTo(order.indexOf(b.id!)));
    final subjects = [
      for (final p in out)
        _lineSubject(p, room.currentRound, questions.reversed, correct),
    ];
    final lines = await HostLines.linesFor(
      subjects,
      log: (m) => session.log(m, level: LogLevel.warning),
    );
    await Player.db.update(
      session,
      [for (final p in out) p.copyWith(exitLine: lines[p.id!])],
      columns: (t) => [t.exitLine],
    );
    await _broadcast(session, roomId);
  }

  /// [p] for the line writer, with their latest miss this round.
  static LineSubject _lineSubject(
    Player p,
    int round,
    Iterable<Question> newestFirst,
    Set<(int, int)> correct,
  ) {
    final missed = newestFirst
        .where((q) => !correct.contains((p.id!, q.id!)))
        .firstOrNull;
    return LineSubject(
      playerId: p.id!,
      nickname: p.nickname,
      round: round,
      score: p.score,
      missedQuestion: missed?.text,
      missedAnswer: missed?.options[missed.correctIndex],
    );
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
    // Players who left are not waited for.
    final playing = await Player.db.find(
      session,
      where: (t) =>
          t.roomId.equals(roomId) &
          t.status.equals(PlayerStatus.active) &
          t.leftAt.equals(null),
    );
    if (playing.isEmpty) return false;
    final answered = await Answer.db.count(
      session,
      where: (t) =>
          t.questionId.equals(questionId) &
          t.isShadow.equals(false) &
          t.playerId.inSet(playing.map((p) => p.id!).toSet()),
    );
    if (answered < playing.length) return false;
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
    final buzzWinnerId = buzzes
        .where((b) => b.wasCorrect ?? false)
        .map((b) => b.playerId)
        .firstOrNull;

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
              exitLine: p.exitLine,
              left: p.leftAt != null,
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
      locked: room.locked,
      sessionEndsAt: room.status == RoomStatus.finished
          ? null
          : room.startedAt?.add(sessionLength),
      endReason: room.endReason,
      showQuestionOnPhones: room.showQuestionOnPhones,
      remote: room.remote,
      projectedSurvivors: _projectedSurvivors(room, question, players),
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
      questionStartsAt: open ? room.questionStartedAt : null,
      questionEndsAt: open ? room.questionEndsAt : null,
      serverTime: DateTime.now().toUtc(),
      players: views,
      lastElimination: room.lastElimination,
      buzzerHolderId: room.buzzerHolderId,
      buzzWinnerId: buzzWinnerId,
    );
  }

  /// The danger line: survivors the cut would keep now (same function).
  static int? _projectedSurvivors(
    Room room,
    Question? question,
    List<Player> players,
  ) {
    final inRound =
        room.status == RoomStatus.question || room.status == RoomStatus.reveal;
    if (!inRound ||
        question == null ||
        question.isFinal ||
        room.eliminationRule == EliminationRule.suddenDeath) {
      return null;
    }
    final active = players.where((p) => p.status == PlayerStatus.active).length;
    return survivorsAfterRound(
      activeCount: active,
      rule: room.eliminationRule,
      eliminationPercent: room.eliminationPercent,
      finalistTarget: room.finalistTarget,
      startingPlayers: room.startingPlayerCount ?? active,
      roundsBeforeFinal: room.roundsBeforeFinal,
      round: room.currentRound,
    );
  }

  static Future<void> _broadcast(Session session, int roomId) async {
    var room = await Room.db.findById(session, roomId);
    if (room == null) return;
    // Every broadcast follows a change, so it marks the room as active.
    room = await Room.db.updateRow(
      session,
      room.copyWith(lastActivityAt: DateTime.now().toUtc()),
      columns: (t) => [t.lastActivityAt],
    );
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
