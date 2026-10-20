import 'dart:math';

import '../generated/protocol.dart';

/// An active player as seen by the cut logic.
class CutCandidate {
  final int id;
  final int score;
  final int totalCorrectAnswerMs;

  const CutCandidate({
    required this.id,
    required this.score,
    required this.totalCorrectAnswerMs,
  });
}

/// The outcome of a cut.
class CutResult {
  /// Eliminated player ids in reveal order: worst first, the bubble last.
  final List<int> eliminatedIds;

  /// Surviving player ids, best first.
  final List<int> survivorIds;

  /// True when the last survivor and the first eliminated player had the
  /// same score, so total answer time decided who stayed.
  final bool tieBrokenBySpeed;

  const CutResult({
    required this.eliminatedIds,
    required this.survivorIds,
    required this.tieBrokenBySpeed,
  });
}

/// The fewest players a cut may leave standing.
const minSurvivors = 2;

/// Ranks players best first: highest cumulative score, then fastest total
/// correct-answer time, then earliest id (deterministic).
List<CutCandidate> rankCandidates(Iterable<CutCandidate> candidates) {
  final ranked = candidates.toList()
    ..sort((a, b) {
      final byScore = b.score.compareTo(a.score);
      if (byScore != 0) return byScore;
      final byTime = a.totalCorrectAnswerMs.compareTo(b.totalCorrectAnswerMs);
      if (byTime != 0) return byTime;
      return a.id.compareTo(b.id);
    });
  return ranked;
}

/// The fraction of players kept each round under [EliminationRule.autoScaled],
/// so [startingPlayers] reaches [finalistTarget] after [roundsBeforeFinal].
double autoScaledKeepFraction({
  required int startingPlayers,
  required int finalistTarget,
  required int roundsBeforeFinal,
}) {
  if (startingPlayers <= finalistTarget || roundsBeforeFinal <= 0) return 1;
  return pow(
    finalistTarget / startingPlayers,
    1 / roundsBeforeFinal,
  ).toDouble();
}

/// How many players should survive the end-of-round cut.
///
/// Never goes below [finalistTarget] or [minSurvivors], and never above the
/// number of active players.
int survivorsAfterRound({
  required int activeCount,
  required EliminationRule rule,
  required double eliminationPercent,
  required int finalistTarget,
  required int startingPlayers,
  required int roundsBeforeFinal,
  required int round,
}) {
  final floor = max(finalistTarget, minSurvivors);
  if (activeCount <= floor) return activeCount;

  int target;
  switch (rule) {
    case EliminationRule.bottomPercent:
      // Always cut at least one player so the game makes progress.
      final cut = max(1, (activeCount * eliminationPercent).round());
      target = activeCount - cut;
    case EliminationRule.autoScaled:
      if (round >= roundsBeforeFinal) {
        target = finalistTarget;
      } else {
        final keep = autoScaledKeepFraction(
          startingPlayers: startingPlayers,
          finalistTarget: finalistTarget,
          roundsBeforeFinal: roundsBeforeFinal,
        );
        target = (startingPlayers * pow(keep, round)).round();
        // Late joiners or rescued players can push us off the schedule;
        // still always cut someone.
        target = min(target, activeCount - 1);
      }
    case EliminationRule.suddenDeath:
      // Sudden death cuts per question, not per round.
      return activeCount;
  }
  return target.clamp(floor, activeCount);
}

/// Cuts [active] down to [survivors] players.
CutResult cutToSize(List<CutCandidate> active, int survivors) {
  final ranked = rankCandidates(active);
  final keep = survivors.clamp(0, ranked.length);
  final kept = ranked.sublist(0, keep);
  final cut = ranked.sublist(keep);
  final tie =
      kept.isNotEmpty && cut.isNotEmpty && kept.last.score == cut.first.score;
  return CutResult(
    eliminatedIds: cut.reversed.map((c) => c.id).toList(),
    survivorIds: kept.map((c) => c.id).toList(),
    tieBrokenBySpeed: tie,
  );
}

/// The end-of-round cut for [rule].
CutResult computeRoundCut({
  required List<CutCandidate> active,
  required EliminationRule rule,
  required double eliminationPercent,
  required int finalistTarget,
  required int startingPlayers,
  required int roundsBeforeFinal,
  required int round,
}) {
  final survivors = survivorsAfterRound(
    activeCount: active.length,
    rule: rule,
    eliminationPercent: eliminationPercent,
    finalistTarget: finalistTarget,
    startingPlayers: startingPlayers,
    roundsBeforeFinal: roundsBeforeFinal,
    round: round,
  );
  return cutToSize(active, survivors);
}

/// The sudden-death cut after a question: everyone in [active] whose id is
/// not in [correctIds] goes out, unless that would leave fewer than
/// [minSurvivors]; then the best-ranked of them are spared.
CutResult computeSuddenDeathCut({
  required List<CutCandidate> active,
  required Set<int> correctIds,
}) {
  final ranked = rankCandidates(active);
  final right = ranked.where((c) => correctIds.contains(c.id)).toList();
  final wrong = ranked.where((c) => !correctIds.contains(c.id)).toList();
  final spare = max(0, min(minSurvivors, ranked.length) - right.length);
  final kept = [...right, ...wrong.take(spare)];
  final cut = wrong.skip(spare).toList();
  return CutResult(
    eliminatedIds: cut.reversed.map((c) => c.id).toList(),
    survivorIds: rankCandidates(kept).map((c) => c.id).toList(),
    tieBrokenBySpeed: false,
  );
}

/// Points for a correct round answer: 1000 scaled by time remaining, never
/// below 500.
int pointsForAnswer({
  required bool correct,
  required int elapsedMs,
  required int timeLimitSeconds,
}) {
  if (!correct) return 0;
  final limitMs = timeLimitSeconds * 1000;
  final remaining = (limitMs - elapsedMs).clamp(0, limitMs);
  return max(500, (1000 * remaining / limitMs).round());
}
