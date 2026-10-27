import 'package:serverpod/serverpod.dart';

import '../observability/events.dart';
import '../security/guard.dart';

/// Errors from the web app, written to the server log so they show up next
/// to the server's own (Serverpod Cloud Logs and Insights).
class DiagnosticsEndpoint extends Endpoint {
  /// The most any log field holds (see [Events]).
  static const maxMessage = 200;
  static const maxStack = 4000;
  static const maxRoute = 100;

  /// Logs one app error. [route] is the page it happened on (`/room/4821`).
  Future<void> reportError(
    Session session,
    String message,
    String? stackTrace,
    String route,
  ) async {
    Guard.check(session, Limits.clientError);
    session.log(
      Events.format('client.error', {
        'route': _cut(route, maxRoute),
        'message': _cut(message, maxMessage),
      }),
      level: LogLevel.error,
      stackTrace: stackTrace == null || stackTrace.isEmpty
          ? null
          : StackTrace.fromString(_cut(stackTrace, maxStack)),
    );
  }

  static String _cut(String text, int max) =>
      text.length <= max ? text : '${text.substring(0, max)}…';
}
