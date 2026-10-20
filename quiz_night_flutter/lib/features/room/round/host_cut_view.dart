import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:quiz_night_client/quiz_night_client.dart';

import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../widgets/common.dart';
import '../../../widgets/leaderboard_list.dart';
import '../cut_reveal/cut_reveal_scope.dart';
import '../cut_reveal/eliminated_name_tile.dart';
import '../cut_reveal/reveal_sequence_cubit.dart';
import '../room_cubit.dart';
import '../round_logic.dart';
import 'host_step_button.dart';

/// Projector view after a cut: a one-by-one reveal of who goes home, then
/// the survivors, the wildcard and the next step.
class HostCutView extends StatelessWidget {
  final RoomState room;

  /// Overridable for tests.
  final RevealSequenceCubit Function(int total)? createSequence;

  const HostCutView({super.key, required this.room, this.createSequence});

  /// The host may rescue one eliminated player before the final starts.
  static bool canUseWildcard(RoomState room) =>
      !room.wildcardUsed && room.finalQuestionsPlayed == 0;

  @override
  Widget build(BuildContext context) {
    final event = room.lastElimination;
    final byId = {for (final p in room.players) p.id: p};
    final out = [
      for (final id in event?.eliminatedPlayerIds ?? const <int>[]) ?byId[id],
    ];

    return CutRevealScope(
      event: event,
      createCubit: createSequence,
      builder: (context, seq) => CenteredContent(
        maxWidth: AppSpacing.formMaxWidth,
        child: ListView(
          padding: AppSpacing.screenPadding,
          children: [
            Text(
              'ROUND ${room.round} RESULTS',
              style: AppTextStyles.roundLabel,
            ),
            const SizedBox(height: AppSpacing.md),
            if (seq.phase == RevealPhase.intro)
              Text(
                out.isEmpty ? 'Is anyone going home?' : "Who's going home?",
                style: AppTextStyles.revealIntro,
              )
            else
              Text(
                out.isEmpty
                    ? 'Nobody goes home this round'
                    : '${out.length} going home',
                style: AppTextStyles.heading,
              ),
            const SizedBox(height: AppSpacing.xl),
            for (var i = 0; i < seq.revealed && i < out.length; i++)
              EliminatedNameTile(
                key: ValueKey('out.${out[i].id}'),
                nickname: out[i].nickname,
                isBubble: i == out.length - 1 && out.length > 1,
                trailing: seq.isDone && canUseWildcard(room)
                    ? _WildcardButton(player: out[i])
                    : null,
              ),
            if (!seq.isDone)
              Align(
                alignment: Alignment.centerRight,
                child: TextButton(
                  onPressed: context.read<RevealSequenceCubit>().skip,
                  child: const Text('Skip'),
                ),
              )
            else
              ..._results(event),
          ],
        ),
      ),
    );
  }

  List<Widget> _results(EliminationEvent? event) => [
    if (event?.tieBrokenBySpeed ?? false)
      const Padding(
        padding: EdgeInsets.only(bottom: AppSpacing.md),
        child: Text(
          'A tie at the cutoff was broken by answer speed.',
          style: AppTextStyles.caption,
        ),
      ),
    const SizedBox(height: AppSpacing.md),
    Text(
      (event?.finalistsDecided ?? false) ? 'Your finalists' : 'Safe!',
      style: AppTextStyles.heading,
    ),
    const SizedBox(height: AppSpacing.md),
    LeaderboardList(players: leaderboard(room)),
    const SizedBox(height: AppSpacing.xl),
    HostStepButton(room: room),
  ];
}

class _WildcardButton extends StatelessWidget {
  final PlayerView player;

  const _WildcardButton({required this.player});

  Future<void> _confirm(BuildContext context) async {
    final cubit = context.read<RoomCubit>();
    final ok = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Rescue ${player.nickname}?'),
        content: const Text('The wildcard can only be used once per game.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Rescue'),
          ),
        ],
      ),
    );
    if (ok == true) await cubit.useWildcard(player.id);
  }

  @override
  Widget build(BuildContext context) => OutlinedButton.icon(
    key: Key('wildcard.${player.id}'),
    onPressed: () => _confirm(context),
    icon: const Icon(Icons.auto_awesome_rounded),
    label: const Text('Wildcard'),
  );
}
