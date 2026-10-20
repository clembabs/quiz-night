import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_text_styles.dart';

/// The giant round BUZZ button. Disabled when [onPressed] is null.
class BuzzButton extends StatelessWidget {
  final VoidCallback? onPressed;
  final String label;

  const BuzzButton({super.key, required this.onPressed, this.label = 'BUZZ'});

  @override
  Widget build(BuildContext context) {
    final enabled = onPressed != null;
    return Semantics(
      button: true,
      enabled: enabled,
      label: label,
      // Screen readers activate through semantics, not pointer events.
      onTap: onPressed,
      // A raw pointer-down fires on contact. A tap recognizer inside a
      // scrollable waits ~100ms to rule out a scroll, which loses races.
      child: Listener(
        key: const Key('buzz'),
        onPointerDown: enabled ? (_) => onPressed!() : null,
        child: AnimatedOpacity(
          duration: const Duration(milliseconds: 150),
          opacity: enabled ? 1 : 0.35,
          child: Container(
            width: AppSpacing.buzzerSize,
            height: AppSpacing.buzzerSize,
            alignment: Alignment.center,
            decoration: const BoxDecoration(
              shape: BoxShape.circle,
              color: AppColors.buzzer,
              border: Border.fromBorderSide(
                BorderSide(color: AppColors.buzzerRim, width: 12),
              ),
              boxShadow: [
                BoxShadow(
                  color: AppColors.buzzerRim,
                  offset: Offset(0, 10),
                  blurRadius: 0,
                ),
              ],
            ),
            child: Text(label, style: AppTextStyles.buzzLabel),
          ),
        ),
      ),
    );
  }
}
