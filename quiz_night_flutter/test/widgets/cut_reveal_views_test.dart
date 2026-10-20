import 'package:bloc_test/bloc_test.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:quiz_night_client/quiz_night_client.dart';
import 'package:quiz_night_flutter/core/theme/app_theme.dart';
import 'package:quiz_night_flutter/features/room/cut_reveal/reveal_sequence_cubit.dart';
import 'package:quiz_night_flutter/features/room/room_cubit.dart';
import 'package:quiz_night_flutter/features/room/round/host_cut_view.dart';
import 'package:quiz_night_flutter/features/room/round/player_cut_view.dart';
import 'package:quiz_night_flutter/features/room/round/player_question_view.dart';
import 'package:quiz_night_flutter/features/room/round/player_reveal_view.dart';

import '../fakes/fakes.dart';

class MockRoomCubit extends MockCubit<RoomViewState> implements RoomCubit {}

const intro = Duration(seconds: 1);
const step = Duration(seconds: 1);

RevealSequenceCubit fastSequence(int total) =>
    RevealSequenceCubit(total: total, intro: intro, step: step);

void main() {
  setUpAll(registerFallbacks);

  late MockRoomCubit cubit;

  setUp(() {
    cubit = MockRoomCubit();
    when(() => cubit.state).thenReturn(const RoomViewState(seat: hostSeat));
    when(() => cubit.nextQuestion()).thenAnswer((_) async {});
    when(() => cubit.useWildcard(any())).thenAnswer((_) async {});
    when(() => cubit.backFinalist(any())).thenAnswer((_) async {});
  });

  Future<void> pump(WidgetTester tester, Widget child) async {
    tester.view.physicalSize = const Size(900, 1600);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.dark(),
        home: Scaffold(
          body: BlocProvider<RoomCubit>.value(value: cubit, child: child),
        ),
      ),
    );
  }

  /// Round 1: Dee then Cy go out (Cy is the bubble), Ada and Bo survive.
  RoomState roundOneCut({bool finalists = false, bool wildcardUsed = false}) {
    final room = roomState(
      status: RoomStatus.elimination,
      round: 1,
      lastElimination: cut(
        out: [4, 3],
        survivors: 2,
        tie: true,
        finalists: finalists,
      ),
      players: [
        player(
          1,
          'Ada',
          score: 900,
          status: finalists ? PlayerStatus.finalist : PlayerStatus.active,
        ),
        player(
          2,
          'Bo',
          score: 500,
          status: finalists ? PlayerStatus.finalist : PlayerStatus.active,
        ),
        player(3, 'Cy', status: PlayerStatus.eliminated, eliminatedInRound: 1),
        player(4, 'Dee', status: PlayerStatus.eliminated, eliminatedInRound: 1),
      ],
    );
    return wildcardUsed ? room.copyWith(wildcardUsed: true) : room;
  }

  group('Given the host shows a cut', () {
    testWidgets('when it starts then asks who is going home, names hidden', (
      tester,
    ) async {
      await pump(
        tester,
        HostCutView(room: roundOneCut(), createSequence: fastSequence),
      );

      expect(find.text("Who's going home?"), findsOneWidget);
      expect(find.text('Dee'), findsNothing);
      expect(find.text('Next round'), findsNothing);
    });

    testWidgets('when time passes then names come in worst first, the bubble '
        'last, then the survivors and Next round', (tester) async {
      await pump(
        tester,
        HostCutView(room: roundOneCut(), createSequence: fastSequence),
      );

      await tester.pump(intro);
      await tester.pumpAndSettle();
      expect(find.text('Dee'), findsOneWidget);
      expect(find.text('Cy'), findsNothing);

      await tester.pump(step);
      await tester.pumpAndSettle();
      expect(find.text('Cy'), findsOneWidget);
      expect(find.text('SO CLOSE'), findsOneWidget);

      await tester.pump(step);
      await tester.pumpAndSettle();
      expect(find.text('Safe!'), findsOneWidget);
      expect(find.textContaining('broken by answer speed'), findsOneWidget);
      await tester.tap(find.text('Next round'));
      verify(() => cubit.nextQuestion()).called(1);
    });

    testWidgets('when the host skips then everything shows at once', (
      tester,
    ) async {
      await pump(
        tester,
        HostCutView(room: roundOneCut(), createSequence: fastSequence),
      );

      await tester.tap(find.text('Skip'));
      await tester.pumpAndSettle();

      expect(find.text('Dee'), findsOneWidget);
      expect(find.text('Cy'), findsOneWidget);
      expect(find.text('Next round'), findsOneWidget);
    });

    testWidgets('when the host confirms the wildcard then that player is '
        'rescued', (tester) async {
      await pump(
        tester,
        HostCutView(room: roundOneCut(), createSequence: fastSequence),
      );
      await tester.tap(find.text('Skip'));
      await tester.pumpAndSettle();

      await tester.tap(find.byKey(const Key('wildcard.3')));
      await tester.pumpAndSettle();
      expect(find.text('Rescue Cy?'), findsOneWidget);
      await tester.tap(find.text('Rescue'));
      await tester.pumpAndSettle();

      verify(() => cubit.useWildcard(3)).called(1);
    });

    testWidgets('when the wildcard is used up then it is not offered', (
      tester,
    ) async {
      await pump(
        tester,
        HostCutView(
          room: roundOneCut(wildcardUsed: true),
          createSequence: fastSequence,
        ),
      );
      await tester.tap(find.text('Skip'));
      await tester.pumpAndSettle();

      expect(find.text('Wildcard'), findsNothing);
    });

    testWidgets('when finalists are decided then the button starts the final', (
      tester,
    ) async {
      await pump(
        tester,
        HostCutView(
          room: roundOneCut(finalists: true),
          createSequence: fastSequence,
        ),
      );
      await tester.tap(find.text('Skip'));
      await tester.pumpAndSettle();

      expect(find.text('Your finalists'), findsOneWidget);
      expect(find.text('Start the final'), findsOneWidget);
    });
  });

  group('Given a player watches the cut', () {
    testWidgets('when their name has not come up then they wait in suspense', (
      tester,
    ) async {
      final room = roundOneCut();
      await pump(
        tester,
        PlayerCutView(
          room: room,
          me: room.players[2], // Cy, the bubble, revealed second.
          createSequence: fastSequence,
        ),
      );
      await tester.pump(intro);

      expect(find.text('Are you safe?'), findsOneWidget);
      expect(find.text('1 of 2 revealed'), findsOneWidget);
    });

    testWidgets('when their name comes up then they are told they are out', (
      tester,
    ) async {
      final room = roundOneCut();
      await pump(
        tester,
        PlayerCutView(
          room: room,
          me: room.players[3], // Dee, revealed first.
          createSequence: fastSequence,
        ),
      );
      await tester.pump(intro);

      expect(find.text("You're out"), findsOneWidget);
    });

    testWidgets('when a survivor waits to the end then they are told they '
        'survived', (tester) async {
      final room = roundOneCut();
      await pump(
        tester,
        PlayerCutView(
          room: room,
          me: room.players[0],
          createSequence: fastSequence,
        ),
      );
      await tester.pump(intro);
      await tester.pump(step);
      expect(find.text('Are you safe?'), findsOneWidget);

      await tester.pump(step);
      expect(find.text('You survived round 1'), findsOneWidget);
    });

    testWidgets('when finalists are decided then a spectator can back one', (
      tester,
    ) async {
      final room = roundOneCut(finalists: true);
      await pump(
        tester,
        PlayerCutView(
          room: room,
          me: room.players[3],
          createSequence: fastSequence,
        ),
      );
      await tester.pump(intro);
      await tester.pump(step);
      await tester.pump(step);

      expect(find.text('Who will win? Back a finalist'), findsOneWidget);
      await tester.tap(find.byKey(const Key('back.1')));
      verify(() => cubit.backFinalist(1)).called(1);
    });

    testWidgets('when they have backed someone then it says who', (
      tester,
    ) async {
      final room = roundOneCut(finalists: true);
      await pump(
        tester,
        PlayerCutView(
          room: room,
          me: room.players[3],
          myBackedId: 2,
          createSequence: fastSequence,
        ),
      );
      await tester.pump(intro);
      await tester.pump(step);
      await tester.pump(step);

      expect(find.text("You're backing Bo"), findsOneWidget);
    });
  });

  group('Given a spectator plays along', () {
    final spectator = player(
      3,
      'Cy',
      status: PlayerStatus.eliminated,
      eliminatedInRound: 1,
      lastPoints: 800,
    ).copyWith(shadowScore: 1800);

    testWidgets('when a question is open then the banner shows their shadow '
        'score and they can still answer', (tester) async {
      when(() => cubit.submitAnswer(any())).thenAnswer((_) async {});
      final room = roomState(
        status: RoomStatus.question,
        question: question(),
        questionEndsAt: DateTime.now().toUtc().add(const Duration(minutes: 5)),
        players: [spectator],
      );
      await pump(
        tester,
        PlayerQuestionView(
          room: room,
          me: spectator,
          myChoice: null,
          clockOffset: Duration.zero,
        ),
      );

      expect(find.text('Spectating · shadow score 1800'), findsOneWidget);
      await tester.tap(find.byKey(const Key('answer.1')));
      verify(() => cubit.submitAnswer(1)).called(1);
    });

    testWidgets('when revealed then points are marked as shadow, no rank', (
      tester,
    ) async {
      final room = roomState(
        status: RoomStatus.reveal,
        question: question(revealed: true),
        players: [spectator],
      );
      await pump(
        tester,
        PlayerRevealView(room: room, me: spectator, myChoice: 1),
      );

      expect(find.text('+800 shadow'), findsOneWidget);
      expect(find.textContaining('pts'), findsNothing);
    });
  });
}
