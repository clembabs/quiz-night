import 'dart:async';

import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_motion.dart';
import '../../core/theme/app_text_styles.dart';

/// Covers [child] with a 3-2-1 until [startsAt] (server time), so every
/// screen starts the question together; nothing under it can be pressed.
class GetReady extends StatefulWidget {
  final DateTime? startsAt;

  /// Server minus local time, so the count matches the server's clock.
  final Duration clockOffset;
  final Widget child;

  /// Projector size, for the host screen.
  final bool large;

  /// Called on each number (a buzz on phones).
  final VoidCallback? onTick;

  const GetReady({
    super.key,
    required this.startsAt,
    required this.clockOffset,
    required this.child,
    this.large = false,
    this.onTick,
  });

  /// Whole seconds left before [startsAt], 0 once it has passed.
  static int secondsLeft(DateTime? startsAt, Duration offset, DateTime now) {
    if (startsAt == null) return 0;
    final left = startsAt.difference(now.toUtc().add(offset));
    if (left <= Duration.zero) return 0;
    return (left.inMilliseconds / 1000).ceil();
  }

  @override
  State<GetReady> createState() => _GetReadyState();
}

class _GetReadyState extends State<GetReady> {
  Timer? _timer;
  int _left = 0;

  int get _now =>
      GetReady.secondsLeft(widget.startsAt, widget.clockOffset, DateTime.now());

  @override
  void initState() {
    super.initState();
    _left = _now;
    _schedule();
  }

  @override
  void didUpdateWidget(GetReady old) {
    super.didUpdateWidget(old);
    if (old.startsAt != widget.startsAt) {
      _left = _now;
      _schedule();
    }
  }

  void _schedule() {
    _timer?.cancel();
    if (_left == 0) return;
    widget.onTick?.call();
    _timer = Timer.periodic(const Duration(milliseconds: 100), (_) {
      final left = _now;
      if (left == _left) return;
      setState(() => _left = left);
      if (left == 0) {
        _timer?.cancel();
      } else {
        widget.onTick?.call();
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => Stack(
    children: [
      widget.child,
      if (_left > 0)
        Positioned.fill(
          child: ColoredBox(
            key: const Key('getReady'),
            color: AppColors.board.withValues(alpha: 0.94),
            child: Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'GET READY',
                    style: AppTextStyles.label.copyWith(
                      color: AppColors.gold,
                      fontSize: widget.large ? 40 : 16,
                      letterSpacing: 2,
                    ),
                  ),
                  const SizedBox(height: 8),
                  // Each number pops in, like the stamps.
                  TweenAnimationBuilder<double>(
                    key: ValueKey(_left),
                    tween: Tween(begin: 1.5, end: 1),
                    duration: AppDurations.slow,
                    curve: AppCurves.stamp,
                    builder: (context, s, child) =>
                        Transform.scale(scale: s, child: child),
                    child: Text(
                      '$_left',
                      key: const Key('getReady.count'),
                      style: AppTextStyles.displayXl.copyWith(
                        fontSize: widget.large ? 280 : 140,
                        height: 1,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
    ],
  );
}
