import 'dart:js_interop';
import 'dart:js_interop_unsafe';

import 'package:web/web.dart' as web;

import 'haptics.dart';

Haptics createHaptics() => _VibrationHaptics();

/// The Vibration API (Android Chrome). Unsupported browsers are ignored.
class _VibrationHaptics implements Haptics {
  @override
  bool enabled = true;

  bool get _supported => web.window.navigator.has('vibrate');

  @override
  void play(HapticToken token) {
    if (!enabled || !_supported) return;
    try {
      web.window.navigator.vibrate(
        token.pattern.map((ms) => ms.toJS).toList().toJS,
      );
    } catch (_) {}
  }
}
