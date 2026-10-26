import 'dart:js_interop';
import 'dart:js_interop_unsafe';

import 'package:web/web.dart' as web;

import 'screen_wake_lock.dart';

ScreenWakeLock createScreenWakeLock() => _BrowserScreenWakeLock();

/// Screen Wake Lock API; unsupported or denied requests are ignored.
class _BrowserScreenWakeLock implements ScreenWakeLock {
  web.WakeLockSentinel? _sentinel;

  bool get _supported => web.window.navigator.has('wakeLock');

  @override
  Future<void> keepOn() async {
    if (!_supported) return;
    if (_sentinel != null && !_sentinel!.released) return;
    try {
      _sentinel = await web.window.navigator.wakeLock.request('screen').toDart;
    } catch (_) {
      _sentinel = null;
    }
  }

  @override
  Future<void> release() async {
    final sentinel = _sentinel;
    _sentinel = null;
    if (sentinel == null || sentinel.released) return;
    try {
      await sentinel.release().toDart;
    } catch (_) {}
  }
}
