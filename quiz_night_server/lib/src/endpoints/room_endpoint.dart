import 'package:serverpod/serverpod.dart';

import '../game/room_service.dart';
import '../generated/protocol.dart';

/// Room lifecycle. Host-only methods take the `hostToken` returned by
/// [createRoom]; the server rejects them without it.
class RoomEndpoint extends Endpoint {
  Future<CreateRoomResult> createRoom(Session session, RoomConfig config) =>
      RoomService.createRoom(session, config);

  Future<JoinResult> joinRoom(Session session, String code, String nickname) =>
      RoomService.joinRoom(session, code, nickname);

  /// Recovers a player's identity after a reload, using their stored token.
  Future<JoinResult> rejoin(Session session, String code, String playerToken) =>
      RoomService.rejoin(session, code, playerToken);

  Future<void> startGame(Session session, String code, String hostToken) =>
      RoomService.startGame(session, code, hostToken);

  Future<void> nextQuestion(Session session, String code, String hostToken) =>
      RoomService.nextQuestion(session, code, hostToken);

  Future<void> reveal(Session session, String code, String hostToken) =>
      RoomService.reveal(session, code, hostToken);

  /// Runs the elimination cut for the current round. Safe to call twice.
  Future<void> endRound(Session session, String code, String hostToken) =>
      RoomService.endRound(session, code, hostToken);

  Future<void> useWildcard(
    Session session,
    String code,
    String hostToken,
    int playerId,
  ) => RoomService.useWildcard(session, code, hostToken, playerId);

  /// Live room updates. The first event is always a full snapshot, so
  /// re-subscribing after a disconnect restores the client's view.
  Stream<RoomState> watchRoom(Session session, String code) =>
      RoomService.watchRoom(session, code);
}
