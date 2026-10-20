import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../app/app_routes.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/theme/app_text_styles.dart';
import '../../widgets/common.dart';
import 'join_cubit.dart';

class JoinScreen extends StatefulWidget {
  final String? initialCode;

  const JoinScreen({super.key, this.initialCode});

  @override
  State<JoinScreen> createState() => _JoinScreenState();
}

/// Stateful only to own the text controllers.
class _JoinScreenState extends State<JoinScreen> {
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
    return BlocConsumer<JoinCubit, JoinState>(
      listenWhen: (a, b) => b.seat != null && a.seat != b.seat,
      listener: (context, state) =>
          Navigator.of(context).pushReplacement(AppRoutes.room(state.seat!)),
      builder: (context, state) => Scaffold(
        appBar: AppBar(title: const Text('Join a game')),
        body: SafeArea(
          child: CenteredContent(
            child: ListView(
              shrinkWrap: true,
              padding: AppSpacing.screenPadding,
              children: [
                TextField(
                  key: const Key('join.code'),
                  controller: _code,
                  autofocus: widget.initialCode == null,
                  textCapitalization: TextCapitalization.characters,
                  inputFormatters: [
                    FilteringTextInputFormatter.allow(RegExp('[A-Za-z0-9]')),
                    LengthLimitingTextInputFormatter(6),
                  ],
                  textAlign: TextAlign.center,
                  style: AppTextStyles.codeInput,
                  decoration: const InputDecoration(labelText: 'Room code'),
                ),
                const SizedBox(height: AppSpacing.lg),
                TextField(
                  key: const Key('join.nickname'),
                  controller: _name,
                  autofocus: widget.initialCode != null,
                  maxLength: 20,
                  textInputAction: TextInputAction.go,
                  onSubmitted: (_) => _submit(),
                  style: AppTextStyles.input,
                  decoration: const InputDecoration(labelText: 'Your nickname'),
                ),
                ErrorText(state.error),
                const SizedBox(height: AppSpacing.lg),
                LoadingButton(
                  label: "Let's go",
                  loading: state.submitting,
                  onPressed: _submit,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
