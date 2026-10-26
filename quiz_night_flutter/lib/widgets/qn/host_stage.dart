import 'dart:math';

import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../brand/chalk_background.dart';
import '../brand/crest.dart';
import 'notices.dart';

/// Size of the projector canvas every host screen is designed on.
const hostCanvas = Size(1920, 1080);

/// Narrowest portrait canvas; its height follows the window to fill it.
const hostPortraitWidth = 800.0;

/// Projector or portrait layout; portrait screens stack their columns.
class HostLayout extends InheritedWidget {
  final bool portrait;

  const HostLayout({super.key, required this.portrait, required super.child});

  /// Portrait when an ancestor [HostStage] says so; landscape otherwise.
  static bool isPortrait(BuildContext context) =>
      context.dependOnInheritedWidgetOfExactType<HostLayout>()?.portrait ??
      false;

  @override
  bool updateShouldNotify(HostLayout old) => old.portrait != portrait;
}

/// Scales a fixed canvas to the window: 1920×1080 wide, 800 wide portrait,
/// so text on phones stays readable instead of shrinking to a strip.
class HostStage extends StatelessWidget {
  final Widget child;

  /// Phase label in the header ("Lobby", "Round 2 · Question 4"…).
  final String topLabel;

  /// The room code pill; hidden while creating the room.
  final String? code;
  final bool reconnecting;

  /// Small actions in the header's right edge (e.g. Leave).
  final List<Widget> actions;

  /// Time left in the game, shown beside the room code.
  final Widget? clock;

  const HostStage({
    super.key,
    required this.child,
    required this.topLabel,
    this.code,
    this.reconnecting = false,
    this.actions = const [],
    this.clock,
  });

  /// The canvas for a window of [window] logical pixels.
  static Size canvasFor(Size window) {
    if (window.width >= window.height || window.width <= 0) return hostCanvas;
    // Phones get 800; upright tablets wider, not a stretched phone.
    final width = max(hostPortraitWidth, window.width * 1.35);
    return Size(width, width * window.height / window.width);
  }

  @override
  Widget build(BuildContext context) {
    return ColoredBox(
      color: AppColors.boardDeep,
      child: LayoutBuilder(
        builder: (context, constraints) {
          final canvas = canvasFor(constraints.biggest);
          final portrait = canvas != hostCanvas;
          return Center(
            child: FittedBox(
              child: SizedBox.fromSize(
                size: canvas,
                child: MediaQuery(
                  // Fixed design size: ignore text scale to avoid overflow.
                  data: MediaQuery.of(
                    context,
                  ).copyWith(textScaler: TextScaler.noScaling),
                  child: HostLayout(
                    portrait: portrait,
                    child: ChalkBackground(
                      spacing: 12,
                      child: Stack(
                        children: [
                          Padding(
                            padding: portrait
                                ? const EdgeInsets.fromLTRB(40, 48, 40, 40)
                                : const EdgeInsets.symmetric(
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
                                  clock: clock,
                                  portrait: portrait,
                                ),
                                SizedBox(height: portrait ? 32 : 40),
                                Expanded(child: child),
                              ],
                            ),
                          ),
                          if (reconnecting)
                            const Positioned(
                              top: 40,
                              left: 0,
                              right: 0,
                              child: Center(
                                child: ReconnectingPill(large: true),
                              ),
                            ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

/// Two panes: side by side on the projector, stacked on a portrait phone.
class HostSplit extends StatelessWidget {
  final Widget first;
  final Widget second;
  final int firstFlex;
  final int secondFlex;
  final double gap;

  /// Pane taking spare height when stacked; null scrolls both.
  final HostSplitFill? portraitFill;

  const HostSplit({
    super.key,
    required this.first,
    required this.second,
    this.firstFlex = 1,
    this.secondFlex = 1,
    this.gap = 64,
    this.portraitFill = HostSplitFill.first,
  });

  @override
  Widget build(BuildContext context) {
    if (!HostLayout.isPortrait(context)) {
      return Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Expanded(flex: firstFlex, child: first),
          SizedBox(width: gap),
          Expanded(flex: secondFlex, child: second),
        ],
      );
    }
    const portraitGap = SizedBox(height: 32);
    return switch (portraitFill) {
      HostSplitFill.first => Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Expanded(child: first),
          portraitGap,
          second,
        ],
      ),
      HostSplitFill.second => Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          first,
          portraitGap,
          Expanded(child: second),
        ],
      ),
      null => SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [first, portraitGap, second],
        ),
      ),
    };
  }
}

enum HostSplitFill { first, second }

class _Header extends StatelessWidget {
  final String topLabel;
  final String? code;
  final List<Widget> actions;
  final Widget? clock;
  final bool portrait;

  const _Header({
    required this.topLabel,
    this.code,
    required this.actions,
    this.clock,
    required this.portrait,
  });

  @override
  Widget build(BuildContext context) {
    final label = Text(
      topLabel,
      maxLines: 1,
      overflow: TextOverflow.ellipsis,
      style: AppProjectorText.label.copyWith(fontSize: 32, letterSpacing: 0),
    );
    final codePill = code == null
        ? null
        : Container(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 10),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(14),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
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
          );
    final brand = [
      const Crest(width: 64),
      const SizedBox(width: 24),
      Text('QUIZ NIGHT', style: AppTextStyles.headline.copyWith(fontSize: 40)),
    ];
    final actionRow = [
      for (final a in actions) ...[const SizedBox(width: 16), a],
    ];

    // Phones: brand and actions on top, phase and code underneath.
    if (portrait) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(children: [...brand, const Spacer(), ...actionRow]),
          const SizedBox(height: 24),
          Row(
            children: [
              Expanded(child: label),
              if (codePill != null) ...[const SizedBox(width: 16), codePill],
            ],
          ),
          // Its own line: a phone is too narrow for phase, clock and code.
          if (clock != null) ...[
            const SizedBox(height: 16),
            Align(alignment: Alignment.centerLeft, child: clock),
          ],
        ],
      );
    }
    return Row(
      children: [
        ...brand,
        const SizedBox(width: 24),
        Expanded(
          child: Align(alignment: Alignment.centerRight, child: label),
        ),
        if (clock != null) ...[const SizedBox(width: 24), clock!],
        if (codePill != null) ...[const SizedBox(width: 24), codePill],
        ...actionRow,
      ],
    );
  }
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
