import 'package:flutter/material.dart';
import 'package:quiz_night_client/quiz_night_client.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_motion.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../widgets/qn/standings_row.dart';
import '../round/host_step_button.dart';
import '../round_logic.dart';
import '../standings_logic.dart';

/// "After round N": the leaderboard in two columns with the danger line
/// sliding in above those who would go home.
class HostStandings extends StatelessWidget {
  final RoomState room;
  final Map<int, int> rankMoves;

  /// Rows per column on the 1080p canvas.
  static const perColumn = 9;

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
    // Nine 74 px rows plus the danger line need ~840 px; the canvas leaves
    // ~760 under the title, so rows shrink a little on full boards.
    final rowScale = shown.length > 14 ? 0.86 : 1.0;
    final right = shown.skip(perColumn).toList();

    Widget column(List<PlayerView> rows, {required int delayOffset}) => Column(
      children: [
        for (var i = 0; i < rows.length; i++) ...[
          if (ranks[rows[i].id] == line + 1) ...[
            _SlideIn(child: DangerLine(scale: rowScale)),
            const SizedBox(height: 10),
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
            ),
          ),
          SizedBox(height: 10 * rowScale),
        ],
      ],
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.baseline,
          textBaseline: TextBaseline.alphabetic,
          children: [
            Text(
              'AFTER ROUND ${room.round}',
              style: AppTextStyles.displayXl.copyWith(fontSize: 80),
            ),
            const SizedBox(width: 24),
            Expanded(
              child: Text(
                cutSummary(room),
                style: AppProjectorText.body.copyWith(color: AppColors.muted),
              ),
            ),
            HostStepButton(room: room),
          ],
        ),
        const SizedBox(height: 28),
        Expanded(
          // Fits nine rows a column at 1080p; scrolls rather than overflows
          // with very long boards or large text.
          child: SingleChildScrollView(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(child: column(left, delayOffset: 0)),
                const SizedBox(width: 48),
                Expanded(child: column(right, delayOffset: 4)),
              ],
            ),
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
