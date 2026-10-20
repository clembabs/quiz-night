import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:quiz_night_flutter/features/home/home_cubit.dart';

import '../fakes/fakes.dart';

void main() {
  setUpAll(registerFallbacks);

  late MockLobbyRepository lobby;
  late MockSeatRepository seats;

  setUp(() {
    lobby = MockLobbyRepository();
    seats = MockSeatRepository();
    when(() => seats.clear()).thenAnswer((_) async {});
  });

  group('Given no saved seat', () {
    blocTest<HomeCubit, HomeState>(
      'when restoring then shows the plain home screen',
      setUp: () => when(() => seats.load()).thenAnswer((_) async => null),
      build: () => HomeCubit(lobby, seats),
      act: (c) => c.restore(),
      expect: () => [const HomeState(loading: false)],
    );

    blocTest<HomeCubit, HomeState>(
      'when opened from a QR link then goes to the join form with the code',
      setUp: () => when(() => seats.load()).thenAnswer((_) async => null),
      build: () => HomeCubit(lobby, seats, initialCode: 'WXYZ'),
      act: (c) => c.restore(),
      expect: () => [const HomeState(loading: false, route: JoinRoute('WXYZ'))],
    );
  });

  group('Given a saved seat', () {
    setUp(() => when(() => seats.load()).thenAnswer((_) async => playerSeat));

    blocTest<HomeCubit, HomeState>(
      'when it is still valid then offers to rejoin',
      setUp: () => when(
        () => lobby.isSeatValid(playerSeat),
      ).thenAnswer((_) async => true),
      build: () => HomeCubit(lobby, seats),
      act: (c) => c.restore(),
      expect: () => [const HomeState(loading: false, savedSeat: playerSeat)],
    );

    blocTest<HomeCubit, HomeState>(
      'when it is no longer valid then forgets it',
      setUp: () => when(
        () => lobby.isSeatValid(playerSeat),
      ).thenAnswer((_) async => false),
      build: () => HomeCubit(lobby, seats),
      act: (c) => c.restore(),
      expect: () => [const HomeState(loading: false)],
      verify: (_) => verify(() => seats.clear()).called(1),
    );

    blocTest<HomeCubit, HomeState>(
      'when the QR is for the same room then goes straight back in',
      setUp: () => when(
        () => lobby.isSeatValid(playerSeat),
      ).thenAnswer((_) async => true),
      build: () => HomeCubit(lobby, seats, initialCode: 'ABCD'),
      act: (c) => c.restore(),
      expect: () => [
        const HomeState(
          loading: false,
          savedSeat: playerSeat,
          route: RoomRoute(playerSeat),
        ),
      ],
    );

    blocTest<HomeCubit, HomeState>(
      'when the QR is for another room then joins that room instead',
      build: () => HomeCubit(lobby, seats, initialCode: 'WXYZ'),
      act: (c) => c.restore(),
      expect: () => [const HomeState(loading: false, route: JoinRoute('WXYZ'))],
      verify: (_) => verifyNever(() => lobby.isSeatValid(any())),
    );
  });
}
