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
