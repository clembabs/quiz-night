import 'package:quiz_night_server/src/security/rate_limiter.dart';
import 'package:test/test.dart';

void main() {
  final t0 = DateTime.utc(2026, 10, 23, 12);
  const perMinute = RateLimit('test', 3, Duration(minutes: 1));

  group('Given a limit of 3 a minute', () {
    test('when a key calls 4 times then the 4th is refused', () {
      final limiter = RateLimiter();
      final results = [
        for (var i = 0; i < 4; i++) limiter.tryAcquire('a', perMinute, t0),
      ];
      expect(results, [true, true, true, false]);
    });

    test('when the window passes then the key may call again', () {
      final limiter = RateLimiter();
      for (var i = 0; i < 3; i++) {
        limiter.tryAcquire('a', perMinute, t0);
      }
      expect(limiter.tryAcquire('a', perMinute, t0), isFalse);
      expect(
        limiter.tryAcquire('a', perMinute, t0.add(const Duration(minutes: 1))),
        isTrue,
      );
    });

    test('when two keys call then each has its own count', () {
      final limiter = RateLimiter();
      for (var i = 0; i < 3; i++) {
        limiter.tryAcquire('a', perMinute, t0);
      }
      expect(limiter.tryAcquire('b', perMinute, t0), isTrue);
    });

    test('when two limits share a key then they count separately', () {
      final limiter = RateLimiter();
      const other = RateLimit('other', 1, Duration(minutes: 1));
      for (var i = 0; i < 3; i++) {
        limiter.tryAcquire('a', perMinute, t0);
      }
      expect(limiter.tryAcquire('a', other, t0), isTrue);
    });
  });

  group('Given a failures-only limit', () {
    test('when failures are recorded then it is exhausted at the limit', () {
      final limiter = RateLimiter();
      expect(limiter.isExhausted('a', perMinute, t0), isFalse);
      for (var i = 0; i < 3; i++) {
        limiter.record('a', perMinute, t0);
      }
      expect(limiter.isExhausted('a', perMinute, t0), isTrue);
      expect(
        limiter.isExhausted('a', perMinute, t0.add(const Duration(minutes: 1))),
        isFalse,
      );
    });
  });

  group('Given a failure limit that blocks for 5 minutes', () {
    const wrong = RateLimit(
      'wrong',
      6,
      Duration(minutes: 1),
      blockFor: Duration(minutes: 5),
    );

    test('when a key fails 6 times then it may still go on', () {
      final limiter = RateLimiter();
      for (var i = 0; i < 6; i++) {
        limiter.record('a', wrong, t0);
      }
      expect(limiter.isExhausted('a', wrong, t0), isFalse);
    });

    test('when it fails a 7th time then it is blocked for 5 minutes, even '
        'after the minute resets', () {
      final limiter = RateLimiter();
      for (var i = 0; i < 7; i++) {
        limiter.record('a', wrong, t0);
      }
      expect(limiter.isExhausted('a', wrong, t0), isTrue);
      expect(
        limiter.isExhausted('a', wrong, t0.add(const Duration(minutes: 2))),
        isTrue,
      );
      expect(
        limiter.isExhausted('a', wrong, t0.add(const Duration(minutes: 5))),
        isFalse,
      );
      expect(limiter.isExhausted('b', wrong, t0), isFalse);
    });
  });

  group('Given many short-lived keys', () {
    test('when their windows expire then the counters are swept', () {
      final limiter = RateLimiter();
      for (var i = 0; i < RateLimiter.sweepEvery - 1; i++) {
        limiter.tryAcquire('k$i', perMinute, t0);
      }
      expect(limiter.size, RateLimiter.sweepEvery - 1);
      limiter.tryAcquire('late', perMinute, t0.add(const Duration(hours: 1)));
      expect(limiter.size, 1);
    });
  });

  group('Given stream slots', () {
    test('when a key holds the maximum then another is refused until one '
        'closes', () {
      final slots = StreamSlots();
      expect(slots.tryOpen('a', 2), isTrue);
      expect(slots.tryOpen('a', 2), isTrue);
      expect(slots.tryOpen('a', 2), isFalse);
      slots.close('a');
      expect(slots.openFor('a'), 1);
      expect(slots.tryOpen('a', 2), isTrue);
    });
  });
}
