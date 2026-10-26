import 'package:quiz_night_client/quiz_night_client.dart';

/// The one thing the host's main button does next.
enum HostStep {
  startGame,
  reveal,
  nextQuestion,

  /// Show the "After round N" standings with the danger line before the cut.
  showStandings,
  endRound,
  nextRound,
  startFinal,
  showPodium,
  none,
}

/// The host's next step; [showingStandings] is the local standings board.
HostStep hostStepFor(RoomState room, {bool showingStandings = false}) {
  switch (room.status) {
    case RoomStatus.lobby:
      return HostStep.startGame;
    case RoomStatus.question:
    case RoomStatus.buzzerFinal:
      return HostStep.reveal;
    case RoomStatus.reveal:
      final q = room.question;
      if (q == null) return HostStep.none;
      if (q.isFinal) {
        return room.finalQuestionsPlayed >= room.finalQuestionCount
            ? HostStep.showPodium
            : HostStep.nextQuestion;
      }
      if (_suddenDeathDecided(room)) return HostStep.endRound;
      if (q.indexInRound < room.questionsPerRound) return HostStep.nextQuestion;
      // Only a predicted cut has a danger line worth showing first.
      final hasLine = room.projectedSurvivors != null;
      return hasLine && !showingStandings
          ? HostStep.showStandings
          : HostStep.endRound;
    case RoomStatus.elimination:
      return (room.lastElimination?.finalistsDecided ?? false)
          ? HostStep.startFinal
          : HostStep.nextRound;
    case RoomStatus.tiebreak:
    case RoomStatus.finished:
      return HostStep.none;
  }
}

/// Sudden death cuts per question, so a round can end early.
bool _suddenDeathDecided(RoomState room) =>
    room.eliminationRule == EliminationRule.suddenDeath &&
    activeCount(room) <= room.finalistTarget;

int activeCount(RoomState room) =>
    room.players.where((p) => p.status == PlayerStatus.active).length;

/// Players still competing, best first.
List<PlayerView> leaderboard(RoomState room) {
  final competing = room.players
      .where((p) => p.status != PlayerStatus.eliminated)
      .toList();
  competing.sort((a, b) {
    final byScore = b.score.compareTo(a.score);
    return byScore != 0 ? byScore : a.id.compareTo(b.id);
  });
  return competing;
}

/// 1-based rank of [playerId] among competing players, or null.
int? rankOf(RoomState room, int playerId) {
  final i = leaderboard(room).indexWhere((p) => p.id == playerId);
  return i < 0 ? null : i + 1;
}

/// How many competing players have answered the open question.
int answeredCount(RoomState room) => room.players
    .where((p) => p.status == PlayerStatus.active && p.hasAnswered)
    .length;

/// Time left on the server's clock; [clockOffset] is server minus local time.
Duration timeLeft({
  required DateTime endsAt,
  required Duration clockOffset,
  required DateTime localNow,
}) {
  final left = endsAt.difference(localNow.toUtc().add(clockOffset));
  return left.isNegative ? Duration.zero : left;
}

/// Letter label for an option index: A, B, C, D…
String optionLetter(int index) => String.fromCharCode(65 + index);

/// What happened to this player on the question just revealed.
enum PlayerVerdict { correct, wrong, noAnswer }

PlayerVerdict verdictFor({required PlayerView? me, required int? myChoice}) {
  final points = me?.lastPoints;
  if (points == null && myChoice == null) return PlayerVerdict.noAnswer;
  return (points ?? 0) > 0 ? PlayerVerdict.correct : PlayerVerdict.wrong;
}

/// What the latest cut meant for this player.
enum CutOutcome { survived, finalist, out, alreadyOut }

CutOutcome cutOutcomeFor(RoomState room, PlayerView? me) {
  if (me == null) return CutOutcome.alreadyOut;
  return switch (me.status) {
    PlayerStatus.finalist => CutOutcome.finalist,
    PlayerStatus.active => CutOutcome.survived,
    PlayerStatus.eliminated =>
      me.eliminatedInRound == room.round
          ? CutOutcome.out
          : CutOutcome.alreadyOut,
  };
}
