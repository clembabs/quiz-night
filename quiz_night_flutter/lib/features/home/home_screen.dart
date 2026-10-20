import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../app/app_routes.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/theme/app_text_styles.dart';
import '../../widgets/brand/crest.dart';
import '../../widgets/qn/notices.dart';
import '../../widgets/qn/phone_frame.dart';
import '../join/join_cubit.dart';
import 'home_cubit.dart';

/// The landing page is the join form (prototype "Join"): crest lockup, room
/// code, nickname, JOIN GAME. Hosts on a laptop use the link underneath.
class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

/// Stateful only to start a fresh form each time you come back from a room.
class _HomeScreenState extends State<HomeScreen> {
  /// Bumped on return from a room; a new key gives the form empty fields.
  int _formGeneration = 0;

  Future<void> _open(Route<void> route) async {
    final home = context.read<HomeCubit>();
    final join = context.read<JoinCubit>();
    await Navigator.of(context).push(route);
    await home.refresh();
    if (!mounted) return;
    // Old code, nickname and errors belong to the game you just left.
    join.reset();
    setState(() => _formGeneration++);
  }

  @override
  Widget build(BuildContext context) {
    return MultiBlocListener(
      listeners: [
        BlocListener<HomeCubit, HomeState>(
          listenWhen: (a, b) => b.route != null && a.route != b.route,
          listener: (context, state) {
            final route = state.route!;
            context.read<HomeCubit>().routeHandled();
            // A QR link only pre-fills the code; a live seat goes straight in.
            if (route is RoomRoute) {
              _open(AppRoutes.room(route.seat));
            }
          },
        ),
        BlocListener<JoinCubit, JoinState>(
          listenWhen: (a, b) => b.seat != null && a.seat != b.seat,
          listener: (context, state) => _open(AppRoutes.room(state.seat!)),
        ),
      ],
      child: Scaffold(
        body: PhoneFrame(
          child: JoinForm(
            key: ValueKey(_formGeneration),
            // The QR's code is for the first visit only.
            initialCode: _formGeneration == 0
                ? context.read<HomeCubit>().initialCode
                : null,
            onHost: () => _open(AppRoutes.hostSetup()),
          ),
        ),
      ),
    );
  }
}

/// Room code + nickname + JOIN GAME.
class JoinForm extends StatefulWidget {
  final String? initialCode;
  final VoidCallback onHost;

  const JoinForm({super.key, this.initialCode, required this.onHost});

  @override
  State<JoinForm> createState() => _JoinFormState();
}

/// Stateful only to own the text controllers.
class _JoinFormState extends State<JoinForm> {
  late final _code = TextEditingController(text: widget.initialCode ?? '');
  final _name = TextEditingController();

  @override
  void dispose() {
    _code.dispose();
    _name.dispose();
    super.dispose();
  }

  void _submit() => context.read<JoinCubit>().join(_code.text, _name.text);

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<JoinCubit, JoinState>(
      builder: (context, state) {
        final notFound = state.errorKind == JoinError.roomNotFound;
        final started = state.errorKind == JoinError.gameStarted;
        final fieldError = !notFound && !started ? state.error : null;
        return LayoutBuilder(
          builder: (context, constraints) => SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 20),
            child: ConstrainedBox(
              constraints: BoxConstraints(
                minHeight: (constraints.maxHeight - 36).clamp(0, 9999),
              ),
              child: IntrinsicHeight(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const Padding(
                      padding: EdgeInsets.only(top: 32),
                      child: Center(
                        child: QuizNightStackedMark(
                          subtitle: 'Survive the round, or go home.',
                        ),
                      ),
                    ),
                    const Spacer(),
                    const SizedBox(height: 20),
                    if (started) ...[
                      QnBanner(kind: BannerKind.warning, text: state.error!),
                      const SizedBox(height: 20),
                    ],
                    const _FieldLabel('Room code'),
                    TextField(
                      key: const Key('join.code'),
                      controller: _code,
                      autofocus: widget.initialCode == null,
                      keyboardType: TextInputType.number,
                      inputFormatters: [
                        FilteringTextInputFormatter.digitsOnly,
                        LengthLimitingTextInputFormatter(4),
                      ],
                      style: AppTextStyles.codeInput,
                      decoration: InputDecoration(
                        hintText: '0000',
                        hintStyle: AppTextStyles.codeInput.copyWith(
                          color: AppColors.faint,
                        ),
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 13,
                        ),
                        enabledBorder: _codeBorder(
                          notFound ? AppColors.wrong : AppColors.gold,
                        ),
                        focusedBorder: _codeBorder(
                          notFound ? AppColors.wrong : AppColors.gold,
                        ),
                      ),
                    ),
                    if (notFound)
                      Padding(
                        padding: const EdgeInsets.only(top: 6),
                        child: Text(
                          '✕ ${state.error}',
                          style: AppTextStyles.error,
                        ),
                      ),
                    const SizedBox(height: 20),
                    const _FieldLabel('Nickname'),
                    TextField(
                      key: const Key('join.nickname'),
                      controller: _name,
                      autofocus: widget.initialCode != null,
                      maxLength: 20,
                      textInputAction: TextInputAction.go,
                      onSubmitted: (_) => _submit(),
                      style: AppTextStyles.input,
                      decoration: const InputDecoration(
                        hintText: 'e.g. Ọlá',
                        counterText: '',
                      ),
                    ),
                    if (fieldError != null)
                      Padding(
                        padding: const EdgeInsets.only(top: 6),
                        child: Text(fieldError, style: AppTextStyles.error),
                      ),
                    const SizedBox(height: 20),
                    SizedBox(
                      height: 60,
                      child: FilledButton(
                        key: const Key('join.submit'),
                        onPressed: state.submitting ? null : _submit,
                        style: FilledButton.styleFrom(
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14),
                          ),
                        ),
                        child: state.submitting
                            ? const SizedBox.square(
                                dimension: 22,
                                child: CircularProgressIndicator(
                                  strokeWidth: 3,
                                  color: AppColors.goldInk,
                                ),
                              )
                            : Text(
                                'JOIN GAME',
                                style: AppTextStyles.headline.copyWith(
                                  fontSize: 22,
                                  color: AppColors.goldInk,
                                ),
                              ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    TextButton(
                      key: const Key('home.host'),
                      onPressed: widget.onHost,
                      child: Text(
                        'Hosting on a big screen? Host a game',
                        style: AppTextStyles.body.copyWith(
                          color: AppColors.muted,
                          fontSize: 15,
                        ),
                      ),
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

  static OutlineInputBorder _codeBorder(Color color) => OutlineInputBorder(
    borderRadius: BorderRadius.circular(AppRadii.md),
    borderSide: BorderSide(color: color, width: AppBorders.focus),
  );
}

class _FieldLabel extends StatelessWidget {
  final String text;

  const _FieldLabel(this.text);

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.only(bottom: 6),
    child: Text(
      text,
      style: AppTextStyles.chip.copyWith(
        fontSize: 14,
        color: AppColors.chalkSoft,
      ),
    ),
  );
}
