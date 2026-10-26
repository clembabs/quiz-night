import 'package:quiz_night_server/src/ai/question_generator.dart';
import 'package:quiz_night_server/src/ai/question_packs.dart';
import 'package:quiz_night_server/src/generated/protocol.dart';
import 'package:quiz_night_server/src/security/guard.dart';
import 'package:test/test.dart';

import 'test_tools/serverpod_test_tools.dart';

/// Answers every request with numbered questions, or fails as told.
class FakeGenerator implements QuestionGenerator {
  Object? failWith;
  final requests = <GenerationRequest>[];

  @override
  Future<List<DraftQuestion>> generate(GenerationRequest request) async {
    requests.add(request);
    if (failWith != null) throw failWith!;
    return [
      for (var i = 1; i <= request.roundCount; i++)
        DraftQuestion(
          text: 'Round question number $i about ${request.topic}?',
          options: ['Right $i', 'Wrong A$i', 'Wrong B$i', 'Wrong C$i'],
          correctIndex: 0,
          isFinal: false,
        ),
      for (var i = 1; i <= request.finalCount; i++)
        DraftQuestion(
          text: 'Final question number $i about ${request.topic}?',
          options: ['Right F$i', 'Wrong FA$i', 'Wrong FB$i', 'Wrong FC$i'],
          correctIndex: 0,
          isFinal: true,
        ),
    ];
  }
}

Matcher throwsQuiz(QuizErrorCode code) =>
    throwsA(isA<QuizException>().having((e) => e.code, 'code', code));

void main() {
  late FakeGenerator fake;
  setUp(() {
    fake = FakeGenerator();
    QuestionPacks.generator = fake;
  });
  tearDown(() {
    QuestionPacks.generator = null;
    Guard.enabled = false;
    Guard.reset();
  });

  withServerpod('Given AI questions are set up', (sb, endpoints) {
    test('when the host generates a pack then it is sized for the game and '
        'previewed with answers', () async {
      final config = RoomConfig(questionsPerRound: 3, finalQuestionCount: 2);
      final draft = await endpoints.questions.generatePack(
        sb,
        '  Nollywood  ',
        QuestionDifficulty.mixed,
        config,
      );
      final need = QuestionPacks.questionsNeeded(config);
      expect(draft.topic, 'Nollywood');
      expect(
        fake.requests.single.roundCount,
        need.rounds + QuestionPacks.roundSpares,
      );
      expect(
        fake.requests.single.finalCount,
        need.finals + QuestionPacks.finalSpares,
      );
      final rounds = draft.questions.where((q) => !q.isFinal).toList();
      final finals = draft.questions.where((q) => q.isFinal).toList();
      expect(rounds, hasLength(need.rounds + QuestionPacks.roundSpares));
      expect(finals, hasLength(need.finals + QuestionPacks.finalSpares));
      // Shuffled, but the answer still points at the right option.
      for (final q in draft.questions) {
        expect(q.options[q.correctIndex], startsWith('Right'));
      }
      expect(await endpoints.questions.aiAvailable(sb), isTrue);
    });

    test(
      'when the host removes a question then the preview drops it',
      () async {
        final config = RoomConfig();
        final draft = await endpoints.questions.generatePack(
          sb,
          'Football',
          QuestionDifficulty.easy,
          config,
        );
        final victim = draft.questions.first;
        final after = await endpoints.questions.removePackQuestion(
          sb,
          draft.packId,
          draft.packToken,
          victim.id,
          config,
        );
        expect(after.questions.map((q) => q.id), isNot(contains(victim.id)));
        expect(after.questions, hasLength(draft.questions.length - 1));
        await expectLater(
          endpoints.questions.removePackQuestion(
            sb,
            draft.packId,
            'wrong-token',
            after.questions.first.id,
            config,
          ),
          throwsQuiz(QuizErrorCode.notAllowed),
        );
      },
    );

    test('when a room uses the pack then its questions are played first, in '
        'order', () async {
      final draft = await endpoints.questions.generatePack(
        sb,
        'Afrobeats',
        QuestionDifficulty.mixed,
        RoomConfig(),
      );
      final room = await endpoints.room.createRoom(
        sb,
        RoomConfig(packId: draft.packId, packToken: draft.packToken),
      );
      await endpoints.room.joinRoom(sb, room.roomCode, 'Ada');
      await endpoints.room.joinRoom(sb, room.roomCode, 'Bo');
      await endpoints.room.startGame(sb, room.roomCode, room.hostToken);
      final state = await endpoints.room.watchRoom(sb, room.roomCode).first;
      expect(
        state.question!.text,
        draft.questions.firstWhere((q) => !q.isFinal).text,
      );
    });

    test("when a room names someone else's pack then it is refused", () async {
      final draft = await endpoints.questions.generatePack(
        sb,
        'History',
        QuestionDifficulty.mixed,
        RoomConfig(),
      );
      await expectLater(
        endpoints.room.createRoom(
          sb,
          RoomConfig(packId: draft.packId, packToken: 'guessed'),
        ),
        throwsQuiz(QuizErrorCode.notAllowed),
      );
    });

    test('when the topic is empty, too long or offensive then nothing is '
        'generated', () async {
      for (final topic in ['', 'x' * 101, 'sh1t jokes']) {
        await expectLater(
          endpoints.questions.generatePack(
            sb,
            topic,
            QuestionDifficulty.mixed,
            RoomConfig(),
          ),
          throwsQuiz(QuizErrorCode.invalidInput),
          reason: topic,
        );
      }
      expect(fake.requests, isEmpty);
    });

    test('when the provider refuses or fails then the host gets a clear '
        'error', () async {
      fake.failWith = const GenerationRefused('SAFETY');
      await expectLater(
        endpoints.questions.generatePack(
          sb,
          'Something odd',
          QuestionDifficulty.mixed,
          RoomConfig(),
        ),
        throwsQuiz(QuizErrorCode.invalidInput),
      );
      fake.failWith = const GenerationFailed('quota');
      await expectLater(
        endpoints.questions.generatePack(
          sb,
          'Science',
          QuestionDifficulty.mixed,
          RoomConfig(),
        ),
        throwsA(
          isA<QuizException>()
              .having((e) => e.code, 'code', QuizErrorCode.generationFailed)
              .having((e) => e.message, 'message', contains('quota')),
        ),
      );
    });

    test('when an address generates too often then it is refused', () async {
      Guard.enabled = true;
      for (var i = 0; i < QuestionPacks.perAddress.max; i++) {
        await endpoints.questions.generatePack(
          sb,
          'Topic $i',
          QuestionDifficulty.mixed,
          RoomConfig(),
        );
      }
      await expectLater(
        endpoints.questions.generatePack(
          sb,
          'One more',
          QuestionDifficulty.mixed,
          RoomConfig(),
        ),
        throwsQuiz(QuizErrorCode.rateLimited),
      );
    });
  });

  withServerpod('Given AI questions are not set up', (sb, endpoints) {
    test('when the host asks then it says so', () async {
      QuestionPacks.generator = null;
      expect(await endpoints.questions.aiAvailable(sb), isFalse);
      await expectLater(
        endpoints.questions.generatePack(
          sb,
          'Football',
          QuestionDifficulty.mixed,
          RoomConfig(),
        ),
        throwsQuiz(QuizErrorCode.aiUnavailable),
      );
    });
  });
}
