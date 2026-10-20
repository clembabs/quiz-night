import 'dart:async';

import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:quiz_night_client/quiz_night_client.dart';
import 'package:quiz_night_flutter/data/app_failure.dart';
import 'package:quiz_night_flutter/features/room/room_cubit.dart';

import '../fakes/fakes.dart';

void main() {
  setUpAll(registerFallbacks);

  late MockGameRepository game;
  late MockSeatRepository seats;
  late List<StreamController<RoomState>> streams;

  setUp(() {
    game = MockGameRepository();
    seats = MockSeatRepository();
    streams = [];
    // Every subscribe gets its own stream, like a fresh WebSocket.
    when(() => game.watchRoom('ABCD')).thenAnswer((_) {
      final c = StreamController<RoomState>();
      streams.add(c);
      return c.stream;
    });
  });

  RoomCubit build({Duration retry = Duration.zero}) => RoomCubit(
    game,
    seats,
    hostSeat,
    backoff: (_) => retry,
    now: () => DateTime.utc(2026, 1, 1, 0, 0, 0),
  );

  group('Given the room stream', () {
    test(
      'when a snapshot arrives then it is connected with that state',
      () async {
        final cubit = build()..start();
        streams.last.add(roomState(players: [player(1, 'Ada')]));
        await pumpEventQueue();

        expect(cubit.state.connection, ConnectionStatus.connected);
        expect(cubit.state.room!.players.single.nickname, 'Ada');
        await cubit.close();
      },
    );

    test(
      'when the server clock is ahead then the offset is recorded',
      () async {
        final cubit = build()..start();
        streams.last.add(
          roomState(serverTime: DateTime.utc(2026, 1, 1, 0, 0, 3)),
        );
        await pumpEventQueue();

        expect(cubit.state.clockOffset, const Duration(seconds: 3));
        await cubit.close();
      },
    );

    test(
      'when the connection drops then it reconnects and gets a fresh snapshot',
      () async {
        final cubit = build()..start();
        streams.last.add(roomState());
        await pumpEventQueue();

        streams.last.addError(AppFailure.connection);
        await pumpEventQueue();
        expect(streams, hasLength(2), reason: 'subscribed again');

        streams.last.add(roomState(players: [player(2, 'Bo')]));
        await pumpEventQueue();
        expect(cubit.state.connection, ConnectionStatus.connected);
        expect(cubit.state.room!.players.single.nickname, 'Bo');
        await cubit.close();
      },
    );

    test(
      'when the stream closes then it shows reconnecting until retried',
      () async {
        final cubit = build(retry: const Duration(hours: 1))..start();
        await streams.last.close();
        await pumpEventQueue();

        expect(cubit.state.connection, ConnectionStatus.reconnecting);
        expect(streams, hasLength(1));
        await cubit.close();
      },
    );

    test('when the room is gone then it stops retrying', () async {
      final cubit = build()..start();
      streams.last.addError(const AppFailure('Room not found', roomGone: true));
      await pumpEventQueue();

      expect(cubit.state.roomGone, isTrue);
      expect(streams, hasLength(1));
      await cubit.close();
    });

    test('when the tab resumes then it resubscribes', () async {
      final cubit = build()..start();
      cubit.reconnect();
      expect(streams, hasLength(2));
      await cubit.close();
    });
  });

  group('Given host actions', () {
    blocTest<RoomCubit, RoomViewState>(
      'when start fails twice with the same message then both are surfaced',
      setUp: () => when(
        () => game.startGame(hostSeat),
      ).thenThrow(const AppFailure('Need at least 2 players')),
      build: build,
      act: (c) async {
        await c.startGame();
        await c.startGame();
      },
      expect: () => [
        isA<RoomViewState>()
            .having((s) => s.actionError, 'error', 'Need at least 2 players')
            .having((s) => s.errorSeq, 'seq', 1),
        isA<RoomViewState>().having((s) => s.errorSeq, 'seq', 2),
      ],
    );

    blocTest<RoomCubit, RoomViewState>(
      'when start succeeds then no error is shown',
      setUp: () =>
          when(() => game.startGame(hostSeat)).thenAnswer((_) async {}),
      build: build,
      act: (c) => c.startGame(),
      expect: () => <RoomViewState>[],
    );
  });

  group('Given the user leaves', () {
    blocTest<RoomCubit, RoomViewState>(
      'when leaving then the saved seat is cleared',
      setUp: () => when(() => seats.clear()).thenAnswer((_) async {}),
      build: build,
      act: (c) => c.leave(),
      expect: () => [isA<RoomViewState>().having((s) => s.left, 'left', true)],
      verify: (_) => verify(() => seats.clear()).called(1),
    );
  });

  group('Given a player seat', () {
    test('when the snapshot includes them then me is their player', () async {
      final cubit = RoomCubit(game, seats, playerSeat)..start();
      streams.last.add(roomState(players: [player(1, 'Ada'), player(2, 'Bo')]));
      await pumpEventQueue();

      expect(cubit.state.me!.nickname, 'Ada');
      await cubit.close();
    });
  });
}
