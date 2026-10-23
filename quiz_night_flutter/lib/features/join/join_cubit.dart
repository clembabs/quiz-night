import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../data/app_failure.dart';
import '../../data/room_repositories.dart';
import '../../data/seat.dart';
import '../../data/seat_repository.dart';

/// Which field an error belongs to, so the form can show it in place.
enum JoinError {
  missingFields,
  roomNotFound,
  gameStarted,
  roomFull,
  nicknameTaken,
  other,
}

class JoinState extends Equatable {
  final bool submitting;
  final String? error;
  final JoinError? errorKind;

  /// Set once joined; the screen moves into the room.
  final Seat? seat;

  const JoinState({
    this.submitting = false,
    this.error,
    this.errorKind,
    this.seat,
  });

  @override
  List<Object?> get props => [submitting, error, errorKind, seat];
}

class JoinCubit extends Cubit<JoinState> {
  final LobbyRepository _lobby;
  final SeatRepository _seats;

  JoinCubit(this._lobby, this._seats) : super(const JoinState());

  Future<void> join(String code, String nickname) async {
    final cleanCode = code.trim().toUpperCase();
    final cleanName = nickname.trim();
    if (cleanCode.isEmpty || cleanName.isEmpty) {
      emit(
        const JoinState(
          error: 'Enter the room code and a nickname',
          errorKind: JoinError.missingFields,
        ),
      );
      return;
    }
    emit(const JoinState(submitting: true));
    try {
      final seat = await _lobby.joinRoom(cleanCode, cleanName);
      await _seats.save(seat);
      emit(JoinState(seat: seat));
    } on AppFailure catch (f) {
      emit(JoinState(error: _messageFor(f), errorKind: _kindFor(f)));
    }
  }

  static JoinError _kindFor(AppFailure f) => switch (f.kind) {
    FailureKind.roomGone => JoinError.roomNotFound,
    FailureKind.gameStarted => JoinError.gameStarted,
    FailureKind.roomFull => JoinError.roomFull,
    FailureKind.nicknameTaken => JoinError.nicknameTaken,
    _ => JoinError.other,
  };

  /// The design system's wording for the errors players actually hit.
  static String _messageFor(AppFailure f) => switch (f.kind) {
    FailureKind.roomGone =>
      "This game session doesn't exist. Check the code on the big screen.",
    FailureKind.gameStarted =>
      'This game already started. Ask the host to open a new room.',
    _ => f.message,
  };
}
