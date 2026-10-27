import 'package:serverpod/serverpod.dart';

/// One searchable log line per thing that happens in a game:
/// `round.cut room=4821 round=2 out=3 ms=41`. Never log nicknames, topics,
/// tokens or addresses: room codes and counts are enough to follow a game.
abstract final class Events {
  static const _maxValue = 200;

  static void log(
    Session session,
    String event, [
    Map<String, Object?> fields = const {},
    LogLevel level = LogLevel.info,
  ]) => session.log(format(event, fields), level: level);

  /// `event key=value …`; nulls are left out, durations become `ms`.
  static String format(String event, Map<String, Object?> fields) => [
    event,
    for (final MapEntry(:key, :value) in fields.entries)
      if (value != null) '$key=${_value(value)}',
  ].join(' ');

  static String _value(Object value) {
    if (value is Duration) return '${value.inMilliseconds}';
    if (value is Enum) return value.name;
    var text = '$value'.replaceAll(RegExp(r'\s+'), ' ').trim();
    if (text.length > _maxValue) text = '${text.substring(0, _maxValue)}…';
    // Quote anything with spaces or quotes, so fields stay separable.
    return RegExp(r'[\s"=]').hasMatch(text)
        ? '"${text.replaceAll('"', r'\"')}"'
        : text;
  }
}
