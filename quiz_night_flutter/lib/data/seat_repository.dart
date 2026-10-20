import 'package:shared_preferences/shared_preferences.dart';

import 'seat.dart';

/// Remembers this browser's seat so a reload puts you back in the room.
abstract interface class SeatRepository {
  Future<Seat?> load();
  Future<void> save(Seat seat);
  Future<void> clear();
}

/// [SeatRepository] backed by `shared_preferences` (localStorage on web).
///
/// Storage can be unavailable (private browsing, blocked site data); then
/// every call quietly does nothing and the app still works for this visit.
class PrefsSeatRepository implements SeatRepository {
  static const _role = 'seat.role';
  static const _code = 'seat.code';
  static const _token = 'seat.token';
  static const _playerId = 'seat.playerId';

  @override
  Future<Seat?> load() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final role = prefs.getString(_role);
      final code = prefs.getString(_code);
      final token = prefs.getString(_token);
      if (role == null || code == null || token == null) return null;
      return Seat(
        role: SeatRole.values.byName(role),
        code: code,
        token: token,
        playerId: prefs.getInt(_playerId),
      );
    } catch (_) {
      return null;
    }
  }

  @override
  Future<void> save(Seat seat) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_role, seat.role.name);
      await prefs.setString(_code, seat.code);
      await prefs.setString(_token, seat.token);
      final id = seat.playerId;
      if (id != null) {
        await prefs.setInt(_playerId, id);
      } else {
        await prefs.remove(_playerId);
      }
    } catch (_) {}
  }

  @override
  Future<void> clear() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      for (final key in [_role, _code, _token, _playerId]) {
        await prefs.remove(key);
      }
    } catch (_) {}
  }
}
