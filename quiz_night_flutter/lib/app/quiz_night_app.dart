import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../core/platform/haptics.dart';
import '../core/platform/screen_wake_lock.dart';
import '../core/theme/app_theme.dart';
import '../data/room_repositories.dart';
import '../data/seat_repository.dart';
import '../features/home/home_cubit.dart';
import 'app_paths.dart';
import 'app_router.dart';

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

/// Stateful only to own the router and the resume check for the app's life.
class _QuizNightAppState extends State<QuizNightApp> {
  late final GoRouter _router = buildAppRouter(
    initialLocation: widget.initialLocation,
  );

  /// The address the app opened at.
  late final Uri _start = widget.initialLocation == null
      ? Uri.base
      : Uri.parse(widget.initialLocation!);

  late final HomeCubit _resume = HomeCubit(
    widget.lobby,
    widget.seats,
    initialCode: _start.queryParameters['code'],
  )..restore();

  @override
  void dispose() {
    _resume.close();
    _router.dispose();
    super.dispose();
  }

  /// A reload, a rescanned QR or a phone waking up on the home or join page
  /// goes straight back into a live game. Other pages stay where they are.
  void _resumeIfOnTheWayIn(RoomRoute route) {
    final path = _router.routerDelegate.currentConfiguration.uri.path;
    if (path != AppPaths.home && path != AppPaths.join) return;
    _router.go(AppPaths.roomFor(route.seat.code), extra: route.seat);
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
      child: BlocListener<HomeCubit, HomeState>(
        bloc: _resume,
        listenWhen: (a, b) => b.route is RoomRoute && a.route != b.route,
        listener: (context, state) {
          _resume.routeHandled();
          _resumeIfOnTheWayIn(state.route! as RoomRoute);
        },
        child: MaterialApp.router(
          title: 'Quiz Night',
          debugShowCheckedModeBanner: false,
          theme: AppTheme.dark(),
          routerConfig: _router,
        ),
      ),
    );
  }
}
