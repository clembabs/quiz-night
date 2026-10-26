import 'package:quiz_night_client/quiz_night_client.dart';

import 'final/final_logic.dart';
import 'round_logic.dart';

/// Where a player stands against the danger line.
enum DangerKind { safe, danger, finalist }

class DangerStatus {
  final DangerKind kind;
  final String title;
  final String detail;

  const DangerStatus(this.kind, this.title, this.detail);
}

/// Within this many places above the line still counts as the danger zone.
const dangerMargin = 1;

String _places(int n) => n == 1 ? '1 place' : '$n places';

/// The phone's danger indicator for [me], or null when there is nothing to
/// show (spectators, sudden death, the final).
DangerStatus? dangerStatusFor(RoomState room, PlayerView me) {
  if (me.status == PlayerStatus.finalist) {
    return const DangerStatus(
      DangerKind.finalist,
      'Finalist',
      'Through to the buzzer round',
    );
  }
  final line = room.projectedSurvivors;
  if (me.status != PlayerStatus.active || line == null) return null;
  final rank = rankOf(room, me.id);
  if (rank == null) return null;
  if (rank > line) {
    return DangerStatus(
      DangerKind.danger,
      'In the danger zone',
      '${_places(rank - line)} below the danger line',
    );
  }
  final above = line - rank;
  if (above <= dangerMargin) {
    return DangerStatus(
      DangerKind.danger,
      'In the danger zone',
      above == 0
          ? 'Right on the danger line'
          : '${_places(above)} above the danger line',
    );
  }
  return DangerStatus(
    DangerKind.safe,
    'Safe',
    '${_places(above)} above the danger line',
  );
}

/// Final placement of every player: finalists by the final, then everyone
/// else by how late they went out, then by score.
List<PlayerView> finalPlacements(RoomState room) {
  final top = finalStandings(room);
  final topIds = {for (final p in top) p.id};
  final out = room.players.where((p) => !topIds.contains(p.id)).toList();
  out.sort((a, b) {
    final byRound = (b.eliminatedInRound ?? 999).compareTo(
      a.eliminatedInRound ?? 999,
    );
    if (byRound != 0) return byRound;
    final byScore = b.score.compareTo(a.score);
    return byScore != 0 ? byScore : a.id.compareTo(b.id);
  });
  return [...top, ...out];
}

/// 1-based final placement of [playerId], or null.
int? placementOf(RoomState room, int playerId) {
  final i = finalPlacements(room).indexWhere((p) => p.id == playerId);
  return i < 0 ? null : i + 1;
}

/// 1st, 2nd, 3rd, 4th, 11th, 12th, 13th, 21st…
String ordinal(int n) {
  final teen = n % 100;
  if (teen >= 11 && teen <= 13) return '${n}th';
  return switch (n % 10) {
    1 => '${n}st',
    2 => '${n}nd',
    3 => '${n}rd',
    _ => '${n}th',
  };
}

/// Ranks by player id, from [leaderboard].
Map<int, int> ranksOf(RoomState room) {
  final board = leaderboard(room);
  return {for (var i = 0; i < board.length; i++) board[i].id: i + 1};
}

/// Places each player moved between two rankings: positive is up.
Map<int, int> rankMoves(Map<int, int> before, Map<int, int> after) => {
  for (final e in after.entries)
    if (before[e.key] != null) e.key: before[e.key]! - e.value,
};

/// "Bottom 30% go home · 5 of 18" for the standings board.
String cutSummary(RoomState room) {
  final line = room.projectedSurvivors;
  final active = activeCount(room);
  final out = line == null ? 0 : active - line;
  final rule = switch (room.eliminationRule) {
    EliminationRule.bottomPercent => 'Bottom 30% go home',
    EliminationRule.autoScaled => 'Cut sized to reach the final',
    EliminationRule.suddenDeath => 'Sudden death',
  };
  return '$rule · $out of $active';
}
