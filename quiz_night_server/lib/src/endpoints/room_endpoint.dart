import 'package:serverpod/serverpod.dart';

import '../game/room_service.dart';
import '../generated/protocol.dart';
import '../security/guard.dart';

/// Room lifecycle. Host-only methods take the `hostToken` returned by
/// [createRoom]; the server rejects them without it. Every method is rate
/// limited (see [Limits]).
class RoomEndpoint extends Endpoint {
  Future<CreateRoomResult> createRoom(Session session, RoomConfig config) {
    Guard.check(session, Limits.createRoom);
    return RoomService.createRoom(session, config);
  }

  Future<JoinResult> joinRoom(
    Session session,
    String code,
    String nickname,
  ) async {
    // Too many wrong codes from this address: stop it guessing room codes.
    Guard.checkFailures(session, Limits.wrongCode);
    Guard.check(session, Limits.joinRoom);
    Guard.check(session, Limits.joinPerRoom, key: 'room:${code.trim()}');
    try {
      return await RoomService.joinRoom(session, code, nickname);
    } on QuizException catch (e) {
      if (e.code == QuizErrorCode.roomNotFound) {
        Guard.recordFailure(session, Limits.wrongCode);
      }
      rethrow;
    }
  }

  /// Recovers a player's identity after a reload, using their stored token.
  Future<JoinResult> rejoin(Session session, String code, String playerToken) {
    Guard.check(session, Limits.rejoin);
    return RoomService.rejoin(session, code, playerToken);
  }

  Future<void> startGame(Session session, String code, String hostToken) {
    Guard.check(session, Limits.hostAction, key: hostToken);
    return RoomService.startGame(session, code, hostToken);
  }

  Future<void> nextQuestion(Session session, String code, String hostToken) {
    Guard.check(session, Limits.hostAction, key: hostToken);
    return RoomService.nextQuestion(session, code, hostToken);
  }

  Future<void> reveal(Session session, String code, String hostToken) {
    Guard.check(session, Limits.hostAction, key: hostToken);
    return RoomService.reveal(session, code, hostToken);
  }

  /// Runs the elimination cut for the current round. Safe to call twice.
  Future<void> endRound(Session session, String code, String hostToken) {
    Guard.check(session, Limits.hostAction, key: hostToken);
    return RoomService.endRound(session, code, hostToken);
  }

  Future<void> useWildcard(
    Session session,
    String code,
    String hostToken,
    int playerId,
  ) {
    Guard.check(session, Limits.hostAction, key: hostToken);
    return RoomService.useWildcard(session, code, hostToken, playerId);
  }

  /// Removes a player from the lobby, before the game starts.
  Future<void> removePlayer(
    Session session,
    String code,
    String hostToken,
    int playerId,
  ) {
    Guard.check(session, Limits.hostAction, key: hostToken);
    return RoomService.removePlayer(session, code, hostToken, playerId);
  }

  /// Live room updates. The first event is always a full snapshot, so
  /// re-subscribing after a disconnect restores the client's view.
  Stream<RoomState> watchRoom(Session session, String code) async* {
    Guard.check(session, Limits.watch);
    final release = Guard.openStream(session);
    try {
      yield* RoomService.watchRoom(session, code);
    } finally {
      release();
    }
  }
}
