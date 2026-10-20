import 'dart:math';

import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../brand/crest.dart';

/// Three dots pulsing in turn: "waiting" and "reconnecting".
class PulsingDots extends StatefulWidget {
  final double size;
  final Color color;

  const PulsingDots({super.key, this.size = 7, this.color = AppColors.mint});

  @override
  State<PulsingDots> createState() => _PulsingDotsState();
}

class _PulsingDotsState extends State<PulsingDots>
    with SingleTickerProviderStateMixin {
  late final _c = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 1200),
  )..repeat();

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  // 0%, 80%, 100%: faint and small; 40%: full.
  double _pulse(double t) {
    final x = (t % 1.0);
    if (x > 0.8) return 0;
    return sin(x / 0.8 * pi);
  }

  @override
  Widget build(BuildContext context) {
    final reduced = MediaQuery.disableAnimationsOf(context);
    return AnimatedBuilder(
      animation: _c,
      builder: (context, _) => Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          for (var i = 0; i < 3; i++) ...[
            if (i > 0) SizedBox(width: widget.size * 0.6),
            Builder(
              builder: (context) {
                final p = reduced ? 1.0 : _pulse(_c.value - i * 0.133);
                return Opacity(
                  opacity: 0.25 + 0.75 * p,
                  child: Transform.scale(
                    scale: 0.8 + 0.2 * p,
                    child: Container(
                      width: widget.size,
                      height: widget.size,
                      decoration: BoxDecoration(
                        color: widget.color,
                        shape: BoxShape.circle,
                      ),
                    ),
                  ),
                );
              },
            ),
          ],
        ],
      ),
    );
  }
}

/// A thin gold bar filling from the left, over and over.
class LoadBar extends StatefulWidget {
  final double width;

  const LoadBar({super.key, this.width = 140});

  @override
  State<LoadBar> createState() => _LoadBarState();
}

class _LoadBarState extends State<LoadBar> with SingleTickerProviderStateMixin {
  late final _c = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 1600),
  )..repeat();

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => ClipRRect(
    borderRadius: BorderRadius.circular(2),
    child: Container(
      width: widget.width,
      height: 4,
      color: AppColors.chalk.withValues(alpha: 0.12),
      alignment: Alignment.centerLeft,
      child: AnimatedBuilder(
        animation: _c,
        builder: (context, _) => FractionallySizedBox(
          widthFactor: const Cubic(0.2, 0, 0, 1).transform(_c.value),
          child: Container(color: AppColors.gold),
        ),
      ),
    ),
  );
}

/// The full-screen "Loading Quiz Night…" (crest, bar, caption).
class LoadingView extends StatelessWidget {
  const LoadingView({super.key});

  @override
  Widget build(BuildContext context) => Center(
    child: Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        const Crest(width: 64),
        const SizedBox(height: 20),
        const LoadBar(),
        const SizedBox(height: 20),
        Text(
          'Loading Quiz Night…',
          style: AppTextStyles.caption.copyWith(
            fontSize: 14,
          ),
        ),
      ],
    ),
  );
}
