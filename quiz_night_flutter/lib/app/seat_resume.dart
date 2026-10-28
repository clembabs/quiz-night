import '../data/room_repositories.dart';
import '../data/seat_repository.dart';
import 'app_paths.dart';

/// Router redirect sending a visitor with a live seat back into their game.
/// Runs only on ways in (reload, QR, wake, Back), never pulling you out.
class SeatResume {
  final LobbyRepository _lobby;
  final SeatRepository _seats;

  SeatResume(this._lobby, this._seats);

  /// Pages that lead into a game; other pages cost no network call.
  static const entryPaths = {AppPaths.home, AppPaths.join, AppPaths.host};

  /// The room to go to instead of [uri], or null to stay.
  Future<String?> redirectFor(Uri uri) async {
    if (!entryPaths.contains(uri.path)) return null;
    final saved = await _seats.load();
    if (saved == null) return null;
    // A QR for a different room wins over an old seat.
    final code = uri.queryParameters['code'];
    if (code != null && code.isNotEmpty && code.toUpperCase() != saved.code) {
      return null;
    }
    if (!await _lobby.isSeatLive(saved)) {
      await _seats.clear();
      return null;
    }
    return AppPaths.roomFor(saved.code);
  }
}
