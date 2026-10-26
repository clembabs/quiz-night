import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../app/app_paths.dart';
import '../../data/room_repositories.dart';
import '../../data/seat_repository.dart';
import '../../widgets/qn/notices.dart';
import '../landing/landing_screen.dart';
import '../landing/widgets/landing_parts.dart';
import 'join_cubit.dart';
import 'join_form.dart';

/// `/join`: code and nickname form; [code] comes from the URL (QR or landing).
class JoinScreen extends StatelessWidget {
  final String? code;

  const JoinScreen({super.key, this.code});

  @override
  Widget build(BuildContext context) => BlocProvider(
    // A new code is a new form: no error carried over from the last one.
    key: ValueKey(code),
    create: (context) => JoinCubit(
      context.read<LobbyRepository>(),
      context.read<SeatRepository>(),
    ),
    child: MultiBlocListener(
      listeners: [
        BlocListener<JoinCubit, JoinState>(
          listenWhen: (a, b) => b.seat != null && a.seat != b.seat,
          listener: (context, state) =>
              context.go(AppPaths.roomFor(state.seat!.code)),
        ),
        // Errors also show in the form, next to what they are about.
        BlocListener<JoinCubit, JoinState>(
          listenWhen: (a, b) => b.error != null && a.error != b.error,
          listener: (context, state) => showToast(
            context,
            state.error!,
            // The room exists but can't take you: a warning, as in the banner.
            kind: switch (state.errorKind) {
              JoinError.gameStarted ||
              JoinError.roomFull ||
              JoinError.roomLocked => ToastKind.warning,
              _ => ToastKind.error,
            },
          ),
        ),
      ],
      child: SiteScaffold(
        current: null,
        sections: (context) => [
          JoinSection(
            key: ValueKey(code),
            code: code,
            onHost: () => context.go(AppPaths.host),
          ),
        ],
      ),
    ),
  );
}

/// The page's heading and the form in a card, in a narrow column.
class JoinSection extends StatelessWidget {
  final String? code;
  final VoidCallback onHost;

  const JoinSection({super.key, this.code, required this.onHost});

  /// Wide enough for the form, narrow enough to read as one card.
  static const maxWidth = 560.0;

  @override
  Widget build(BuildContext context) => LandingSection(
    maxWidth: maxWidth,
    top: 32,
    bottom: 72,
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const SectionHeading(eyebrow: 'Join a game', title: 'Get in the room'),
        const SizedBox(height: 20),
        LandingCard(
          child: JoinForm(initialCode: code, onHost: onHost),
        ),
      ],
    ),
  );
}
