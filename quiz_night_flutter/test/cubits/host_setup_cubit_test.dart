import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:quiz_night_client/quiz_night_client.dart';
import 'package:quiz_night_flutter/data/app_failure.dart';
import 'package:quiz_night_flutter/features/host_setup/host_setup_cubit.dart';

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

  group('Given host settings', () {
    blocTest<HostSetupCubit, HostSetupState>(
      'when values go out of range then they are clamped',
      build: () => HostSetupCubit(lobby, seats),
      act: (c) => c
        ..setFinalists(99)
        ..setQuestionsPerRound(0)
        ..setSecondsPerQuestion(5),
      verify: (c) {
        expect(c.state.finalists, HostSetupLimits.finalists.max);
        expect(
          c.state.questionsPerRound,
          HostSetupLimits.questionsPerRound.min,
        );
        expect(c.state.secondsPerQuestion, HostSetupLimits.seconds.min);
      },
    );

    blocTest<HostSetupCubit, HostSetupState>(
      'when creating then sends the chosen config and saves the host seat',
      setUp: () =>
          when(() => lobby.createRoom(any())).thenAnswer((_) async => hostSeat),
      build: () => HostSetupCubit(lobby, seats),
      act: (c) async {
        c
          ..setRule(EliminationRule.autoScaled)
          ..setFinalists(4)
          ..setRoundsBeforeFinal(2);
        await c.create();
      },
      verify: (c) {
        final config =
            verify(() => lobby.createRoom(captureAny())).captured.single
                as RoomConfig;
        expect(config.eliminationRule, EliminationRule.autoScaled);
        expect(config.finalistTarget, 4);
        expect(config.roundsBeforeFinal, 2);
        verify(() => seats.save(hostSeat)).called(1);
        expect(c.state.seat, hostSeat);
        expect(c.state.submitting, isFalse);
      },
    );

    blocTest<HostSetupCubit, HostSetupState>(
      'when the server is unreachable then shows an error and keeps settings',
      setUp: () =>
          when(() => lobby.createRoom(any())).thenThrow(AppFailure.connection),
      build: () => HostSetupCubit(lobby, seats),
      act: (c) async {
        c.setFinalists(4);
        await c.create();
      },
      verify: (c) {
        expect(c.state.error, AppFailure.connection.message);
        expect(c.state.finalists, 4);
        expect(c.state.seat, isNull);
      },
    );
  });
}
