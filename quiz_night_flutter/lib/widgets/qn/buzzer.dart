import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_motion.dart';
import '../../core/theme/app_text_styles.dart';

/// How the buzzer looks right now (design system "Buzzer").
class BuzzerLook {
  final String title;
  final String subtitle;
  final Color bg;
  final Color fg;
  final Color rim;
  final Color shadow;

  const BuzzerLook({
    required this.title,
    required this.subtitle,
    required this.bg,
    required this.fg,
    required this.rim,
    required this.shadow,
  });

  /// Maroon: tap when you know it.
  static const ready = BuzzerLook(
    title: 'Buzz',
    subtitle: 'Tap when you know it',
    bg: AppColors.maroon,
    fg: AppColors.white,
    rim: AppColors.maroonRim,
    shadow: AppColors.maroonDarkest,
  );

  /// Gold: you buzzed first.
  static const first = BuzzerLook(
    title: 'First!',
    subtitle: 'Pick your answer below',
    bg: AppColors.gold,
    fg: AppColors.goldInk,
    rim: AppColors.goldRim,
    shadow: AppColors.goldShadow,
  );

  /// Grey: someone else buzzed first.
  static BuzzerLook other(String name) => BuzzerLook(
    title: name,
    subtitle: 'buzzed first · wait',
    bg: AppColors.slate,
    fg: AppColors.chalk,
    rim: AppColors.surfaceHigh,
    shadow: AppColors.board,
  );

  /// Dark: locked out for this question.
  static const locked = BuzzerLook(
    title: 'Locked',
    subtitle: 'Locked out this question',
    bg: AppColors.surfaceHigh,
    fg: AppColors.muted,
    rim: AppColors.surface,
    shadow: AppColors.boardDeep,
  );

  /// Grey: between questions.
  static const wait = BuzzerLook(
    title: 'Get ready',
    subtitle: 'Next question soon',
    bg: AppColors.slate,
    fg: AppColors.chalkSoft,
    rim: AppColors.surfaceHigh,
    shadow: AppColors.board,
  );
}

/// The round buzzer; press feedback is local, before the server confirms.
class BuzzerButton extends StatefulWidget {
  final BuzzerLook look;
  final double size;
  final VoidCallback? onPressed;

  const BuzzerButton({
    super.key,
    required this.look,
    this.size = 260,
    this.onPressed,
  });

  @override
  State<BuzzerButton> createState() => _BuzzerButtonState();
}

class _BuzzerButtonState extends State<BuzzerButton> {
  bool _down = false;

  void _press() {
    setState(() => _down = true);
    widget.onPressed?.call();
  }

  @override
  Widget build(BuildContext context) {
    final l = widget.look;
    final enabled = widget.onPressed != null;
    final pressed = _down && enabled;
    return Semantics(
      button: true,
      enabled: enabled,
      label: '${l.title}. ${l.subtitle}',
      onTap: widget.onPressed,
      excludeSemantics: true,
      // Pointer-down: taps in scrollables wait ~100 ms and lose races.
      child: Listener(
        key: const Key('buzz'),
        onPointerDown: enabled ? (_) => _press() : null,
        onPointerUp: (_) => setState(() => _down = false),
        onPointerCancel: (_) => setState(() => _down = false),
        child: AnimatedContainer(
          duration: AppDurations.instant,
          width: widget.size,
          height: widget.size,
          transform: Matrix4.translationValues(0, pressed ? 6 : 0, 0),
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: l.bg,
            border: Border.all(color: l.rim, width: 10),
            boxShadow: [
              BoxShadow(
                color: l.shadow,
                offset: Offset(0, pressed ? 2 : 8),
              ),
            ],
          ),
          alignment: Alignment.center,
          child: Padding(
            padding: EdgeInsets.all(widget.size * 0.15),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                FittedBox(
                  child: Text(
                    l.title.toUpperCase(),
                    style: AppTextStyles.displayL.copyWith(
                      fontSize: 42,
                      color: l.fg,
                      height: 1.0,
                    ),
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  l.subtitle,
                  textAlign: TextAlign.center,
                  style: AppTextStyles.chip.copyWith(color: l.fg, fontSize: 15),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
