import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:quiz_night_client/quiz_night_client.dart';

import 'reveal_sequence_cubit.dart';

/// Starts a fresh [RevealSequenceCubit] for each cut and rebuilds [builder]
/// as names are revealed.
class CutRevealScope extends StatelessWidget {
  final EliminationEvent? event;
  final Widget Function(BuildContext context, RevealSequenceState sequence)
  builder;

  /// Overridable for tests.
  final RevealSequenceCubit Function(int total)? createCubit;

  const CutRevealScope({
    super.key,
    required this.event,
    required this.builder,
    this.createCubit,
  });

  @override
  Widget build(BuildContext context) {
    final total = event?.eliminatedPlayerIds.length ?? 0;
    return BlocProvider(
      // A new cut (or a reconnect into one) restarts the sequence.
      key: ValueKey('cut-${event?.round}-${event?.eliminatedPlayerIds}'),
      create: (_) =>
          (createCubit?.call(total) ?? RevealSequenceCubit(total: total))
            ..start(),
      child: BlocBuilder<RevealSequenceCubit, RevealSequenceState>(
        builder: builder,
      ),
    );
  }
}

/// Whether this player's fate is visible yet in the [sequence].
bool fateRevealed({
  required EliminationEvent? event,
  required int? myId,
  required RevealSequenceState sequence,
}) {
  if (sequence.isDone) return true;
  final index = event?.eliminatedPlayerIds.indexOf(myId ?? -1) ?? -1;
  return index >= 0 && index < sequence.revealed;
}
