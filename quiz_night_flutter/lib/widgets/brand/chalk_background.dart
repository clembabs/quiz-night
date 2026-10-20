import 'package:flutter/widgets.dart';

import '../../core/theme/app_colors.dart';

/// The blackboard: a faint grid of chalk-dust dots behind everything.
/// Painted, so it costs zero image bytes.
class ChalkBackground extends StatelessWidget {
  final Widget child;
  final Color color;

  /// Distance between dots; the projector canvas uses a larger grid.
  final double spacing;

  const ChalkBackground({
    super.key,
    required this.child,
    this.color = AppColors.board,
    this.spacing = 7,
  });

  @override
  Widget build(BuildContext context) => ColoredBox(
    color: color,
    child: CustomPaint(
      painter: _ChalkDustPainter(spacing),
      isComplex: true,
      child: child,
    ),
  );
}

class _ChalkDustPainter extends CustomPainter {
  final double spacing;

  _ChalkDustPainter(this.spacing);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = AppColors.chalk.withValues(alpha: 0.035);
    final radius = spacing / 7;
    for (var y = spacing / 2; y < size.height; y += spacing) {
      for (var x = spacing / 2; x < size.width; x += spacing) {
        canvas.drawCircle(Offset(x, y), radius, paint);
      }
    }
  }

  @override
  bool shouldRepaint(_ChalkDustPainter old) => old.spacing != spacing;
}
