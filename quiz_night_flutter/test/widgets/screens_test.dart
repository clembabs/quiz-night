import 'dart:async';

import 'package:bloc_test/bloc_test.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:quiz_night_client/quiz_night_client.dart';
import 'package:quiz_night_flutter/app/quiz_night_app.dart';
import 'package:quiz_night_flutter/core/platform/screen_wake_lock.dart';
import 'package:quiz_night_flutter/core/theme/app_theme.dart';
import 'package:quiz_night_flutter/features/home/home_cubit.dart';
import 'package:quiz_night_flutter/features/home/home_screen.dart';
import 'package:quiz_night_flutter/features/join/join_cubit.dart';

import '../fakes/fakes.dart';

class MockJoinCubit extends MockCubit<JoinState> implements JoinCubit {}

class MockHomeCubit extends MockCubit<HomeState> implements HomeCubit {}

class CountingWakeLock implements ScreenWakeLock {
  int keepOnCalls = 0;
  int releaseCalls = 0;

  @override
  Future<void> keepOn() async => keepOnCalls++;

  @override
  Future<void> release() async => releaseCalls++;
}

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

    testWidgets('when there is no saved seat then the landing page is the '
        'join form', (tester) async {
      when(() => seats.load()).thenAnswer((_) async => null);
      await tester.pumpWidget(
        QuizNightApp(lobby: lobby, game: game, seats: seats),
      );
      await tester.pumpAndSettle();

      expect(find.text('QUIZ NIGHT'), findsOneWidget);
      expect(find.text('Survive the round, or go home.'), findsOneWidget);
      expect(find.byKey(const Key('join.code')), findsOneWidget);
      expect(find.text('JOIN GAME'), findsOneWidget);
      expect(find.byKey(const Key('home.host')), findsOneWidget);
    });

    testWidgets('when opened from a QR link then the code is pre-filled', (
      tester,
    ) async {
      when(() => seats.load()).thenAnswer((_) async => null);
      await tester.pumpWidget(
        QuizNightApp(
          lobby: lobby,
          game: game,
          seats: seats,
          initialCode: '4821',
        ),
      );
      await tester.pumpAndSettle();

      final code = tester.widget<TextField>(find.byKey(const Key('join.code')));
      expect(code.controller!.text, '4821');
    });

    testWidgets('when the host link is tapped then the create screen opens', (
      tester,
    ) async {
      tester.view.physicalSize = const Size(1920, 1080);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.reset);
      when(() => seats.load()).thenAnswer((_) async => null);
      await tester.pumpWidget(
        QuizNightApp(lobby: lobby, game: game, seats: seats),
      );
      await tester.pumpAndSettle();

      await tester.tap(find.byKey(const Key('home.host')));
      await tester.pumpAndSettle();
      expect(find.text('NEW GAME'), findsOneWidget);
    });

    testWidgets('when a live seat is saved then reopens straight into the '
        'room and keeps the screen on', (tester) async {
      when(() => seats.load()).thenAnswer((_) async => playerSeat);
      when(() => lobby.isSeatLive(playerSeat)).thenAnswer((_) async => true);
      // A live room stream stays open; one that closes means a dropped
      // connection and the cubit would keep reconnecting.
      final live = StreamController<RoomState>()
        ..add(roomState(players: [player(1, 'Ada')]));
      addTearDown(live.close);
      when(() => game.watchRoom('ABCD')).thenAnswer((_) => live.stream);
      final wakeLock = CountingWakeLock();
      await tester.pumpWidget(
        QuizNightApp(
          lobby: lobby,
          game: game,
          seats: seats,
          wakeLock: wakeLock,
        ),
      );
      await tester.pump(const Duration(seconds: 1));
      await tester.pump(const Duration(seconds: 1));

      expect(find.text("YOU'RE IN!"), findsOneWidget);
      expect(find.text('Lobby'), findsOneWidget);
      expect(wakeLock.keepOnCalls, 1, reason: 'screen kept on in a room');
    });
  });

  group('Given the join form', () {
    late MockJoinCubit join;
    late MockHomeCubit home;

    setUp(() {
      join = MockJoinCubit();
      home = MockHomeCubit();
      when(() => home.state).thenReturn(const HomeState(loading: false));
      when(() => home.initialCode).thenReturn(null);
      when(() => join.join(any(), any())).thenAnswer((_) async {});
    });

    Future<void> pump(WidgetTester tester, JoinState state) async {
      when(() => join.state).thenReturn(state);
      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.dark(),
          home: MultiBlocProvider(
            providers: [
              BlocProvider<HomeCubit>.value(value: home),
              BlocProvider<JoinCubit>.value(value: join),
            ],
            child: const HomeScreen(),
          ),
        ),
      );
    }

    testWidgets('when submitting then passes the code and nickname', (
      tester,
    ) async {
      await pump(tester, const JoinState());
      await tester.enterText(find.byKey(const Key('join.code')), '4821');
      await tester.enterText(find.byKey(const Key('join.nickname')), 'Ọlá');
      await tester.tap(find.byKey(const Key('join.submit')));

      verify(() => join.join('4821', 'Ọlá')).called(1);
    });

    testWidgets('when letters are typed into the code then only digits stay', (
      tester,
    ) async {
      await pump(tester, const JoinState());
      await tester.enterText(find.byKey(const Key('join.code')), '48ab21');
      final code = tester.widget<TextField>(find.byKey(const Key('join.code')));
      expect(code.controller!.text, '4821');
    });

    testWidgets('when the room is not found then the error sits under the '
        'code', (tester) async {
      await pump(
        tester,
        const JoinState(
          error:
              "This game session doesn't exist. Check the code on the big screen.",
          errorKind: JoinError.roomNotFound,
        ),
      );
      expect(
        find.text(
          "✕ This game session doesn't exist. Check the code on the big screen.",
        ),
        findsOneWidget,
      );
    });

    testWidgets('when the game already started then a warning banner shows', (
      tester,
    ) async {
      await pump(
        tester,
        const JoinState(
          error: 'This game already started. Ask the host to open a new room.',
          errorKind: JoinError.gameStarted,
        ),
      );
      expect(
        find.text(
          'This game already started. Ask the host to open a new room.',
        ),
        findsOneWidget,
      );
    });

    testWidgets('when the nickname is taken then the error sits under it', (
      tester,
    ) async {
      await pump(
        tester,
        const JoinState(
          error: 'That nickname is taken',
          errorKind: JoinError.nicknameTaken,
        ),
      );
      expect(find.text('That nickname is taken'), findsOneWidget);
    });
  });

  group('Given a player comes back from a game', () {
    testWidgets('when they leave the room then the join form is empty again', (
      tester,
    ) async {
      final lobby = MockLobbyRepository();
      final game = MockGameRepository();
      final seats = MockSeatRepository();
      when(() => seats.load()).thenAnswer((_) async => null);
      when(() => seats.save(any())).thenAnswer((_) async {});
      when(() => seats.clear()).thenAnswer((_) async {});
      when(
        () => lobby.joinRoom('4821', 'Opera'),
      ).thenAnswer((_) async => playerSeat);
      final live = StreamController<RoomState>()
        ..add(roomState(players: [player(1, 'Opera')]));
      addTearDown(live.close);
      when(() => game.watchRoom(any())).thenAnswer((_) => live.stream);

      await tester.pumpWidget(
        QuizNightApp(lobby: lobby, game: game, seats: seats),
      );
      await tester.pumpAndSettle();
      await tester.enterText(find.byKey(const Key('join.code')), '4821');
      await tester.enterText(find.byKey(const Key('join.nickname')), 'Opera');
      await tester.tap(find.byKey(const Key('join.submit')));
      await tester.pump(const Duration(seconds: 1));
      await tester.pump(const Duration(seconds: 1));
      expect(find.text("YOU'RE IN!"), findsOneWidget);

      await tester.tap(find.text('Leave'));
      await tester.pump(const Duration(seconds: 1));
      await tester.tap(find.widgetWithText(FilledButton, 'Leave'));
      await tester.pump(const Duration(seconds: 1));
      await tester.pump(const Duration(seconds: 1));

      final code = tester.widget<TextField>(find.byKey(const Key('join.code')));
      final name = tester.widget<TextField>(
        find.byKey(const Key('join.nickname')),
      );
      expect(code.controller!.text, isEmpty);
      expect(name.controller!.text, isEmpty);
    });
  });
}
