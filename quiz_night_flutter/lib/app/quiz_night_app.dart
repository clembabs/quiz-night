import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../core/platform/haptics.dart';
import '../core/platform/screen_wake_lock.dart';
import '../core/theme/app_theme.dart';
import '../data/room_repositories.dart';
import '../data/seat_repository.dart';
import 'app_router.dart';
import 'seat_resume.dart';

/// App root. Takes its repositories from outside, so tests can pass fakes.
class QuizNightApp extends StatefulWidget {
  final LobbyRepository lobby;
  final GameRepository game;
  final SeatRepository seats;

  /// Defaults to doing nothing; main.dart passes the browser's wake lock.
  final ScreenWakeLock wakeLock;

  /// Vibration feedback; main.dart passes the browser's Vibration API.
  final Haptics? haptics;

  /// Where to start, e.g. `/join?code=4821`. Null on the web: the router
  /// reads the browser's address bar.
  final String? initialLocation;

  const QuizNightApp({
    super.key,
    required this.lobby,
    required this.game,
    required this.seats,
    this.wakeLock = const NoopScreenWakeLock(),
    this.haptics,
    this.initialLocation,
  });

  @override
  State<QuizNightApp> createState() => _QuizNightAppState();
}

/// Stateful only to own the router for the app's life.
class _QuizNightAppState extends State<QuizNightApp> {
  late final GoRouter _router = buildAppRouter(
    resume: SeatResume(widget.lobby, widget.seats),
    initialLocation: widget.initialLocation,
  );

  @override
  void dispose() {
    _router.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MultiRepositoryProvider(
      providers: [
        RepositoryProvider<LobbyRepository>.value(value: widget.lobby),
        RepositoryProvider<GameRepository>.value(value: widget.game),
        RepositoryProvider<SeatRepository>.value(value: widget.seats),
        RepositoryProvider<ScreenWakeLock>.value(value: widget.wakeLock),
        RepositoryProvider<Haptics>(
          create: (_) => widget.haptics ?? SilentHaptics(),
        ),
      ],
      child: MaterialApp.router(
        title: 'Quiz Night',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.dark(),
        routerConfig: _router,
      ),
    );
  }
}
