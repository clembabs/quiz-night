import 'package:flutter/material.dart';
import 'package:quiz_night_client/quiz_night_client.dart';

import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../widgets/countdown_bar.dart';
import '../../../widgets/options_grid.dart';
import '../round/host_step_button.dart';
import '../round/question_header.dart';
import 'final_logic.dart';
import 'finalist_card.dart';

/// Projector view of a buzzer-final question, open or revealed.
class HostFinalView extends StatelessWidget {
  final RoomState room;
  final Duration clockOffset;

  const HostFinalView({
    super.key,
    required this.room,
    required this.clockOffset,
  });

  @override
  Widget build(BuildContext context) {
    final q = room.question!;
    final revealed = q.correctIndex != null;
    final endsAt = room.questionEndsAt;
    // Join order keeps cards from jumping around as points land.
    final finalists = finalStandings(room)
      ..sort((a, b) => a.id.compareTo(b.id));

    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppSpacing.xxl),
      child: Column(
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
          FinalistRow(room: room, finalists: finalists),
          const SizedBox(height: AppSpacing.xl),
          Row(
            children: [
              Expanded(
                child: Text(
                  finalStatusLine(room),
                  style: AppTextStyles.heading,
                ),
              ),
              HostStepButton(room: room),
            ],
          ),
        ],
      ),
    );
  }
}
