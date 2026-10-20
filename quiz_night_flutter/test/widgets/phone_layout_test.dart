import 'package:bloc_test/bloc_test.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:quiz_night_client/quiz_night_client.dart';
import 'package:quiz_night_flutter/core/theme/app_theme.dart';
import 'package:quiz_night_flutter/features/home/home_cubit.dart';
import 'package:quiz_night_flutter/features/home/home_screen.dart';
import 'package:quiz_night_flutter/features/host_setup/host_setup_cubit.dart';
import 'package:quiz_night_flutter/features/host_setup/host_setup_screen.dart';
import 'package:quiz_night_flutter/features/join/join_cubit.dart';
import 'package:quiz_night_flutter/features/join/join_screen.dart';
import 'package:quiz_night_flutter/features/room/cut_reveal/reveal_sequence_cubit.dart';
import 'package:quiz_night_flutter/features/room/final/player_final_view.dart';
import 'package:quiz_night_flutter/features/room/final/podium_view.dart';
import 'package:quiz_night_flutter/features/room/player_lobby_view.dart';
import 'package:quiz_night_flutter/features/room/room_cubit.dart';
import 'package:quiz_night_flutter/features/room/round/player_cut_view.dart';
import 'package:quiz_night_flutter/features/room/round/player_question_view.dart';
import 'package:quiz_night_flutter/features/room/round/player_reveal_view.dart';

import '../fakes/fakes.dart';

class MockRoomCubit extends MockCubit<RoomViewState> implements RoomCubit {}

class MockHomeCubit extends MockCubit<HomeState> implements HomeCubit {}

class MockJoinCubit extends MockCubit<JoinState> implements JoinCubit {}

class MockHostSetupCubit extends MockCubit<HostSetupState>
    implements HostSetupCubit {}

/// A small Android phone; iPhone SE is 375 wide.
const phone = Size(360, 640);

/// Long names and long answers, the worst case for a narrow screen.
const longName = 'Bartholomew-Jones';

void main() {
  setUpAll(registerFallbacks);

  final endsAt = DateTime.now().toUtc().add(const Duration(minutes: 5));
  final me = player(1, longName, score: 12345, lastPoints: 987);

  /// Renders [child] at phone size. Flutter fails the test on any overflow.
  Future<void> render(WidgetTester tester, Widget child) async {
    tester.view.physicalSize = phone;
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    final room = MockRoomCubit();
    when(() => room.state).thenReturn(const RoomViewState(seat: playerSeat));
    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.dark(),
        home: Scaffold(
          appBar: AppBar(title: const Text('Room ABCD')),
          body: BlocProvider<RoomCubit>.value(value: room, child: child),
        ),
      ),
    );
    await tester.pump();
  }

  List<PlayerView> crowd() => [
    me,
    for (var i = 2; i <= 12; i++) player(i, '$longName $i', score: i * 100),
  ];

  group('Given a 360x640 phone', () {
    testWidgets('when on the home screen then nothing overflows', (
      tester,
    ) async {
      final cubit = MockHomeCubit();
      when(() => cubit.state).thenReturn(
        const HomeState(loading: false, savedSeat: playerSeat),
      );
      when(() => cubit.initialCode).thenReturn(null);
      await render(
        tester,
        BlocProvider<HomeCubit>.value(value: cubit, child: const HomeScreen()),
      );
      expect(tester.takeException(), isNull);
    });

    testWidgets('when on the join form then nothing overflows', (tester) async {
      final cubit = MockJoinCubit();
      when(() => cubit.state).thenReturn(
        const JoinState(error: 'That nickname is already taken in this room'),
      );
      await render(
        tester,
        BlocProvider<JoinCubit>.value(value: cubit, child: const JoinScreen()),
      );
      expect(tester.takeException(), isNull);
    });

    testWidgets('when on host setup then the rule picker fits', (tester) async {
      final cubit = MockHostSetupCubit();
      when(() => cubit.state).thenReturn(
        const HostSetupState(rule: EliminationRule.autoScaled),
      );
      await render(
        tester,
        BlocProvider<HostSetupCubit>.value(
          value: cubit,
          child: const HostSetupScreen(),
        ),
      );
      expect(tester.takeException(), isNull);
    });

    testWidgets('when in the lobby with a crowd then nothing overflows', (
      tester,
    ) async {
      await render(
        tester,
        PlayerLobbyView(
          room: roomState(players: crowd()),
          me: me,
        ),
      );
      expect(tester.takeException(), isNull);
    });

    testWidgets('when answering a long question then nothing overflows', (
      tester,
    ) async {
      final room = roomState(
        status: RoomStatus.question,
        question: question(),
        questionEndsAt: endsAt,
        players: [me],
      );
      await render(
        tester,
        PlayerQuestionView(
          room: room,
          me: me,
          myChoice: 2,
          clockOffset: Duration.zero,
        ),
      );
      expect(tester.takeException(), isNull);
    });

    testWidgets('when seeing a reveal then nothing overflows', (tester) async {
      final room = roomState(
        status: RoomStatus.reveal,
        question: question(revealed: true),
        players: crowd(),
      );
      await render(tester, PlayerRevealView(room: room, me: me, myChoice: 1));
      expect(tester.takeException(), isNull);
    });

    testWidgets('when backing a finalist after a cut then nothing overflows', (
      tester,
    ) async {
      final spectator = player(
        9,
        longName,
        status: PlayerStatus.eliminated,
        eliminatedInRound: 1,
      );
      final room = roomState(
        status: RoomStatus.elimination,
        round: 1,
        lastElimination: cut(out: [9], finalists: true),
        players: [
          for (var i = 1; i <= 3; i++)
            player(i, '$longName $i', status: PlayerStatus.finalist),
          spectator,
        ],
      );
      await render(
        tester,
        PlayerCutView(
          room: room,
          me: spectator,
          createSequence: (total) => RevealSequenceCubit(total: total)..skip(),
        ),
      );
      expect(tester.takeException(), isNull);
    });

    testWidgets('when buzzing in the final then the buzzer and cards fit', (
      tester,
    ) async {
      final finalist = player(1, longName, status: PlayerStatus.finalist);
      final room = roomState(
        status: RoomStatus.buzzerFinal,
        question: question(isFinal: true),
        questionEndsAt: endsAt,
        players: [
          finalist,
          player(2, '$longName 2', status: PlayerStatus.finalist),
          player(3, '$longName 3', status: PlayerStatus.finalist),
        ],
      );
      await render(
        tester,
        PlayerFinalView(
          room: room,
          me: finalist,
          myChoice: null,
          myBackedId: null,
          buzzing: false,
          clockOffset: Duration.zero,
        ),
      );
      expect(tester.takeException(), isNull);
    });

    testWidgets('when on the podium then nothing overflows', (tester) async {
      final room = roomState(
        status: RoomStatus.finished,
        players: [
          for (var i = 1; i <= 4; i++)
            player(
              i,
              '$longName $i',
              status: PlayerStatus.finalist,
              finalScore: 5000 - i * 1000,
            ),
          player(
            9,
            longName,
            status: PlayerStatus.eliminated,
            backedPlayerId: 1,
            shadowScore: 99999,
          ),
        ],
      );
      await render(tester, PodiumView(room: room, me: room.players.last));
      expect(tester.takeException(), isNull);
    });
  });
}
