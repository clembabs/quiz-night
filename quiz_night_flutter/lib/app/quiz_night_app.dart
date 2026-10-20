import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../core/platform/screen_wake_lock.dart';
import '../core/theme/app_theme.dart';
import '../data/room_repositories.dart';
import '../data/seat_repository.dart';
import '../features/home/home_cubit.dart';
import '../features/home/home_screen.dart';

/// App root. Takes its repositories from outside, so tests can pass fakes.
class QuizNightApp extends StatelessWidget {
  final LobbyRepository lobby;
  final GameRepository game;
  final SeatRepository seats;

  /// Defaults to doing nothing; main.dart passes the browser's wake lock.
  final ScreenWakeLock wakeLock;

  /// Room code from a scanned QR link.
  final String? initialCode;

  const QuizNightApp({
    super.key,
    required this.lobby,
    required this.game,
    required this.seats,
    this.wakeLock = const NoopScreenWakeLock(),
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
      ],
      child: MaterialApp(
        title: 'Quiz Night',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.dark(),
        home: BlocProvider(
          create: (_) =>
              HomeCubit(lobby, seats, initialCode: initialCode)..restore(),
          child: const HomeScreen(),
        ),
      ),
    );
  }
}
