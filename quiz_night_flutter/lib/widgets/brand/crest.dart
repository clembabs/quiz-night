import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';

/// Crest outline, as CSS `border-radius: r r 50% 50% / r r 46% 46%`.
class CrestBorder extends OutlinedBorder {
  /// Top corner radius as a fraction of the width.
  final double topRadius;

  const CrestBorder({super.side, this.topRadius = 0.125});

  RRect _rrect(Rect rect) => RRect.fromRectAndCorners(
    rect,
    topLeft: Radius.circular(rect.width * topRadius),
    topRight: Radius.circular(rect.width * topRadius),
    bottomLeft: Radius.elliptical(rect.width * 0.5, rect.height * 0.46),
    bottomRight: Radius.elliptical(rect.width * 0.5, rect.height * 0.46),
  );

  @override
  EdgeInsetsGeometry get dimensions => EdgeInsets.all(side.width);

  @override
  Path getInnerPath(Rect rect, {TextDirection? textDirection}) =>
      Path()..addRRect(_rrect(rect).deflate(side.width));

  @override
  Path getOuterPath(Rect rect, {TextDirection? textDirection}) =>
      Path()..addRRect(_rrect(rect));

  @override
  void paint(Canvas canvas, Rect rect, {TextDirection? textDirection}) {
    if (side.style == BorderStyle.none || side.width == 0) return;
    canvas.drawRRect(_rrect(rect).deflate(side.width / 2), side.toPaint());
  }

  @override
  ShapeBorder scale(double t) =>
      CrestBorder(side: side.scale(t), topRadius: topRadius);

  @override
  CrestBorder copyWith({BorderSide? side}) =>
      CrestBorder(side: side ?? this.side, topRadius: topRadius);
}

/// A crest-shaped badge; with no [child], "QN" over a gold rule.
class Crest extends StatelessWidget {
  final double width;
  final Color fill;
  final Color rim;
  final Widget? child;

  /// Adds the small maroon diamond under the rule (the full brand mark).
  final bool withDiamond;

  const Crest({
    super.key,
    this.width = 64,
    this.fill = AppColors.green,
    this.rim = AppColors.gold,
    this.child,
    this.withDiamond = false,
  });

  double get height => width * 76 / 64;

  @override
  Widget build(BuildContext context) {
    final rimWidth = (width / 20).clamp(2.0, 6.0);
    return Container(
      width: width,
      height: height,
      alignment: Alignment.center,
      decoration: ShapeDecoration(
        color: fill,
        shape: CrestBorder(
          side: BorderSide(color: rim, width: rimWidth),
        ),
      ),
      child: child ?? _monogram(),
    );
  }

  Widget _monogram() => Column(
    mainAxisSize: MainAxisSize.min,
    children: [
      Text(
        'QN',
        style: AppTextStyles.headline.copyWith(fontSize: width * 0.4),
      ),
      SizedBox(height: width * 0.03),
      Container(
        width: width * 0.44,
        height: (width / 32).clamp(1.5, 4.0),
        color: rim,
      ),
      if (withDiamond) ...[
        SizedBox(height: width * 0.06),
        Transform.rotate(
          angle: 0.785398,
          child: Container(
            width: width * 0.08,
            height: width * 0.08,
            color: AppColors.maroon,
          ),
        ),
      ],
    ],
  );
}

/// The stacked mark: crest above "QUIZ NIGHT", centred.
class QuizNightStackedMark extends StatelessWidget {
  final double crestWidth;
  final String? subtitle;

  const QuizNightStackedMark({super.key, this.crestWidth = 72, this.subtitle});

  @override
  Widget build(BuildContext context) => Column(
    mainAxisSize: MainAxisSize.min,
    children: [
      Crest(width: crestWidth, withDiamond: true),
      SizedBox(height: crestWidth * 0.22),
      Text(
        'QUIZ NIGHT',
        textAlign: TextAlign.center,
        style: AppTextStyles.headline.copyWith(
          fontSize: crestWidth * 0.5,
          height: 1.0,
        ),
      ),
      if (subtitle != null) ...[
        const SizedBox(height: 6),
        Text(
          subtitle!,
          textAlign: TextAlign.center,
          style: AppTextStyles.caption.copyWith(fontSize: 15),
        ),
      ],
    ],
  );
}

/// Crest plus "QUIZ NIGHT" wordmark, side by side.
class QuizNightLockup extends StatelessWidget {
  final double crestWidth;
  final double fontSize;
  final String? subtitle;

  const QuizNightLockup({
    super.key,
    this.crestWidth = 44,
    this.fontSize = 28,
    this.subtitle,
  });

  @override
  Widget build(BuildContext context) => Row(
    mainAxisSize: MainAxisSize.min,
    children: [
      Crest(width: crestWidth),
      SizedBox(width: crestWidth * 0.27),
      Flexible(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'QUIZ NIGHT',
              style: AppTextStyles.headline.copyWith(
                fontSize: fontSize,
                height: 1.0,
              ),
            ),
            if (subtitle != null)
              Text(
                subtitle!,
                style: AppTextStyles.caption.copyWith(fontSize: 14),
              ),
          ],
        ),
      ),
    ],
  );
}
