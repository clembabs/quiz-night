/// At most [max] events per [window], counted separately per key.
class RateLimit {
  /// Names the limit, so two limits never share counters.
  final String name;
  final int max;
  final Duration window;

  /// For failure limits: going over [max] blocks the key for this long,
  /// even after the window resets.
  final Duration? blockFor;

  const RateLimit(this.name, this.max, this.window, {this.blockFor});
}

class _Window {
  final DateTime start;
  final Duration length;
  int count = 0;

  _Window(this.start, this.length);

  bool expiredAt(DateTime now) => now.difference(start) >= length;
}

/// Fixed-window counters held in memory. Fine for one server instance; with
/// several behind a load balancer each would count separately, and this
/// would move to Redis.
class RateLimiter {
  final _windows = <String, _Window>{};

  /// Keys blocked by a [RateLimit.blockFor] limit, until when.
  final _blockedUntil = <String, DateTime>{};
  int _sinceSweep = 0;

  /// Sweep expired counters every this many calls, so memory stays bounded
  /// by the number of recently active keys.
  static const sweepEvery = 1000;

  _Window _current(String key, RateLimit limit, DateTime now) {
    final id = '${limit.name}|$key';
    final existing = _windows[id];
    if (existing != null && !existing.expiredAt(now)) return existing;
    return _windows[id] = _Window(now, limit.window);
  }

  /// Counts one event for [key]; false (and nothing counted) once the limit
  /// is reached for the current window.
  bool tryAcquire(String key, RateLimit limit, DateTime now) {
    _maybeSweep(now);
    final window = _current(key, limit, now);
    if (window.count >= limit.max) return false;
    window.count++;
    return true;
  }

  /// Whether [key] may not go on, without counting anything: blocked by a
  /// [RateLimit.blockFor] limit, or (without one) used up this window.
  bool isExhausted(String key, RateLimit limit, DateTime now) {
    final id = '${limit.name}|$key';
    if (limit.blockFor != null) {
      final until = _blockedUntil[id];
      return until != null && now.isBefore(until);
    }
    final window = _windows[id];
    return window != null &&
        !window.expiredAt(now) &&
        window.count >= limit.max;
  }

  /// Counts one event for [key], even past the limit (for "failed attempt"
  /// limits checked separately with [isExhausted]). Going over the limit of a
  /// [RateLimit.blockFor] limit starts the block.
  void record(String key, RateLimit limit, DateTime now) {
    _maybeSweep(now);
    final window = _current(key, limit, now);
    window.count++;
    final blockFor = limit.blockFor;
    if (blockFor != null && window.count > limit.max) {
      _blockedUntil['${limit.name}|$key'] = now.add(blockFor);
    }
  }

  void _maybeSweep(DateTime now) {
    if (++_sinceSweep < sweepEvery) return;
    _sinceSweep = 0;
    _windows.removeWhere((_, w) => w.expiredAt(now));
    _blockedUntil.removeWhere((_, until) => !now.isBefore(until));
  }

  /// Counters currently held; for tests.
  int get size => _windows.length;

  void clear() {
    _windows.clear();
    _blockedUntil.clear();
  }
}

/// Caps how many long-lived streams one key holds open at once.
class StreamSlots {
  final _open = <String, int>{};

  /// Takes a slot for [key]; false when it already holds [max].
  bool tryOpen(String key, int max) {
    final current = _open[key] ?? 0;
    if (current >= max) return false;
    _open[key] = current + 1;
    return true;
  }

  void close(String key) {
    final current = _open[key] ?? 0;
    if (current <= 1) {
      _open.remove(key);
    } else {
      _open[key] = current - 1;
    }
  }

  int openFor(String key) => _open[key] ?? 0;

  void clear() => _open.clear();
}
