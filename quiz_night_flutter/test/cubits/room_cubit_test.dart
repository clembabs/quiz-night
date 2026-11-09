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
    when(
      () => game.watchRoom('ABCD', hostToken: any(named: 'hostToken')),
    ).thenAnswer((_) {
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
      streams.last.addError(
        const AppFailure('Room not found', kind: FailureKind.roomGone),
      );
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
      'when the host stops hosting then the game ends for everyone and the '
      'seat is cleared',
      setUp: () {
        when(() => seats.clear()).thenAnswer((_) async {});
        when(() => game.endGame(hostSeat)).thenAnswer((_) async {});
      },
      build: build,
      act: (c) => c.leave(),
      expect: () => [isA<RoomViewState>().having((s) => s.left, 'left', true)],
      verify: (_) {
        verify(() => seats.clear()).called(1);
        verify(() => game.endGame(hostSeat)).called(1);
        verifyNever(() => game.leaveRoom(any()));
      },
    );

    test(
      'when the host leaves a finished game then nothing is ended',
      () async {
        when(() => seats.clear()).thenAnswer((_) async {});
        final cubit = build()..start();
        streams.last.add(roomState(status: RoomStatus.finished));
        await pumpEventQueue();
        await cubit.leave();
        verifyNever(() => game.endGame(any()));
        expect(cubit.state.left, isTrue);
        await cubit.close();
      },
    );

    test('when the host is watching then it opens the host stream, so the '
        'server knows the host is there', () async {
      final cubit = build()..start();
      await pumpEventQueue();
      verify(() => game.watchRoom('ABCD', hostToken: 'host-token')).called(1);
      await cubit.close();
    });

    test('when a player is watching then it opens the plain stream', () async {
      final cubit = RoomCubit(game, seats, playerSeat)..start();
      await pumpEventQueue();
      verify(() => game.watchRoom('ABCD', hostToken: null)).called(1);
      await cubit.close();
    });

    blocTest<RoomCubit, RoomViewState>(
      'when a player leaves then the server is told, and they leave even '
      'when it cannot be reached',
      setUp: () {
        when(() => seats.clear()).thenAnswer((_) async {});
        when(
          () => game.leaveRoom(playerSeat),
        ).thenThrow(const AppFailure('Could not reach the server'));
      },
      build: () => RoomCubit(game, seats, playerSeat),
      act: (c) => c.leave(),
      expect: () => [isA<RoomViewState>().having((s) => s.left, 'left', true)],
      verify: (_) {
        verify(() => game.leaveRoom(playerSeat)).called(1);
        verify(() => seats.clear()).called(1);
      },
    );
  });

  group('Given a player seat', () {
    test('when the snapshot includes them then me is their player', () async {
      final cubit = RoomCubit(game, seats, playerSeat)..start();
      streams.last.add(roomState(players: [player(1, 'Ada'), player(2, 'Bo')]));
      await pumpEventQueue();

      expect(cubit.state.me!.nickname, 'Ada');
      expect(cubit.state.removedByHost, isFalse);
      await cubit.close();
    });

    test('when a snapshot no longer includes them then they were removed by '
        'the host', () async {
      final cubit = RoomCubit(game, seats, playerSeat)..start();
      streams.last.add(roomState(players: [player(1, 'Ada'), player(2, 'Bo')]));
      await pumpEventQueue();
      streams.last.add(roomState(players: [player(2, 'Bo')]));
      await pumpEventQueue();

      expect(cubit.state.removedByHost, isTrue);
      await cubit.close();
    });
  });

  group('Given the host removes a player', () {
    test(
      'when it succeeds then the repository is asked with the host seat',
      () async {
        when(() => game.removePlayer(hostSeat, 2)).thenAnswer((_) async {});
        final cubit = build()..start();
        await cubit.removePlayer(2);
        verify(() => game.removePlayer(hostSeat, 2)).called(1);
        expect(
          cubit.state.removedByHost,
          isFalse,
          reason: 'hosts are never removed',
        );
        await cubit.close();
      },
    );
  });

  group('Given round host actions', () {
    setUp(() {
      when(() => game.nextQuestion(hostSeat)).thenAnswer((_) async {});
      when(() => game.reveal(hostSeat)).thenAnswer((_) async {});
      when(() => game.endRound(hostSeat)).thenAnswer((_) async {});
    });

    test('when the host advances, reveals and ends a round then each '
        'reaches the server with the host seat', () async {
      final cubit = build();
      await cubit.nextQuestion();
      await cubit.reveal();
      await cubit.endRound();

      verify(() => game.nextQuestion(hostSeat)).called(1);
      verify(() => game.reveal(hostSeat)).called(1);
      verify(() => game.endRound(hostSeat)).called(1);
      await cubit.close();
    });
  });

  group('Given an open question for a player', () {
    late RoomCubit cubit;

    Future<RoomCubit> openQuestion({
      RoomStatus status = RoomStatus.question,
    }) async {
      final c = RoomCubit(
        game,
        seats,
        playerSeat,
        backoff: (_) => Duration.zero,
        answerRetryDelay: Duration.zero,
      )..start();
      streams.last.add(
        roomState(
          status: status,
          question: question(id: 10),
          players: [player(1, 'Ada')],
        ),
      );
      await pumpEventQueue();
      return c;
    }

    tearDown(() => cubit.close());

    test('when tapping an option then it is locked in and sent', () async {
      when(() => game.submitAnswer(playerSeat, 10, 2)).thenAnswer((_) async {});
      cubit = await openQuestion();

      await cubit.submitAnswer(2);

      expect(cubit.state.myChoice, 2);
      verify(() => game.submitAnswer(playerSeat, 10, 2)).called(1);
    });

    test('when tapping again then the second tap is ignored', () async {
      when(
        () => game.submitAnswer(any(), any(), any()),
      ).thenAnswer((_) async {});
      cubit = await openQuestion();

      await cubit.submitAnswer(2);
      await cubit.submitAnswer(3);

      expect(cubit.state.myChoice, 2);
      verify(() => game.submitAnswer(playerSeat, 10, 2)).called(1);
      verifyNever(() => game.submitAnswer(playerSeat, 10, 3));
    });

    test('when the answer arrives too late then the pick is undone '
        'and the reason shown', () async {
      when(() => game.submitAnswer(any(), any(), any())).thenThrow(
        const AppFailure('Time is up', kind: FailureKind.tooLate),
      );
      cubit = await openQuestion();

      await cubit.submitAnswer(1);

      expect(cubit.state.myChoice, isNull);
      expect(cubit.state.actionError, 'Time is up');
    });

    test('when the connection blips then the answer is resent once', () async {
      var calls = 0;
      when(() => game.submitAnswer(playerSeat, 10, 2)).thenAnswer((_) async {
        if (calls++ == 0) throw AppFailure.connection;
      });
      cubit = await openQuestion();

      await cubit.submitAnswer(2);

      expect(calls, 2);
      expect(cubit.state.myChoice, 2);
      expect(cubit.state.errorSeq, 0);
    });

    test(
      'when the first attempt did arrive then the retry keeps the pick',
      () async {
        var calls = 0;
        when(() => game.submitAnswer(any(), any(), any())).thenAnswer((
          _,
        ) async {
          if (calls++ == 0) throw AppFailure.connection;
          throw const AppFailure(
            'Already answered',
            kind: FailureKind.alreadyAnswered,
          );
        });
        cubit = await openQuestion();

        await cubit.submitAnswer(2);

        expect(cubit.state.myChoice, 2);
        expect(cubit.state.errorSeq, 0);
      },
    );

    test(
      'when still offline after the retry then the pick is undone',
      () async {
        when(
          () => game.submitAnswer(any(), any(), any()),
        ).thenThrow(AppFailure.connection);
        cubit = await openQuestion();

        await cubit.submitAnswer(2);

        verify(() => game.submitAnswer(playerSeat, 10, 2)).called(2);
        expect(cubit.state.myChoice, isNull);
        expect(cubit.state.actionError, AppFailure.connection.message);
      },
    );

    test('when the server already has an answer then the pick stays', () async {
      when(() => game.submitAnswer(any(), any(), any())).thenThrow(
        const AppFailure('Already answered', kind: FailureKind.alreadyAnswered),
      );
      cubit = await openQuestion();

      await cubit.submitAnswer(1);

      expect(cubit.state.myChoice, 1);
      expect(cubit.state.errorSeq, 0);
    });

    test(
      'when the question is already revealed then nothing is sent',
      () async {
        cubit = await openQuestion(status: RoomStatus.reveal);

        await cubit.submitAnswer(1);

        expect(cubit.state.myChoice, isNull);
        verifyNever(() => game.submitAnswer(any(), any(), any()));
      },
    );
  });

  group('Given the host seat', () {
    test('when asked to submit an answer then nothing is sent', () async {
      final cubit = build()..start();
      streams.last.add(
        roomState(status: RoomStatus.question, question: question()),
      );
      await pumpEventQueue();

      await cubit.submitAnswer(0);

      verifyNever(() => game.submitAnswer(any(), any(), any()));
      await cubit.close();
    });
  });

  group('Given a spectator backing a finalist', () {
    const spectator = playerSeat;

    test('when backing then the pick shows at once and is sent', () async {
      when(() => game.backFinalist(spectator, 5)).thenAnswer((_) async {});
      final cubit = RoomCubit(game, seats, spectator);

      await cubit.backFinalist(5);

      expect(cubit.state.myBackedId, 5);
      verify(() => game.backFinalist(spectator, 5)).called(1);
      await cubit.close();
    });

    test(
      'when changing their mind then the new pick replaces the old',
      () async {
        when(() => game.backFinalist(any(), any())).thenAnswer((_) async {});
        final cubit = RoomCubit(game, seats, spectator);

        await cubit.backFinalist(5);
        await cubit.backFinalist(6);

        expect(cubit.state.myBackedId, 6);
        await cubit.close();
      },
    );

    test('when the server refuses then the previous pick comes back', () async {
      final cubit = RoomCubit(game, seats, spectator);
      when(() => game.backFinalist(spectator, 5)).thenAnswer((_) async {});
      await cubit.backFinalist(5);
      when(
        () => game.backFinalist(spectator, 6),
      ).thenThrow(const AppFailure('The final has started'));

      await cubit.backFinalist(6);

      expect(cubit.state.myBackedId, 5);
      expect(cubit.state.actionError, 'The final has started');
      await cubit.close();
    });
  });

  group('Given the host uses the wildcard', () {
    test('when rescuing a player then the server is asked', () async {
      when(() => game.useWildcard(hostSeat, 3)).thenAnswer((_) async {});
      final cubit = build();

      await cubit.useWildcard(3);

      verify(() => game.useWildcard(hostSeat, 3)).called(1);
      await cubit.close();
    });

    test(
      'when the host tries to back a finalist then nothing is sent',
      () async {
        final cubit = build();
        await cubit.backFinalist(5);
        verifyNever(() => game.backFinalist(any(), any()));
        await cubit.close();
      },
    );
  });

  group('Given the buzzer final on a finalist phone', () {
    Future<RoomCubit> finalRoom({
      PlayerStatus status = PlayerStatus.finalist,
      bool lockedOut = false,
      int? holder,
      RoomStatus roomStatus = RoomStatus.buzzerFinal,
    }) async {
      final c = RoomCubit(
        game,
        seats,
        playerSeat,
        backoff: (_) => Duration.zero,
      )..start();
      streams.last.add(
        roomState(
          status: roomStatus,
          question: question(id: 20, isFinal: true),
          buzzerHolderId: holder,
          players: [
            player(1, 'Ada', status: status, lockedOut: lockedOut),
            player(2, 'Bo', status: PlayerStatus.finalist),
          ],
        ),
      );
      await pumpEventQueue();
      return c;
    }

    test(
      'when buzzing then the server is asked once, even on a double tap',
      () async {
        final reply = Completer<BuzzResult>();
        when(() => game.buzz(playerSeat, 20)).thenAnswer((_) => reply.future);
        final cubit = await finalRoom();

        final first = cubit.buzz();
        expect(cubit.state.buzzing, isTrue);
        await cubit.buzz();
        reply.complete(BuzzResult(gotBuzzer: true));
        await first;

        verify(() => game.buzz(playerSeat, 20)).called(1);
        expect(cubit.state.buzzing, isFalse);
        expect(cubit.state.errorSeq, 0);
        await cubit.close();
      },
    );

    test('when someone beat them to it then the reason is shown', () async {
      when(
        () => game.buzz(any(), any()),
      ).thenAnswer(
        (_) async => BuzzResult(gotBuzzer: false, reason: 'Too slow'),
      );
      final cubit = await finalRoom();

      await cubit.buzz();

      expect(cubit.state.actionError, 'Too slow');
      expect(cubit.state.buzzing, isFalse);
      await cubit.close();
    });

    for (final (name, make) in [
      ('a spectator', () => finalRoom(status: PlayerStatus.eliminated)),
      ('a locked-out finalist', () => finalRoom(lockedOut: true)),
      ('anyone while another holds it', () => finalRoom(holder: 2)),
      (
        'anyone after the reveal',
        () => finalRoom(roomStatus: RoomStatus.reveal),
      ),
    ]) {
      test('when $name buzzes then nothing is sent', () async {
        final cubit = await make();
        await cubit.buzz();
        verifyNever(() => game.buzz(any(), any()));
        await cubit.close();
      });
    }

    test('when holding the buzzer then the answer is sent and shown', () async {
      when(
        () => game.submitBuzzAnswer(playerSeat, 20, 1),
      ).thenAnswer((_) async => true);
      final cubit = await finalRoom(holder: 1);

      await cubit.submitBuzzAnswer(1);

      expect(cubit.state.myChoice, 1);
      verify(() => game.submitBuzzAnswer(playerSeat, 20, 1)).called(1);
      await cubit.close();
    });

    test('when not holding the buzzer then an answer is not sent', () async {
      final cubit = await finalRoom(holder: 2);
      await cubit.submitBuzzAnswer(1);
      verifyNever(() => game.submitBuzzAnswer(any(), any(), any()));
      await cubit.close();
    });

    test('when the buzz answer fails then the pick is undone', () async {
      when(
        () => game.submitBuzzAnswer(any(), any(), any()),
      ).thenThrow(const AppFailure('You do not hold the buzzer'));
      final cubit = await finalRoom(holder: 1);

      await cubit.submitBuzzAnswer(1);

      expect(cubit.state.myChoice, isNull);
      expect(cubit.state.actionError, 'You do not hold the buzzer');
      await cubit.close();
    });
  });

  group('Given the redesign state on the RoomCubit', () {
    RoomState reveal(int qid, List<PlayerView> players) => roomState(
      status: RoomStatus.reveal,
      question: question(id: qid, revealed: true),
      players: players,
    );

    test('when two reveals come in then rank movement is measured between '
        'them', () async {
      final cubit = build()..start();
      streams.last.add(
        reveal(1, [player(1, 'Ada', score: 900), player(2, 'Bo', score: 500)]),
      );
      await pumpEventQueue();
      expect(cubit.state.rankMoves, isEmpty, reason: 'first reveal');

      streams.last.add(
        reveal(2, [player(1, 'Ada', score: 900), player(2, 'Bo', score: 1500)]),
      );
      await pumpEventQueue();
      expect(cubit.state.rankMoves, {2: 1, 1: -1});
      await cubit.close();
    });

    test('when the same reveal is re-sent then movement is kept', () async {
      final cubit = build()..start();
      final players = [
        player(1, 'Ada', score: 900),
        player(2, 'Bo', score: 500),
      ];
      streams.last.add(reveal(1, players));
      await pumpEventQueue();
      streams.last.add(reveal(2, players.reversed.toList()));
      await pumpEventQueue();
      final moves = cubit.state.rankMoves;
      streams.last.add(reveal(2, players));
      await pumpEventQueue();
      expect(cubit.state.rankMoves, moves);
      await cubit.close();
    });

    test('when the host shows standings then it stays up until the room '
        'moves on', () async {
      final cubit = build()..start();
      streams.last.add(reveal(1, [player(1, 'Ada')]));
      await pumpEventQueue();

      cubit.showStandings();
      expect(cubit.state.showingStandings, isTrue);

      streams.last.add(
        roomState(status: RoomStatus.elimination, lastElimination: cut()),
      );
      await pumpEventQueue();
      expect(cubit.state.showingStandings, isFalse);
      await cubit.close();
    });

    test('when a player asks for standings then nothing changes', () async {
      final cubit = RoomCubit(game, seats, playerSeat)..start();
      streams.last.add(reveal(1, [player(1, 'Ada')]));
      await pumpEventQueue();
      cubit.showStandings();
      expect(cubit.state.showingStandings, isFalse);
      await cubit.close();
    });

    test('when an eliminated player keeps watching then it lasts for this '
        'cut only', () async {
      final cubit = RoomCubit(game, seats, playerSeat)..start();
      streams.last.add(
        roomState(status: RoomStatus.elimination, lastElimination: cut()),
      );
      await pumpEventQueue();
      cubit.keepWatchingAsSpectator();
      expect(cubit.state.keepWatching, isTrue);

      streams.last.add(
        roomState(status: RoomStatus.question, question: question()),
      );
      await pumpEventQueue();
      expect(cubit.state.keepWatching, isFalse);
      await cubit.close();
    });
  });
}
