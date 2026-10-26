import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:quiz_night_client/quiz_night_client.dart';

import '../../../widgets/qn/host_stage.dart';
import '../room_cubit.dart';
import '../round_logic.dart';

/// The host's single "what next" button, driven by [hostStepFor].
class HostStepButton extends StatelessWidget {
  final RoomState room;
  final double height;

  const HostStepButton({super.key, required this.room, this.height = 96});

  static String labelFor(HostStep step) => switch (step) {
    HostStep.startGame => 'Start game',
    HostStep.reveal => 'Reveal now',
    HostStep.nextQuestion => 'Next question',
    HostStep.showStandings => 'Show standings',
    HostStep.endRound => 'Run the cut',
    HostStep.nextRound => 'Next round',
    HostStep.startFinal => 'Start the final',
    HostStep.showPodium => 'Show the podium',
    HostStep.none => '',
  };

  @override
  Widget build(BuildContext context) {
    final step = hostStepFor(
      room,
      showingStandings: context.select(
        (RoomCubit c) => c.state.showingStandings,
      ),
    );
    if (step == HostStep.none) return const SizedBox.shrink();
    final cubit = context.read<RoomCubit>();
    final Future<void> Function() action = switch (step) {
      HostStep.startGame => cubit.startGame,
      HostStep.reveal => cubit.reveal,
      HostStep.showStandings => () async => cubit.showStandings(),
      HostStep.endRound => cubit.endRound,
      // The server knows whether "next" means a question, a round or the final.
      HostStep.nextQuestion ||
      HostStep.nextRound ||
      HostStep.startFinal ||
      HostStep.showPodium => cubit.nextQuestion,
      HostStep.none => () async {},
    };
    return HostButton(
      buttonKey: const Key('host.step'),
      label: labelFor(step),
      onPressed: action,
      height: height,
    );
  }
}
