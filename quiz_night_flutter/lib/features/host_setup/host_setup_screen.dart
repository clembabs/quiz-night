import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:quiz_night_client/quiz_night_client.dart';

import 'package:go_router/go_router.dart';

import '../../app/app_paths.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../widgets/qn/host_stage.dart';
import '../../widgets/qn/loaders.dart';
import 'host_setup_cubit.dart';
import 'question_pack_cubit.dart';

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
          context.go(AppPaths.roomFor(state.seat!.code));
        } else if (state.error != null) {
          ScaffoldMessenger.of(context)
            ..hideCurrentSnackBar()
            ..showSnackBar(SnackBar(content: Text(state.error!)));
        }
      },
      builder: (context, state) =>
          BlocBuilder<QuestionPackCubit, QuestionPackState>(
            builder: (context, pack) {
              final packCubit = context.read<QuestionPackCubit>();
              final readyPack = pack.status == PackStatus.ready
                  ? pack.pack
                  : null;
              final packBusy = pack.status == PackStatus.generating;
              return Scaffold(
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
                            style: AppTextStyles.displayXl.copyWith(
                              fontSize: 96,
                            ),
                          ),
                          const SizedBox(height: 28),
                          const _Label('Elimination rule'),
                          const SizedBox(height: 16),
                          Flex(
                            direction: portrait
                                ? Axis.vertical
                                : Axis.horizontal,
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
                          const _Label('Topic · questions written by AI'),
                          const SizedBox(height: 16),
                          _TopicSection(config: state.toConfig()),
                        ],
                      );
                      final items = Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          for (final item in cubit.summary)
                            _SummaryRow(item: item),
                          _SummaryRow(item: packCubit.summaryItem),
                        ],
                      );
                      final summary = Container(
                        padding: EdgeInsets.all(portrait ? 36 : 48),
                        decoration: BoxDecoration(
                          color: AppColors.surface,
                          borderRadius: BorderRadius.circular(28),
                        ),
                        child: Column(
                          mainAxisSize: portrait
                              ? MainAxisSize.min
                              : MainAxisSize.max,
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            const _Label('Summary'),
                            const SizedBox(height: 20),
                            if (portrait)
                              items
                            else
                              Expanded(
                                child: SingleChildScrollView(child: items),
                              ),
                            const SizedBox(height: 24),
                            HostButton(
                              buttonKey: const Key('create.submit'),
                              label: state.submitting
                                  ? 'Creating…'
                                  : 'Create room',
                              onPressed: state.submitting || packBusy
                                  ? null
                                  : () => cubit.create(pack: readyPack),
                            ),
                          ],
                        ),
                      );
                      // A phone scrolls one column: the form, then the summary.
                      if (portrait) {
                        return SingleChildScrollView(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              form,
                              const SizedBox(height: 40),
                              summary,
                            ],
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
              );
            },
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

/// Topic box, difficulty, "Write questions", and the preview of what the AI
/// wrote. Stateful only to own the text controller.
class _TopicSection extends StatefulWidget {
  /// The game as currently set up, so the pack is sized for it.
  final RoomConfig config;

  const _TopicSection({required this.config});

  @override
  State<_TopicSection> createState() => _TopicSectionState();
}

class _TopicSectionState extends State<_TopicSection> {
  late final TextEditingController _topic;

  @override
  void initState() {
    super.initState();
    // Here, not lazily: when AI is unavailable the field is never built,
    // and a first use in dispose() would read a torn-down context.
    _topic = TextEditingController(
      text: context.read<QuestionPackCubit>().state.topic,
    );
  }

  @override
  void dispose() {
    _topic.dispose();
    super.dispose();
  }

  static const _difficulties = [
    (QuestionDifficulty.easy, 'Easy'),
    (QuestionDifficulty.mixed, 'Mixed'),
    (QuestionDifficulty.hard, 'Hard'),
  ];

  @override
  Widget build(BuildContext context) {
    final cubit = context.read<QuestionPackCubit>();
    final state = context.watch<QuestionPackCubit>().state;
    switch (state.status) {
      case PackStatus.checking:
        return const Padding(
          padding: EdgeInsets.symmetric(vertical: 24),
          child: PulsingDots(size: 12),
        );
      case PackStatus.unavailable:
        return Text(
          "AI questions aren't set up on this server, so the game uses the "
          'built-in questions.',
          style: AppProjectorText.body.copyWith(color: AppColors.faint),
        );
      case PackStatus.idle || PackStatus.generating || PackStatus.ready:
        break;
    }
    final generating = state.status == PackStatus.generating;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        TextField(
          key: const Key('topic.field'),
          controller: _topic,
          enabled: !generating,
          maxLength: 100,
          onChanged: cubit.setTopic,
          onSubmitted: (_) => cubit.generate(widget.config),
          textInputAction: TextInputAction.go,
          style: AppProjectorText.body,
          decoration: InputDecoration(
            hintText: 'e.g. Nollywood, Premier League, Bible stories',
            hintStyle: AppProjectorText.body.copyWith(color: AppColors.faint),
            counterText: '',
            filled: true,
            fillColor: AppColors.boardDeep,
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 28,
              vertical: 24,
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: BorderSide(
                color: AppColors.chalk.withValues(alpha: 0.3),
                width: 3,
              ),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: BorderSide(
                color: AppColors.chalk.withValues(alpha: 0.3),
                width: 3,
              ),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: const BorderSide(color: AppColors.gold, width: 3),
            ),
          ),
        ),
        const SizedBox(height: 20),
        Wrap(
          spacing: 10,
          runSpacing: 16,
          crossAxisAlignment: WrapCrossAlignment.center,
          children: [
            for (final (d, label) in _difficulties)
              _Choice(
                key: Key('topic.difficulty.${d.name}'),
                text: label,
                width: 170,
                selected: state.difficulty == d,
                onTap: generating ? () {} : () => cubit.setDifficulty(d),
              ),
            const SizedBox(width: 16),
            HostButton(
              buttonKey: const Key('topic.generate'),
              label: generating
                  ? 'Writing…'
                  : state.pack == null
                  ? 'Write questions'
                  : 'Write new ones',
              height: 80,
              onPressed: state.canGenerate
                  ? () => cubit.generate(widget.config)
                  : null,
            ),
          ],
        ),
        if (generating) ...[
          const SizedBox(height: 24),
          const LoadBar(),
          const SizedBox(height: 12),
          Text(
            'Writing your questions… usually 10–20 seconds.',
            style: AppProjectorText.bodySoft.copyWith(fontSize: 28),
          ),
        ],
        if (state.error case final error?) ...[
          const SizedBox(height: 20),
          Text(
            error,
            key: const Key('topic.error'),
            style: AppProjectorText.body.copyWith(
              color: AppColors.errorText,
              fontSize: 30,
            ),
          ),
        ],
        if (state.pack case final pack? when !generating) ...[
          const SizedBox(height: 28),
          _PackPreview(pack: pack, config: widget.config),
        ],
      ],
    );
  }
}

/// What the AI wrote, with answers, so the host can drop any they don't
/// like before the game.
class _PackPreview extends StatelessWidget {
  final PackDraft pack;
  final RoomConfig config;

  const _PackPreview({required this.pack, required this.config});

  @override
  Widget build(BuildContext context) {
    final cubit = context.read<QuestionPackCubit>();
    final rounds = pack.questions.where((q) => !q.isFinal).toList();
    final finals = pack.questions.where((q) => q.isFinal).toList();
    Widget group(String title, List<PackQuestionView> questions) => Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(title.toUpperCase(), style: AppProjectorText.label),
        const SizedBox(height: 12),
        for (final q in questions)
          Padding(
            padding: const EdgeInsets.only(bottom: 16),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        q.text,
                        style: AppProjectorText.body.copyWith(fontSize: 28),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '✓ ${q.options[q.correctIndex]}',
                        style: AppProjectorText.bodySoft.copyWith(
                          fontSize: 24,
                          color: AppColors.mint,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 12),
                Semantics(
                  button: true,
                  label: 'Remove this question',
                  excludeSemantics: true,
                  child: InkResponse(
                    key: Key('pack.remove.${q.id}'),
                    onTap: () => cubit.remove(q.id, config),
                    radius: 32,
                    child: Padding(
                      padding: const EdgeInsets.all(8),
                      child: Text(
                        '✕',
                        style: AppProjectorText.body.copyWith(
                          fontSize: 28,
                          color: AppColors.muted,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
      ],
    );
    return Container(
      padding: const EdgeInsets.all(28),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  'Preview · ${rounds.length} round + ${finals.length} final',
                  key: const Key('pack.count'),
                  style: AppProjectorText.title.copyWith(fontSize: 34),
                ),
              ),
              HostTextButton(
                label: 'Use built-in instead',
                onPressed: cubit.discard,
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            'Check them, and remove any you are unsure of. If they run out, '
            'the built-in questions fill in.',
            style: AppProjectorText.bodySoft.copyWith(fontSize: 24),
          ),
          const SizedBox(height: 20),
          // Long packs scroll inside the card.
          ConstrainedBox(
            constraints: const BoxConstraints(maxHeight: 520),
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  group('Rounds', rounds),
                  const SizedBox(height: 12),
                  group('Buzzer final', finals),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
