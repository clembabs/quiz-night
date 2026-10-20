import 'package:flutter/material.dart';
import 'package:quiz_night_client/quiz_night_client.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../widgets/brand/option_shape.dart';
import '../../../widgets/qn/answer_button.dart';
import '../../../widgets/qn/countdown.dart';
import '../final/final_logic.dart';
import '../round/host_step_button.dart';
import 'host_cut.dart';

/// The projector during the buzzer final: question, a compact option strip
/// (finalists answer on their phones), and the finalists' desks.
class HostFinal extends StatelessWidget {
  final RoomState room;
  final Duration clockOffset;

  const HostFinal({super.key, required this.room, required this.clockOffset});

  @override
  Widget build(BuildContext context) {
    final q = room.question!;
    final revealed = q.correctIndex != null;
    final endsAt = room.questionEndsAt;
    return Column(
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Column(
                children: [
                  Text(
                    'FINAL · QUESTION ${q.indexInRound} OF '
                    '${room.finalQuestionCount}',
                    style: AppProjectorText.label.copyWith(
                      fontSize: 32,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 3.8,
                      color: AppColors.gold,
                    ),
                  ),
                  const SizedBox(height: 20),
                  Text(
                    q.text,
                    textAlign: TextAlign.center,
                    style: AppProjectorText.title.copyWith(
                      fontSize: 80,
                      height: 1.1,
                    ),
                  ),
                ],
              ),
            ),
            if (!revealed && endsAt != null) ...[
              const SizedBox(width: 40),
              CountdownBuilder(
                endsAt: endsAt,
                totalSeconds: q.timeLimitSeconds,
                clockOffset: clockOffset,
                builder: (context, frame) =>
                    CountdownRing(frame: frame, size: 180),
              ),
            ],
          ],
        ),
        const SizedBox(height: 32),
        Row(
          children: [
            for (var i = 0; i < q.options.length; i++) ...[
              if (i > 0) const SizedBox(width: 20),
              Expanded(
                child: _OptionStrip(index: i, text: q.options[i], q: q),
              ),
            ],
          ],
        ),
        const SizedBox(height: 40),
        Expanded(child: FinalistDesks(room: room)),
        const SizedBox(height: 24),
        Row(
          children: [
            Expanded(
              child: Text(
                finalStatusLine(room),
                key: const Key('final.status'),
                style: AppTextStyles.headline.copyWith(fontSize: 48),
              ),
            ),
            HostStepButton(room: room),
          ],
        ),
      ],
    );
  }
}

class _OptionStrip extends StatelessWidget {
  final int index;
  final String text;
  final QuestionView q;

  const _OptionStrip({
    required this.index,
    required this.text,
    required this.q,
  });

  @override
  Widget build(BuildContext context) {
    final look = answerLookFor(
      index: index,
      correctIndex: q.correctIndex,
      picked: null,
    );
    final correct = look == AnswerLook.correct;
    final bg = correct ? AppColors.correct : AppColors.options[index % 4];
    final fg = correct ? AppColors.white : AppColors.optionInk[index % 4];
    return Opacity(
      opacity: look == AnswerLook.dimmed ? 0.45 : 1,
      child: Container(
        height: 96,
        padding: const EdgeInsets.symmetric(horizontal: 20),
        decoration: BoxDecoration(
          color: bg,
          borderRadius: BorderRadius.circular(20),
          border: correct ? Border.all(color: AppColors.chalk, width: 4) : null,
        ),
        child: Row(
          children: [
            OptionLetterTile(index: index, size: 60),
            const SizedBox(width: 16),
            OptionShape(index: index, color: fg, size: 24),
            const SizedBox(width: 16),
            Expanded(
              child: Text(
                text,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: AppProjectorText.title.copyWith(fontSize: 32, color: fg),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
