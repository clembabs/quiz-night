import 'dart:async';

import 'package:flutter/foundation.dart';

/// Sends one error to the server; the app passes the diagnostics endpoint.
typedef ErrorSender =
    Future<void> Function(String message, String? stackTrace, String route);

/// Sends the app's uncaught errors to the server log, next to the server's
/// own. Each distinct error once, at most [maxPerLoad] a page load; never
/// throws, and Flutter's own console output is kept.
class ErrorReporter {
  final ErrorSender _send;

  /// The page path, without the query string (it can hold a room code).
  final String Function() _route;
  final int maxPerLoad;
  final _seen = <String>{};
  int _sent = 0;

  ErrorReporter(this._send, {String Function()? route, this.maxPerLoad = 10})
    : _route = route ?? (() => Uri.base.path);

  void report(Object error, StackTrace? stackTrace) {
    final message = '${error.runtimeType}: $error';
    if (_sent >= maxPerLoad || !_seen.add(message)) return;
    _sent++;
    unawaited(
      _send(message, stackTrace?.toString(), _route()).catchError((_) {}),
    );
  }

  /// Catches errors in widgets (FlutterError) and everywhere else (the
  /// platform dispatcher).
  void install() {
    final previous = FlutterError.onError;
    FlutterError.onError = (details) {
      previous?.call(details);
      report(details.exception, details.stack);
    };
    PlatformDispatcher.instance.onError = (error, stack) {
      report(error, stack);
      // Not handled: the browser console still shows it.
      return false;
    };
  }
}
