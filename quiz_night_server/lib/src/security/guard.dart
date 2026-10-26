import 'package:serverpod/serverpod.dart';

import '../generated/protocol.dart';
import 'client_address.dart';
import 'rate_limiter.dart';

/// Sized for a venue sharing one Wi-Fi: generous per address, tight per token.
abstract final class Limits {
  /// New rooms per address.
  static const createRoom = RateLimit('createRoom', 20, Duration(hours: 1));

  /// Joins per address: a roomful on one Wi-Fi, but not a room-hopping script.
  static const joinRoom = RateLimit('joinRoom', 60, Duration(minutes: 1));

  /// Joins per room from any address: stops a script flooding a known code.
  static const joinPerRoom = RateLimit('joinPerRoom', 20, Duration(minutes: 1));

  /// Wrong codes per address: over 6 a minute blocks 5 minutes, making 4-digit
  /// code guessing impractical while real typos stay well under.
  static const wrongCode = RateLimit(
    'wrongCode',
    6,
    Duration(minutes: 1),
    blockFor: Duration(minutes: 5),
  );

  /// Reconnects per address (phones waking up, flaky Wi-Fi).
  static const rejoin = RateLimit('rejoin', 120, Duration(minutes: 1));

  /// Host controls per host token.
  static const hostAction = RateLimit('hostAction', 120, Duration(minutes: 1));

  /// Answers, buzzes and backing a finalist, per player token.
  static const playerAction = RateLimit(
    'playerAction',
    30,
    Duration(seconds: 10),
  );

  /// New room streams per address.
  static const watch = RateLimit('watch', 300, Duration(minutes: 1));

  /// Open streams per address: a full room plus host, with reconnect overlap.
  static const maxOpenStreams = 60;
}

/// Applies [Limits] in endpoints. Off for tests; `server.dart` turns it on.
abstract final class Guard {
  static bool enabled = false;
  static RateLimiter limiter = RateLimiter();
  static StreamSlots streams = StreamSlots();

  /// Clock, replaceable in tests.
  static DateTime Function() now = () => DateTime.now().toUtc();

  static QuizException get _tooMany => QuizException(
    code: QuizErrorCode.rateLimited,
    message: 'Too many requests. Wait a moment and try again.',
  );

  /// Counts a call for [key] (default: address); throws once used up.
  static void check(Session session, RateLimit limit, {String? key}) {
    if (!enabled) return;
    if (!limiter.tryAcquire(key ?? clientAddress(session), limit, now())) {
      throw _tooMany;
    }
  }

  /// Throws if [limit] is used up, without counting; pair with [recordFailure].
  static void checkFailures(Session session, RateLimit limit) {
    if (!enabled) return;
    if (limiter.isExhausted(clientAddress(session), limit, now())) {
      throw _tooMany;
    }
  }

  static void recordFailure(Session session, RateLimit limit) {
    if (!enabled) return;
    limiter.record(clientAddress(session), limit, now());
  }

  /// Takes a stream slot (throws if too many); returns the release function.
  static void Function() openStream(Session session) {
    if (!enabled) return () {};
    final key = clientAddress(session);
    if (!streams.tryOpen(key, Limits.maxOpenStreams)) throw _tooMany;
    var closed = false;
    return () {
      if (closed) return;
      closed = true;
      streams.close(key);
    };
  }

  /// Back to a clean state; for tests.
  static void reset() {
    limiter.clear();
    streams.clear();
    now = () => DateTime.now().toUtc();
  }
}
