import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:quiz_night_flutter/data/app_failure.dart';
import 'package:quiz_night_flutter/features/join/join_cubit.dart';

import '../fakes/fakes.dart';

void main() {
  setUpAll(registerFallbacks);

  late MockLobbyRepository lobby;
  late MockSeatRepository seats;

  setUp(() {
    lobby = MockLobbyRepository();
    seats = MockSeatRepository();
    when(() => seats.save(any())).thenAnswer((_) async {});
  });

  group('Given the join form', () {
    blocTest<JoinCubit, JoinState>(
      'when code or nickname is blank then shows an error without calling the server',
      build: () => JoinCubit(lobby, seats),
      act: (c) => c.join('  ', 'Ada'),
      expect: () => [
        const JoinState(
          error: 'Enter the room code and a nickname',
          errorKind: JoinError.missingFields,
        ),
      ],
      verify: (_) => verifyNever(() => lobby.joinRoom(any(), any())),
    );

    blocTest<JoinCubit, JoinState>(
      'when joining succeeds then trims and upper-cases input, saves the seat',
      setUp: () => when(
        () => lobby.joinRoom('ABCD', 'Ada'),
      ).thenAnswer((_) async => playerSeat),
      build: () => JoinCubit(lobby, seats),
      act: (c) => c.join(' abcd ', ' Ada '),
      expect: () => [
        const JoinState(submitting: true),
        const JoinState(seat: playerSeat),
      ],
      verify: (_) => verify(() => seats.save(playerSeat)).called(1),
    );

    blocTest<JoinCubit, JoinState>(
      'when the server rejects the nickname then shows its message',
      setUp: () =>
          when(
            () => lobby.joinRoom(any(), any()),
          ).thenThrow(
            const AppFailure(
              'That nickname is taken',
              kind: FailureKind.nicknameTaken,
            ),
          ),
      build: () => JoinCubit(lobby, seats),
      act: (c) => c.join('ABCD', 'Ada'),
      expect: () => [
        const JoinState(submitting: true),
        const JoinState(
          error: 'That nickname is taken',
          errorKind: JoinError.nicknameTaken,
        ),
      ],
      verify: (_) => verifyNever(() => seats.save(any())),
    );

    blocTest<JoinCubit, JoinState>(
      'when the room is full then says so, as a room problem',
      setUp: () => when(() => lobby.joinRoom(any(), any())).thenThrow(
        const AppFailure(
          'This room is full (20 players). Ask the host for another room.',
          kind: FailureKind.roomFull,
        ),
      ),
      build: () => JoinCubit(lobby, seats),
      act: (c) => c.join('4821', 'Ada'),
      expect: () => [
        const JoinState(submitting: true),
        const JoinState(
          error:
              'This room is full (20 players). Ask the host for another room.',
          errorKind: JoinError.roomFull,
        ),
      ],
    );

    blocTest<JoinCubit, JoinState>(
      'when the room is locked then says so, as a room problem',
      setUp: () => when(() => lobby.joinRoom(any(), any())).thenThrow(
        const AppFailure(
          'The host has locked this room. Ask them to unlock it.',
          kind: FailureKind.roomLocked,
        ),
      ),
      build: () => JoinCubit(lobby, seats),
      act: (c) => c.join('4821', 'Ada'),
      expect: () => [
        const JoinState(submitting: true),
        const JoinState(
          error: 'The host has locked this room. Ask them to unlock it.',
          errorKind: JoinError.roomLocked,
        ),
      ],
    );

    blocTest<JoinCubit, JoinState>(
      'when the code is unknown then says to check the big screen',
      setUp: () => when(() => lobby.joinRoom(any(), any())).thenThrow(
        const AppFailure('Room not found', kind: FailureKind.roomGone),
      ),
      build: () => JoinCubit(lobby, seats),
      act: (c) => c.join('9999', 'Ada'),
      skip: 1,
      expect: () => [
        const JoinState(
          error:
              "This game session doesn't exist. Check the code on the big screen.",
          errorKind: JoinError.roomNotFound,
        ),
      ],
    );

    blocTest<JoinCubit, JoinState>(
      'when the game already started then says to ask for a new room',
      setUp: () => when(() => lobby.joinRoom(any(), any())).thenThrow(
        const AppFailure('started', kind: FailureKind.gameStarted),
      ),
      build: () => JoinCubit(lobby, seats),
      act: (c) => c.join('4821', 'Ada'),
      skip: 1,
      expect: () => [
        const JoinState(
          error: 'This game already started. Ask the host to open a new room.',
          errorKind: JoinError.gameStarted,
        ),
      ],
    );
  });
}
