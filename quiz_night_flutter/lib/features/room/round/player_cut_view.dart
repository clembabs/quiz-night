import 'package:flutter/material.dart';
import 'package:quiz_night_client/quiz_night_client.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../widgets/common.dart';

/// What the cut meant for this player.
enum CutOutcome { survived, finalist, out, alreadyOut }

CutOutcome cutOutcomeFor(RoomState room, PlayerView? me) {
  if (me == null) return CutOutcome.alreadyOut;
  return switch (me.status) {
    PlayerStatus.finalist => CutOutcome.finalist,
    PlayerStatus.active => CutOutcome.survived,
    PlayerStatus.eliminated =>
      me.eliminatedInRound == room.round
          ? CutOutcome.out
          : CutOutcome.alreadyOut,
  };
}

/// Phone view after a cut. Milestone 5 adds the spectator experience.
class PlayerCutView extends StatelessWidget {
  final RoomState room;
  final PlayerView? me;

  const PlayerCutView({super.key, required this.room, required this.me});

  @override
  Widget build(BuildContext context) {
    final (icon, color, title, subtitle) = switch (cutOutcomeFor(room, me)) {
      CutOutcome.finalist => (
        Icons.emoji_events_rounded,
        AppColors.gold,
        'You made the final!',
        'Get ready for the buzzer round.',
      ),
      CutOutcome.survived => (
        Icons.shield_rounded,
        AppColors.success,
        'You survived round ${room.round}',
        'Next round coming up…',
      ),
      CutOutcome.out => (
        Icons.sentiment_dissatisfied_rounded,
        AppColors.danger,
        "You're out",
        'Stick around: you can still play along as a spectator.',
      ),
      CutOutcome.alreadyOut => (
        Icons.visibility_rounded,
        AppColors.muted,
        'Spectating',
        'Watch who survives this round.',
      ),
    };

    return CenteredContent(
      child: Padding(
        padding: AppSpacing.screenPadding,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: AppIconSizes.hero, color: color),
            const SizedBox(height: AppSpacing.md),
            Text(
              title,
              textAlign: TextAlign.center,
              style: AppTextStyles.verdict,
            ),
            const SizedBox(height: AppSpacing.sm),
            Text(
              subtitle,
              textAlign: TextAlign.center,
              style: AppTextStyles.bodyMuted,
            ),
          ],
        ),
      ),
    );
  }
}
