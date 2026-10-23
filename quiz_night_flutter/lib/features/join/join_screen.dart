import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../app/app_paths.dart';
import '../../data/room_repositories.dart';
import '../../data/seat_repository.dart';
import '../../widgets/qn/phone_frame.dart';
import 'join_cubit.dart';
import 'join_form.dart';

/// `/join`: room code and nickname on a phone. [code] comes from the URL
/// (a scanned QR, or the landing page's code box).
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
    child: BlocListener<JoinCubit, JoinState>(
      listenWhen: (a, b) => b.seat != null && a.seat != b.seat,
      listener: (context, state) =>
          context.go(AppPaths.roomFor(state.seat!.code)),
      child: Scaffold(
        body: PhoneFrame(
          child: JoinForm(
            key: ValueKey(code),
            initialCode: code,
            onHost: () => context.go(AppPaths.host),
            onBack: () => context.go(AppPaths.home),
          ),
        ),
      ),
    ),
  );
}
