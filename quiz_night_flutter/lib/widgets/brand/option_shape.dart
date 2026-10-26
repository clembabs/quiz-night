import 'package:flutter/widgets.dart';

/// Option shapes beyond colour: A triangle, B diamond, C circle, D square.
enum OptionShapeKind { triangle, diamond, circle, square }

OptionShapeKind optionShapeFor(int index) =>
    OptionShapeKind.values[index % OptionShapeKind.values.length];

/// Spoken name of each shape, for screen readers.
String optionShapeName(int index) => switch (optionShapeFor(index)) {
  OptionShapeKind.triangle => 'triangle',
  OptionShapeKind.diamond => 'diamond',
  OptionShapeKind.circle => 'circle',
  OptionShapeKind.square => 'square',
};

/// A filled option shape.
class OptionShape extends StatelessWidget {
  final int index;
  final double size;
  final Color color;

  const OptionShape({
    super.key,
    required this.index,
    required this.color,
    this.size = 16,
  });

  @override
  Widget build(BuildContext context) => CustomPaint(
    size: Size.square(size),
    painter: _ShapePainter(optionShapeFor(index), color),
  );
}

class _ShapePainter extends CustomPainter {
  final OptionShapeKind kind;
  final Color color;

  _ShapePainter(this.kind, this.color);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = color;
    final w = size.width, h = size.height;
    switch (kind) {
      case OptionShapeKind.triangle:
        canvas.drawPath(
          Path()
            ..moveTo(w / 2, 0)
            ..lineTo(w, h)
            ..lineTo(0, h)
            ..close(),
          paint,
        );
      case OptionShapeKind.diamond:
        canvas.drawPath(
          Path()
            ..moveTo(w / 2, 0)
            ..lineTo(w, h / 2)
            ..lineTo(w / 2, h)
            ..lineTo(0, h / 2)
            ..close(),
          paint,
        );
      case OptionShapeKind.circle:
        canvas.drawOval(Offset.zero & size, paint);
      case OptionShapeKind.square:
        canvas.drawRRect(
          RRect.fromRectAndRadius(Offset.zero & size, Radius.circular(w / 9)),
          paint,
        );
    }
  }

  @override
  bool shouldRepaint(_ShapePainter old) =>
      old.kind != kind || old.color != color;
}
