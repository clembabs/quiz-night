import 'package:flutter/material.dart';
import 'package:quiz_night_client/quiz_night_client.dart';

import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../widgets/countdown_bar.dart';
import '../../../widgets/leaderboard_list.dart';
import '../../../widgets/options_grid.dart';
import '../round_logic.dart';
import 'host_step_button.dart';
import 'question_header.dart';

/// Projector view for an open question and for its reveal.
class HostQuestionView extends StatelessWidget {
  final RoomState room;
  final Duration clockOffset;

  /// How many leaderboard rows to show after a reveal.
  static const leaderboardRows = 5;

  const HostQuestionView({
    super.key,
    required this.room,
    required this.clockOffset,
  });

  @override
  Widget build(BuildContext context) {
    final q = room.question!;
    final revealed = q.correctIndex != null;
    final endsAt = room.questionEndsAt;
    final active = activeCount(room);

    final questionPanel = Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        QuestionHeader(room: room),
        const SizedBox(height: AppSpacing.md),
        Text(q.text, style: AppTextStyles.questionHost),
        const SizedBox(height: AppSpacing.xl),
        if (!revealed && endsAt != null) ...[
          CountdownBar(
            endsAt: endsAt,
            totalSeconds: q.timeLimitSeconds,
            clockOffset: clockOffset,
          ),
          const SizedBox(height: AppSpacing.xl),
        ],
        OptionsGrid(question: q),
        const SizedBox(height: AppSpacing.xl),
        Row(
          children: [
            Expanded(
              child: Text(
                revealed
                    ? '${_correctCount(q)} of $active got it right'
                    : '${answeredCount(room)} of $active answered',
                style: AppTextStyles.bodyMuted,
              ),
            ),
            HostStepButton(room: room),
          ],
        ),
      ],
    );

    if (!revealed) {
      return SingleChildScrollView(
        padding: const EdgeInsets.all(AppSpacing.xxl),
        child: questionPanel,
      );
    }

    final board = Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const Text('Leaderboard', style: AppTextStyles.heading),
        const SizedBox(height: AppSpacing.lg),
        LeaderboardList(players: leaderboard(room), limit: leaderboardRows),
      ],
    );
    return LayoutBuilder(
      builder: (context, constraints) {
        if (constraints.maxWidth >= AppSpacing.wideBreakpoint) {
          return Padding(
            padding: const EdgeInsets.all(AppSpacing.xxl),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  flex: 3,
                  child: SingleChildScrollView(child: questionPanel),
                ),
                const SizedBox(width: AppSpacing.xxl),
                Expanded(flex: 2, child: SingleChildScrollView(child: board)),
              ],
            ),
          );
        }
        return ListView(
          padding: AppSpacing.screenPadding,
          children: [
            questionPanel,
            const SizedBox(height: AppSpacing.xxl),
            board,
          ],
        );
      },
    );
  }

  static int _correctCount(QuestionView q) {
    final counts = q.answerCounts;
    final correct = q.correctIndex;
    if (counts == null || correct == null || correct >= counts.length) return 0;
    return counts[correct];
  }
}
