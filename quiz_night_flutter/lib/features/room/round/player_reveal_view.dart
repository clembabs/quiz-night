import 'package:flutter/material.dart';
import 'package:quiz_night_client/quiz_night_client.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../widgets/answer_option.dart';
import '../../../widgets/spectator_banner.dart';
import '../round_logic.dart';
import 'question_header.dart';

/// What happened to this player on the question just revealed.
enum PlayerVerdict { correct, wrong, noAnswer }

PlayerVerdict verdictFor({required PlayerView? me, required int? myChoice}) {
  final points = me?.lastPoints;
  if (points == null && myChoice == null) return PlayerVerdict.noAnswer;
  return (points ?? 0) > 0 ? PlayerVerdict.correct : PlayerVerdict.wrong;
}

/// Phone view after a reveal: right or wrong, points, rank.
class PlayerRevealView extends StatelessWidget {
  final RoomState room;
  final PlayerView? me;
  final int? myChoice;

  const PlayerRevealView({
    super.key,
    required this.room,
    required this.me,
    required this.myChoice,
  });

  @override
  Widget build(BuildContext context) {
    final q = room.question!;
    final me = this.me;
    final verdict = verdictFor(me: me, myChoice: myChoice);
    final rank = me == null ? null : rankOf(room, me.id);
    final correct = q.correctIndex;
    final spectator = SpectatorBanner.appliesTo(me);

    final (icon, color, text) = switch (verdict) {
      PlayerVerdict.correct => (
        Icons.check_circle_rounded,
        AppColors.success,
        'Correct!',
      ),
      PlayerVerdict.wrong => (Icons.cancel_rounded, AppColors.danger, 'Wrong'),
      PlayerVerdict.noAnswer => (
        Icons.timer_off_rounded,
        AppColors.muted,
        'No answer',
      ),
    };

    return ListView(
      padding: AppSpacing.screenPadding,
      children: [
        if (spectator) ...[
          SpectatorBanner(me: me!),
          const SizedBox(height: AppSpacing.md),
        ],
        QuestionHeader(room: room),
        const SizedBox(height: AppSpacing.xl),
        Icon(icon, size: AppIconSizes.hero, color: color),
        const SizedBox(height: AppSpacing.sm),
        Text(text, textAlign: TextAlign.center, style: AppTextStyles.verdict),
        if (verdict == PlayerVerdict.correct)
          Text(
            spectator
                ? '+${me?.lastPoints ?? 0} shadow'
                : '+${me?.lastPoints ?? 0}',
            textAlign: TextAlign.center,
            style: AppTextStyles.points,
          ),
        const SizedBox(height: AppSpacing.md),
        // Spectators have no rank; their banner shows the shadow score.
        if (me != null && !spectator)
          Text(
            rank == null ? '${me.score} pts' : '#$rank · ${me.score} pts',
            textAlign: TextAlign.center,
            style: AppTextStyles.rank,
          ),
        const SizedBox(height: AppSpacing.xl),
        if (correct != null && correct < q.options.length)
          AnswerOption(
            index: correct,
            text: q.options[correct],
            look: OptionLook.correct,
          ),
      ],
    );
  }
}
