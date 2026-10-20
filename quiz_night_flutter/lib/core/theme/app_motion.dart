import 'package:flutter/animation.dart';

/// Durations (design system "Motion"). Transform and opacity only.
abstract final class AppDurations {
  static const instant = Duration(milliseconds: 50);
  static const fast = Duration(milliseconds: 150);
  static const normal = Duration(milliseconds: 250);
  static const slow = Duration(milliseconds: 400);
  static const dramatic = Duration(milliseconds: 900);

  /// Gap between staggered items (answer options, leaderboard rows).
  static const stagger = Duration(milliseconds: 60);
}

/// Easing curves (design system "Easing curves").
abstract final class AppCurves {
  /// Most transitions.
  static const standard = Cubic(0.2, 0, 0, 1);

  /// Entries and staggers.
  static const decelerate = Cubic(0.05, 0.7, 0.1, 1);

  /// Exits; the eliminated drop.
  static const accelerate = Cubic(0.3, 0, 1, 1);

  /// Stamp, pop, podium: a little overshoot.
  static const stamp = Cubic(0.34, 1.56, 0.64, 1);
}

/// Countdown thresholds: chalk, then gold at 5 s, then red at 3 s.
abstract final class AppCountdown {
  static const hurrySeconds = 5;
  static const lastSeconds = 3;
}
