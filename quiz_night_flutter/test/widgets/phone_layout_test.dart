import 'package:bloc_test/bloc_test.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:quiz_night_client/quiz_night_client.dart';
import 'package:quiz_night_flutter/core/platform/haptics.dart';
import 'package:quiz_night_flutter/core/theme/app_theme.dart';
import 'package:quiz_night_flutter/features/join/join_cubit.dart';
import 'package:quiz_night_flutter/features/join/join_screen.dart';
import 'package:quiz_night_flutter/features/landing/landing_screen.dart';
import 'package:quiz_night_flutter/features/room/phone/phone_cut.dart';
import 'package:quiz_night_flutter/features/room/phone/phone_final.dart';
import 'package:quiz_night_flutter/features/room/phone/phone_placement.dart';
import 'package:quiz_night_flutter/features/room/phone/phone_question.dart';
import 'package:quiz_night_flutter/features/room/phone/phone_result.dart';
import 'package:quiz_night_flutter/features/room/phone/phone_waiting.dart';
import 'package:quiz_night_flutter/features/room/room_cubit.dart';
import 'package:quiz_night_flutter/widgets/qn/phone_frame.dart';
import 'package:quiz_night_flutter/widgets/qn/session_clock.dart';

import '../fakes/fakes.dart';
import 'harness.dart';

class MockJoinCubit extends MockCubit<JoinState> implements JoinCubit {}

/// A small Android phone; iPhone SE is 375 wide.
const phone = Size(360, 640);

/// Long names and long answers, the worst case for a narrow screen.
const longName = 'Olúwaṣẹ́gun-the-Great';

const f = PlayerStatus.finalist;
const out = PlayerStatus.eliminated;

void main() {
  setUpAll(registerFallbacks);

  final endsAt = DateTime.now().toUtc().add(const Duration(minutes: 5));
  final me = player(1, longName, score: 123456, lastPoints: 987);
  final spectator = player(
    9,
    longName,
    status: out,
    eliminatedInRound: 1,
    shadowScore: 99999,
  );

  /// Renders [child] in the 360×640 phone frame; any overflow fails the test.
  Future<void> render(
    WidgetTester tester,
    Widget child, {
    // Off on the results screens: the clock goes once the game ends.
    bool withClock = true,
  }) async {
    tester.view.physicalSize = phone;
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    final room = MockRoomCubit();
    when(() => room.state).thenReturn(const RoomViewState(seat: playerSeat));
    await tester.pumpWidget(
      RepositoryProvider<Haptics>(
        create: (_) => SilentHaptics(),
        child: MaterialApp(
          theme: AppTheme.dark(),
          home: Scaffold(
            body: BlocProvider<RoomCubit>.value(
              value: room,
              child: PhoneFrame(
                code: '4821',
                phase: 'Round 2',
                // The game clock sits under the header once a game starts.
                clock: withClock
                    ? SessionClock(
                        endsAt: DateTime.now().toUtc().add(
                          const Duration(minutes: 24),
                        ),
                        clockOffset: Duration.zero,
                      )
                    : null,
                child: child,
              ),
            ),
          ),
        ),
      ),
    );
    await tester.pump(const Duration(seconds: 3));
  }

  List<PlayerView> crowd() => [
    me,
    for (var i = 2; i <= 30; i++) player(i, '$longName $i', score: i * 100),
  ];

  QuestionView longQuestion({bool revealed = false, bool isFinal = false}) =>
      QuestionView(
        id: 10,
        round: 2,
        indexInRound: 8,
        isFinal: isFinal,
        text:
            'Which river forms most of the border between Nigeria and Niger, '
            'and where does it meet the Benue?',
        options: const [
          'The Federal Capital Territory moved from Lagos to Abuja in 1991',
          'Ibadan',
          'Kaduna, the old capital of the Northern Region',
          'Enugu',
        ],
        timeLimitSeconds: 20,
        correctIndex: revealed ? 0 : null,
      );

  group('Given a 360x640 phone', () {
    testWidgets('when on the join form with a warning then nothing overflows', (
      t,
    ) async {
      final join = MockJoinCubit();
      when(() => join.state).thenReturn(
        const JoinState(
          error: 'This game already started. Ask the host to open a new room.',
          errorKind: JoinError.gameStarted,
        ),
      );
      t.view.physicalSize = phone;
      t.view.devicePixelRatio = 1;
      addTearDown(t.view.reset);
      await t.pumpWidget(
        MaterialApp(
          theme: AppTheme.dark(),
          home: MultiBlocProvider(
            providers: [
              BlocProvider<JoinCubit>.value(value: join),
            ],
            child: SiteScaffold(
              current: null,
              sections: (_) => [JoinSection(onHost: () {})],
            ),
          ),
        ),
      );
      expect(t.takeException(), isNull);
    });

    testWidgets('when waiting with a crowd then nothing overflows', (t) async {
      await render(
        t,
        PhoneWaiting(
          room: roomState(players: crowd()),
          me: me,
        ),
      );
      expect(t.takeException(), isNull);
    });

    testWidgets('when answering a long question then nothing overflows', (
      t,
    ) async {
      final room = roomState(
        status: RoomStatus.question,
        question: longQuestion(),
        questionEndsAt: endsAt,
        players: [me],
      );
      await render(
        t,
        PhoneQuestion(
          room: room,
          me: me,
          myChoice: null,
          clockOffset: Duration.zero,
        ),
      );
      expect(t.takeException(), isNull);
    });

    testWidgets('when locked in then nothing overflows', (t) async {
      final room = roomState(
        status: RoomStatus.question,
        question: longQuestion(),
        questionEndsAt: endsAt,
        players: crowd(),
      );
      await render(
        t,
        PhoneQuestion(
          room: room,
          me: me,
          myChoice: 0,
          clockOffset: Duration.zero,
        ),
      );
      expect(t.takeException(), isNull);
    });

    testWidgets('when seeing a result in the danger zone then nothing '
        'overflows', (t) async {
      final room = roomState(
        status: RoomStatus.reveal,
        question: longQuestion(revealed: true),
        players: crowd(),
      ).copyWith(projectedSurvivors: 2);
      await render(
        t,
        PhoneResult(room: room, me: room.players.last, myChoice: 2, move: -12),
      );
      expect(t.takeException(), isNull);
    });

    testWidgets('when out and backing a finalist then nothing overflows', (
      t,
    ) async {
      final room = roomState(
        status: RoomStatus.elimination,
        round: 1,
        lastElimination: cut(out: [9], finalists: true),
        players: [
          for (var i = 1; i <= 4; i++) player(i, '$longName $i', status: f),
          spectator,
        ],
      );
      await render(
        t,
        PhoneCut(room: room, me: spectator, myBackedId: 1, keepWatching: true),
      );
      expect(t.takeException(), isNull);
    });

    testWidgets('when eliminated then nothing overflows', (t) async {
      final room = roomState(
        status: RoomStatus.elimination,
        round: 1,
        lastElimination: cut(out: [9], tie: true),
        players: [me, spectator],
      );
      await render(t, PhoneCut(room: room, me: spectator));
      expect(t.takeException(), isNull);
    });

    testWidgets('when holding the buzzer with long options then nothing '
        'overflows', (t) async {
      final finalist = player(1, longName, status: f);
      final room = roomState(
        status: RoomStatus.buzzerFinal,
        question: longQuestion(isFinal: true),
        questionEndsAt: endsAt,
        buzzerHolderId: 1,
        players: [
          finalist,
          player(2, '$longName 2', status: f),
        ],
      );
      await render(
        t,
        PhoneBuzzer(room: room, me: finalist, myChoice: null, buzzing: false),
      );
      expect(t.takeException(), isNull);
    });

    testWidgets('when watching the final then nothing overflows', (t) async {
      final room = roomState(
        status: RoomStatus.buzzerFinal,
        question: longQuestion(isFinal: true),
        questionEndsAt: endsAt,
        players: [
          for (var i = 1; i <= 4; i++) player(i, '$longName $i', status: f),
          spectator,
        ],
      );
      await render(t, PhoneWatching(room: room, me: spectator, myBackedId: 1));
      expect(t.takeException(), isNull);
    });

    testWidgets('when on the final placement then nothing overflows', (
      t,
    ) async {
      final room = roomState(
        status: RoomStatus.finished,
        players: [
          for (var i = 1; i <= 3; i++)
            player(i, '$longName $i', status: f, finalScore: 99000),
          spectator.copyWith(backedPlayerId: 2),
        ],
      );
      await render(
        t,
        PhonePlacement(room: room, me: room.players.last),
        withClock: false,
      );
      expect(t.takeException(), isNull);
    });

    testWidgets('when the game ran out of time then the results and their '
        'notice fit', (t) async {
      final room = roomState(
        status: RoomStatus.finished,
        round: 2,
        players: [
          for (var i = 1; i <= 3; i++)
            player(i, '$longName $i', score: 99000 - i),
          spectator,
        ],
      ).copyWith(endReason: RoomEndReason.timeUp);
      await render(
        t,
        PhonePlacement(room: room, me: room.players.first),
        withClock: false,
      );
      expect(t.takeException(), isNull);
      expect(find.text("TIME'S UP"), findsOneWidget);
    });
  });
}
