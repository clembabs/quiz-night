import 'package:quiz_night_client/quiz_night_client.dart';

import 'app_failure.dart';
import 'seat.dart';

/// Getting into a room: creating one, joining, or proving an old seat.
abstract interface class LobbyRepository {
  /// Creates a room and returns the host's seat.
  Future<Seat> createRoom(RoomConfig config);

  /// Joins a room in the lobby and returns the player's seat.
  Future<Seat> joinRoom(String code, String nickname);

  /// Checks a saved seat is still valid on the server.
  Future<bool> isSeatValid(Seat seat);
}

/// Playing in a room: the live state stream and actions.
abstract interface class GameRepository {
  /// Live room state. The first event is always a full snapshot.
  Stream<RoomState> watchRoom(String code);

  Future<void> startGame(Seat host);
}

/// Both repositories over the generated Serverpod [Client].
class ServerpodRoomRepository implements LobbyRepository, GameRepository {
  final Client _client;

  ServerpodRoomRepository(this._client);

  @override
  Future<Seat> createRoom(RoomConfig config) => _guard(() async {
    final r = await _client.room.createRoom(config);
    return Seat(role: SeatRole.host, code: r.roomCode, token: r.hostToken);
  });

  @override
  Future<Seat> joinRoom(String code, String nickname) => _guard(() async {
    final r = await _client.room.joinRoom(code, nickname);
    return Seat(
      role: SeatRole.player,
      code: r.roomCode,
      token: r.playerToken,
      playerId: r.playerId,
    );
  });

  @override
  Future<bool> isSeatValid(Seat seat) async {
    try {
      if (seat.isHost) {
        // Watching fails fast if the room is gone.
        await _client.room.watchRoom(seat.code).first;
      } else {
        await _client.room.rejoin(seat.code, seat.token);
      }
      return true;
    } on QuizException {
      return false;
    } catch (_) {
      // Offline: keep the seat and let the room screen retry.
      return true;
    }
  }

  @override
  Stream<RoomState> watchRoom(String code) => _client.room
      .watchRoom(code)
      .handleError(
        (Object e) => throw toFailure(e),
      );

  @override
  Future<void> startGame(Seat host) =>
      _guard(() => _client.room.startGame(host.code, host.token));

  static Future<T> _guard<T>(Future<T> Function() call) async {
    try {
      return await call();
    } catch (e) {
      throw toFailure(e);
    }
  }

  /// Maps transport errors to [AppFailure].
  static AppFailure toFailure(Object e) {
    if (e is AppFailure) return e;
    if (e is QuizException) {
      return AppFailure(
        e.message,
        roomGone: e.code == QuizErrorCode.roomNotFound,
      );
    }
    return AppFailure.connection;
  }
}
