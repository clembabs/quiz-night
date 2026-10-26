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
import 'package:quiz_night_flutter/data/app_failure.dart';
import 'package:quiz_night_flutter/data/seat.dart';
import 'package:quiz_night_flutter/features/join/join_cubit.dart';
import 'package:quiz_night_flutter/features/join/join_form.dart';
import 'package:quiz_night_flutter/features/landing/widgets/info_sections.dart';

import '../fakes/fakes.dart';

class MockJoinCubit extends MockCubit<JoinState> implements JoinCubit {}

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

    testWidgets('when there is no saved seat then the landing page shows '
        'with both ways in', (tester) async {
      when(() => seats.load()).thenAnswer((_) async => null);
      await tester.pumpWidget(
        QuizNightApp(lobby: lobby, game: game, seats: seats),
      );
      await tester.pumpAndSettle();

      expect(find.text('SURVIVE THE ROUND. WIN THE NIGHT.'), findsOneWidget);
      expect(find.byKey(const Key('landing.code')), findsOneWidget);
      expect(find.byKey(const Key('landing.host')), findsOneWidget);
      expect(find.byKey(const Key('join.code')), findsNothing);
    });

    testWidgets('when a code is typed on the landing page then Join game '
        'opens the join form with it, and the brand returns home', (
      tester,
    ) async {
      when(() => seats.load()).thenAnswer((_) async => null);
      await tester.pumpWidget(
        QuizNightApp(lobby: lobby, game: game, seats: seats),
      );
      await tester.pumpAndSettle();

      await tester.enterText(find.byKey(const Key('landing.code')), '4821');
      await tester.pump();
      await tester.ensureVisible(find.byKey(const Key('landing.join')));
      await tester.tap(find.byKey(const Key('landing.join')));
      await tester.pumpAndSettle();
      final code = tester.widget<TextField>(find.byKey(const Key('join.code')));
      expect(code.controller!.text, '4821');

      await tester.tap(find.byKey(const Key('site.home')));
      await tester.pumpAndSettle();
      expect(find.byKey(const Key('join.code')), findsNothing);
      expect(find.byKey(const Key('landing.code')), findsOneWidget);
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
          initialLocation: '/join?code=4821',
        ),
      );
      await tester.pumpAndSettle();

      final code = tester.widget<TextField>(find.byKey(const Key('join.code')));
      expect(code.controller!.text, '4821');
    });

    testWidgets('when joining fails then the error shows under the field '
        'and as a toast', (tester) async {
      when(() => seats.load()).thenAnswer((_) async => null);
      when(
        () => lobby.joinRoom(any(), any()),
      ).thenAnswer((_) async => throw AppFailure.connection);
      await tester.pumpWidget(
        QuizNightApp(
          lobby: lobby,
          game: game,
          seats: seats,
          initialLocation: '/join?code=4821',
        ),
      );
      await tester.pumpAndSettle();
      await tester.enterText(find.byKey(const Key('join.nickname')), 'Clem');
      await tester.tap(find.byKey(const Key('join.submit')));
      await tester.pumpAndSettle();

      final message = AppFailure.connection.message;
      expect(
        find.descendant(
          of: find.byKey(const Key('toast.error')),
          matching: find.text(message),
        ),
        findsOneWidget,
      );
      expect(find.text(message), findsNWidgets(2));
    });

    testWidgets('when the game already started then the toast is a warning, '
        'like the banner', (tester) async {
      when(() => seats.load()).thenAnswer((_) async => null);
      when(() => lobby.joinRoom(any(), any())).thenAnswer(
        (_) async => throw const AppFailure(
          'Already started',
          kind: FailureKind.gameStarted,
        ),
      );
      await tester.pumpWidget(
        QuizNightApp(
          lobby: lobby,
          game: game,
          seats: seats,
          initialLocation: '/join?code=4821',
        ),
      );
      await tester.pumpAndSettle();
      await tester.enterText(find.byKey(const Key('join.nickname')), 'Clem');
      await tester.tap(find.byKey(const Key('join.submit')));
      await tester.pumpAndSettle();

      expect(find.byKey(const Key('toast.warning')), findsOneWidget);
      expect(find.byKey(const Key('toast.error')), findsNothing);
    });

    testWidgets('when a page is shorter than the window then the footer sits '
        'at the bottom', (tester) async {
      tester.view.physicalSize = const Size(1440, 1600);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.reset);
      when(() => seats.load()).thenAnswer((_) async => null);
      await tester.pumpWidget(
        QuizNightApp(
          lobby: lobby,
          game: game,
          seats: seats,
          initialLocation: '/join',
        ),
      );
      await tester.pumpAndSettle();

      expect(tester.getRect(find.byType(LandingFooter)).bottom, 1600);
    });

    testWidgets('when opened from an old QR link on the home page then it '
        'redirects to the join form with the code', (tester) async {
      when(() => seats.load()).thenAnswer((_) async => null);
      await tester.pumpWidget(
        QuizNightApp(
          lobby: lobby,
          game: game,
          seats: seats,
          initialLocation: '/?code=4821',
        ),
      );
      await tester.pumpAndSettle();

      final code = tester.widget<TextField>(find.byKey(const Key('join.code')));
      expect(code.controller!.text, '4821');
    });

    testWidgets('when Back leads from a live game to its join page then the '
        'game reopens instead of an empty form', (tester) async {
      when(() => seats.load()).thenAnswer((_) async => playerSeat);
      when(() => lobby.isSeatLive(playerSeat)).thenAnswer((_) async => true);
      final live = StreamController<RoomState>()
        ..add(roomState(players: [player(1, 'Ada')]));
      addTearDown(live.close);
      when(() => game.watchRoom('ABCD')).thenAnswer((_) => live.stream);
      await tester.pumpWidget(
        QuizNightApp(
          lobby: lobby,
          game: game,
          seats: seats,
          initialLocation: '/join?code=ABCD',
        ),
      );
      // The resume redirect is async: a few frames to settle the route.
      for (var i = 0; i < 4; i++) {
        await tester.pump(const Duration(seconds: 1));
      }

      expect(find.text("YOU'RE IN!"), findsOneWidget);
      expect(find.byKey(const Key('join.code')), findsNothing);
    });

    testWidgets('when a room address opens without a seat on this device '
        'then it goes to the join form for that room', (tester) async {
      when(() => seats.load()).thenAnswer((_) async => null);
      await tester.pumpWidget(
        QuizNightApp(
          lobby: lobby,
          game: game,
          seats: seats,
          initialLocation: '/room/4821',
        ),
      );
      await tester.pumpAndSettle();

      final code = tester.widget<TextField>(find.byKey(const Key('join.code')));
      expect(code.controller!.text, '4821');
      verifyNever(() => game.watchRoom(any()));
    });

    testWidgets('when a room address is reloaded with this device\'s seat '
        'then the room opens again', (tester) async {
      when(() => seats.load()).thenAnswer((_) async => playerSeat);
      when(() => lobby.isSeatLive(playerSeat)).thenAnswer((_) async => true);
      final live = StreamController<RoomState>()
        ..add(roomState(players: [player(1, 'Ada')]));
      addTearDown(live.close);
      when(() => game.watchRoom('ABCD')).thenAnswer((_) => live.stream);
      await tester.pumpWidget(
        QuizNightApp(
          lobby: lobby,
          game: game,
          seats: seats,
          initialLocation: '/room/ABCD',
        ),
      );
      // The resume redirect is async: a few frames to settle the route.
      for (var i = 0; i < 4; i++) {
        await tester.pump(const Duration(seconds: 1));
      }

      expect(find.text("YOU'RE IN!"), findsOneWidget);
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

      await tester.ensureVisible(find.byKey(const Key('landing.host')));
      await tester.tap(find.byKey(const Key('landing.host')));
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
      // The resume redirect is async: a few frames to settle the route.
      for (var i = 0; i < 4; i++) {
        await tester.pump(const Duration(seconds: 1));
      }

      expect(find.text("YOU'RE IN!"), findsOneWidget);
      expect(find.text('Lobby'), findsOneWidget);
      expect(wakeLock.keepOnCalls, 1, reason: 'screen kept on in a room');
    });
  });

  group('Given the join form', () {
    late MockJoinCubit join;

    setUp(() {
      join = MockJoinCubit();
      when(() => join.join(any(), any())).thenAnswer((_) async {});
    });

    Future<void> pump(WidgetTester tester, JoinState state) async {
      when(() => join.state).thenReturn(state);
      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.dark(),
          home: MultiBlocProvider(
            providers: [
              BlocProvider<JoinCubit>.value(value: join),
            ],
            child: Scaffold(body: JoinForm(onHost: () {})),
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
    testWidgets(
      'when they leave the room then the landing page is back with an empty code',
      (
        tester,
      ) async {
        final lobby = MockLobbyRepository();
        final game = MockGameRepository();
        // Remembers what is saved, like the browser's storage.
        final seats = MockSeatRepository();
        Seat? stored;
        when(() => seats.load()).thenAnswer((_) async => stored);
        when(() => seats.save(any())).thenAnswer(
          (i) async => stored = i.positionalArguments.single as Seat,
        );
        when(() => seats.clear()).thenAnswer((_) async => stored = null);
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
        await tester.enterText(find.byKey(const Key('landing.code')), '4821');
        await tester.pump();
        await tester.ensureVisible(find.byKey(const Key('landing.join')));
        await tester.tap(find.byKey(const Key('landing.join')));
        await tester.pumpAndSettle();
        await tester.enterText(find.byKey(const Key('join.nickname')), 'Opera');
        await tester.tap(find.byKey(const Key('join.submit')));
        for (var i = 0; i < 4; i++) {
          await tester.pump(const Duration(seconds: 1));
        }
        expect(find.text("YOU'RE IN!"), findsOneWidget);

        await tester.tap(find.text('Leave'));
        await tester.pump(const Duration(seconds: 1));
        await tester.tap(find.widgetWithText(FilledButton, 'Leave'));
        await tester.pump(const Duration(seconds: 1));
        await tester.pump(const Duration(seconds: 1));

        // Back on the landing page, with the old code gone.
        final code = tester.widget<TextField>(
          find.byKey(const Key('landing.code')),
        );
        expect(code.controller!.text, isEmpty);
        expect(find.byKey(const Key('join.nickname')), findsNothing);
      },
    );
  });
}
