import 'dart:async';

import 'package:flutter/material.dart';

import '../core/theme/app_colors.dart';
import '../core/theme/app_spacing.dart';
import '../core/theme/app_text_styles.dart';
import '../features/room/round_logic.dart';

/// Seconds left plus a shrinking bar, on the server's clock.
///
/// Stateful only to repaint on a timer; the time itself comes from
/// [timeLeft], so every screen shows the same countdown.
class CountdownBar extends StatefulWidget {
  final DateTime endsAt;
  final int totalSeconds;
  final Duration clockOffset;

  /// Below this many seconds the bar turns red.
  static const warningSeconds = 5;

  const CountdownBar({
    super.key,
    required this.endsAt,
    required this.totalSeconds,
    required this.clockOffset,
  });

  @override
  State<CountdownBar> createState() => _CountdownBarState();
}

class _CountdownBarState extends State<CountdownBar> {
  late final Timer _ticker = Timer.periodic(
    const Duration(milliseconds: 100),
    (_) => setState(() {}),
  );

  @override
  void dispose() {
    _ticker.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final left = timeLeft(
      endsAt: widget.endsAt,
      clockOffset: widget.clockOffset,
      localNow: DateTime.now(),
    );
    final total = widget.totalSeconds * 1000;
    final fraction = total == 0
        ? 0.0
        : (left.inMilliseconds / total).clamp(0.0, 1.0);
    final seconds = (left.inMilliseconds / 1000).ceil();
    final urgent = seconds <= CountdownBar.warningSeconds;
    final color = urgent ? AppColors.danger : AppColors.gold;

    return Row(
      children: [
        Expanded(
          child: ClipRRect(
            borderRadius: BorderRadius.circular(AppRadii.pill),
            child: LinearProgressIndicator(
              value: fraction,
              minHeight: 12,
              color: color,
              backgroundColor: AppColors.surfaceHigh,
            ),
          ),
        ),
        const SizedBox(width: AppSpacing.md),
        SizedBox(
          width: 56,
          child: Text(
            '$seconds',
            key: const Key('countdown.seconds'),
            textAlign: TextAlign.end,
            style: AppTextStyles.timer.copyWith(color: color),
          ),
        ),
      ],
    );
  }
}
