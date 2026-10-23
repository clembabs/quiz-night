import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:quiz_night_flutter/features/room/room_gate.dart';

import '../fakes/fakes.dart';

void main() {
  late MockSeatRepository seats;

  setUp(() => seats = MockSeatRepository());

  group('Given a room address', () {
    blocTest<RoomGateCubit, RoomGateState>(
      'when this device saved a seat for it then it is ready',
      setUp: () => when(() => seats.load()).thenAnswer((_) async => playerSeat),
      build: () => RoomGateCubit(seats, 'ABCD'),
      act: (c) => c.load(),
      expect: () => [const RoomGateState.ready(playerSeat)],
    );

    blocTest<RoomGateCubit, RoomGateState>(
      'when the saved seat is for another room then there is no seat',
      setUp: () => when(() => seats.load()).thenAnswer((_) async => playerSeat),
      build: () => RoomGateCubit(seats, '4821'),
      act: (c) => c.load(),
      expect: () => [const RoomGateState.noSeat()],
    );
  });
}
