import 'package:mocktail/mocktail.dart';
import 'package:quiz_night_client/quiz_night_client.dart';
import 'package:quiz_night_flutter/data/room_repositories.dart';
import 'package:quiz_night_flutter/data/seat.dart';
import 'package:quiz_night_flutter/data/seat_repository.dart';

class MockLobbyRepository extends Mock implements LobbyRepository {}

class MockGameRepository extends Mock implements GameRepository {}

class MockSeatRepository extends Mock implements SeatRepository {}

/// Registers fallback values mocktail needs for `any()` matchers.
void registerFallbacks() {
  registerFallbackValue(RoomConfig());
  registerFallbackValue(hostSeat);
}

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
}) => PlayerView(
  id: id,
  nickname: nickname,
  score: score,
  shadowScore: 0,
  finalScore: 0,
  status: status,
  eliminatedInRound: eliminatedInRound,
  hasAnswered: hasAnswered,
  lastPoints: lastPoints,
  lockedOut: false,
);

/// A four-option round question; correct answer is "Paris" (index 1) once
/// [revealed].
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
}) => RoomState(
  code: code,
  status: status,
  round: round,
  questionsPerRound: questionsPerRound,
  finalistTarget: finalistTarget,
  finalQuestionCount: 5,
  finalQuestionsPlayed: 0,
  eliminationRule: rule,
  wildcardUsed: false,
  question: question,
  questionEndsAt: questionEndsAt,
  serverTime: serverTime ?? DateTime.utc(2026, 1, 1),
  players: players,
  lastElimination: lastElimination,
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
