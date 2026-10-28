import 'dart:async';
import 'dart:math';

import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:quiz_night_client/quiz_night_client.dart';

import '../../data/app_failure.dart';
import '../../data/room_repositories.dart';
import '../../data/seat.dart';
import '../../data/seat_repository.dart';
import 'standings_logic.dart';

enum ConnectionStatus { connecting, connected, reconnecting }

class RoomViewState extends Equatable {
  final Seat seat;

  /// Latest snapshot from the server; null until the first one arrives.
  final RoomState? room;
  final ConnectionStatus connection;

  /// The room no longer exists on the server.
  final bool roomGone;

  /// The user left; the screen should close.
  final bool left;

  /// Last failed action; [errorSeq] bumps so a repeat message shows again.
  final String? actionError;
  final int errorSeq;

  /// Server clock minus local clock, so countdowns follow server time.
  final Duration clockOffset;

  /// This player's pick per question id, kept locally to stay highlighted.
  final Map<int, int> myChoices;

  /// This spectator's backed finalist; the server hides picks until the end.
  final int? myBackedId;

  /// A buzz is on its way to the server; ignore further taps.
  final bool buzzing;

  /// Host only: the "After round N" standings are on screen.
  final bool showingStandings;

  /// Places each player moved at the latest reveal (positive is up).
  final Map<int, int> rankMoves;

  /// Phone only: an eliminated player tapped "Keep watching as spectator".
  final bool keepWatching;

  const RoomViewState({
    required this.seat,
    this.room,
    this.connection = ConnectionStatus.connecting,
    this.roomGone = false,
    this.left = false,
    this.actionError,
    this.errorSeq = 0,
    this.clockOffset = Duration.zero,
    this.myChoices = const {},
    this.myBackedId,
    this.buzzing = false,
    this.showingStandings = false,
    this.rankMoves = const {},
    this.keepWatching = false,
  });

  PlayerView? get me => seat.playerId == null
      ? null
      : room?.players.where((p) => p.id == seat.playerId).firstOrNull;

  /// A player whose seat is no longer in the room: the host removed them.
  bool get removedByHost =>
      !seat.isHost && room != null && !roomGone && me == null;

  /// This player's pick for the current question, if any.
  int? get myChoice {
    final id = room?.question?.id;
    return id == null ? null : myChoices[id];
  }

  RoomViewState copyWith({
    RoomState? room,
    ConnectionStatus? connection,
    bool? roomGone,
    bool? left,
    String? actionError,
    int? errorSeq,
    Duration? clockOffset,
    Map<int, int>? myChoices,
    int? Function()? myBackedId,
    bool? buzzing,
    bool? showingStandings,
    Map<int, int>? rankMoves,
    bool? keepWatching,
  }) => RoomViewState(
    seat: seat,
    room: room ?? this.room,
    connection: connection ?? this.connection,
    roomGone: roomGone ?? this.roomGone,
    left: left ?? this.left,
    actionError: actionError ?? this.actionError,
    errorSeq: errorSeq ?? this.errorSeq,
    clockOffset: clockOffset ?? this.clockOffset,
    myChoices: myChoices ?? this.myChoices,
    myBackedId: myBackedId != null ? myBackedId() : this.myBackedId,
    buzzing: buzzing ?? this.buzzing,
    showingStandings: showingStandings ?? this.showingStandings,
    rankMoves: rankMoves ?? this.rankMoves,
    keepWatching: keepWatching ?? this.keepWatching,
  );

  @override
  List<Object?> get props => [
    seat,
    room,
    connection,
    roomGone,
    left,
    actionError,
    errorSeq,
    clockOffset,
    myChoices,
    myBackedId,
    buzzing,
    showingStandings,
    rankMoves,
    keepWatching,
  ];
}

/// Retry delay for the n-th reconnect attempt: 0.5s, 1s, 2s, 4s, then 5s.
Duration defaultBackoff(int attempt) =>
    Duration(milliseconds: min(5000, 500 * pow(2, attempt).toInt()));

/// One seat's live room state and actions.
/// Every subscribe gets a full snapshot, so reconnecting is just resubscribing.
class RoomCubit extends Cubit<RoomViewState> {
  final GameRepository _game;
  final SeatRepository _seats;

  /// Delay before the n-th reconnect attempt.
  final Duration Function(int attempt) backoff;

  /// Pause before resending an answer that hit a connection error.
  final Duration answerRetryDelay;
  final DateTime Function() _now;

  StreamSubscription<RoomState>? _sub;
  int? _lastRevealId;
  Map<int, int>? _ranksAtLastReveal;
  Timer? _retry;
  int _attempt = 0;

  RoomCubit(
    this._game,
    this._seats,
    Seat seat, {
    this.backoff = defaultBackoff,
    this.answerRetryDelay = const Duration(milliseconds: 600),
    DateTime Function()? now,
  }) : _now = now ?? (() => DateTime.now().toUtc()),
       super(RoomViewState(seat: seat));

  void start() => _subscribe();

  /// Forces a fresh snapshot, e.g. when a phone tab becomes visible again.
  void reconnect() {
    if (state.roomGone || isClosed) return;
    _attempt = 0;
    _subscribe();
  }

  void _subscribe() {
    _retry?.cancel();
    _sub?.cancel();
    _sub = _game
        .watchRoom(state.seat.code)
        .listen(
          _onSnapshot,
          onError: _onStreamError,
          onDone: _scheduleRetry,
          cancelOnError: true,
        );
  }

  void _onSnapshot(RoomState room) {
    _attempt = 0;
    emit(
      state.copyWith(
        room: room,
        connection: ConnectionStatus.connected,
        clockOffset: room.serverTime.difference(_now()),
        rankMoves: _movesAt(room),
        // The standings board only lives inside a reveal.
        showingStandings: room.status == RoomStatus.reveal
            ? state.showingStandings
            : false,
        // A new cut asks again whether to keep watching.
        keepWatching: room.status == RoomStatus.elimination
            ? state.keepWatching
            : false,
      ),
    );
  }

  /// Rank movement is measured from one reveal to the next.
  Map<int, int>? _movesAt(RoomState room) {
    final q = room.question;
    if (room.status != RoomStatus.reveal ||
        q == null ||
        q.id == _lastRevealId) {
      return null;
    }
    final ranks = ranksOf(room);
    final before = _ranksAtLastReveal;
    _lastRevealId = q.id;
    _ranksAtLastReveal = ranks;
    return before == null ? const {} : rankMoves(before, ranks);
  }

  void _onStreamError(Object error) {
    if (error is AppFailure && error.roomGone) {
      _retry?.cancel();
      emit(state.copyWith(roomGone: true));
      return;
    }
    _scheduleRetry();
  }

  void _scheduleRetry() {
    if (isClosed || state.roomGone) return;
    emit(state.copyWith(connection: ConnectionStatus.reconnecting));
    _retry?.cancel();
    _retry = Timer(backoff(_attempt++), _subscribe);
  }

  Future<void> _act(Future<void> Function() action) async {
    try {
      await action();
    } on AppFailure catch (f) {
      _showError(f.message);
    }
  }

  void _showError(String message) {
    if (isClosed) return;
    emit(state.copyWith(actionError: message, errorSeq: state.errorSeq + 1));
  }

  // ---- host actions

  Future<void> startGame() => _act(() => _game.startGame(state.seat));
  Future<void> nextQuestion() => _act(() => _game.nextQuestion(state.seat));
  Future<void> reveal() => _act(() => _game.reveal(state.seat));
  Future<void> endRound() => _act(() => _game.endRound(state.seat));

  /// Host: show the standings board with the danger line before the cut.
  void showStandings() {
    if (state.seat.isHost && state.room?.status == RoomStatus.reveal) {
      emit(state.copyWith(showingStandings: true));
    }
  }

  /// Phone: leave the "You're out" screen and spectate.
  void keepWatchingAsSpectator() => emit(state.copyWith(keepWatching: true));

  Future<void> useWildcard(int playerId) =>
      _act(() => _game.useWildcard(state.seat, playerId));

  /// Host: closes the room to new players, or opens it again.
  Future<void> setLocked(bool locked) =>
      _act(() => _game.setLocked(state.seat, locked));

  /// Host: removes a player from the lobby.
  Future<void> removePlayer(int playerId) =>
      _act(() => _game.removePlayer(state.seat, playerId));

  // ---- player actions

  /// Locks in [choiceIndex]; shows at once, rolled back if the server rejects.
  Future<void> submitAnswer(int choiceIndex) async {
    final room = state.room;
    final question = room?.question;
    if (state.seat.isHost ||
        room == null ||
        question == null ||
        room.status != RoomStatus.question ||
        state.myChoice != null) {
      return;
    }
    final id = question.id;
    emit(state.copyWith(myChoices: {...state.myChoices, id: choiceIndex}));
    try {
      await _sendAnswer(id, choiceIndex);
    } on AppFailure catch (f) {
      // An earlier answer already counts; keep showing a pick.
      if (f.kind == FailureKind.alreadyAnswered || isClosed) return;
      emit(state.copyWith(myChoices: {...state.myChoices}..remove(id)));
      _showError(f.message);
    }
  }

  /// Retries once after a connection blip; alreadyAnswered then means success.
  Future<void> _sendAnswer(int questionId, int choiceIndex) async {
    try {
      await _game.submitAnswer(state.seat, questionId, choiceIndex);
    } on AppFailure catch (f) {
      if (f.kind != FailureKind.connection || isClosed) rethrow;
      await Future<void>.delayed(answerRetryDelay);
      if (isClosed) rethrow;
      await _game.submitAnswer(state.seat, questionId, choiceIndex);
    }
  }

  /// Backs [finalistId]; shows at once, rolled back if rejected.
  Future<void> backFinalist(int finalistId) async {
    if (state.seat.isHost || state.myBackedId == finalistId) return;
    final previous = state.myBackedId;
    emit(state.copyWith(myBackedId: () => finalistId));
    try {
      await _game.backFinalist(state.seat, finalistId);
    } on AppFailure catch (f) {
      if (isClosed) return;
      emit(state.copyWith(myBackedId: () => previous));
      _showError(f.message);
    }
  }

  // ---- buzzer final

  /// Claims the buzzer; the result comes in the next snapshot, or "Too slow".
  Future<void> buzz() async {
    final room = state.room;
    final q = room?.question;
    final me = state.me;
    if (room == null ||
        q == null ||
        me == null ||
        state.buzzing ||
        room.status != RoomStatus.buzzerFinal ||
        me.status != PlayerStatus.finalist ||
        me.lockedOut ||
        room.buzzerHolderId != null) {
      return;
    }
    emit(state.copyWith(buzzing: true));
    try {
      final result = await _game.buzz(state.seat, q.id);
      if (!result.gotBuzzer) _showError(result.reason ?? 'Too slow');
    } on AppFailure catch (f) {
      _showError(f.message);
    } finally {
      if (!isClosed) emit(state.copyWith(buzzing: false));
    }
  }

  Future<void> submitBuzzAnswer(int choiceIndex) async {
    final room = state.room;
    final q = room?.question;
    final me = state.me;
    if (room == null ||
        q == null ||
        me == null ||
        room.status != RoomStatus.buzzerFinal ||
        room.buzzerHolderId != me.id ||
        state.myChoices.containsKey(q.id)) {
      return;
    }
    emit(state.copyWith(myChoices: {...state.myChoices, q.id: choiceIndex}));
    try {
      await _game.submitBuzzAnswer(state.seat, q.id, choiceIndex);
    } on AppFailure catch (f) {
      if (isClosed) return;
      emit(state.copyWith(myChoices: {...state.myChoices}..remove(q.id)));
      _showError(f.message);
    }
  }

  // ---- seat

  Future<void> leave() async {
    // Best effort: offline, the game simply stops hearing from them.
    if (!state.seat.isHost) {
      try {
        await _game.leaveRoom(state.seat);
      } catch (_) {}
    }
    await _seats.clear();
    emit(state.copyWith(left: true));
  }

  @override
  Future<void> close() {
    _retry?.cancel();
    _sub?.cancel();
    return super.close();
  }
}
