import 'package:bloc_test/bloc_test.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:quiz_night_client/quiz_night_client.dart';
import 'package:quiz_night_flutter/core/theme/app_theme.dart';
import 'package:quiz_night_flutter/features/room/room_cubit.dart';
import 'package:quiz_night_flutter/features/room/round/host_question_view.dart';
import 'package:quiz_night_flutter/features/room/round/player_question_view.dart';
import 'package:quiz_night_flutter/features/room/round/player_reveal_view.dart';

import '../fakes/fakes.dart';

class MockRoomCubit extends MockCubit<RoomViewState> implements RoomCubit {}

void main() {
  setUpAll(registerFallbacks);

  late MockRoomCubit cubit;
  final endsAt = DateTime.now().toUtc().add(const Duration(minutes: 5));

  setUp(() {
    cubit = MockRoomCubit();
    when(() => cubit.state).thenReturn(const RoomViewState(seat: hostSeat));
    when(() => cubit.submitAnswer(any())).thenAnswer((_) async {});
    when(() => cubit.reveal()).thenAnswer((_) async {});
    when(() => cubit.nextQuestion()).thenAnswer((_) async {});
    when(() => cubit.endRound()).thenAnswer((_) async {});
  });

  Future<void> pump(WidgetTester tester, Widget child, {Size? size}) async {
    if (size != null) {
      tester.view.physicalSize = size;
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.reset);
    }
    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.dark(),
        home: Scaffold(
          body: BlocProvider<RoomCubit>.value(value: cubit, child: child),
        ),
      ),
    );
  }

  group('Given a player sees an open question', () {
    final room = roomState(
      status: RoomStatus.question,
      question: question(),
      questionEndsAt: endsAt,
      players: [player(1, 'Ada')],
    );

    testWidgets('when tapping an option then it submits that option', (
      tester,
    ) async {
      await pump(
        tester,
        PlayerQuestionView(
          room: room,
          me: room.players.first,
          myChoice: null,
          clockOffset: Duration.zero,
        ),
      );

      expect(find.text('Capital of France?'), findsOneWidget);
      expect(find.text('ROUND 1 · QUESTION 1 OF 5'), findsOneWidget);
      await tester.tap(find.byKey(const Key('answer.1')));
      verify(() => cubit.submitAnswer(1)).called(1);
    });

    testWidgets('when already answered then options are locked', (
      tester,
    ) async {
      await pump(
        tester,
        PlayerQuestionView(
          room: room,
          me: room.players.first,
          myChoice: 2,
          clockOffset: Duration.zero,
        ),
      );

      expect(find.text('Answer locked in'), findsOneWidget);
      await tester.tap(find.byKey(const Key('answer.0')));
      verifyNever(() => cubit.submitAnswer(any()));
    });

    testWidgets('when the page reloaded after answering then still locked', (
      tester,
    ) async {
      await pump(
        tester,
        PlayerQuestionView(
          room: room,
          me: player(1, 'Ada', hasAnswered: true),
          myChoice: null,
          clockOffset: Duration.zero,
        ),
      );

      expect(find.text('Answer locked in'), findsOneWidget);
    });
  });

  group('Given a player sees the reveal', () {
    testWidgets('when they were right then shows points and rank', (
      tester,
    ) async {
      final me = player(1, 'Ada', score: 1800, lastPoints: 900);
      final room = roomState(
        status: RoomStatus.reveal,
        question: question(revealed: true),
        players: [me, player(2, 'Bo', score: 500)],
      );
      await pump(tester, PlayerRevealView(room: room, me: me, myChoice: 1));

      expect(find.text('Correct!'), findsOneWidget);
      expect(find.text('+900'), findsOneWidget);
      expect(find.text('#1 · 1800 pts'), findsOneWidget);
      expect(find.text('Paris'), findsOneWidget);
    });

    testWidgets('when they were wrong then says so', (tester) async {
      final me = player(1, 'Ada', lastPoints: 0);
      final room = roomState(
        status: RoomStatus.reveal,
        question: question(revealed: true),
        players: [me],
      );
      await pump(tester, PlayerRevealView(room: room, me: me, myChoice: 0));

      expect(find.text('Wrong'), findsOneWidget);
    });
  });

  group('Given the host runs a question', () {
    final wide = const Size(1400, 1000);

    testWidgets('when it is open then shows progress and Reveal now', (
      tester,
    ) async {
      final room = roomState(
        status: RoomStatus.question,
        question: question(),
        questionEndsAt: endsAt,
        players: [
          player(1, 'A', hasAnswered: true),
          player(2, 'B', hasAnswered: true),
          player(3, 'C'),
        ],
      );
      await pump(
        tester,
        HostQuestionView(room: room, clockOffset: Duration.zero),
        size: wide,
      );

      expect(find.text('2 of 3 answered'), findsOneWidget);
      await tester.tap(find.text('Reveal now'));
      verify(() => cubit.reveal()).called(1);
    });

    testWidgets('when revealed mid-round then shows votes, board and Next', (
      tester,
    ) async {
      final room = roomState(
        status: RoomStatus.reveal,
        question: question(revealed: true, answerCounts: [1, 2, 0, 0]),
        players: [
          player(1, 'Ada', score: 900, lastPoints: 900),
          player(2, 'Bo', score: 700, lastPoints: 700),
          player(3, 'Cy'),
        ],
      );
      await pump(
        tester,
        HostQuestionView(room: room, clockOffset: Duration.zero),
        size: wide,
      );

      expect(find.text('2 of 3 got it right'), findsOneWidget);
      expect(find.text('Leaderboard'), findsOneWidget);
      expect(find.text('+900'), findsOneWidget);
      await tester.tap(find.text('Next question'));
      verify(() => cubit.nextQuestion()).called(1);
    });

    testWidgets('when the round is over then the button ends the round', (
      tester,
    ) async {
      final room = roomState(
        status: RoomStatus.reveal,
        questionsPerRound: 1,
        question: question(revealed: true, answerCounts: [0, 1, 0, 0]),
        players: [player(1, 'Ada')],
      );
      await pump(
        tester,
        HostQuestionView(room: room, clockOffset: Duration.zero),
        size: wide,
      );

      await tester.tap(find.text('End round'));
      verify(() => cubit.endRound()).called(1);
    });
  });
}
