import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../app/app_routes.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/theme/app_text_styles.dart';
import '../../data/seat.dart';
import '../../widgets/common.dart';
import 'home_cubit.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  Future<void> _open(BuildContext context, Route<void> route) async {
    final cubit = context.read<HomeCubit>();
    await Navigator.of(context).push(route);
    await cubit.refresh();
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<HomeCubit, HomeState>(
      listenWhen: (a, b) => b.route != null && a.route != b.route,
      listener: (context, state) {
        final route = state.route!;
        context.read<HomeCubit>().routeHandled();
        _open(
          context,
          switch (route) {
            JoinRoute(:final code) => AppRoutes.join(code: code),
            RoomRoute(:final seat) => AppRoutes.room(seat),
          },
        );
      },
      builder: (context, state) {
        final saved = state.savedSeat;
        return Scaffold(
          body: SafeArea(
            child: CenteredContent(
              child: Padding(
                padding: AppSpacing.screenPadding,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const Icon(
                      Icons.emoji_events_rounded,
                      size: AppIconSizes.hero,
                      color: AppColors.gold,
                    ),
                    const SizedBox(height: AppSpacing.md),
                    const Text(
                      'Quiz Night',
                      textAlign: TextAlign.center,
                      style: AppTextStyles.title,
                    ),
                    const SizedBox(height: AppSpacing.sm),
                    const Text(
                      'Survive the round, or go home.',
                      textAlign: TextAlign.center,
                      style: AppTextStyles.tagline,
                    ),
                    const SizedBox(height: AppSpacing.xxxl),
                    if (saved != null) ...[
                      FilledButton.icon(
                        onPressed: () => _open(context, AppRoutes.room(saved)),
                        icon: const Icon(Icons.login_rounded),
                        label: Text(rejoinLabel(saved)),
                      ),
                      const SizedBox(height: AppSpacing.xl),
                    ],
                    FilledButton(
                      onPressed: () => _open(
                        context,
                        AppRoutes.join(
                          code: context.read<HomeCubit>().initialCode,
                        ),
                      ),
                      child: const Text('Join a game'),
                    ),
                    const SizedBox(height: AppSpacing.md),
                    OutlinedButton(
                      onPressed: () => _open(context, AppRoutes.hostSetup()),
                      child: const Text('Host a game'),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

/// Label for the button that takes you back to a saved seat.
String rejoinLabel(Seat seat) =>
    seat.isHost ? 'Back to hosting ${seat.code}' : 'Rejoin room ${seat.code}';
