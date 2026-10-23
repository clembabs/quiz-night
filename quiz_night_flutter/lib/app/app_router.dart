import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../data/room_repositories.dart';
import '../data/seat_repository.dart';
import '../features/host_setup/host_setup_cubit.dart';
import '../features/host_setup/host_setup_screen.dart';
import '../features/join/join_screen.dart';
import '../features/landing/landing_screen.dart';
import '../features/room/room_gate.dart';
import 'app_paths.dart';
import 'seat_resume.dart';

/// The app's URLs. Each screen builds its own cubit from the repositories
/// above the router, so screens never construct their dependencies.
GoRouter buildAppRouter({
  required SeatResume resume,
  String? initialLocation,
}) => GoRouter(
  initialLocation: initialLocation,
  redirect: (context, state) async {
    final room = await resume.redirectFor(state.uri);
    if (room != null) return room;
    // Old QR links put the code on the home page: `/?code=4821`.
    final code = state.uri.queryParameters['code'];
    if (state.uri.path == AppPaths.home && code != null && code.isNotEmpty) {
      return AppPaths.joinWith(code);
    }
    return null;
  },
  errorBuilder: (context, state) => const NotFoundPage(),
  routes: [
    GoRoute(path: AppPaths.home, builder: (_, _) => const HomePage()),
    GoRoute(
      path: AppPaths.howItWorks,
      builder: (_, _) => const HowItWorksPage(),
    ),
    GoRoute(path: AppPaths.teachers, builder: (_, _) => const TeachersPage()),
    GoRoute(path: AppPaths.faq, builder: (_, _) => const FaqPage()),
    GoRoute(
      path: AppPaths.join,
      builder: (_, state) =>
          JoinScreen(code: state.uri.queryParameters['code']),
    ),
    GoRoute(
      path: AppPaths.host,
      builder: (context, _) => BlocProvider(
        create: (context) => HostSetupCubit(
          context.read<LobbyRepository>(),
          context.read<SeatRepository>(),
        ),
        child: const HostSetupScreen(),
      ),
    ),
    GoRoute(
      path: AppPaths.room,
      builder: (_, state) => RoomGate(code: state.pathParameters['code']!),
    ),
  ],
);
