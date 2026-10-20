import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:quiz_night_client/quiz_night_client.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../widgets/answer_option.dart';
import '../../../widgets/countdown_bar.dart';
import '../../../widgets/spectator_banner.dart';
import '../room_cubit.dart';
import 'question_header.dart';

/// Phone view for an open question: four big buttons and the countdown.
class PlayerQuestionView extends StatelessWidget {
  final RoomState room;
  final PlayerView? me;
  final int? myChoice;
  final Duration clockOffset;

  const PlayerQuestionView({
    super.key,
    required this.room,
    required this.me,
    required this.myChoice,
    required this.clockOffset,
  });

  @override
  Widget build(BuildContext context) {
    final q = room.question!;
    final endsAt = room.questionEndsAt;
    // After a reload the local pick is gone, but the server still knows.
    final locked = myChoice != null || (me?.hasAnswered ?? false);
    final cubit = context.read<RoomCubit>();

    return ListView(
      padding: AppSpacing.screenPadding,
      children: [
        if (SpectatorBanner.appliesTo(me)) ...[
          SpectatorBanner(me: me!),
          const SizedBox(height: AppSpacing.md),
        ],
        QuestionHeader(room: room),
        const SizedBox(height: AppSpacing.sm),
        Text(q.text, style: AppTextStyles.questionPlayer),
        const SizedBox(height: AppSpacing.lg),
        if (endsAt != null)
          CountdownBar(
            endsAt: endsAt,
            totalSeconds: q.timeLimitSeconds,
            clockOffset: clockOffset,
          ),
        const SizedBox(height: AppSpacing.lg),
        for (var i = 0; i < q.options.length; i++)
          Padding(
            padding: const EdgeInsets.only(bottom: AppSpacing.md),
            child: SizedBox(
              height: AppSpacing.answerButtonHeight,
              child: AnswerOption(
                key: Key('answer.$i'),
                index: i,
                text: q.options[i],
                look: lookFor(index: i, correctIndex: null, picked: myChoice),
                onTap: locked ? null : () => cubit.submitAnswer(i),
              ),
            ),
          ),
        if (locked)
          const Padding(
            padding: EdgeInsets.only(top: AppSpacing.sm),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.lock_rounded, color: AppColors.gold),
                SizedBox(width: AppSpacing.sm),
                Text('Answer locked in', style: AppTextStyles.label),
              ],
            ),
          ),
      ],
    );
  }
}
