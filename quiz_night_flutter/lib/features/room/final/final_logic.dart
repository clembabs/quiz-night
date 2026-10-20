import 'package:quiz_night_client/quiz_night_client.dart';

/// Finalists, best first: final score, then round score, then join order.
List<PlayerView> finalStandings(RoomState room) {
  final finalists = room.players
      .where((p) => p.status == PlayerStatus.finalist)
      .toList();
  finalists.sort((a, b) {
    final byFinal = b.finalScore.compareTo(a.finalScore);
    if (byFinal != 0) return byFinal;
    final byScore = b.score.compareTo(a.score);
    return byScore != 0 ? byScore : a.id.compareTo(b.id);
  });
  return finalists;
}

PlayerView? winnerOf(RoomState room) => finalStandings(room).firstOrNull;

/// Spectators who backed [finalistId]. Picks are only sent once finished.
List<PlayerView> backersOf(RoomState room, int finalistId) =>
    room.players.where((p) => p.backedPlayerId == finalistId).toList();

/// The eliminated player with the best shadow score, if anyone scored.
PlayerView? shadowChampion(RoomState room) {
  final spectators = room.players
      .where((p) => p.status == PlayerStatus.eliminated && p.shadowScore > 0)
      .toList();
  if (spectators.isEmpty) return null;
  spectators.sort((a, b) => b.shadowScore.compareTo(a.shadowScore));
  return spectators.first;
}

/// Where a finalist placed (1-based), or null for spectators.
int? finalPlaceOf(RoomState room, int playerId) {
  final i = finalStandings(room).indexWhere((p) => p.id == playerId);
  return i < 0 ? null : i + 1;
}

/// What a phone should offer during an open final question.
enum BuzzerSeat {
  /// A finalist who may buzz now.
  canBuzz,

  /// This finalist's buzz is on its way.
  buzzing,

  /// This finalist holds the buzzer and must answer.
  holding,

  /// Another finalist holds the buzzer.
  otherHolding,

  /// This finalist answered wrong on this question.
  lockedOut,

  /// Not a finalist: watching.
  spectator,
}

BuzzerSeat buzzerSeatFor(
  RoomState room,
  PlayerView? me, {
  bool buzzing = false,
}) {
  if (me == null || me.status != PlayerStatus.finalist) {
    return BuzzerSeat.spectator;
  }
  final holder = room.buzzerHolderId;
  if (holder == me.id) return BuzzerSeat.holding;
  if (me.lockedOut) return BuzzerSeat.lockedOut;
  if (holder != null) return BuzzerSeat.otherHolding;
  return buzzing ? BuzzerSeat.buzzing : BuzzerSeat.canBuzz;
}

/// Nickname of [id] in [room], if they exist.
String? nicknameOf(RoomState room, int? id) =>
    room.players.where((p) => p.id == id).firstOrNull?.nickname;

/// The line under a final question: who is answering, or how it ended.
String finalStatusLine(RoomState room) {
  if (room.question?.correctIndex != null) {
    final winner = nicknameOf(room, room.buzzWinnerId);
    return winner == null ? 'Nobody got it' : '$winner got it! +1000';
  }
  final holder = nicknameOf(room, room.buzzerHolderId);
  return holder == null ? 'Buzz to answer!' : '$holder is answering…';
}

/// A finalist's state on the current final question.
enum DeskState { ready, buzzedFirst, lockedOut, gotIt }

DeskState deskStateFor(RoomState room, PlayerView finalist) {
  if (room.buzzWinnerId == finalist.id) return DeskState.gotIt;
  if (room.buzzerHolderId == finalist.id) return DeskState.buzzedFirst;
  if (finalist.lockedOut) return DeskState.lockedOut;
  return DeskState.ready;
}

/// Finalists in join order, so desks do not jump around as points land.
List<PlayerView> finalistsByJoin(RoomState room) =>
    finalStandings(room)..sort((a, b) => a.id.compareTo(b.id));
