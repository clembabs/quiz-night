import 'package:bloc_test/bloc_test.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:quiz_night_client/quiz_night_client.dart';
import 'package:quiz_night_flutter/core/theme/app_theme.dart';
import 'package:quiz_night_flutter/features/room/final/host_final_view.dart';
import 'package:quiz_night_flutter/features/room/final/player_final_view.dart';
import 'package:quiz_night_flutter/features/room/final/podium_view.dart';
import 'package:quiz_night_flutter/features/room/room_cubit.dart';

import '../fakes/fakes.dart';

class MockRoomCubit extends MockCubit<RoomViewState> implements RoomCubit {}

const f = PlayerStatus.finalist;

void main() {
  setUpAll(registerFallbacks);

  late MockRoomCubit cubit;
  final endsAt = DateTime.now().toUtc().add(const Duration(minutes: 5));

  setUp(() {
    cubit = MockRoomCubit();
    when(() => cubit.state).thenReturn(const RoomViewState(seat: playerSeat));
    when(() => cubit.buzz()).thenAnswer((_) async {});
    when(() => cubit.submitBuzzAnswer(any())).thenAnswer((_) async {});
    when(() => cubit.nextQuestion()).thenAnswer((_) async {});
    when(() => cubit.leave()).thenAnswer((_) async {});
  });

  Future<void> pump(WidgetTester tester, Widget child) async {
    tester.view.physicalSize = const Size(1000, 2200);
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

  RoomState openFinal({int? holder, bool adaLockedOut = false}) => roomState(
    status: RoomStatus.buzzerFinal,
    question: question(isFinal: true),
    questionEndsAt: endsAt,
    finalQuestionCount: 3,
    finalQuestionsPlayed: 1,
    buzzerHolderId: holder,
    players: [
      player(1, 'Ada', status: f, finalScore: 1000, lockedOut: adaLockedOut),
      player(2, 'Bo', status: f),
      player(
        3,
        'Cy',
        status: PlayerStatus.eliminated,
        eliminatedInRound: 1,
        shadowScore: 700,
      ),
    ],
  );

  Widget playerView(
    RoomState room,
    int myId, {
    int? myChoice,
    int? backed,
    bool buzzing = false,
  }) => PlayerFinalView(
    room: room,
    me: room.players.firstWhere((p) => p.id == myId),
    myChoice: myChoice,
    myBackedId: backed,
    buzzing: buzzing,
    clockOffset: Duration.zero,
  );

  String prompt(WidgetTester tester) =>
      tester.widget<Text>(find.byKey(const Key('final.prompt'))).data!;

  group('Given a finalist on an open final question', () {
    testWidgets('when free to buzz then pressing BUZZ buzzes', (tester) async {
      await pump(tester, playerView(openFinal(), 1));

      expect(prompt(tester), 'Know it? Buzz!');
      expect(find.text('FINAL · QUESTION 1 OF 3'), findsOneWidget);
      await tester.press(find.byKey(const Key('buzz')));
      verify(() => cubit.buzz()).called(1);
    });

    testWidgets('when options are tapped before buzzing then nothing happens', (
      tester,
    ) async {
      await pump(tester, playerView(openFinal(), 1));
      await tester.tap(find.byKey(const Key('final.answer.1')));
      verifyNever(() => cubit.submitBuzzAnswer(any()));
    });

    testWidgets('when holding the buzzer then they answer by tapping', (
      tester,
    ) async {
      await pump(tester, playerView(openFinal(holder: 1), 1));

      expect(prompt(tester), 'You have the buzzer! Answer now');
      expect(find.byKey(const Key('buzz')), findsNothing);
      await tester.tap(find.byKey(const Key('final.answer.1')));
      verify(() => cubit.submitBuzzAnswer(1)).called(1);
    });

    testWidgets('when someone else holds it then they are told who', (
      tester,
    ) async {
      await pump(tester, playerView(openFinal(holder: 2), 1));
      expect(prompt(tester), 'Bo buzzed in…');
      expect(find.text('BUZZED!'), findsOneWidget);
    });

    testWidgets('when locked out then no buzz button is offered', (
      tester,
    ) async {
      await pump(tester, playerView(openFinal(adaLockedOut: true), 1));
      expect(prompt(tester), 'Locked out on this one');
      expect(find.byKey(const Key('buzz')), findsNothing);
      expect(find.text('LOCKED OUT'), findsOneWidget);
    });
  });

  group('Given a spectator during the final', () {
    testWidgets('when watching then they see who they back and cannot buzz', (
      tester,
    ) async {
      await pump(tester, playerView(openFinal(holder: 1), 3, backed: 1));

      expect(find.text('Spectating · shadow score 700'), findsOneWidget);
      expect(prompt(tester), 'Ada is answering…');
      expect(find.text("You're backing Ada"), findsOneWidget);
      expect(find.byKey(const Key('buzz')), findsNothing);
    });
  });

  group('Given the host shows the final', () {
    testWidgets('when a finalist buzzes then the board says who is answering', (
      tester,
    ) async {
      await pump(
        tester,
        HostFinalView(room: openFinal(holder: 2), clockOffset: Duration.zero),
      );

      expect(find.text('Bo is answering…'), findsOneWidget);
      expect(find.text('BUZZED!'), findsOneWidget);
      expect(find.text('Reveal now'), findsOneWidget);
    });

    testWidgets('when the last final question is revealed then the host '
        'shows the podium', (tester) async {
      final room = roomState(
        status: RoomStatus.reveal,
        question: question(isFinal: true, revealed: true),
        finalQuestionCount: 3,
        finalQuestionsPlayed: 3,
        buzzWinnerId: 1,
        players: [
          player(1, 'Ada', status: f, finalScore: 2000),
          player(2, 'Bo', status: f),
        ],
      );
      await pump(tester, HostFinalView(room: room, clockOffset: Duration.zero));

      expect(find.text('Ada got it! +1000'), findsOneWidget);
      expect(find.text('GOT IT'), findsOneWidget);
      await tester.tap(find.text('Show the podium'));
      verify(() => cubit.nextQuestion()).called(1);
    });
  });

  group('Given the game is finished', () {
    final room = roomState(
      status: RoomStatus.finished,
      players: [
        player(1, 'Ada', status: f, finalScore: 3000),
        player(2, 'Bo', status: f, finalScore: 1000),
        player(3, 'Cy', status: f),
        player(
          4,
          'Dee',
          status: PlayerStatus.eliminated,
          backedPlayerId: 1,
          shadowScore: 1500,
        ),
      ],
    );

    testWidgets('when the host shows the podium then winner, places, backers '
        'and shadow champion appear', (tester) async {
      await pump(tester, PodiumView(room: room));

      expect(find.text('Ada wins!'), findsOneWidget);
      expect(find.text('Bo'), findsOneWidget);
      expect(find.text('Cy'), findsOneWidget);
      expect(find.text('Backed the winner: Dee'), findsOneWidget);
      expect(find.text('Shadow champion: Dee (1500)'), findsOneWidget);
      expect(find.byKey(const Key('podium.personal')), findsNothing);
    });

    testWidgets('when a spectator who backed the winner looks then they '
        'called it', (tester) async {
      await pump(tester, PodiumView(room: room, me: room.players[3]));
      expect(find.text('You called it!'), findsOneWidget);
    });

    testWidgets('when Done is tapped then the player leaves', (tester) async {
      await pump(tester, PodiumView(room: room, me: room.players[1]));
      expect(find.text('You finished #2'), findsOneWidget);
      await tester.tap(find.text('Done'));
      verify(() => cubit.leave()).called(1);
    });
  });
}
