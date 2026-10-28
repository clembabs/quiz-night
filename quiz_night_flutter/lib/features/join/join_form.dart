import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../core/room_code.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/theme/app_text_styles.dart';
import '../../widgets/qn/notices.dart';
import 'join_cubit.dart';

/// Room code + nickname + JOIN GAME. The page around it scrolls.
class JoinForm extends StatefulWidget {
  final String? initialCode;
  final VoidCallback onHost;

  const JoinForm({super.key, this.initialCode, required this.onHost});

  @override
  State<JoinForm> createState() => _JoinFormState();
}

/// Stateful to own the text controllers and the fields' focus.
class _JoinFormState extends State<JoinForm> {
  late final _code = TextEditingController(text: widget.initialCode ?? '');
  final _name = TextEditingController();
  final _codeFocus = FocusNode();
  final _nameFocus = FocusNode();
  final _submitArea = GlobalKey();
  Timer? _scroll;

  @override
  void initState() {
    super.initState();
    _codeFocus.addListener(_keepJoinVisible);
    _nameFocus.addListener(_keepJoinVisible);
  }

  @override
  void dispose() {
    _code.dispose();
    _name.dispose();
    _codeFocus.dispose();
    _nameFocus.dispose();
    _scroll?.cancel();
    super.dispose();
  }

  /// Phone keyboards cover the bottom of the page; once one has opened,
  /// scroll so JOIN GAME sits just above it.
  void _keepJoinVisible() {
    if (!_codeFocus.hasFocus && !_nameFocus.hasFocus) return;
    _scroll?.cancel();
    _scroll = Timer(const Duration(milliseconds: 350), () {
      final target = _submitArea.currentContext;
      if (target == null || !target.mounted) return;
      Scrollable.ensureVisible(
        target,
        duration: const Duration(milliseconds: 200),
        alignmentPolicy: ScrollPositionAlignmentPolicy.keepVisibleAtEnd,
      );
    });
  }

  void _submit() => context.read<JoinCubit>().join(_code.text, _name.text);

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<JoinCubit, JoinState>(
      builder: (context, state) {
        final notFound = state.errorKind == JoinError.roomNotFound;
        // Problems with the room itself go in a banner, not under a field.
        final started =
            state.errorKind == JoinError.gameStarted ||
            state.errorKind == JoinError.roomFull ||
            state.errorKind == JoinError.roomLocked;
        final fieldError = !notFound && !started ? state.error : null;
        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            if (started) ...[
              QnBanner(kind: BannerKind.warning, text: state.error!),
              const SizedBox(height: 20),
            ],
            const _FieldLabel('Room code'),
            TextField(
              key: const Key('join.code'),
              controller: _code,
              focusNode: _codeFocus,
              autofocus: widget.initialCode == null,
              keyboardType: TextInputType.visiblePassword,
              textCapitalization: TextCapitalization.characters,
              autocorrect: false,
              enableSuggestions: false,
              inputFormatters: RoomCode.formatters,
              style: AppTextStyles.codeInput,
              decoration: InputDecoration(
                hintText: RoomCode.example,
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
              focusNode: _nameFocus,
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
              key: _submitArea,
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
