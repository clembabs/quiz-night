import 'dart:async';

import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../features/room/round_logic.dart';

/// Game time left on the server's clock; gold under 5 min, red under 1.
class SessionClock extends StatefulWidget {
  final DateTime endsAt;
  final Duration clockOffset;

  /// Projector size (the host header) rather than phone size.
  final bool large;

  const SessionClock({
    super.key,
    required this.endsAt,
    required this.clockOffset,
    this.large = false,
  });

  /// `mm:ss`, for [left].
  static String format(Duration left) {
    final minutes = left.inMinutes;
    final seconds = left.inSeconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:'
        '${seconds.toString().padLeft(2, '0')}';
  }

  /// The colour for [left]: chalk, then gold, then red.
  static Color colorFor(Duration left) {
    if (left <= const Duration(minutes: 1)) return AppColors.errorText;
    if (left <= const Duration(minutes: 5)) return AppColors.gold;
    return AppColors.chalkSoft;
  }

  @override
  State<SessionClock> createState() => _SessionClockState();
}

/// Stateful only to tick once a second.
class _SessionClockState extends State<SessionClock> {
  late final Timer _ticker;

  @override
  void initState() {
    super.initState();
    _ticker = Timer.periodic(
      const Duration(seconds: 1),
      (_) => setState(() {}),
    );
  }

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
    final color = SessionClock.colorFor(left);
    final text = '⏱ ${SessionClock.format(left)} left';
    return Semantics(
      label:
          '${left.inMinutes} minutes ${left.inSeconds % 60} seconds left '
          'in this game',
      excludeSemantics: true,
      child: Container(
        key: const Key('session.clock'),
        padding: EdgeInsets.symmetric(
          horizontal: widget.large ? 24 : 10,
          vertical: widget.large ? 10 : 3,
        ),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(widget.large ? 14 : 999),
          border: Border.all(color: color.withValues(alpha: 0.5)),
        ),
        child: Text(
          text,
          style: (widget.large ? AppProjectorText.label : AppTextStyles.label)
              .copyWith(
                fontSize: widget.large ? 30 : 13,
                color: color,
                letterSpacing: 0,
                fontFeatures: const [FontFeature.tabularFigures()],
              ),
        ),
      ),
    );
  }
}
