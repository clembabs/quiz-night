import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:quiz_night_client/quiz_night_client.dart';

import 'package:go_router/go_router.dart';

import '../../app/app_paths.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../widgets/qn/host_stage.dart';
import 'host_setup_cubit.dart';

/// Host "New game" on the projector canvas: rule cards, number pickers, the
/// AI topic (coming soon), and a summary with CREATE ROOM.
class HostSetupScreen extends StatelessWidget {
  const HostSetupScreen({super.key});

  static const rules = [
    (
      EliminationRule.bottomPercent,
      'Bottom 30%',
      'Lowest 30% leave each round',
    ),
    (
      EliminationRule.autoScaled,
      'Auto-scaled',
      'Cut size adapts to reach the finalists',
    ),
    (
      EliminationRule.suddenDeath,
      'Sudden death',
      'A wrong answer sends you home',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final cubit = context.read<HostSetupCubit>();
    return BlocConsumer<HostSetupCubit, HostSetupState>(
      listenWhen: (a, b) =>
          (b.seat != null && a.seat != b.seat) ||
          (b.error != null && a.error != b.error),
      listener: (context, state) {
        if (state.seat != null) {
          context.go(
            AppPaths.roomFor(state.seat!.code),
            extra: state.seat,
          );
        } else if (state.error != null) {
          ScaffoldMessenger.of(context)
            ..hideCurrentSnackBar()
            ..showSnackBar(SnackBar(content: Text(state.error!)));
        }
      },
      builder: (context, state) => Scaffold(
        body: HostStage(
          topLabel: 'Host setup',
          actions: [
            HostTextButton(
              label: 'Back',
              onPressed: () => context.go(AppPaths.home),
            ),
          ],
          child: Builder(
            builder: (context) {
              final portrait = HostLayout.isPortrait(context);
              final form = Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'NEW GAME',
                    style: AppTextStyles.displayXl.copyWith(fontSize: 96),
                  ),
                  const SizedBox(height: 28),
                  const _Label('Elimination rule'),
                  const SizedBox(height: 16),
                  Flex(
                    direction: portrait ? Axis.vertical : Axis.horizontal,
                    crossAxisAlignment: portrait
                        ? CrossAxisAlignment.stretch
                        : CrossAxisAlignment.start,
                    children: [
                      for (final (rule, name, desc) in rules) ...[
                        if (rule != rules.first.$1)
                          const SizedBox(width: 16, height: 16),
                        _flexible(
                          portrait,
                          _RuleCard(
                            key: Key('rule.${rule.name}'),
                            name: name,
                            description: desc,
                            selected: state.rule == rule,
                            onTap: () => cubit.setRule(rule),
                          ),
                        ),
                      ],
                    ],
                  ),
                  const SizedBox(height: 28),
                  Wrap(
                    spacing: 48,
                    runSpacing: 32,
                    children: [
                      _Picker(
                        label: 'Questions per round',
                        values: HostSetupLimits.questionsChoices,
                        selected: state.questionsPerRound,
                        onPick: cubit.setQuestionsPerRound,
                      ),
                      _Picker(
                        label: 'Finalists',
                        values: HostSetupLimits.finalistChoices,
                        selected: state.finalists,
                        onPick: cubit.setFinalists,
                      ),
                      _Picker(
                        label: 'Seconds',
                        values: HostSetupLimits.secondsChoices,
                        selected: state.secondsPerQuestion,
                        onPick: cubit.setSecondsPerQuestion,
                      ),
                      _Toggle(
                        label: 'Question on phones',
                        value: state.showQuestionOnPhones,
                        onChanged: cubit.setShowQuestionOnPhones,
                      ),
                      if (state.rule == EliminationRule.autoScaled)
                        _Picker(
                          label: 'Rounds before final',
                          values: const [2, 3, 4],
                          selected: state.roundsBeforeFinal,
                          onPick: cubit.setRoundsBeforeFinal,
                        ),
                    ],
                  ),
                  const SizedBox(height: 28),
                  const _Label('Topic · questions generated by AI'),
                  const SizedBox(height: 16),
                  Container(
                    constraints: const BoxConstraints(minHeight: 96),
                    alignment: Alignment.centerLeft,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 28,
                      vertical: 16,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.boardDeep,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: AppColors.chalk.withValues(alpha: 0.3),
                        width: 3,
                      ),
                    ),
                    child: Text(
                      'Coming soon · built-in question bank for now',
                      style: AppProjectorText.body.copyWith(
                        color: AppColors.faint,
                      ),
                    ),
                  ),
                ],
              );
              final items = Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  for (final item in cubit.summary) _SummaryRow(item: item),
                ],
              );
              final summary = Container(
                padding: EdgeInsets.all(portrait ? 36 : 48),
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(28),
                ),
                child: Column(
                  mainAxisSize: portrait ? MainAxisSize.min : MainAxisSize.max,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const _Label('Summary'),
                    const SizedBox(height: 20),
                    if (portrait)
                      items
                    else
                      Expanded(child: SingleChildScrollView(child: items)),
                    const SizedBox(height: 24),
                    HostButton(
                      buttonKey: const Key('create.submit'),
                      label: state.submitting ? 'Creating…' : 'Create room',
                      onPressed: state.submitting ? null : cubit.create,
                    ),
                  ],
                ),
              );
              // A phone scrolls one column: the form, then the summary.
              if (portrait) {
                return SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [form, const SizedBox(height: 40), summary],
                  ),
                );
              }
              return HostSplit(
                firstFlex: 14,
                secondFlex: 10,
                first: SingleChildScrollView(child: form),
                second: summary,
              );
            },
          ),
        ),
      ),
    );
  }

  /// Rule cards share the row on the projector and stack on a phone.
  static Widget _flexible(bool portrait, Widget child) =>
      portrait ? child : Expanded(child: child);
}

/// A picked setting in gold, with what it means underneath.
class _SummaryRow extends StatelessWidget {
  final SummaryItem item;

  const _SummaryRow({required this.item});

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.only(bottom: 22),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          item.title,
          style: AppProjectorText.body.copyWith(
            fontSize: 30,
            fontWeight: FontWeight.w800,
            color: AppColors.gold,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          item.detail,
          style: AppProjectorText.bodySoft.copyWith(fontSize: 23, height: 1.35),
        ),
      ],
    ),
  );
}

class _Label extends StatelessWidget {
  final String text;

  const _Label(this.text);

  @override
  Widget build(BuildContext context) =>
      Text(text.toUpperCase(), style: AppProjectorText.label);
}

class _RuleCard extends StatelessWidget {
  final String name;
  final String description;
  final bool selected;
  final VoidCallback onTap;

  const _RuleCard({
    super.key,
    required this.name,
    required this.description,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) => Material(
    color: selected ? AppColors.green : AppColors.surface,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(20),
      side: BorderSide(
        color: selected ? AppColors.gold : Colors.transparent,
        width: 4,
      ),
    ),
    child: InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(name, style: AppTextStyles.headline.copyWith(fontSize: 36)),
            const SizedBox(height: 8),
            Text(
              description,
              style: AppProjectorText.bodySoft.copyWith(fontSize: 24),
            ),
          ],
        ),
      ),
    ),
  );
}

class _Picker extends StatelessWidget {
  final String label;
  final List<int> values;
  final int selected;
  final ValueChanged<int> onPick;

  const _Picker({
    required this.label,
    required this.values,
    required this.selected,
    required this.onPick,
  });

  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      _Label(label),
      const SizedBox(height: 16),
      Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          for (final v in values) ...[
            if (v != values.first) const SizedBox(width: 10),
            _Choice(
              key: Key('pick.$label.$v'),
              text: '$v',
              selected: v == selected,
              onTap: () => onPick(v),
            ),
          ],
        ],
      ),
    ],
  );
}

class _Toggle extends StatelessWidget {
  final String label;
  final bool value;
  final ValueChanged<bool> onChanged;

  const _Toggle({
    required this.label,
    required this.value,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      _Label(label),
      const SizedBox(height: 16),
      Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _Choice(
            key: Key('pick.$label.on'),
            text: 'On',
            width: 120,
            selected: value,
            onTap: () => onChanged(true),
          ),
          const SizedBox(width: 10),
          _Choice(
            key: Key('pick.$label.off'),
            text: 'Off',
            width: 120,
            selected: !value,
            onTap: () => onChanged(false),
          ),
        ],
      ),
    ],
  );
}

class _Choice extends StatelessWidget {
  final String text;
  final bool selected;
  final VoidCallback onTap;
  final double width;

  const _Choice({
    super.key,
    required this.text,
    required this.selected,
    required this.onTap,
    this.width = 96,
  });

  @override
  Widget build(BuildContext context) => Material(
    color: selected ? AppColors.chalk : Colors.transparent,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(16),
      side: BorderSide(
        color: selected
            ? AppColors.chalk
            : AppColors.chalk.withValues(alpha: 0.3),
        width: 3,
      ),
    ),
    child: InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: SizedBox(
        width: width,
        height: 80,
        child: Center(
          child: Text(
            text,
            style: AppTextStyles.headline.copyWith(
              fontSize: 40,
              color: selected ? AppColors.board : AppColors.chalk,
            ),
          ),
        ),
      ),
    ),
  );
}
