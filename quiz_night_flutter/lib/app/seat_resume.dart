import '../data/room_repositories.dart';
import '../data/seat_repository.dart';
import 'app_paths.dart';

/// Sends a visitor who still holds a seat in a live game back into it, as a
/// router redirect. Runs as part of each navigation, so it never pulls
/// someone out of a page later, and only on the ways in: a reload, a
/// rescanned QR, a phone waking up, or Back out of a room.
class SeatResume {
  final LobbyRepository _lobby;
  final SeatRepository _seats;

  SeatResume(this._lobby, this._seats);

  /// Pages that lead into a game. Every other page is left alone and costs
  /// no network call.
  static const entryPaths = {AppPaths.home, AppPaths.join, AppPaths.host};

  /// The room to go to instead of [uri], or null to stay.
  Future<String?> redirectFor(Uri uri) async {
    if (!entryPaths.contains(uri.path)) return null;
    final saved = await _seats.load();
    if (saved == null) return null;
    // A QR for a different room wins over an old seat.
    final code = uri.queryParameters['code'];
    if (code != null && code.isNotEmpty && code != saved.code) return null;
    if (!await _lobby.isSeatLive(saved)) {
      await _seats.clear();
      return null;
    }
    return AppPaths.roomFor(saved.code);
  }
}
