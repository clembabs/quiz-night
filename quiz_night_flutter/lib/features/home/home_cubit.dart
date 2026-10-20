import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../data/room_repositories.dart';
import '../../data/seat.dart';
import '../../data/seat_repository.dart';

/// Where the home screen should send the user right away, if anywhere.
sealed class HomeRoute extends Equatable {
  const HomeRoute();
}

/// Open the join form, pre-filled with a code from a scanned QR.
class JoinRoute extends HomeRoute {
  final String code;
  const JoinRoute(this.code);

  @override
  List<Object?> get props => [code];
}

/// Go straight back into a room this browser already has a seat in.
class RoomRoute extends HomeRoute {
  final Seat seat;
  const RoomRoute(this.seat);

  @override
  List<Object?> get props => [seat];
}

class HomeState extends Equatable {
  final bool loading;

  /// A still-valid seat from an earlier visit, offered as "Rejoin".
  final Seat? savedSeat;

  /// One-shot navigation; the screen calls [HomeCubit.routeHandled] after.
  final HomeRoute? route;

  const HomeState({this.loading = true, this.savedSeat, this.route});

  @override
  List<Object?> get props => [loading, savedSeat, route];
}

class HomeCubit extends Cubit<HomeState> {
  final LobbyRepository _lobby;
  final SeatRepository _seats;

  /// Room code from the page URL (`?code=ABCD`), if the user scanned a QR.
  final String? initialCode;

  HomeCubit(this._lobby, this._seats, {this.initialCode})
    : super(const HomeState());

  Future<void> restore() async {
    final code = initialCode;
    final saved = await _seats.load();

    // A QR for a different room wins over an old seat.
    if (code != null && saved?.code != code) {
      emit(HomeState(loading: false, route: JoinRoute(code)));
      return;
    }
    if (saved == null) {
      emit(const HomeState(loading: false));
      return;
    }
    if (!await _lobby.isSeatValid(saved)) {
      await _seats.clear();
      emit(const HomeState(loading: false));
      return;
    }
    emit(
      HomeState(
        loading: false,
        savedSeat: saved,
        // Rescanning the QR of the room you're in: go straight back in.
        route: code != null ? RoomRoute(saved) : null,
      ),
    );
  }

  void routeHandled() =>
      emit(HomeState(loading: state.loading, savedSeat: state.savedSeat));

  /// Re-reads the saved seat, e.g. after returning from a room.
  Future<void> refresh() async {
    final saved = await _seats.load();
    emit(HomeState(loading: false, savedSeat: saved));
  }
}
