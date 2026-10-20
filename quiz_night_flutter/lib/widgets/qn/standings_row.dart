import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../brand/initial_badge.dart';

/// "▲2", "▼1" or "—".
String moveLabel(int? move) {
  if (move == null || move == 0) return '—';
  return move > 0 ? '▲$move' : '▼${-move}';
}

Color moveColor(int? move) {
  if (move == null || move == 0) return AppColors.muted;
  return move > 0 ? AppColors.greenLine : AppColors.errorText;
}

/// One leaderboard row: rank, badge, name (+ tag), score, movement.
/// Sized for the 1920×1080 projector canvas; [scale] shrinks it for phones.
class StandingsRow extends StatelessWidget {
  final int rank;
  final String nickname;
  final int score;
  final int? move;
  final bool belowLine;
  final bool isYou;
  final double scale;

  const StandingsRow({
    super.key,
    required this.rank,
    required this.nickname,
    required this.score,
    this.move,
    this.belowLine = false,
    this.isYou = false,
    this.scale = 1,
  });

  @override
  Widget build(BuildContext context) {
    final s = scale;
    final bg = belowLine
        ? AppColors.maroonDeep
        : isYou
        ? AppColors.green
        : AppColors.surface;
    final border = isYou
        ? AppColors.gold
        : belowLine
        ? AppColors.maroon
        : Colors.transparent;
    return Container(
      height: 74 * s,
      padding: EdgeInsets.symmetric(horizontal: 24 * s),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(16 * s),
        border: Border.all(color: border, width: 3 * s),
      ),
      child: Row(
        children: [
          SizedBox(
            width: 72 * s,
            child: Text(
              '$rank',
              style: AppTextStyles.numeric.copyWith(fontSize: 40 * s),
            ),
          ),
          InitialBadge(nickname: nickname, size: 56 * s),
          SizedBox(width: 20 * s),
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  nickname,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: AppTextStyles.chip.copyWith(
                    fontSize: 36 * s,
                    height: 1.1,
                  ),
                ),
                if (belowLine)
                  Text(
                    '! DANGER',
                    style: AppTextStyles.label.copyWith(
                      fontSize: 20 * s,
                      height: 1.0,
                      fontWeight: FontWeight.w800,
                      color: AppColors.errorText,
                    ),
                  ),
              ],
            ),
          ),
          Text(
            formatScore(score),
            style: AppTextStyles.numeric.copyWith(fontSize: 40 * s),
          ),
          SizedBox(
            width: 92 * s,
            child: Text(
              moveLabel(move),
              textAlign: TextAlign.right,
              style: AppTextStyles.label.copyWith(
                fontSize: 28 * s,
                fontWeight: FontWeight.w800,
                color: moveColor(move),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// The dashed red DANGER LINE between survivors and those going home.
class DangerLine extends StatelessWidget {
  final double scale;

  const DangerLine({super.key, this.scale = 1});

  @override
  Widget build(BuildContext context) => Padding(
    padding: EdgeInsets.symmetric(vertical: 4 * scale),
    child: Row(
      children: [
        Expanded(child: _Dashes(scale: scale)),
        SizedBox(width: 16 * scale),
        Text(
          'DANGER LINE',
          style: AppTextStyles.label.copyWith(
            fontSize: 26 * scale,
            fontWeight: FontWeight.w800,
            letterSpacing: 0.14 * 26 * scale,
            color: AppColors.errorText,
          ),
        ),
        SizedBox(width: 16 * scale),
        Expanded(child: _Dashes(scale: scale)),
      ],
    ),
  );
}

class _Dashes extends StatelessWidget {
  final double scale;

  const _Dashes({required this.scale});

  @override
  Widget build(BuildContext context) => CustomPaint(
    size: Size(double.infinity, 5 * scale),
    painter: _DashPainter(scale),
  );
}

class _DashPainter extends CustomPainter {
  final double scale;

  _DashPainter(this.scale);

  @override
  void paint(Canvas canvas, Size size) {
    final p = Paint()
      ..color = AppColors.wrong
      ..strokeWidth = 5 * scale;
    final dash = 14 * scale, gap = 10 * scale;
    for (var x = 0.0; x < size.width; x += dash + gap) {
      canvas.drawLine(
        Offset(x, size.height / 2),
        Offset((x + dash).clamp(0, size.width), size.height / 2),
        p,
      );
    }
  }

  @override
  bool shouldRepaint(_DashPainter old) => old.scale != scale;
}

/// 9210 → "9,210".
String formatScore(int n) {
  final s = n.abs().toString();
  final b = StringBuffer(n < 0 ? '-' : '');
  for (var i = 0; i < s.length; i++) {
    if (i > 0 && (s.length - i) % 3 == 0) b.write(',');
    b.write(s[i]);
  }
  return b.toString();
}
