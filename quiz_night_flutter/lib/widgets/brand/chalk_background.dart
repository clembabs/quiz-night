import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:flutter/widgets.dart';

import '../../core/theme/app_colors.dart';

/// The blackboard: a painted grid of chalk-dust dots, zero image bytes.
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

  /// One dot drawn once per spacing and repeated, so a page paints a single
  /// rectangle; thousands of separate dots made phone scrolling stutter.
  static final _paints = <double, Paint>{};

  /// The tile is drawn larger than it shows, so dots stay round when zoomed.
  static const _detail = 4.0;

  static Paint _paintFor(double spacing) => _paints.putIfAbsent(spacing, () {
    final side = (spacing * _detail).ceil();
    final recorder = ui.PictureRecorder();
    Canvas(recorder).drawCircle(
      Offset(side / 2, side / 2),
      side / 7,
      Paint()..color = AppColors.chalk.withValues(alpha: 0.035),
    );
    final picture = recorder.endRecording();
    final tile = picture.toImageSync(side, side);
    picture.dispose();
    final scale = spacing / side;
    return Paint()
      ..shader = ui.ImageShader(
        tile,
        TileMode.repeated,
        TileMode.repeated,
        Float64List.fromList([
          scale, 0, 0, 0, //
          0, scale, 0, 0,
          0, 0, 1, 0,
          0, 0, 0, 1,
        ]),
        filterQuality: FilterQuality.medium,
      );
  });

  @override
  void paint(Canvas canvas, Size size) =>
      canvas.drawRect(Offset.zero & size, _paintFor(spacing));

  @override
  bool shouldRepaint(_ChalkDustPainter old) => old.spacing != spacing;
}
