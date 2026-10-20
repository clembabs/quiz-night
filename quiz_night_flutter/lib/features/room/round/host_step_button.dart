import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:quiz_night_client/quiz_night_client.dart';

import '../room_cubit.dart';
import '../round_logic.dart';

/// The host's single "what next" button, driven by [hostStepFor].
class HostStepButton extends StatelessWidget {
  final RoomState room;

  const HostStepButton({super.key, required this.room});

  static String labelFor(HostStep step) => switch (step) {
    HostStep.startGame => 'Start the game',
    HostStep.reveal => 'Reveal now',
    HostStep.nextQuestion => 'Next question',
    HostStep.endRound => 'End round',
    HostStep.nextRound => 'Next round',
    HostStep.startFinal => 'Start the final',
    HostStep.showPodium => 'Show the podium',
    HostStep.none => '',
  };

  static IconData iconFor(HostStep step) => switch (step) {
    HostStep.reveal => Icons.visibility_rounded,
    HostStep.endRound => Icons.content_cut_rounded,
    HostStep.startFinal || HostStep.showPodium => Icons.emoji_events_rounded,
    _ => Icons.arrow_forward_rounded,
  };

  @override
  Widget build(BuildContext context) {
    final step = hostStepFor(room);
    if (step == HostStep.none) return const SizedBox.shrink();
    final cubit = context.read<RoomCubit>();
    final Future<void> Function() action = switch (step) {
      HostStep.startGame => cubit.startGame,
      HostStep.reveal => cubit.reveal,
      HostStep.endRound => cubit.endRound,
      // The server knows whether "next" means a question, a round or the final.
      HostStep.nextQuestion ||
      HostStep.nextRound ||
      HostStep.startFinal ||
      HostStep.showPodium => cubit.nextQuestion,
      HostStep.none => () async {},
    };
    return FilledButton.icon(
      key: const Key('host.step'),
      onPressed: action,
      icon: Icon(iconFor(step)),
      label: Text(labelFor(step)),
    );
  }
}
