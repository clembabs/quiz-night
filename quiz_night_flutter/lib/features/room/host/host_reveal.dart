import 'dart:math';

import 'package:flutter/material.dart';
import 'package:quiz_night_client/quiz_night_client.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_motion.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../widgets/brand/option_shape.dart';
import '../../../widgets/qn/host_stage.dart';
import '../../../widgets/qn/standings_row.dart';
import '../round/host_step_button.dart';
import '../round_logic.dart';

/// The projector reveal: answer bars grow, the correct one turns green.
class HostReveal extends StatelessWidget {
  final RoomState room;

  const HostReveal({super.key, required this.room});

  @override
  Widget build(BuildContext context) {
    final q = room.question!;
    final counts = q.answerCounts ?? List.filled(q.options.length, 0);
    final most = counts.isEmpty ? 0 : counts.reduce(max);
    final portrait = HostLayout.isPortrait(context);
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
        Text(
          q.text,
          style: portrait
              ? AppProjectorText.title.copyWith(fontSize: 48)
              : AppProjectorText.title,
        ),
        const SizedBox(height: 40),
        Expanded(
          child: Flex(
            // Projector: a bar chart of columns. Phone: one bar per row.
            direction: portrait ? Axis.vertical : Axis.horizontal,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              for (var i = 0; i < q.options.length; i++) ...[
                if (i > 0) SizedBox(width: 32, height: portrait ? 28 : 32),
                Expanded(
                  child: _Column(
                    index: i,
                    text: q.options[i],
                    count: i < counts.length ? counts[i] : 0,
                    share: most == 0
                        ? 0
                        : (i < counts.length ? counts[i] : 0) / most,
                    correct: i == q.correctIndex,
                    horizontal: portrait,
                  ),
                ),
              ],
            ],
          ),
        ),
        const SizedBox(height: 24),
        Row(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    '${_correctCount(q)} of ${activeCount(room)} got it right',
                    style: AppProjectorText.bodySoft,
                  ),
                  // The table's top and its danger zone, without stopping
                  // for the full board every question.
                  ..._strip(room),
                ],
              ),
            ),
            HostStepButton(room: room),
          ],
        ),
      ],
    );
  }

  static List<Widget> _strip(RoomState room) {
    final board = leaderboard(room);
    // Until someone has points, a leaderboard says nothing.
    if (board.isEmpty || board.first.score == 0) return const [];
    final top =
        'Leading: ${[for (final p in board.take(3)) '${p.nickname} ${formatScore(p.score)}'].join('  ·  ')}';
    final line = room.projectedSurvivors;
    final danger = line == null || line >= board.length
        ? const <String>[]
        : [for (final p in board.skip(line)) p.nickname];
    return [
      const SizedBox(height: 8),
      Text(
        top,
        key: const Key('reveal.top'),
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: AppProjectorText.caption.copyWith(
          fontSize: 28,
          color: AppColors.chalk,
        ),
      ),
      if (danger.isNotEmpty)
        Text(
          'In danger: ${danger.join(', ')}',
          key: const Key('reveal.danger'),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: AppProjectorText.caption.copyWith(
            fontSize: 28,
            color: AppColors.maroonPale,
          ),
        ),
    ];
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

  /// Grow left to right (portrait phone) instead of as an upward column.
  final bool horizontal;

  const _Column({
    required this.index,
    required this.text,
    required this.count,
    required this.share,
    required this.correct,
    this.horizontal = false,
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
        if (horizontal) {
          return Opacity(
            opacity: dim,
            child: _row(grow, bg, ink, labelBg, labelFg),
          );
        }
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

  Widget _row(
    double grow,
    Color bg,
    Color ink,
    Color labelBg,
    Color labelFg,
  ) =>
      // Short phones: the row shrinks to fit rather than overflowing.
      LayoutBuilder(
        builder: (context, c) => FittedBox(
          fit: BoxFit.scaleDown,
          alignment: Alignment.centerLeft,
          child: SizedBox(
            width: c.maxWidth,
            child: Row(
              children: [
                Container(
                  width: 96,
                  padding: const EdgeInsets.symmetric(vertical: 10),
                  decoration: BoxDecoration(
                    color: labelBg,
                    borderRadius: BorderRadius.circular(20),
                    border: correct
                        ? Border.all(color: AppColors.chalk, width: 4)
                        : null,
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        optionLetter(index),
                        style: AppTextStyles.headline.copyWith(
                          fontSize: 44,
                          color: labelFg,
                        ),
                      ),
                      const SizedBox(height: 6),
                      OptionShape(index: index, color: labelFg, size: 24),
                    ],
                  ),
                ),
                const SizedBox(width: 24),
                Expanded(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              text,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: AppProjectorText.title.copyWith(
                                fontSize: 36,
                                decoration: correct
                                    ? null
                                    : TextDecoration.lineThrough,
                                decorationColor: AppColors.chalk,
                              ),
                            ),
                          ),
                          const SizedBox(width: 16),
                          Text(
                            correct ? '✓ $count' : '$count',
                            style: AppProjectorText.numeric.copyWith(
                              fontSize: 48,
                              color: correct
                                  ? AppColors.correct
                                  : AppColors.chalk,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Container(
                        height: 28,
                        decoration: BoxDecoration(
                          color: AppColors.surface,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        alignment: Alignment.centerLeft,
                        child: FractionallySizedBox(
                          widthFactor: max(share * grow, 0.03),
                          heightFactor: 1,
                          child: DecoratedBox(
                            decoration: BoxDecoration(
                              color: bg,
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      );
}
