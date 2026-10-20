import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../data/room_repositories.dart';
import '../data/seat.dart';
import '../data/seat_repository.dart';
import '../features/host_setup/host_setup_cubit.dart';
import '../features/host_setup/host_setup_screen.dart';
import '../features/join/join_cubit.dart';
import '../features/join/join_screen.dart';
import '../features/room/room_cubit.dart';
import '../features/room/room_screen.dart';

/// Builds each screen together with its cubit, so screens never construct
/// their own dependencies.
abstract final class AppRoutes {
  static Route<void> join({String? code}) => MaterialPageRoute(
    builder: (context) => BlocProvider(
      create: (context) => JoinCubit(
        context.read<LobbyRepository>(),
        context.read<SeatRepository>(),
      ),
      child: JoinScreen(initialCode: code),
    ),
  );

  static Route<void> hostSetup() => MaterialPageRoute(
    builder: (context) => BlocProvider(
      create: (context) => HostSetupCubit(
        context.read<LobbyRepository>(),
        context.read<SeatRepository>(),
      ),
      child: const HostSetupScreen(),
    ),
  );

  static Route<void> room(Seat seat) => MaterialPageRoute(
    builder: (context) => BlocProvider(
      create: (context) => RoomCubit(
        context.read<GameRepository>(),
        context.read<SeatRepository>(),
        seat,
      )..start(),
      child: const RoomScreen(),
    ),
  );
}
