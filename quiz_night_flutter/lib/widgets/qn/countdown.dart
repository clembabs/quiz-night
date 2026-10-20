import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_motion.dart';
import '../../core/theme/app_text_styles.dart';
import '../../features/room/round_logic.dart';

/// Chalk, then gold at 5 s, then red at 3 s.
Color countdownColor(Duration left) {
  final s = left.inMilliseconds / 1000;
  if (s <= AppCountdown.lastSeconds) return AppColors.wrong;
  if (s <= AppCountdown.hurrySeconds) return AppColors.gold;
  return AppColors.chalk;
}

/// What a countdown looks like at one moment.
class CountdownFrame {
  final Duration left;
  final Duration total;

  /// Seconds elapsed since the widget started, for pulse and shake.
  final double clock;
  final bool reducedMotion;

  const CountdownFrame(this.left, this.total, this.clock, this.reducedMotion);

  double get fraction => total.inMilliseconds == 0
      ? 0
      : (left.inMilliseconds / total.inMilliseconds).clamp(0.0, 1.0);
  int get wholeSeconds => (left.inMilliseconds / 1000).ceil();
  Color get color => countdownColor(left);
  bool get running => left > Duration.zero;
  bool get last => running && left.inMilliseconds <= 3000;
  bool get hurry => running && left.inMilliseconds <= 5000;

  /// Gentle pulse at 5 s, stronger at 3 s; none with reduced motion.
  double get pulse {
    if (reducedMotion) return 1;
    if (last) return 1 + 0.06 * sin(clock * pi * 2).abs();
    if (hurry) return 1 + 0.03 * sin(clock * pi).abs();
    return 1;
  }

  /// A small left-right shake in the last 3 seconds.
  double get shakeX {
    if (reducedMotion || !last) return 0;
    return (clock * 10).round().isOdd ? -3 : 3;
  }
}

/// Repaints every 100 ms with time left on the server's clock.
class CountdownBuilder extends StatefulWidget {
  final DateTime endsAt;
  final int totalSeconds;
  final Duration clockOffset;
  final Widget Function(BuildContext context, CountdownFrame frame) builder;

  /// Called once per whole second in the last 3 seconds (tick haptic).
  final VoidCallback? onLastSecondsTick;

  const CountdownBuilder({
    super.key,
    required this.endsAt,
    required this.totalSeconds,
    required this.clockOffset,
    required this.builder,
    this.onLastSecondsTick,
  });

  @override
  State<CountdownBuilder> createState() => _CountdownBuilderState();
}

class _CountdownBuilderState extends State<CountdownBuilder> {
  final _started = DateTime.now();
  int? _lastTick;
  late final Timer _ticker;

  @override
  void initState() {
    super.initState();
    _ticker = Timer.periodic(
      const Duration(milliseconds: 100),
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
    final now = DateTime.now();
    final frame = CountdownFrame(
      timeLeft(
        endsAt: widget.endsAt,
        clockOffset: widget.clockOffset,
        localNow: now,
      ),
      Duration(seconds: widget.totalSeconds),
      now.difference(_started).inMilliseconds / 1000,
      MediaQuery.disableAnimationsOf(context),
    );
    if (frame.last && frame.wholeSeconds != _lastTick) {
      _lastTick = frame.wholeSeconds;
      widget.onLastSecondsTick?.call();
    }
    return widget.builder(context, frame);
  }
}

/// The phone's 10 px bar across the top.
class CountdownBar extends StatelessWidget {
  final CountdownFrame frame;
  final double height;

  const CountdownBar({super.key, required this.frame, this.height = 10});

  @override
  Widget build(BuildContext context) => Transform.translate(
    offset: Offset(frame.shakeX, 0),
    child: ClipRRect(
      borderRadius: BorderRadius.circular(height / 2),
      child: Container(
        height: height,
        color: AppColors.chalk.withValues(alpha: 0.1),
        alignment: Alignment.centerLeft,
        child: FractionallySizedBox(
          widthFactor: frame.fraction,
          child: Container(
            decoration: BoxDecoration(
              color: frame.color,
              borderRadius: BorderRadius.circular(height / 2),
            ),
          ),
        ),
      ),
    ),
  );
}

/// Whole seconds, coloured and pulsing.
class CountdownSeconds extends StatelessWidget {
  final CountdownFrame frame;
  final double fontSize;

  const CountdownSeconds({super.key, required this.frame, this.fontSize = 28});

  @override
  Widget build(BuildContext context) => Transform.translate(
    offset: Offset(frame.shakeX, 0),
    child: Transform.scale(
      scale: frame.pulse,
      child: Text(
        '${frame.wholeSeconds}',
        key: const Key('countdown.seconds'),
        style: AppTextStyles.numeric.copyWith(
          fontSize: fontSize,
          color: frame.color,
        ),
      ),
    ),
  );
}

/// The host's ring: a conic sweep with the seconds inside.
class CountdownRing extends StatelessWidget {
  final CountdownFrame frame;
  final double size;

  /// The colour behind the number (the page or panel).
  final Color centre;

  const CountdownRing({
    super.key,
    required this.frame,
    this.size = 240,
    this.centre = AppColors.board,
  });

  @override
  Widget build(BuildContext context) => Transform.translate(
    offset: Offset(frame.shakeX, 0),
    child: Transform.scale(
      scale: frame.pulse,
      child: SizedBox.square(
        dimension: size,
        child: CustomPaint(
          painter: _RingPainter(frame.fraction, frame.color, centre),
          child: Center(
            child: Text(
              '${frame.wholeSeconds}',
              key: const Key('countdown.seconds'),
              style: AppTextStyles.numeric.copyWith(
                fontSize: size * 0.46,
                color: frame.color,
              ),
            ),
          ),
        ),
      ),
    ),
  );
}

class _RingPainter extends CustomPainter {
  final double fraction;
  final Color color;
  final Color centre;

  _RingPainter(this.fraction, this.color, this.centre);

  @override
  void paint(Canvas canvas, Size size) {
    final rect = Offset.zero & size;
    canvas.drawOval(
      rect,
      Paint()..color = AppColors.chalk.withValues(alpha: 0.1),
    );
    canvas.drawArc(
      rect,
      -pi / 2,
      2 * pi * fraction,
      true,
      Paint()..color = color,
    );
    // Inner disc: ring thickness is ~9% of the diameter, as in the design.
    canvas.drawCircle(
      rect.center,
      size.width * 0.408,
      Paint()..color = centre,
    );
  }

  @override
  bool shouldRepaint(_RingPainter old) =>
      old.fraction != fraction || old.color != color || old.centre != centre;
}
