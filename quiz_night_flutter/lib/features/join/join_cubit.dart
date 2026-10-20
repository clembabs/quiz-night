import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../data/app_failure.dart';
import '../../data/room_repositories.dart';
import '../../data/seat.dart';
import '../../data/seat_repository.dart';

class JoinState extends Equatable {
  final bool submitting;
  final String? error;

  /// Set once joined; the screen moves into the room.
  final Seat? seat;

  const JoinState({this.submitting = false, this.error, this.seat});

  @override
  List<Object?> get props => [submitting, error, seat];
}

class JoinCubit extends Cubit<JoinState> {
  final LobbyRepository _lobby;
  final SeatRepository _seats;

  JoinCubit(this._lobby, this._seats) : super(const JoinState());

  Future<void> join(String code, String nickname) async {
    final cleanCode = code.trim().toUpperCase();
    final cleanName = nickname.trim();
    if (cleanCode.isEmpty || cleanName.isEmpty) {
      emit(const JoinState(error: 'Enter the room code and a nickname'));
      return;
    }
    emit(const JoinState(submitting: true));
    try {
      final seat = await _lobby.joinRoom(cleanCode, cleanName);
      await _seats.save(seat);
      emit(JoinState(seat: seat));
    } on AppFailure catch (f) {
      emit(JoinState(error: f.message));
    }
  }
}
