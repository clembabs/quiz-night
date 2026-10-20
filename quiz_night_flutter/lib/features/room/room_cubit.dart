import 'dart:async';
import 'dart:math';

import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:quiz_night_client/quiz_night_client.dart';

import '../../data/app_failure.dart';
import '../../data/room_repositories.dart';
import '../../data/seat.dart';
import '../../data/seat_repository.dart';

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

  /// Last failed action. [errorSeq] changes on every failure so the same
  /// message twice still shows twice.
  final String? actionError;
  final int errorSeq;

  /// Server clock minus local clock, so countdowns follow server time.
  final Duration clockOffset;

  /// The option this player picked, per question id. Kept locally so the
  /// tapped button stays highlighted; the server never reveals others' picks.
  final Map<int, int> myChoices;

  /// The finalist this spectator backed. The server keeps picks hidden until
  /// the podium, so it is remembered here.
  final int? myBackedId;

  /// A buzz is on its way to the server; ignore further taps.
  final bool buzzing;

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
  });

  PlayerView? get me => seat.playerId == null
      ? null
      : room?.players.where((p) => p.id == seat.playerId).firstOrNull;

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
  ];
}

/// Retry delay for the n-th reconnect attempt: 0.5s, 1s, 2s, 4s, then 5s.
Duration defaultBackoff(int attempt) =>
    Duration(milliseconds: min(5000, 500 * pow(2, attempt).toInt()));

/// Keeps one seat's live room state and runs its actions.
///
/// The server sends a full snapshot on every subscribe, so reconnecting is
/// just subscribing again.
class RoomCubit extends Cubit<RoomViewState> {
  final GameRepository _game;
  final SeatRepository _seats;

  /// Delay before the n-th reconnect attempt.
  final Duration Function(int attempt) backoff;
  final DateTime Function() _now;

  StreamSubscription<RoomState>? _sub;
  Timer? _retry;
  int _attempt = 0;

  RoomCubit(
    this._game,
    this._seats,
    Seat seat, {
    this.backoff = defaultBackoff,
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
      ),
    );
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
  Future<void> useWildcard(int playerId) =>
      _act(() => _game.useWildcard(state.seat, playerId));

  // ---- player actions

  /// Locks in [choiceIndex] for the open question. The pick shows at once;
  /// if the server rejects it (e.g. too late) it is rolled back.
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
      await _game.submitAnswer(state.seat, id, choiceIndex);
    } on AppFailure catch (f) {
      // An earlier answer already counts; keep showing a pick.
      if (f.kind == FailureKind.alreadyAnswered || isClosed) return;
      emit(state.copyWith(myChoices: {...state.myChoices}..remove(id)));
      _showError(f.message);
    }
  }

  /// Backs [finalistId] to win. Shows at once; rolled back if rejected.
  /// Picking again changes the pick.
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

  /// Tries to claim the buzzer. Whether it worked arrives with the next
  /// snapshot; a refusal ("Too slow") is shown as a message.
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

  /// Answers while holding the buzzer.
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
