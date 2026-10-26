import 'package:mocktail/mocktail.dart';
import 'package:quiz_night_client/quiz_night_client.dart';
import 'package:quiz_night_flutter/data/questions_repository.dart';
import 'package:quiz_night_flutter/data/room_repositories.dart';
import 'package:quiz_night_flutter/data/seat.dart';
import 'package:quiz_night_flutter/data/seat_repository.dart';

class MockLobbyRepository extends Mock implements LobbyRepository {}

class MockGameRepository extends Mock implements GameRepository {}

class MockSeatRepository extends Mock implements SeatRepository {}

class MockQuestionsRepository extends Mock implements QuestionsRepository {}

/// Registers fallback values mocktail needs for `any()` matchers.
void registerFallbacks() {
  registerFallbackValue(RoomConfig());
  registerFallbackValue(hostSeat);
  registerFallbackValue(QuestionDifficulty.mixed);
  registerFallbackValue(samplePack());
}

/// A pack of [rounds] round and [finals] final questions; answer is option 0.
PackDraft samplePack({
  int rounds = 4,
  int finals = 2,
  String topic = 'Nollywood',
}) => PackDraft(
  packId: 7,
  packToken: 'pack-token',
  topic: topic,
  difficulty: QuestionDifficulty.mixed,
  roundQuestionsNeeded: rounds,
  finalQuestionsNeeded: finals,
  questions: [
    for (var i = 1; i <= rounds + finals; i++)
      PackQuestionView(
        id: i,
        isFinal: i > rounds,
        text: 'Question $i about $topic, written to be long enough?',
        options: ['Right $i', 'Wrong A', 'Wrong B', 'Wrong C'],
        correctIndex: 0,
      ),
  ],
);

const hostSeat = Seat(role: SeatRole.host, code: 'ABCD', token: 'host-token');

const playerSeat = Seat(
  role: SeatRole.player,
  code: 'ABCD',
  token: 'player-token',
  playerId: 1,
);

PlayerView player(
  int id,
  String nickname, {
  int score = 0,
  PlayerStatus status = PlayerStatus.active,
  bool hasAnswered = false,
  int? lastPoints,
  int? eliminatedInRound,
  int finalScore = 0,
  int shadowScore = 0,
  bool lockedOut = false,
  int? backedPlayerId,
}) => PlayerView(
  id: id,
  nickname: nickname,
  score: score,
  shadowScore: shadowScore,
  finalScore: finalScore,
  status: status,
  eliminatedInRound: eliminatedInRound,
  backedPlayerId: backedPlayerId,
  hasAnswered: hasAnswered,
  lastPoints: lastPoints,
  lockedOut: lockedOut,
);

/// A four-option round question; "Paris" (index 1) is correct once [revealed].
QuestionView question({
  int id = 10,
  int round = 1,
  int indexInRound = 1,
  bool isFinal = false,
  bool revealed = false,
  List<int>? answerCounts,
}) => QuestionView(
  id: id,
  round: round,
  indexInRound: indexInRound,
  isFinal: isFinal,
  text: 'Capital of France?',
  options: const ['Rome', 'Paris', 'Madrid', 'Berlin'],
  timeLimitSeconds: 20,
  correctIndex: revealed ? 1 : null,
  answerCounts: answerCounts,
);

RoomState roomState({
  String code = 'ABCD',
  RoomStatus status = RoomStatus.lobby,
  List<PlayerView> players = const [],
  DateTime? serverTime,
  int round = 0,
  int questionsPerRound = 5,
  int finalistTarget = 3,
  EliminationRule rule = EliminationRule.bottomPercent,
  QuestionView? question,
  DateTime? questionEndsAt,
  EliminationEvent? lastElimination,
  int finalQuestionCount = 5,
  int finalQuestionsPlayed = 0,
  int? buzzerHolderId,
  int? buzzWinnerId,
}) => RoomState(
  code: code,
  status: status,
  round: round,
  questionsPerRound: questionsPerRound,
  finalistTarget: finalistTarget,
  finalQuestionCount: finalQuestionCount,
  finalQuestionsPlayed: finalQuestionsPlayed,
  eliminationRule: rule,
  wildcardUsed: false,
  question: question,
  questionEndsAt: questionEndsAt,
  serverTime: serverTime ?? DateTime.utc(2026, 1, 1),
  players: players,
  lastElimination: lastElimination,
  buzzerHolderId: buzzerHolderId,
  buzzWinnerId: buzzWinnerId,
);

EliminationEvent cut({
  int round = 1,
  List<int> out = const [],
  int survivors = 3,
  bool tie = false,
  bool finalists = false,
}) => EliminationEvent(
  round: round,
  eliminatedPlayerIds: out,
  survivorsCount: survivors,
  tieBrokenBySpeed: tie,
  finalistsDecided: finalists,
);
