import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../core/platform/haptics.dart';
import '../core/platform/screen_wake_lock.dart';
import '../core/theme/app_theme.dart';
import '../data/room_repositories.dart';
import '../data/seat_repository.dart';
import '../features/home/home_cubit.dart';
import '../features/home/home_screen.dart';
import '../features/join/join_cubit.dart';
import '../features/landing/landing_cubit.dart';

/// App root. Takes its repositories from outside, so tests can pass fakes.
class QuizNightApp extends StatelessWidget {
  final LobbyRepository lobby;
  final GameRepository game;
  final SeatRepository seats;

  /// Defaults to doing nothing; main.dart passes the browser's wake lock.
  final ScreenWakeLock wakeLock;

  /// Vibration feedback; main.dart passes the browser's Vibration API.
  final Haptics? haptics;

  /// Room code from a scanned QR link.
  final String? initialCode;

  const QuizNightApp({
    super.key,
    required this.lobby,
    required this.game,
    required this.seats,
    this.wakeLock = const NoopScreenWakeLock(),
    this.haptics,
    this.initialCode,
  });

  @override
  Widget build(BuildContext context) {
    return MultiRepositoryProvider(
      providers: [
        RepositoryProvider<LobbyRepository>.value(value: lobby),
        RepositoryProvider<GameRepository>.value(value: game),
        RepositoryProvider<SeatRepository>.value(value: seats),
        RepositoryProvider<ScreenWakeLock>.value(value: wakeLock),
        RepositoryProvider<Haptics>(create: (_) => haptics ?? SilentHaptics()),
      ],
      child: MaterialApp(
        title: 'Quiz Night',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.dark(),
        home: MultiBlocProvider(
          providers: [
            BlocProvider(
              create: (_) =>
                  HomeCubit(lobby, seats, initialCode: initialCode)..restore(),
            ),
            BlocProvider(create: (_) => JoinCubit(lobby, seats)),
            BlocProvider(create: (_) => LandingCubit()),
          ],
          child: const HomeScreen(),
        ),
      ),
    );
  }
}
