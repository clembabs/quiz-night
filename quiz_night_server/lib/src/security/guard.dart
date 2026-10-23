import 'package:serverpod/serverpod.dart';

import '../generated/protocol.dart';
import 'client_address.dart';
import 'rate_limiter.dart';

/// The limits, sized for a classroom or venue where every phone shares one
/// Wi-Fi address: generous per address, tight per token.
abstract final class Limits {
  /// New rooms per address.
  static const createRoom = RateLimit('createRoom', 20, Duration(hours: 1));

  /// Joins per address: a whole room of 50 joining at once, with retries.
  static const joinRoom = RateLimit('joinRoom', 120, Duration(minutes: 1));

  /// Wrong room codes per address. Room codes are 4 digits, so this is what
  /// makes guessing them impractical: 15 a minute would take days to try
  /// them all, and real typos rarely pass a handful.
  static const wrongCode = RateLimit('wrongCode', 15, Duration(minutes: 1));

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

  /// Room streams one address may hold open at once: a full room of phones
  /// plus the host, with room for reconnect overlap.
  static const maxOpenStreams = 150;
}

/// Applies [Limits] in the endpoints. Off by default, so tests of game logic
/// are unaffected; `server.dart` turns it on.
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

  /// Counts one call against [limit] for [key] (default: the caller's
  /// address) and throws `rateLimited` once it is used up.
  static void check(Session session, RateLimit limit, {String? key}) {
    if (!enabled) return;
    if (!limiter.tryAcquire(key ?? clientAddress(session), limit, now())) {
      throw _tooMany;
    }
  }

  /// Throws `rateLimited` if this address has used up [limit] without
  /// counting this call; pair with [recordFailure].
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

  /// Takes a stream slot for the caller's address and returns the function
  /// that gives it back. Throws `rateLimited` when the address holds too many.
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
