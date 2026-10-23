import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../app/app_paths.dart';
import '../../core/theme/app_colors.dart';
import '../../data/room_repositories.dart';
import '../../data/seat.dart';
import '../../data/seat_repository.dart';
import '../../widgets/qn/loaders.dart';
import 'room_cubit.dart';
import 'room_screen.dart';

enum RoomGateStatus { loading, ready, noSeat }

class RoomGateState extends Equatable {
  final RoomGateStatus status;
  final Seat? seat;

  const RoomGateState._(this.status, this.seat);
  const RoomGateState.loading() : this._(RoomGateStatus.loading, null);
  const RoomGateState.ready(Seat seat) : this._(RoomGateStatus.ready, seat);
  const RoomGateState.noSeat() : this._(RoomGateStatus.noSeat, null);

  @override
  List<Object?> get props => [status, seat];
}

/// Finds this device's saved seat for the room in the URL. Join and host
/// save the seat before opening the room, so this also covers a refresh.
class RoomGateCubit extends Cubit<RoomGateState> {
  final SeatRepository _seats;
  final String code;

  RoomGateCubit(this._seats, this.code) : super(const RoomGateState.loading());

  Future<void> load() async {
    final saved = await _seats.load();
    emit(
      saved != null && saved.code == code
          ? RoomGateState.ready(saved)
          : const RoomGateState.noSeat(),
    );
  }
}

/// `/room/:code`. Opens the room with this device's seat, or sends a
/// visitor without one to the join form for that code.
class RoomGate extends StatelessWidget {
  final String code;

  const RoomGate({super.key, required this.code});

  @override
  Widget build(BuildContext context) => BlocProvider(
    create: (context) =>
        RoomGateCubit(context.read<SeatRepository>(), code)..load(),
    child: BlocConsumer<RoomGateCubit, RoomGateState>(
      listenWhen: (a, b) => b.status == RoomGateStatus.noSeat,
      listener: (context, _) => context.go(AppPaths.joinWith(code)),
      builder: (context, state) {
        final seat = state.seat;
        if (seat == null) {
          return const Scaffold(
            backgroundColor: AppColors.board,
            body: Center(child: PulsingDots()),
          );
        }
        return BlocProvider(
          key: ValueKey(seat.token),
          create: (context) => RoomCubit(
            context.read<GameRepository>(),
            context.read<SeatRepository>(),
            seat,
          )..start(),
          child: const RoomScreen(),
        );
      },
    ),
  );
}
