import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:quiz_night_client/quiz_night_client.dart';
import 'package:quiz_night_flutter/app/quiz_night_app.dart';
import 'package:quiz_night_flutter/data/seat.dart';
import 'package:quiz_night_flutter/widgets/qn/notices.dart';

import '../fakes/fakes.dart';

void main() {
  setUpAll(registerFallbacks);

  /// The app opened on `/` by a player with a seat in a live game.
  Future<StreamController<RoomState>> openAsPlayer(WidgetTester t) async {
    t.view.physicalSize = const Size(390, 844);
    t.view.devicePixelRatio = 1;
    addTearDown(t.view.reset);
    final lobby = MockLobbyRepository();
    final game = MockGameRepository();
    final seats = MockSeatRepository();
    Seat? stored = playerSeat;
    when(() => seats.load()).thenAnswer((_) async => stored);
    when(() => seats.clear()).thenAnswer((_) async => stored = null);
    // Live until the clear: the dead seat no longer pulls them back.
    when(() => lobby.isSeatLive(any())).thenAnswer((_) async => stored != null);
    when(() => game.leaveRoom(any())).thenAnswer((_) async {});
    final live = StreamController<RoomState>();
    addTearDown(live.close);
    when(
      () => game.watchRoom(any(), hostToken: any(named: 'hostToken')),
    ).thenAnswer((_) => live.stream);
    await t.pumpWidget(QuizNightApp(lobby: lobby, game: game, seats: seats));
    await t.pump();
    return live;
  }

  testWidgets('Given a player in the lobby when the host disconnects then '
      'they see the countdown, and when it ends then THE HOST LEFT with a '
      'way home', (t) async {
    final live = await openAsPlayer(t);
    final now = DateTime.now().toUtc();
    final me = player(1, 'Opera');
    live.add(roomState(players: [me], serverTime: now));
    for (var i = 0; i < 3; i++) {
      await t.pump(const Duration(milliseconds: 300));
    }
    expect(find.text("YOU'RE IN!"), findsOneWidget);
    expect(find.byKey(const Key('hostAway')), findsNothing);

    live.add(
      roomState(players: [me], serverTime: now).copyWith(
        hostAwayUntil: now.add(const Duration(seconds: 30)),
      ),
    );
    await t.pump(const Duration(milliseconds: 300));
    expect(find.byKey(const Key('hostAway')), findsOneWidget);
    expect(find.text('THE HOST DISCONNECTED'), findsOneWidget);

    // Not back in time: the server ends it.
    live.add(
      roomState(
        status: RoomStatus.finished,
        players: [me],
        serverTime: now,
      ).copyWith(endReason: RoomEndReason.hostLeft),
    );
    await t.pump(const Duration(milliseconds: 300));
    expect(find.byKey(const Key('hostAway')), findsNothing);
    expect(find.text('THE HOST LEFT'), findsOneWidget);

    await t.tap(find.byKey(const Key('room.home')));
    for (var i = 0; i < 4; i++) {
      await t.pump(const Duration(milliseconds: 300));
    }
    // The home page, not the old room.
    expect(find.byKey(const Key('landing.code')), findsOneWidget);
    expect(find.text('THE HOST LEFT'), findsNothing);
  });

  testWidgets('Given a game the host left mid-way when the phone shows the '
      'results then it says why and offers the way home', (t) async {
    final live = await openAsPlayer(t);
    live.add(
      roomState(
        status: RoomStatus.finished,
        round: 2,
        players: [player(1, 'Opera', score: 1200), player(8, 'Bo')],
      ).copyWith(endReason: RoomEndReason.hostLeft),
    );
    for (var i = 0; i < 6; i++) {
      await t.pump(const Duration(milliseconds: 500));
    }
    expect(find.textContaining('The host left'), findsWidgets);
    expect(find.byKey(const Key('placement.home')), findsOneWidget);
  });

  test('Given the countdown when time passes then the seconds go down, and '
      'stop at zero', () {
    final until = DateTime.utc(2026, 1, 1, 0, 0, 30);
    expect(
      HostAwayCard.secondsLeft(until, Duration.zero, DateTime.utc(2026)),
      30,
    );
    expect(
      HostAwayCard.secondsLeft(
        until,
        Duration.zero,
        DateTime.utc(2026, 1, 1, 0, 0, 29, 500),
      ),
      1,
    );
    expect(
      HostAwayCard.secondsLeft(
        until,
        Duration.zero,
        DateTime.utc(2026, 1, 1, 0, 1),
      ),
      0,
    );
    // The server is 5 s ahead of this phone.
    expect(
      HostAwayCard.secondsLeft(
        until,
        const Duration(seconds: 5),
        DateTime.utc(2026),
      ),
      25,
    );
  });
}
