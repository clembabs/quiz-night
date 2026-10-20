import 'package:bloc_test/bloc_test.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:quiz_night_flutter/app/quiz_night_app.dart';
import 'package:quiz_night_flutter/core/theme/app_theme.dart';
import 'package:quiz_night_flutter/features/join/join_cubit.dart';
import 'package:quiz_night_flutter/features/join/join_screen.dart';
import 'package:quiz_night_flutter/features/room/host_lobby_view.dart';
import 'package:quiz_night_flutter/features/room/player_lobby_view.dart';
import 'package:quiz_night_flutter/features/room/room_cubit.dart';

import '../fakes/fakes.dart';

class MockRoomCubit extends MockCubit<RoomViewState> implements RoomCubit {}

class MockJoinCubit extends MockCubit<JoinState> implements JoinCubit {}

Widget wrap(Widget child) => MaterialApp(
  theme: AppTheme.dark(),
  home: Scaffold(body: child),
);

void main() {
  setUpAll(registerFallbacks);

  group('Given the app starts', () {
    late MockLobbyRepository lobby;
    late MockGameRepository game;
    late MockSeatRepository seats;

    setUp(() {
      lobby = MockLobbyRepository();
      game = MockGameRepository();
      seats = MockSeatRepository();
    });

    testWidgets('when there is no saved seat then shows Join and Host', (
      tester,
    ) async {
      when(() => seats.load()).thenAnswer((_) async => null);
      await tester.pumpWidget(
        QuizNightApp(lobby: lobby, game: game, seats: seats),
      );
      await tester.pumpAndSettle();

      expect(find.text('Join a game'), findsOneWidget);
      expect(find.text('Host a game'), findsOneWidget);
      expect(find.textContaining('Rejoin'), findsNothing);
    });

    testWidgets('when a valid seat is saved then offers to rejoin it', (
      tester,
    ) async {
      when(() => seats.load()).thenAnswer((_) async => playerSeat);
      when(() => lobby.isSeatValid(playerSeat)).thenAnswer((_) async => true);
      await tester.pumpWidget(
        QuizNightApp(lobby: lobby, game: game, seats: seats),
      );
      await tester.pumpAndSettle();

      expect(find.text('Rejoin room ABCD'), findsOneWidget);
    });

    testWidgets('when opened from a QR link then the join form has the code', (
      tester,
    ) async {
      when(() => seats.load()).thenAnswer((_) async => null);
      await tester.pumpWidget(
        QuizNightApp(
          lobby: lobby,
          game: game,
          seats: seats,
          initialCode: 'WXYZ',
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Join a game'), findsWidgets);
      final code = tester.widget<TextField>(find.byKey(const Key('join.code')));
      expect(code.controller!.text, 'WXYZ');
    });
  });

  group('Given the join screen', () {
    testWidgets(
      'when submitting then passes the typed code and nickname to the cubit',
      (
        tester,
      ) async {
        final cubit = MockJoinCubit();
        when(() => cubit.state).thenReturn(const JoinState());
        when(() => cubit.join(any(), any())).thenAnswer((_) async {});

        await tester.pumpWidget(
          wrap(
            BlocProvider<JoinCubit>.value(
              value: cubit,
              child: const JoinScreen(),
            ),
          ),
        );
        await tester.enterText(find.byKey(const Key('join.code')), 'abcd');
        await tester.enterText(find.byKey(const Key('join.nickname')), 'Ada');
        await tester.tap(find.text("Let's go"));

        // The screen passes raw input; JoinCubit normalises it (see its tests).
        verify(() => cubit.join('abcd', 'Ada')).called(1);
      },
    );

    testWidgets('when there is an error then it is shown', (tester) async {
      final cubit = MockJoinCubit();
      when(
        () => cubit.state,
      ).thenReturn(const JoinState(error: 'That nickname is taken'));

      await tester.pumpWidget(
        wrap(
          BlocProvider<JoinCubit>.value(
            value: cubit,
            child: const JoinScreen(),
          ),
        ),
      );

      expect(find.text('That nickname is taken'), findsOneWidget);
    });
  });

  group('Given the host lobby', () {
    late MockRoomCubit cubit;

    setUp(() {
      cubit = MockRoomCubit();
      when(() => cubit.state).thenReturn(const RoomViewState(seat: hostSeat));
      when(() => cubit.startGame()).thenAnswer((_) async {});
    });

    Future<void> pump(WidgetTester tester, int players) async {
      tester.view.physicalSize = const Size(1400, 900);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.reset);
      await tester.pumpWidget(
        wrap(
          BlocProvider<RoomCubit>.value(
            value: cubit,
            child: HostLobbyView(
              room: roomState(
                players: [
                  for (var i = 1; i <= players; i++) player(i, 'P$i'),
                ],
              ),
            ),
          ),
        ),
      );
    }

    testWidgets('when one player is in then Start is disabled', (tester) async {
      await pump(tester, 1);

      expect(find.text('ABCD'), findsOneWidget);
      expect(find.text('1 player in'), findsOneWidget);
      await tester.tap(find.text('Need at least 2 players'));
      verifyNever(() => cubit.startGame());
    });

    testWidgets('when two players are in then Start starts the game', (
      tester,
    ) async {
      await pump(tester, 2);

      expect(find.text('P1'), findsOneWidget);
      expect(find.text('P2'), findsOneWidget);
      await tester.tap(find.text('Start the game'));
      verify(() => cubit.startGame()).called(1);
    });

    test('when building the join link then the code is in the query', () {
      final url = HostLobbyView.joinUrl(
        Uri.parse('https://quiz.example.com/#/old'),
        'ABCD',
      );
      expect(url.toString(), 'https://quiz.example.com/?code=ABCD');
    });
  });

  group('Given the player lobby', () {
    testWidgets('when waiting then greets the player by name', (tester) async {
      final ada = player(1, 'Ada');
      await tester.pumpWidget(
        wrap(
          PlayerLobbyView(
            room: roomState(players: [ada, player(2, 'Bo')]),
            me: ada,
          ),
        ),
      );

      expect(find.text("You're in, Ada!"), findsOneWidget);
      expect(find.text('2 in the room'), findsOneWidget);
    });
  });
}
