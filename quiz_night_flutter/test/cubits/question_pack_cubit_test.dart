import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:quiz_night_client/quiz_night_client.dart';
import 'package:quiz_night_flutter/data/app_failure.dart';
import 'package:quiz_night_flutter/features/host_setup/question_pack_cubit.dart';

import '../fakes/fakes.dart';

void main() {
  setUpAll(registerFallbacks);

  late MockQuestionsRepository questions;
  setUp(() => questions = MockQuestionsRepository());

  const ready = PackStatus.ready;

  group('Given the setup screen opens', () {
    blocTest<QuestionPackCubit, QuestionPackState>(
      'when the server can write questions then the topic box is ready',
      setUp: () =>
          when(() => questions.aiAvailable()).thenAnswer((_) async => true),
      build: () => QuestionPackCubit(questions),
      act: (c) => c.start(),
      expect: () => [const QuestionPackState(status: PackStatus.idle)],
    );

    blocTest<QuestionPackCubit, QuestionPackState>(
      'when it cannot then only built-in questions are offered',
      setUp: () =>
          when(() => questions.aiAvailable()).thenAnswer((_) async => false),
      build: () => QuestionPackCubit(questions),
      act: (c) => c.start(),
      expect: () => [const QuestionPackState(status: PackStatus.unavailable)],
      verify: (c) => expect(c.summaryItem.title, 'Built-in questions'),
    );
  });

  group('Given a topic', () {
    final pack = samplePack();

    blocTest<QuestionPackCubit, QuestionPackState>(
      'when Write questions succeeds then the pack is ready to preview',
      setUp: () => when(
        () =>
            questions.generatePack('Nollywood', QuestionDifficulty.hard, any()),
      ).thenAnswer((_) async => pack),
      build: () => QuestionPackCubit(questions),
      seed: () => const QuestionPackState(status: PackStatus.idle),
      act: (c) => c
        ..setTopic('  Nollywood ')
        ..setDifficulty(QuestionDifficulty.hard)
        ..generate(RoomConfig()),
      skip: 2,
      expect: () => [
        const QuestionPackState(
          status: PackStatus.generating,
          topic: '  Nollywood ',
          difficulty: QuestionDifficulty.hard,
        ),
        QuestionPackState(
          status: ready,
          topic: '  Nollywood ',
          difficulty: QuestionDifficulty.hard,
          pack: pack,
        ),
      ],
      verify: (c) {
        expect(c.summaryItem.title, '6 AI questions on “Nollywood”');
        expect(c.summaryItem.detail, contains('a few spare'));
      },
    );

    blocTest<QuestionPackCubit, QuestionPackState>(
      'when writing fails again then the earlier pack is kept, with the error',
      setUp: () => when(
        () => questions.generatePack(any(), any(), any()),
      ).thenThrow(const AppFailure('The free AI quota is used up for now.')),
      build: () => QuestionPackCubit(questions),
      seed: () =>
          QuestionPackState(status: ready, topic: 'Nollywood', pack: pack),
      act: (c) => c.generate(RoomConfig()),
      expect: () => [
        QuestionPackState(
          status: PackStatus.generating,
          topic: 'Nollywood',
          pack: pack,
        ),
        QuestionPackState(
          status: ready,
          topic: 'Nollywood',
          pack: pack,
          error: 'The free AI quota is used up for now.',
        ),
      ],
    );

    blocTest<QuestionPackCubit, QuestionPackState>(
      'when the topic is one letter then nothing is asked for',
      build: () => QuestionPackCubit(questions),
      seed: () => const QuestionPackState(status: PackStatus.idle, topic: 'a'),
      act: (c) => c.generate(RoomConfig()),
      expect: () => <QuestionPackState>[],
      verify: (_) =>
          verifyNever(() => questions.generatePack(any(), any(), any())),
    );
  });

  group('Given a ready pack', () {
    final pack = samplePack();
    final smaller = samplePack(rounds: 3);

    blocTest<QuestionPackCubit, QuestionPackState>(
      'when a question is removed then the smaller pack shows, and the '
      'summary says the bank fills in',
      setUp: () =>
          when(
            () => questions.removeQuestion(pack, 2, any()),
          ).thenAnswer(
            (_) async => PackDraft(
              packId: smaller.packId,
              packToken: smaller.packToken,
              topic: smaller.topic,
              difficulty: smaller.difficulty,
              questions: smaller.questions,
              roundQuestionsNeeded: 4,
              finalQuestionsNeeded: 2,
            ),
          ),
      build: () => QuestionPackCubit(questions),
      seed: () =>
          QuestionPackState(status: ready, topic: 'Nollywood', pack: pack),
      act: (c) => c.remove(2, RoomConfig()),
      verify: (c) {
        expect(c.state.roundCount, 3);
        expect(c.summaryItem.detail, contains('fill in'));
      },
    );

    blocTest<QuestionPackCubit, QuestionPackState>(
      'when the host goes back to built-in then the pack is dropped',
      build: () => QuestionPackCubit(questions),
      seed: () =>
          QuestionPackState(status: ready, topic: 'Nollywood', pack: pack),
      act: (c) => c.discard(),
      expect: () => [
        const QuestionPackState(status: PackStatus.idle, topic: 'Nollywood'),
      ],
    );
  });
}
