import 'screen_wake_lock_stub.dart'
    if (dart.library.js_interop) 'screen_wake_lock_web.dart'
    as impl;

/// Keeps the screen on mid-game so phones don't dim and laptops don't sleep.
abstract interface class ScreenWakeLock {
  /// Keeps the screen on; browsers drop it when hidden, so call on resume.
  Future<void> keepOn();

  /// Lets the screen sleep again. Never throws.
  Future<void> release();
}

/// The browser wake lock on web; does nothing elsewhere.
ScreenWakeLock createScreenWakeLock() => impl.createScreenWakeLock();

/// A wake lock that does nothing: off the web, and in tests.
class NoopScreenWakeLock implements ScreenWakeLock {
  const NoopScreenWakeLock();

  @override
  Future<void> keepOn() async {}

  @override
  Future<void> release() async {}
}
