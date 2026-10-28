import 'package:equatable/equatable.dart';
import 'package:quiz_night_client/quiz_night_client.dart';

import '../standings_logic.dart';
import 'final_logic.dart';

/// What a player's shareable result card says.
class ResultSummary extends Equatable {
  /// 1 for the winner.
  final int place;
  final int playerCount;
  final String nickname;

  /// "Champion", "Finalist", "Out in round 2", "Time's up".
  final String title;
  final bool champion;

  /// Made the buzzer final (the champion too).
  final bool finalist;
  final int roundsSurvived;

  /// Points from the rounds (what the cuts ranked on).
  final int points;

  /// Points from the buzzer final; null unless they reached it.
  final int? finalPoints;

  /// Null when they backed nobody (finalists never back anyone).
  final bool? backedWinner;

  /// The host's line when they were cut.
  final String? hostLine;

  const ResultSummary({
    required this.place,
    required this.playerCount,
    required this.nickname,
    required this.title,
    required this.champion,
    this.finalist = false,
    required this.roundsSurvived,
    required this.points,
    this.finalPoints,
    this.backedWinner,
    this.hostLine,
  });

  @override
  List<Object?> get props => [
    place,
    playerCount,
    nickname,
    title,
    champion,
    finalist,
    roundsSurvived,
    points,
    finalPoints,
    backedWinner,
    hostLine,
  ];
}

/// The card for [me] at the end of [room].
ResultSummary resultFor(RoomState room, PlayerView me) {
  final finalist = me.status == PlayerStatus.finalist;
  final champion = finalist && finalPlaceOf(room, me.id) == 1;
  final stillIn = me.status == PlayerStatus.active && endedEarly(room);
  final out = me.status == PlayerStatus.eliminated;
  final winner = winnerOf(room);
  return ResultSummary(
    place: placementOf(room, me.id) ?? room.players.length,
    playerCount: room.players.length,
    nickname: me.nickname,
    title: switch (me) {
      _ when champion => 'Champion',
      _ when finalist => 'Finalist',
      _ when stillIn =>
        room.endReason == RoomEndReason.timeUp
            ? "Still in at time's up"
            : 'Still in when it closed',
      _ => 'Out in round ${me.eliminatedInRound ?? room.round}',
    },
    champion: champion,
    finalist: finalist,
    roundsSurvived: switch (me) {
      // Every cut before the final.
      _ when finalist => room.lastElimination?.round ?? room.round,
      _ when out => (me.eliminatedInRound ?? room.round) - 1,
      _ => room.round > 0 ? room.round - 1 : 0,
    },
    points: me.score,
    finalPoints: finalist ? me.finalScore : null,
    backedWinner: out && me.backedPlayerId != null
        ? me.backedPlayerId == winner?.id
        : null,
    hostLine: out ? me.exitLine : null,
  );
}

/// The words shared with the card image.
String shareTextFor(ResultSummary r, Uri site) {
  final where = '${ordinal(r.place)} of ${r.playerCount}';
  final headline = r.champion
      ? 'I won Quiz Night! 🏆 ($where)'
      : 'I finished $where at Quiz Night.';
  final rounds = r.roundsSurvived == 1 ? 'round' : 'rounds';
  final backed = r.backedWinner == true ? ' And I backed the winner.' : '';
  return '$headline Survived ${r.roundsSurvived} $rounds.$backed '
      'Survive the round, or go home: ${site.host}';
}
