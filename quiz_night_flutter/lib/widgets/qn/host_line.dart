import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_motion.dart';
import '../../core/theme/app_text_styles.dart';

/// The host's farewell line for a cut player, in quotes. It arrives a few
/// seconds after the cut, so it fades in; until then it takes no space.
class HostLine extends StatelessWidget {
  final String? line;
  final double fontSize;
  final int maxLines;
  final TextAlign textAlign;

  const HostLine({
    super.key,
    required this.line,
    this.fontSize = 16,
    this.maxLines = 3,
    this.textAlign = TextAlign.center,
  });

  @override
  Widget build(BuildContext context) => AnimatedSize(
    duration: AppDurations.slow,
    curve: AppCurves.standard,
    child: AnimatedSwitcher(
      duration: AppDurations.slow,
      child: switch (line) {
        final text? => Text(
          '“$text”',
          key: ValueKey(text),
          textAlign: textAlign,
          maxLines: maxLines,
          overflow: TextOverflow.ellipsis,
          style: AppTextStyles.body.copyWith(
            fontSize: fontSize,
            height: 1.3,
            fontStyle: FontStyle.italic,
            color: AppColors.goldPale,
          ),
        ),
        null => const SizedBox(width: double.infinity),
      },
    ),
  );
}
