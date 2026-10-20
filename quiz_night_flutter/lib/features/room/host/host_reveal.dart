import 'dart:math';

import 'package:flutter/material.dart';
import 'package:quiz_night_client/quiz_night_client.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_motion.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../widgets/brand/option_shape.dart';
import '../round/host_step_button.dart';
import '../round_logic.dart';

/// The projector reveal: distribution bars grow from zero, wrong options dim
/// and strike, the correct one turns green with ✓.
class HostReveal extends StatelessWidget {
  final RoomState room;

  const HostReveal({super.key, required this.room});

  @override
  Widget build(BuildContext context) {
    final q = room.question!;
    final counts = q.answerCounts ?? List.filled(q.options.length, 0);
    final most = counts.isEmpty ? 0 : counts.reduce(max);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          'ROUND ${q.round} · QUESTION ${q.indexInRound} · ANSWER',
          style: AppProjectorText.label.copyWith(
            fontSize: 32,
            fontWeight: FontWeight.w800,
            letterSpacing: 3.2,
            color: AppColors.mint,
          ),
        ),
        const SizedBox(height: 16),
        Text(q.text, style: AppProjectorText.title),
        const SizedBox(height: 40),
        Expanded(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              for (var i = 0; i < q.options.length; i++) ...[
                if (i > 0) const SizedBox(width: 32),
                Expanded(
                  child: _Column(
                    index: i,
                    text: q.options[i],
                    count: i < counts.length ? counts[i] : 0,
                    share: most == 0
                        ? 0
                        : (i < counts.length ? counts[i] : 0) / most,
                    correct: i == q.correctIndex,
                  ),
                ),
              ],
            ],
          ),
        ),
        const SizedBox(height: 24),
        Row(
          children: [
            Expanded(
              child: Text(
                '${_correctCount(q)} of ${activeCount(room)} got it right',
                style: AppProjectorText.bodySoft,
              ),
            ),
            HostStepButton(room: room),
          ],
        ),
      ],
    );
  }

  static int _correctCount(QuestionView q) {
    final c = q.answerCounts, i = q.correctIndex;
    if (c == null || i == null || i >= c.length) return 0;
    return c[i];
  }
}

class _Column extends StatelessWidget {
  final int index;
  final String text;
  final int count;
  final double share;
  final bool correct;

  const _Column({
    required this.index,
    required this.text,
    required this.count,
    required this.share,
    required this.correct,
  });

  @override
  Widget build(BuildContext context) {
    final bg = AppColors.options[index % 4];
    final ink = AppColors.optionInk[index % 4];
    final labelBg = correct ? AppColors.correct : bg;
    final labelFg = correct ? AppColors.white : ink;
    final reduced = MediaQuery.disableAnimationsOf(context);
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: reduced ? 1 : 0, end: 1),
      duration:
          AppDurations.dramatic + Duration(milliseconds: 200 + index * 80),
      builder: (context, t, _) {
        final local = reduced
            ? 1.0
            : ((t - (200 + index * 80) / (1100 + index * 80)) /
                      (1 - (200 + index * 80) / (1100 + index * 80)))
                  .clamp(0.0, 1.0);
        final grow = AppCurves.decelerate.transform(local);
        final dim = correct
            ? 1.0
            : 1 - 0.55 * ((t - 0.6) / 0.4).clamp(0.0, 1.0);
        return Opacity(
          opacity: dim,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.end,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                '$count',
                textAlign: TextAlign.center,
                style: AppProjectorText.numeric.copyWith(fontSize: 72),
              ),
              const SizedBox(height: 20),
              Expanded(
                child: Align(
                  alignment: Alignment.bottomCenter,
                  child: FractionallySizedBox(
                    heightFactor: max(share * grow, 0.03),
                    widthFactor: 1,
                    child: Container(
                      alignment: Alignment.topCenter,
                      padding: const EdgeInsets.only(top: 20),
                      decoration: BoxDecoration(
                        color: bg,
                        borderRadius: const BorderRadius.vertical(
                          top: Radius.circular(20),
                          bottom: Radius.circular(6),
                        ),
                      ),
                      child: correct && share * grow > 0.15
                          ? Text(
                              '✓',
                              style: AppProjectorText.numeric.copyWith(
                                fontSize: 64,
                                color: ink,
                              ),
                            )
                          : null,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 20,
                ),
                decoration: BoxDecoration(
                  color: labelBg,
                  borderRadius: BorderRadius.circular(20),
                  border: correct
                      ? Border.all(color: AppColors.chalk, width: 4)
                      : null,
                ),
                child: Row(
                  children: [
                    Text(
                      optionLetter(index),
                      style: AppTextStyles.headline.copyWith(
                        fontSize: 44,
                        color: labelFg,
                      ),
                    ),
                    const SizedBox(width: 16),
                    OptionShape(index: index, color: labelFg, size: 28),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Text(
                        text,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: AppProjectorText.title.copyWith(
                          fontSize: 36,
                          color: labelFg,
                          decoration: correct
                              ? null
                              : TextDecoration.lineThrough,
                          decorationColor: labelFg,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
