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
        const JoinState(error: 'Enter the room code and a nickname'),
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
      setUp: () => when(
        () => lobby.joinRoom(any(), any()),
      ).thenThrow(const AppFailure('That nickname is taken')),
      build: () => JoinCubit(lobby, seats),
      act: (c) => c.join('ABCD', 'Ada'),
      expect: () => [
        const JoinState(submitting: true),
        const JoinState(error: 'That nickname is taken'),
      ],
      verify: (_) => verifyNever(() => seats.save(any())),
    );
  });
}
