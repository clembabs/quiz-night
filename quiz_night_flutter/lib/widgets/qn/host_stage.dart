import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../brand/chalk_background.dart';
import '../brand/crest.dart';
import 'notices.dart';

/// Size of the projector canvas every host screen is designed on.
const hostCanvas = Size(1920, 1080);

/// Lays [child] out on a 1920×1080 canvas and scales it to fit the window,
/// so the projector, a laptop and a tablet all show the same composition.
class HostStage extends StatelessWidget {
  final Widget child;

  /// Phase label in the header ("Lobby", "Round 2 · Question 4"…).
  final String topLabel;

  /// The room code pill; hidden while creating the room.
  final String? code;
  final bool reconnecting;

  /// Small actions in the header's right edge (e.g. Leave).
  final List<Widget> actions;

  const HostStage({
    super.key,
    required this.child,
    required this.topLabel,
    this.code,
    this.reconnecting = false,
    this.actions = const [],
  });

  @override
  Widget build(BuildContext context) {
    return ColoredBox(
      color: AppColors.boardDeep,
      child: Center(
        child: FittedBox(
          child: SizedBox.fromSize(
            size: hostCanvas,
            child: MediaQuery(
              // The canvas is a fixed design size; ignore the window's text
              // scale so 1080p layouts do not overflow.
              data: MediaQuery.of(
                context,
              ).copyWith(textScaler: TextScaler.noScaling),
              child: ChalkBackground(
                spacing: 12,
                child: Stack(
                  children: [
                    Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 72,
                        vertical: 56,
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          _Header(
                            topLabel: topLabel,
                            code: code,
                            actions: actions,
                          ),
                          const SizedBox(height: 40),
                          Expanded(child: child),
                        ],
                      ),
                    ),
                    if (reconnecting)
                      const Positioned(
                        top: 40,
                        left: 0,
                        right: 0,
                        child: Center(child: ReconnectingPill(large: true)),
                      ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _Header extends StatelessWidget {
  final String topLabel;
  final String? code;
  final List<Widget> actions;

  const _Header({required this.topLabel, this.code, required this.actions});

  @override
  Widget build(BuildContext context) => Row(
    children: [
      const Crest(width: 64),
      const SizedBox(width: 24),
      Text('QUIZ NIGHT', style: AppTextStyles.headline.copyWith(fontSize: 40)),
      const Spacer(),
      Text(
        topLabel,
        style: AppProjectorText.label.copyWith(
          fontSize: 32,
          letterSpacing: 0,
        ),
      ),
      if (code != null) ...[
        const SizedBox(width: 24),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 10),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(14),
          ),
          child: Row(
            children: [
              Text(
                'Code',
                style: AppProjectorText.label.copyWith(
                  fontSize: 24,
                  letterSpacing: 0,
                ),
              ),
              const SizedBox(width: 12),
              Text(
                code!,
                style: AppTextStyles.numeric.copyWith(
                  fontSize: 40,
                  letterSpacing: 4.8,
                ),
              ),
            ],
          ),
        ),
      ],
      for (final a in actions) ...[const SizedBox(width: 16), a],
    ],
  );
}

/// A big projector button (120 px tall, display caps).
class HostButton extends StatelessWidget {
  final String label;
  final VoidCallback? onPressed;
  final Color background;
  final Color foreground;
  final Key? buttonKey;
  final double height;

  const HostButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.background = AppColors.gold,
    this.foreground = AppColors.goldInk,
    this.buttonKey,
    this.height = 120,
  });

  @override
  Widget build(BuildContext context) => SizedBox(
    height: height,
    child: FilledButton(
      key: buttonKey,
      onPressed: onPressed,
      style: FilledButton.styleFrom(
        backgroundColor: background,
        foregroundColor: foreground,
        disabledBackgroundColor: AppColors.slateDim,
        disabledForegroundColor: AppColors.goldInk,
        padding: const EdgeInsets.symmetric(horizontal: 72),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      ),
      child: Text(
        label.toUpperCase(),
        style: AppTextStyles.headline.copyWith(
          fontSize: height * 0.4,
          color: foreground,
        ),
      ),
    ),
  );
}

/// A quiet projector button for secondary actions (Leave, Skip).
class HostTextButton extends StatelessWidget {
  final String label;
  final VoidCallback? onPressed;

  const HostTextButton({super.key, required this.label, this.onPressed});

  @override
  Widget build(BuildContext context) => SizedBox(
    height: 64,
    child: OutlinedButton(
      onPressed: onPressed,
      style: OutlinedButton.styleFrom(
        padding: const EdgeInsets.symmetric(horizontal: 28),
        side: BorderSide(
          color: AppColors.chalk.withValues(alpha: 0.4),
          width: 2,
        ),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      ),
      child: Text(
        label,
        style: AppProjectorText.label.copyWith(
          color: AppColors.chalk,
          fontSize: 26,
          letterSpacing: 0,
        ),
      ),
    ),
  );
}
