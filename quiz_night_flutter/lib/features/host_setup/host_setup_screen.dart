import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:quiz_night_client/quiz_night_client.dart';

import '../../app/app_routes.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/theme/app_text_styles.dart';
import '../../widgets/common.dart';
import 'host_setup_cubit.dart';

class HostSetupScreen extends StatelessWidget {
  const HostSetupScreen({super.key});

  static String ruleHelp(HostSetupState s) => switch (s.rule) {
    EliminationRule.bottomPercent =>
      'The lowest 30% of players are cut after each round.',
    EliminationRule.autoScaled =>
      'Cuts are sized so any room reaches the final in '
          '${s.roundsBeforeFinal} rounds.',
    EliminationRule.suddenDeath =>
      'A wrong or missing answer knocks you out immediately.',
  };

  @override
  Widget build(BuildContext context) {
    final cubit = context.read<HostSetupCubit>();
    return BlocConsumer<HostSetupCubit, HostSetupState>(
      listenWhen: (a, b) => b.seat != null && a.seat != b.seat,
      listener: (context, state) =>
          Navigator.of(context).pushReplacement(AppRoutes.room(state.seat!)),
      builder: (context, state) => Scaffold(
        appBar: AppBar(title: const Text('Host a game')),
        body: SafeArea(
          child: CenteredContent(
            maxWidth: AppSpacing.formMaxWidth,
            child: ListView(
              padding: AppSpacing.screenPadding,
              children: [
                const Padding(
                  padding: EdgeInsets.only(bottom: AppSpacing.sm),
                  child: Text('Elimination rule', style: AppTextStyles.label),
                ),
                SegmentedButton<EliminationRule>(
                  segments: const [
                    ButtonSegment(
                      value: EliminationRule.bottomPercent,
                      label: Text('Bottom 30%'),
                    ),
                    ButtonSegment(
                      value: EliminationRule.autoScaled,
                      label: Text('Auto-scaled'),
                    ),
                    ButtonSegment(
                      value: EliminationRule.suddenDeath,
                      label: Text('Sudden death'),
                    ),
                  ],
                  selected: {state.rule},
                  onSelectionChanged: (s) => cubit.setRule(s.first),
                ),
                const SizedBox(height: AppSpacing.sm),
                Text(ruleHelp(state), style: AppTextStyles.caption),
                const SizedBox(height: AppSpacing.xl),
                NumberStepper(
                  label: 'Questions per round',
                  value: state.questionsPerRound,
                  min: HostSetupLimits.questionsPerRound.min,
                  max: HostSetupLimits.questionsPerRound.max,
                  onChanged: cubit.setQuestionsPerRound,
                ),
                NumberStepper(
                  label: 'Finalists',
                  value: state.finalists,
                  min: HostSetupLimits.finalists.min,
                  max: HostSetupLimits.finalists.max,
                  onChanged: cubit.setFinalists,
                ),
                if (state.rule == EliminationRule.autoScaled)
                  NumberStepper(
                    label: 'Rounds before the final',
                    value: state.roundsBeforeFinal,
                    min: HostSetupLimits.rounds.min,
                    max: HostSetupLimits.rounds.max,
                    onChanged: cubit.setRoundsBeforeFinal,
                  ),
                NumberStepper(
                  label: 'Seconds per question',
                  value: state.secondsPerQuestion,
                  min: HostSetupLimits.seconds.min,
                  max: HostSetupLimits.seconds.max,
                  step: HostSetupLimits.seconds.step,
                  onChanged: cubit.setSecondsPerQuestion,
                ),
                ErrorText(state.error),
                const SizedBox(height: AppSpacing.xl),
                LoadingButton(
                  label: 'Create room',
                  loading: state.submitting,
                  onPressed: cubit.create,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
