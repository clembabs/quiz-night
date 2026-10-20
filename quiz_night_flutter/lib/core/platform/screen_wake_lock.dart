import 'screen_wake_lock_stub.dart'
    if (dart.library.js_interop) 'screen_wake_lock_web.dart'
    as impl;

/// Keeps the screen on while a game is running, so phones don't dim mid
/// question and the projector laptop doesn't sleep.
abstract interface class ScreenWakeLock {
  /// Asks to keep the screen on. Browsers drop the lock when the tab is
  /// hidden, so call again when the app resumes. Never throws.
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
