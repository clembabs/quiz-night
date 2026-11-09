import 'package:quiz_night_client/quiz_night_client.dart';

/// Finalists, best first: final score, then round score, then join order.
List<PlayerView> finalStandings(RoomState room) {
  final finalists = room.players
      .where((p) => p.status == PlayerStatus.finalist)
      .toList();
  // Ended before the final: whoever was still in, by score so far.
  if (finalists.isEmpty && endedEarly(room)) {
    return room.players.where((p) => p.status == PlayerStatus.active).toList()
      ..sort((a, b) {
        final byScore = b.score.compareTo(a.score);
        return byScore != 0 ? byScore : a.id.compareTo(b.id);
      });
  }
  finalists.sort((a, b) {
    final byFinal = b.finalScore.compareTo(a.finalScore);
    if (byFinal != 0) return byFinal;
    final byScore = b.score.compareTo(a.score);
    return byScore != 0 ? byScore : a.id.compareTo(b.id);
  });
  return finalists;
}

PlayerView? winnerOf(RoomState room) => finalStandings(room).firstOrNull;

/// Final points for finalists, or the game score if it stopped before.
int podiumScore(PlayerView p) =>
    p.status == PlayerStatus.finalist ? p.finalScore : p.score;

/// Stopped before the podium: time ran out, 30 idle minutes, or the host left.
bool endedEarly(RoomState room) =>
    room.endReason == RoomEndReason.timeUp ||
    room.endReason == RoomEndReason.inactive ||
    room.endReason == RoomEndReason.hostLeft;

/// The room closed before its game ever started (idle lobby, or the host
/// left the lobby).
bool closedBeforeStart(RoomState room) =>
    (room.endReason == RoomEndReason.inactive ||
        room.endReason == RoomEndReason.hostLeft) &&
    room.round == 0;

/// Why the results are "so far", for the podium and phones.
String? endNoticeFor(RoomState room) => switch (room.endReason) {
  RoomEndReason.timeUp =>
    "Time's up: the game's 30 minutes ran out. "
        'These are the scores when the clock stopped.',
  RoomEndReason.inactive =>
    'This room closed after 30 minutes without activity. '
        'These are the scores when it stopped.',
  RoomEndReason.hostLeft =>
    'The host left, so the game ended. '
        'These are the scores when it stopped.',
  _ => null,
};

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

String? nicknameOf(RoomState room, int? id) =>
    room.players.where((p) => p.id == id).firstOrNull?.nickname;

/// Finalists locked out of the open final question, by join order.
List<String> lockedOutNames(RoomState room) => [
  for (final p in finalistsByJoin(room))
    if (p.lockedOut) p.nickname,
];

/// "Ada" / "Ada and Bo" / "Ada, Bo and Cy".
String namesList(List<String> names) => switch (names) {
  [] => '',
  [final one] => one,
  _ => '${names.sublist(0, names.length - 1).join(', ')} and ${names.last}',
};

/// "Ada got it wrong and is locked out." for the latest misses, or null.
String? lockoutLine(RoomState room) {
  final names = lockedOutNames(room);
  if (names.isEmpty) return null;
  final verb = names.length == 1 ? 'is' : 'are';
  return '${namesList(names)} got it wrong and $verb locked out.';
}

/// The line under a final question: who is answering, or how it ended.
String finalStatusLine(RoomState room) {
  if (room.question?.correctIndex != null) {
    final winner = nicknameOf(room, room.buzzWinnerId);
    return winner == null ? 'Nobody got it' : '$winner got it! +1000';
  }
  final holder = nicknameOf(room, room.buzzerHolderId);
  if (holder != null) return '$holder is answering…';
  final missed = lockoutLine(room);
  return missed == null ? 'Buzz to answer!' : '$missed Buzz to answer!';
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
