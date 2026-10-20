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

PlayerView player(int id, String nickname, {int score = 0}) => PlayerView(
  id: id,
  nickname: nickname,
  score: score,
  shadowScore: 0,
  finalScore: 0,
  status: PlayerStatus.active,
  hasAnswered: false,
  lockedOut: false,
);

RoomState roomState({
  String code = 'ABCD',
  RoomStatus status = RoomStatus.lobby,
  List<PlayerView> players = const [],
  DateTime? serverTime,
}) => RoomState(
  code: code,
  status: status,
  round: 0,
  questionsPerRound: 5,
  finalistTarget: 3,
  finalQuestionCount: 5,
  finalQuestionsPlayed: 0,
  eliminationRule: EliminationRule.bottomPercent,
  wildcardUsed: false,
  serverTime: serverTime ?? DateTime.utc(2026, 1, 1),
  players: players,
);
