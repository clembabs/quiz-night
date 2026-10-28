import 'package:quiz_night_client/quiz_night_client.dart';

import 'app_failure.dart';
import 'seat.dart';

/// Getting into a room: creating one, joining, or proving an old seat.
abstract interface class LobbyRepository {
  /// Creates a room and returns the host's seat.
  Future<Seat> createRoom(RoomConfig config);

  /// Joins a room in the lobby and returns the player's seat.
  Future<Seat> joinRoom(String code, String nickname);

  /// Whether a saved seat is in an unfinished game; offline counts as live.
  Future<bool> isSeatLive(Seat seat);
}

/// Playing in a room: the live state stream and actions.
abstract interface class GameRepository {
  /// Live room state. The first event is always a full snapshot.
  Stream<RoomState> watchRoom(String code);

  // Host actions; [host] must be the host's seat.
  Future<void> startGame(Seat host);
  Future<void> nextQuestion(Seat host);
  Future<void> reveal(Seat host);

  /// Runs the elimination cut. Safe to call twice.
  Future<void> endRound(Seat host);

  /// Rescues one eliminated player; once per game, before the final.
  Future<void> useWildcard(Seat host, int playerId);

  /// Removes a player from the lobby, before the game starts.
  Future<void> removePlayer(Seat host, int playerId);

  /// Stops (or allows again) new players joining.
  Future<void> setLocked(Seat host, bool locked);

  /// The player tapped Leave; the game stops waiting for their answers.
  Future<void> leaveRoom(Seat player);

  /// Answers [questionId]; eliminated players' answers are shadow only.
  Future<void> submitAnswer(Seat player, int questionId, int choiceIndex);

  /// A spectator picks the finalist they think will win.
  Future<void> backFinalist(Seat spectator, int finalistId);

  /// A finalist tries to claim the buzzer; the server decides who was first.
  Future<BuzzResult> buzz(Seat finalist, int questionId);

  /// The buzzer holder answers. Returns whether it was correct.
  Future<bool> submitBuzzAnswer(Seat finalist, int questionId, int choiceIndex);
}

/// Both repositories over the generated Serverpod [Client].
class ServerpodRoomRepository implements LobbyRepository, GameRepository {
  final Client _client;

  ServerpodRoomRepository(this._client);

  @override
  Future<Seat> createRoom(RoomConfig config) => _guard(() async {
    final r = await _client.room.createRoom(config);
    return Seat(role: SeatRole.host, code: r.roomCode, token: r.hostToken);
  });

  @override
  Future<Seat> joinRoom(String code, String nickname) => _guard(() async {
    final JoinResult r;
    try {
      r = await _client.room.joinRoom(code, nickname);
    } on QuizException catch (e) {
      // Joining is the one call where "invalid state" means "too late".
      if (e.code == QuizErrorCode.invalidState) {
        throw AppFailure(e.message, kind: FailureKind.gameStarted);
      }
      rethrow;
    }
    return Seat(
      role: SeatRole.player,
      code: r.roomCode,
      token: r.playerToken,
      playerId: r.playerId,
    );
  });

  /// How long to wait for the server before assuming we are offline.
  static const seatCheckTimeout = Duration(seconds: 5);

  @override
  Future<bool> isSeatLive(Seat seat) async {
    try {
      if (!seat.isHost) await _client.room.rejoin(seat.code, seat.token);
      final snapshot = await _client.room
          .watchRoom(seat.code)
          .first
          .timeout(seatCheckTimeout);
      return snapshot.status != RoomStatus.finished;
    } on QuizException {
      // Room gone or token unknown: the seat is dead.
      return false;
    } catch (_) {
      return true;
    }
  }

  @override
  Stream<RoomState> watchRoom(String code) => _client.room
      .watchRoom(code)
      .handleError(
        (Object e) => throw toFailure(e),
      );

  @override
  Future<void> startGame(Seat host) =>
      _guard(() => _client.room.startGame(host.code, host.token));

  @override
  Future<void> nextQuestion(Seat host) =>
      _guard(() => _client.room.nextQuestion(host.code, host.token));

  @override
  Future<void> reveal(Seat host) =>
      _guard(() => _client.room.reveal(host.code, host.token));

  @override
  Future<void> endRound(Seat host) =>
      _guard(() => _client.room.endRound(host.code, host.token));

  @override
  Future<void> useWildcard(Seat host, int playerId) => _guard(
    () => _client.room.useWildcard(host.code, host.token, playerId),
  );

  @override
  Future<void> setLocked(Seat host, bool locked) => _guard(
    () => _client.room.setLocked(host.code, host.token, locked),
  );

  @override
  Future<void> leaveRoom(Seat player) =>
      _guard(() => _client.room.leaveRoom(player.code, player.token));

  @override
  Future<void> removePlayer(Seat host, int playerId) => _guard(
    () => _client.room.removePlayer(host.code, host.token, playerId),
  );

  @override
  Future<BuzzResult> buzz(Seat finalist, int questionId) =>
      _guard(() => _client.buzzer.buzz(finalist.token, questionId));

  @override
  Future<bool> submitBuzzAnswer(
    Seat finalist,
    int questionId,
    int choiceIndex,
  ) => _guard(
    () => _client.buzzer.submitBuzzAnswer(
      finalist.token,
      questionId,
      choiceIndex,
    ),
  );

  @override
  Future<void> backFinalist(Seat spectator, int finalistId) => _guard(
    () => _client.buzzer.backFinalist(spectator.token, finalistId),
  );

  @override
  Future<void> submitAnswer(Seat player, int questionId, int choiceIndex) =>
      _guard(
        () =>
            _client.answer.submitAnswer(player.token, questionId, choiceIndex),
      );

  static Future<T> _guard<T>(Future<T> Function() call) =>
      guardServerCall(call);

  /// Maps transport errors to [AppFailure].
  static AppFailure toFailure(Object e) {
    if (e is AppFailure) return e;
    if (e is QuizException) {
      return AppFailure(e.message, kind: _kindOf(e.code));
    }
    return AppFailure.connection;
  }

  static FailureKind _kindOf(QuizErrorCode code) => switch (code) {
    QuizErrorCode.roomNotFound => FailureKind.roomGone,
    QuizErrorCode.alreadyAnswered => FailureKind.alreadyAnswered,
    QuizErrorCode.tooLate => FailureKind.tooLate,
    QuizErrorCode.nicknameTaken => FailureKind.nicknameTaken,
    QuizErrorCode.roomFull => FailureKind.roomFull,
    QuizErrorCode.roomLocked => FailureKind.roomLocked,
    _ => FailureKind.other,
  };
}

/// Runs a server call; errors become [AppFailure]s with its message.
Future<T> guardServerCall<T>(Future<T> Function() call) async {
  try {
    return await call();
  } catch (e) {
    throw ServerpodRoomRepository.toFailure(e);
  }
}
