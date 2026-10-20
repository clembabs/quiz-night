import 'package:quiz_night_client/quiz_night_client.dart';

/// The one thing the host's main button does next.
enum HostStep {
  startGame,
  reveal,
  nextQuestion,
  endRound,
  nextRound,
  startFinal,
  showPodium,
  none,
}

/// Picks the host's next step from the room state.
HostStep hostStepFor(RoomState room) {
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
      final roundOver = q.indexInRound >= room.questionsPerRound;
      return roundOver || _suddenDeathDecided(room)
          ? HostStep.endRound
          : HostStep.nextQuestion;
    case RoomStatus.elimination:
      return (room.lastElimination?.finalistsDecided ?? false)
          ? HostStep.startFinal
          : HostStep.nextRound;
    case RoomStatus.tiebreak:
    case RoomStatus.finished:
      return HostStep.none;
  }
}

/// Under sudden death the cut happens per question, so the round can be
/// over early once few enough players remain.
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

/// Time left on the question, measured on the server's clock.
///
/// [clockOffset] is server time minus local time, so `localNow +
/// clockOffset` is "now" on the server.
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
