import 'haptics_stub.dart'
    if (dart.library.js_interop) 'haptics_web.dart'
    as impl;

/// Haptic tokens from the design system. Each pairs with a visual cue, so
/// phones without vibration (iOS Safari) lose nothing important.
enum HapticToken {
  /// Timer digit pulse in the last 3 seconds.
  tick([10]),

  /// A chip popping in.
  light([15]),

  /// Locking in an answer.
  medium([25]),

  /// A correct answer.
  success([20, 60, 20]),

  /// A wrong answer, with a shake.
  error([120]),

  /// Being eliminated.
  heavy([300]),

  /// Surviving a cut, with a shape burst.
  celebrate([30, 50, 30, 50, 60]);

  /// Vibrate/pause durations in milliseconds.
  final List<int> pattern;

  const HapticToken(this.pattern);
}

/// Plays [HapticToken]s. Players can turn it off ("Sound on / Muted").
abstract interface class Haptics {
  bool get enabled;
  set enabled(bool value);

  /// Plays [token] if enabled and supported. Never throws.
  void play(HapticToken token);
}

/// The Vibration API on web; silent elsewhere.
Haptics createHaptics() => impl.createHaptics();

/// Haptics that never vibrate: off the web, and in tests.
class SilentHaptics implements Haptics {
  @override
  bool enabled = true;

  @override
  void play(HapticToken token) {}
}
