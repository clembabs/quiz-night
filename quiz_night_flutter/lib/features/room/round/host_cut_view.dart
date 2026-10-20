import 'package:flutter/material.dart';
import 'package:quiz_night_client/quiz_night_client.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../widgets/common.dart';
import '../../../widgets/leaderboard_list.dart';
import '../round_logic.dart';
import 'host_step_button.dart';

/// Projector view after a cut: who went out, who is left.
///
/// Milestone 5 replaces the plain list with a one-by-one reveal.
class HostCutView extends StatelessWidget {
  final RoomState room;

  const HostCutView({super.key, required this.room});

  @override
  Widget build(BuildContext context) {
    final event = room.lastElimination;
    final byId = {for (final p in room.players) p.id: p};
    final out = [
      for (final id in event?.eliminatedPlayerIds ?? const <int>[])
        if (byId[id] != null) byId[id]!,
    ];
    final finalists = event?.finalistsDecided ?? false;

    return CenteredContent(
      maxWidth: AppSpacing.formMaxWidth,
      child: ListView(
        padding: AppSpacing.screenPadding,
        children: [
          Text('ROUND ${room.round} RESULTS', style: AppTextStyles.roundLabel),
          const SizedBox(height: AppSpacing.md),
          Text(
            out.isEmpty
                ? 'Nobody goes home this round'
                : '${out.length} going home',
            style: AppTextStyles.heading,
          ),
          if (event?.tieBrokenBySpeed ?? false)
            const Padding(
              padding: EdgeInsets.only(top: AppSpacing.sm),
              child: Text(
                'A tie at the cutoff was broken by answer speed.',
                style: AppTextStyles.caption,
              ),
            ),
          const SizedBox(height: AppSpacing.lg),
          for (final p in out)
            Padding(
              padding: const EdgeInsets.only(bottom: AppSpacing.sm),
              child: Row(
                children: [
                  const Icon(Icons.close_rounded, color: AppColors.danger),
                  const SizedBox(width: AppSpacing.sm),
                  Text(p.nickname, style: AppTextStyles.leaderName),
                ],
              ),
            ),
          const SizedBox(height: AppSpacing.xl),
          Text(
            finalists ? 'Your finalists' : 'Still standing',
            style: AppTextStyles.label,
          ),
          const SizedBox(height: AppSpacing.md),
          LeaderboardList(players: leaderboard(room)),
          const SizedBox(height: AppSpacing.xl),
          HostStepButton(room: room),
        ],
      ),
    );
  }
}
