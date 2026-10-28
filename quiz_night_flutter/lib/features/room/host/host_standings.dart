import 'dart:math';

import 'package:flutter/material.dart';
import 'package:quiz_night_client/quiz_night_client.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_motion.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../widgets/qn/standings_row.dart';
import '../../../widgets/qn/host_stage.dart';
import '../round/host_step_button.dart';
import 'remove_player.dart';
import '../round_logic.dart';
import '../standings_logic.dart';

/// "After round N": the leaderboard with the danger line sliding in.
class HostStandings extends StatelessWidget {
  final RoomState room;
  final Map<int, int> rankMoves;

  /// Rows per column on the 1080p canvas.
  static const perColumn = 9;

  /// A row and the gap under it, and the danger line with its gap, at full
  /// size.
  static const _rowPitch = 74.0 + 10;
  static const _linePitch = 44.0 + 10;

  const HostStandings({
    super.key,
    required this.room,
    this.rankMoves = const {},
  });

  @override
  Widget build(BuildContext context) {
    final board = leaderboard(room);
    final line = room.projectedSurvivors ?? board.length;
    // Two columns of nine; beyond that the bottom of the table matters most.
    final shown = board.length <= perColumn * 2
        ? board
        : [
            ...board.take(perColumn),
            ...board.skip(board.length - perColumn),
          ];
    final ranks = {for (var i = 0; i < board.length; i++) board[i].id: i + 1};
    final left = shown.take(perColumn).toList();
    final right = shown.skip(perColumn).toList();

    /// Rows shrink so the fuller column, with its danger line, fits [height].
    double scaleFor(double height) {
      bool hasLine(List<PlayerView> rows) =>
          rows.any((p) => ranks[p.id] == line + 1);
      double need(List<PlayerView> rows) =>
          rows.length * _rowPitch + (hasLine(rows) ? _linePitch : 0);
      final tallest = max(need(left), need(right));
      if (tallest == 0 || !height.isFinite) return 1;
      return (height / tallest).clamp(0.6, 1.0);
    }

    Widget column(
      List<PlayerView> rows, {
      required int delayOffset,
      double rowScale = 1,
    }) => Column(
      children: [
        for (var i = 0; i < rows.length; i++) ...[
          if (ranks[rows[i].id] == line + 1) ...[
            _SlideIn(child: DangerLine(scale: rowScale)),
            SizedBox(height: 10 * rowScale),
          ],
          _Stagger(
            delay: Duration(milliseconds: (i + delayOffset) * 50),
            child: StandingsRow(
              scale: rowScale,
              rank: ranks[rows[i].id]!,
              nickname: rows[i].nickname,
              score: rows[i].score,
              move: rankMoves[rows[i].id],
              belowLine: ranks[rows[i].id]! > line,
              onRemove: () => confirmRemovePlayer(context, rows[i]),
            ),
          ),
          SizedBox(height: 10 * rowScale),
        ],
      ],
    );

    final title = Text(
      'AFTER ROUND ${room.round}',
      style: AppTextStyles.displayXl.copyWith(fontSize: 80),
    );
    final summary = Text(
      cutSummary(room),
      maxLines: 2,
      overflow: TextOverflow.ellipsis,
      style: AppProjectorText.body.copyWith(color: AppColors.muted),
    );

    // Phone: one column, the step button at the bottom.
    if (HostLayout.isPortrait(context)) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          FittedBox(
            fit: BoxFit.scaleDown,
            alignment: Alignment.centerLeft,
            child: title,
          ),
          const SizedBox(height: 12),
          summary,
          const SizedBox(height: 28),
          Expanded(
            child: SingleChildScrollView(
              child: column(shown, delayOffset: 0),
            ),
          ),
          const SizedBox(height: 24),
          Align(
            alignment: Alignment.centerRight,
            child: HostStepButton(room: room),
          ),
        ],
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.baseline,
          textBaseline: TextBaseline.alphabetic,
          children: [
            title,
            const SizedBox(width: 24),
            Expanded(child: summary),
            HostStepButton(room: room),
          ],
        ),
        const SizedBox(height: 28),
        Expanded(
          child: LayoutBuilder(
            builder: (context, box) {
              final rowScale = scaleFor(box.maxHeight);
              // Scrolls only with very large text; the scale fits the rest.
              return SingleChildScrollView(
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: column(
                        left,
                        delayOffset: 0,
                        rowScale: rowScale,
                      ),
                    ),
                    const SizedBox(width: 48),
                    Expanded(
                      child: column(
                        right,
                        delayOffset: 4,
                        rowScale: rowScale,
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}

class _Stagger extends StatelessWidget {
  final Duration delay;
  final Widget child;

  const _Stagger({required this.delay, required this.child});

  @override
  Widget build(BuildContext context) {
    if (MediaQuery.disableAnimationsOf(context)) return child;
    final total = const Duration(milliseconds: 500) + delay;
    final start = delay.inMilliseconds / total.inMilliseconds;
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0, end: 1),
      duration: total,
      builder: (context, t, child) {
        final e = AppCurves.standard.transform(
          ((t - start) / (1 - start)).clamp(0.0, 1.0),
        );
        return Opacity(
          opacity: e,
          child: Transform.translate(
            offset: Offset(0, 20 * (1 - e)),
            child: child,
          ),
        );
      },
      child: child,
    );
  }
}

/// The danger line slides in from the left after the rows.
class _SlideIn extends StatelessWidget {
  final Widget child;

  const _SlideIn({required this.child});

  @override
  Widget build(BuildContext context) {
    if (MediaQuery.disableAnimationsOf(context)) return child;
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0, end: 1),
      duration: const Duration(milliseconds: 1500),
      builder: (context, t, child) {
        final e = AppCurves.standard.transform(
          ((t - 0.6) / 0.4).clamp(0.0, 1.0),
        );
        return FractionalTranslation(
          translation: Offset(-1.1 * (1 - e), 0),
          child: child,
        );
      },
      child: child,
    );
  }
}
