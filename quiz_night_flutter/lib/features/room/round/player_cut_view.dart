import 'package:flutter/material.dart';
import 'package:quiz_night_client/quiz_night_client.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../widgets/common.dart';
import '../cut_reveal/back_finalist_panel.dart';
import '../cut_reveal/cut_reveal_scope.dart';
import '../cut_reveal/reveal_sequence_cubit.dart';

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

/// Phone view after a cut: suspense until this player's fate is revealed,
/// then the outcome and, for spectators, backing a finalist.
class PlayerCutView extends StatelessWidget {
  final RoomState room;
  final PlayerView? me;
  final int? myBackedId;

  /// Overridable for tests.
  final RevealSequenceCubit Function(int total)? createSequence;

  const PlayerCutView({
    super.key,
    required this.room,
    required this.me,
    this.myBackedId,
    this.createSequence,
  });

  @override
  Widget build(BuildContext context) {
    final event = room.lastElimination;
    final outcome = cutOutcomeFor(room, me);
    return CutRevealScope(
      event: event,
      createCubit: createSequence,
      builder: (context, seq) {
        // Players already out know their fate; no suspense for them.
        final known =
            outcome == CutOutcome.alreadyOut ||
            fateRevealed(event: event, myId: me?.id, sequence: seq);
        return CenteredContent(
          child: ListView(
            padding: AppSpacing.screenPadding,
            children: [
              const SizedBox(height: AppSpacing.xl),
              if (known)
                _Outcome(outcome: outcome, round: room.round)
              else
                _Suspense(sequence: seq),
              if (known &&
                  seq.isDone &&
                  BackFinalistPanel.isOpen(room, me)) ...[
                const SizedBox(height: AppSpacing.xxl),
                BackFinalistPanel(room: room, backedId: myBackedId),
              ],
            ],
          ),
        );
      },
    );
  }
}

class _Suspense extends StatelessWidget {
  final RevealSequenceState sequence;

  const _Suspense({required this.sequence});

  @override
  Widget build(BuildContext context) => Column(
    children: [
      const SizedBox.square(
        dimension: 64,
        child: CircularProgressIndicator(strokeWidth: 6),
      ),
      const SizedBox(height: AppSpacing.xl),
      const Text(
        'Are you safe?',
        textAlign: TextAlign.center,
        style: AppTextStyles.revealIntro,
      ),
      const SizedBox(height: AppSpacing.sm),
      Text(
        sequence.phase == RevealPhase.intro
            ? 'Look at the big screen…'
            : '${sequence.revealed} of ${sequence.total} revealed',
        textAlign: TextAlign.center,
        style: AppTextStyles.bodyMuted,
      ),
    ],
  );
}

class _Outcome extends StatelessWidget {
  final CutOutcome outcome;
  final int round;

  const _Outcome({required this.outcome, required this.round});

  @override
  Widget build(BuildContext context) {
    final (icon, color, title, subtitle) = switch (outcome) {
      CutOutcome.finalist => (
        Icons.emoji_events_rounded,
        AppColors.gold,
        'You made the final!',
        'Get ready for the buzzer round.',
      ),
      CutOutcome.survived => (
        Icons.shield_rounded,
        AppColors.success,
        'You survived round $round',
        'Next round coming up…',
      ),
      CutOutcome.out => (
        Icons.sentiment_dissatisfied_rounded,
        AppColors.danger,
        "You're out",
        'Stay and play along: your answers now earn a shadow score.',
      ),
      CutOutcome.alreadyOut => (
        Icons.visibility_rounded,
        AppColors.muted,
        'Spectating',
        'Watch who survives this round.',
      ),
    };
    return Column(
      children: [
        Icon(icon, size: AppIconSizes.hero, color: color),
        const SizedBox(height: AppSpacing.md),
        Text(title, textAlign: TextAlign.center, style: AppTextStyles.verdict),
        const SizedBox(height: AppSpacing.sm),
        Text(
          subtitle,
          textAlign: TextAlign.center,
          style: AppTextStyles.bodyMuted,
        ),
      ],
    );
  }
}
