import 'package:flutter/material.dart';

import '../core/theme/app_colors.dart';
import '../core/theme/app_spacing.dart';
import '../core/theme/app_text_styles.dart';

/// Centres [child] and caps its width, for phone-style screens on any device.
class CenteredContent extends StatelessWidget {
  final double maxWidth;
  final Widget child;

  const CenteredContent({
    super.key,
    this.maxWidth = AppSpacing.phoneMaxWidth,
    required this.child,
  });

  @override
  Widget build(BuildContext context) => Center(
    child: ConstrainedBox(
      constraints: BoxConstraints(maxWidth: maxWidth),
      child: child,
    ),
  );
}

/// A big icon over a line of muted text.
class MessageView extends StatelessWidget {
  final IconData icon;
  final String text;

  const MessageView({super.key, required this.icon, required this.text});

  @override
  Widget build(BuildContext context) => Center(
    child: Padding(
      padding: AppSpacing.screenPadding,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: AppIconSizes.message, color: AppColors.muted),
          const SizedBox(height: AppSpacing.md),
          Text(
            text,
            textAlign: TextAlign.center,
            style: AppTextStyles.bodyMuted,
          ),
        ],
      ),
    ),
  );
}

/// Inline error message, or nothing.
class ErrorText extends StatelessWidget {
  final String? message;

  const ErrorText(this.message, {super.key});

  @override
  Widget build(BuildContext context) {
    final m = message;
    if (m == null) return const SizedBox.shrink();
    return Padding(
      padding: const EdgeInsets.only(top: AppSpacing.sm),
      child: Text(m, style: AppTextStyles.error),
    );
  }
}

/// A filled button that shows a spinner while [loading].
class LoadingButton extends StatelessWidget {
  final String label;
  final bool loading;
  final VoidCallback? onPressed;

  const LoadingButton({
    super.key,
    required this.label,
    required this.loading,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) => FilledButton(
    onPressed: loading ? null : onPressed,
    child: loading
        ? const SizedBox.square(
            dimension: 24,
            child: CircularProgressIndicator(strokeWidth: 3),
          )
        : Text(label),
  );
}

/// A labelled `- value +` control.
class NumberStepper extends StatelessWidget {
  final String label;
  final int value;
  final int min;
  final int max;
  final int step;
  final ValueChanged<int> onChanged;

  const NumberStepper({
    super.key,
    required this.label,
    required this.value,
    required this.min,
    required this.max,
    required this.onChanged,
    this.step = 1,
  });

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.symmetric(vertical: AppSpacing.xs),
    child: Row(
      children: [
        Expanded(child: Text(label, style: AppTextStyles.body)),
        IconButton.filledTonal(
          tooltip: 'Decrease $label',
          onPressed: value > min ? () => onChanged(value - step) : null,
          icon: const Icon(Icons.remove),
        ),
        SizedBox(
          width: 48,
          child: Text(
            '$value',
            textAlign: TextAlign.center,
            style: AppTextStyles.stepperValue,
          ),
        ),
        IconButton.filledTonal(
          tooltip: 'Increase $label',
          onPressed: value < max ? () => onChanged(value + step) : null,
          icon: const Icon(Icons.add),
        ),
      ],
    ),
  );
}
