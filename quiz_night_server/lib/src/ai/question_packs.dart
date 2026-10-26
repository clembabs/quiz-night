import 'dart:math';

import 'package:serverpod/serverpod.dart';

import '../game/cut_logic.dart';
import '../game/nickname.dart';
import '../game/room_service.dart';
import '../generated/protocol.dart';
import '../security/client_address.dart';
import '../security/guard.dart';
import '../security/rate_limiter.dart';
import '../security/tokens.dart';
import 'gemini_generator.dart';
import 'question_checks.dart';
import 'question_generator.dart';

/// AI packs: made pre-room, previewed with answers, played before the bank.
abstract final class QuestionPacks {
  /// Set in `server.dart` from `geminiApiKey`; fake in tests; null = AI off.
  static QuestionGenerator? generator;

  /// Generations per address: a host trying a few topics.
  static const perAddress = RateLimit('aiPerAddress', 3, Duration(hours: 1));

  /// Server-wide per day; with fallbacks ~300 calls, under the free tier.
  static const perDay = RateLimit('aiPerDay', 150, Duration(hours: 24));

  static const minTopic = 2;
  static const maxTopic = 100;

  /// How many questions the host may ask for (rounds and final together).
  static const minQuestions = 10;
  static const maxQuestions = 40;

  /// Splits [count] into rounds and finals: the game's finals, max a third.
  static ({int rounds, int finals}) split(int count, RoomConfig config) {
    final finals = min(config.finalQuestionCount, count ~/ 3);
    return (rounds: count - finals, finals: finals);
  }

  static final _rng = Random.secure();

  static QuizException _error(QuizErrorCode code, String message) =>
      QuizException(code: code, message: message);

  /// Questions a full room needs to reach the finalists, capped to fit the
  /// 30-minute game (each question takes about its time limit plus 25s).
  static ({int rounds, int finals}) questionsNeeded(RoomConfig config) {
    var active = RoomService.maxPlayers;
    var rounds = 0;
    if (config.eliminationRule == EliminationRule.suddenDeath) {
      rounds = 4;
    } else {
      while (active > config.finalistTarget && rounds < 10) {
        rounds++;
        final next = survivorsAfterRound(
          activeCount: active,
          rule: config.eliminationRule,
          eliminationPercent: config.eliminationPercent,
          finalistTarget: config.finalistTarget,
          startingPlayers: RoomService.maxPlayers,
          roundsBeforeFinal: config.roundsBeforeFinal,
          round: rounds,
        );
        if (next >= active) break;
        active = next;
      }
    }
    final fitInTime =
        RoomService.sessionLength.inSeconds ~/ (config.timeLimitSeconds + 25);
    final roundQuestions = min<int>(
      config.questionsPerRound * max(rounds, 1),
      fitInTime,
    );
    return (rounds: roundQuestions, finals: config.finalQuestionCount);
  }

  static bool get available => generator != null;

  /// Writes, checks and saves [questionCount] questions on [topic].
  static Future<PackDraft> generate(
    Session session,
    String topic,
    QuestionDifficulty difficulty,
    int questionCount,
    RoomConfig config,
  ) async {
    final gen = generator;
    if (gen == null) {
      throw _error(
        QuizErrorCode.aiUnavailable,
        'AI questions are not set up on this server. The built-in questions '
        'will be used.',
      );
    }
    final cleanTopic = Nickname.clean(topic);
    if (cleanTopic.length < minTopic || cleanTopic.length > maxTopic) {
      throw _error(
        QuizErrorCode.invalidInput,
        'Describe the topic in $minTopic-$maxTopic characters.',
      );
    }
    if (questionCount < minQuestions || questionCount > maxQuestions) {
      throw _error(
        QuizErrorCode.invalidInput,
        'Pick $minQuestions to $maxQuestions questions.',
      );
    }
    if (Nickname.isOffensive(cleanTopic)) {
      throw _error(
        QuizErrorCode.invalidInput,
        'Try a different topic: it should suit a family quiz.',
      );
    }
    if (Guard.enabled) {
      final now = Guard.now();
      final limiter = Guard.limiter;
      if (!limiter.tryAcquire(clientAddress(session), perAddress, now) ||
          !limiter.tryAcquire('server', perDay, now)) {
        throw _error(
          QuizErrorCode.rateLimited,
          'That is a lot of new question sets. Try again later, or use the '
          'built-in questions.',
        );
      }
    }

    final need = questionsNeeded(config);
    final ask = split(questionCount, config);
    final List<DraftQuestion> drafts;
    try {
      drafts = await gen.generate(
        GenerationRequest(
          topic: cleanTopic,
          difficulty: difficulty,
          roundCount: ask.rounds,
          finalCount: ask.finals,
        ),
      );
    } on GenerationRefused {
      throw _error(
        QuizErrorCode.invalidInput,
        "We can't write questions on that topic. Try another one.",
      );
    } on GenerationFailed catch (e) {
      session.log(
        'Question generation failed: ${e.reason}',
        level: LogLevel.warning,
      );
      throw _error(
        QuizErrorCode.generationFailed,
        e.reason == 'quota'
            ? 'The free AI quota is used up for now. Try again later, or use '
                  'the built-in questions.'
            : "Couldn't write questions right now. Try again, or use the "
                  'built-in questions.',
      );
    }

    final checked = checkQuestions(drafts, random: _rng);
    if (checked.where((q) => !q.isFinal).isEmpty) {
      throw _error(
        QuizErrorCode.generationFailed,
        "Couldn't write usable questions on that topic. Try wording it "
        'differently.',
      );
    }

    final token = _token();
    final pack = await session.db.transaction((tx) async {
      final pack = await QuestionPack.db.insertRow(
        session,
        QuestionPack(topic: cleanTopic, difficulty: difficulty, token: token),
        transaction: tx,
      );
      var roundOrder = 0, finalOrder = 0;
      await PackQuestion.db.insert(session, [
        for (final q in checked)
          PackQuestion(
            packId: pack.id!,
            orderIndex: q.isFinal ? ++finalOrder : ++roundOrder,
            isFinal: q.isFinal,
            text: q.text,
            options: q.options,
            correctIndex: q.correctIndex,
          ),
      ], transaction: tx);
      return pack;
    });
    return _draft(session, pack, token, need);
  }

  /// Host: drops one question from their pack before creating the room.
  static Future<PackDraft> removeQuestion(
    Session session,
    int packId,
    String packToken,
    int questionId,
    RoomConfig config,
  ) async {
    final pack = await _ownedPack(session, packId, packToken);
    await PackQuestion.db.deleteWhere(
      session,
      where: (t) => t.id.equals(questionId) & t.packId.equals(pack.id!),
    );
    return _draft(session, pack, packToken, questionsNeeded(config));
  }

  /// The pack, if [token] proves the caller made it.
  static Future<QuestionPack> _ownedPack(
    Session session,
    int packId,
    String token,
  ) async {
    final pack = await QuestionPack.db.findById(session, packId);
    if (pack == null || !tokensMatch(pack.token, token)) {
      throw _error(QuizErrorCode.notAllowed, 'That question set was not found');
    }
    return pack;
  }

  /// Checks a room may use [packId]; returns it, or throws.
  static Future<int?> verifyForRoom(
    Session session,
    int? packId,
    String? token,
  ) async {
    if (packId == null) return null;
    return (await _ownedPack(session, packId, token ?? '')).id;
  }

  static Future<PackDraft> _draft(
    Session session,
    QuestionPack pack,
    String token,
    ({int rounds, int finals}) need,
  ) async {
    final questions = await PackQuestion.db.find(
      session,
      where: (t) => t.packId.equals(pack.id!),
      orderBy: (t) => t.orderIndex,
    );
    questions.sort((a, b) {
      if (a.isFinal != b.isFinal) return a.isFinal ? 1 : -1;
      return a.orderIndex.compareTo(b.orderIndex);
    });
    return PackDraft(
      packId: pack.id!,
      packToken: token,
      topic: pack.topic,
      difficulty: pack.difficulty,
      roundQuestionsNeeded: need.rounds,
      finalQuestionsNeeded: need.finals,
      questions: [
        for (final q in questions)
          PackQuestionView(
            id: q.id!,
            isFinal: q.isFinal,
            text: q.text,
            options: q.options,
            correctIndex: q.correctIndex,
          ),
      ],
    );
  }

  static String _token() =>
      List.generate(32, (_) => _rng.nextInt(16).toRadixString(16)).join();

  /// Sets up the Gemini generator if the `geminiApiKey` password is set.
  static void configure(Serverpod pod) {
    final key = pod.getPassword('geminiApiKey');
    if (key != null && key.isNotEmpty && key != 'change-me') {
      generator = GeminiQuestionGenerator(apiKey: key);
    }
  }
}
