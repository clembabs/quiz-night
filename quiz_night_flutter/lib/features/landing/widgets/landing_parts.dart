import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_text_styles.dart';

/// Centres [child] in the page column (at most [maxWidth], with the side
/// gutter) and pads it top and bottom.
class LandingSection extends StatelessWidget {
  final Widget child;
  final double maxWidth;
  final double top;
  final double bottom;

  const LandingSection({
    super.key,
    required this.child,
    this.maxWidth = AppWebLayout.maxWidth,
    this.top = 48,
    this.bottom = 48,
  });

  @override
  Widget build(BuildContext context) {
    final gutter = AppWebLayout.gutter(MediaQuery.sizeOf(context).width);
    return Center(
      child: ConstrainedBox(
        constraints: BoxConstraints(maxWidth: maxWidth),
        child: Padding(
          padding: EdgeInsets.fromLTRB(gutter, top, gutter, bottom),
          child: child,
        ),
      ),
    );
  }
}

/// An eyebrow over a section heading.
class SectionHeading extends StatelessWidget {
  final String? eyebrow;
  final String title;

  const SectionHeading({super.key, this.eyebrow, required this.title});

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.sizeOf(context).width;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (eyebrow != null) ...[
          Text(eyebrow!.toUpperCase(), style: AppWebText.eyebrow),
          const SizedBox(height: 12),
        ],
        Text(title.toUpperCase(), style: AppWebText.section(width)),
      ],
    );
  }
}

/// A raised card on the page.
class LandingCard extends StatelessWidget {
  final Widget child;
  final Color color;
  final Color? borderColor;
  final double borderWidth;
  final EdgeInsetsGeometry padding;
  final double radius;

  const LandingCard({
    super.key,
    required this.child,
    this.color = AppColors.surface,
    this.borderColor,
    this.borderWidth = 1,
    this.padding = const EdgeInsets.all(24),
    this.radius = AppWebLayout.card,
  });

  @override
  Widget build(BuildContext context) => Container(
    padding: padding,
    decoration: BoxDecoration(
      color: color,
      borderRadius: BorderRadius.circular(radius),
      border: borderColor == null
          ? null
          : Border.all(color: borderColor!, width: borderWidth),
    ),
    child: child,
  );
}

/// Button looks used on the page.
enum LandingButtonKind { gold, chalk, outline }

class LandingButton extends StatelessWidget {
  final String label;
  final VoidCallback? onPressed;
  final LandingButtonKind kind;
  final double height;
  final Key? buttonKey;

  const LandingButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.kind = LandingButtonKind.gold,
    this.height = 56,
    this.buttonKey,
  });

  @override
  Widget build(BuildContext context) {
    final (bg, fg) = switch (kind) {
      LandingButtonKind.gold => (AppColors.gold, AppColors.goldInk),
      LandingButtonKind.chalk => (AppColors.chalk, AppColors.board),
      LandingButtonKind.outline => (Colors.transparent, AppColors.chalk),
    };
    final shape = RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(AppRadii.md),
      side: kind == LandingButtonKind.outline
          ? const BorderSide(color: AppColors.lineStrong, width: 2)
          : BorderSide.none,
    );
    return SizedBox(
      height: height,
      child: FilledButton(
        key: buttonKey,
        onPressed: onPressed,
        style: FilledButton.styleFrom(
          backgroundColor: bg,
          foregroundColor: fg,
          disabledBackgroundColor: bg.withValues(alpha: 0.6),
          disabledForegroundColor: fg,
          padding: const EdgeInsets.symmetric(horizontal: 20),
          shape: shape,
        ),
        child: Text(label, style: AppWebText.button.copyWith(color: fg)),
      ),
    );
  }
}

/// A gold text link.
class LandingLink extends StatelessWidget {
  final String label;
  final VoidCallback onTap;
  final TextStyle? style;

  const LandingLink({
    super.key,
    required this.label,
    required this.onTap,
    this.style,
  });

  @override
  Widget build(BuildContext context) => TextButton(
    onPressed: onTap,
    style: TextButton.styleFrom(
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 0),
      minimumSize: const Size(0, 44),
      foregroundColor: AppColors.gold,
    ),
    child: Text(label, style: style ?? AppWebText.link),
  );
}
