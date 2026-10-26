import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:quiz_night_client/quiz_night_client.dart';

import 'package:go_router/go_router.dart';

import '../../app/app_paths.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/theme/app_text_styles.dart';
import '../../widgets/brand/chalk_background.dart';
import '../../widgets/qn/loaders.dart';
import '../landing/widgets/landing_header.dart';
import '../landing/widgets/landing_parts.dart';
import 'host_setup_cubit.dart';
import 'question_pack_cubit.dart';

/// Host "New game", laid out like the website: a header bar, the form in
/// the page column, and the summary with CREATE ROOM beside it on wide
/// screens (it stays put while the form scrolls) or in a bar along the
/// bottom on phones.
class HostSetupScreen extends StatelessWidget {
  const HostSetupScreen({super.key});

  /// From this width the summary sits beside the form.
  static const wideLayout = 960.0;
  static const sidebarWidth = 360.0;
  static const _sidebarGap = 40.0;
  static const _pageTop = 40.0;

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
              final create = LandingButton(
                buttonKey: const Key('create.submit'),
                label: state.submitting ? 'Creating…' : 'Create room',
                onPressed: state.submitting || packBusy
                    ? null
                    : () => cubit.create(pack: readyPack),
              );
              final summary = [
                for (final item in cubit.summary) _SummaryRow(item: item),
                _SummaryRow(item: packCubit.summaryItem),
              ];
              return Scaffold(
                backgroundColor: AppColors.board,
                body: ChalkBackground(
                  spacing: 7,
                  child: Column(
                    children: [
                      const SafeArea(bottom: false, child: _SetupHeader()),
                      Expanded(
                        child: LayoutBuilder(
                          builder: (context, box) => box.maxWidth >= wideLayout
                              ? _wide(context, state, summary, create)
                              : _narrow(context, state, summary, create),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
    );
  }

  /// The form scrolls as the page; the summary stays in view beside it.
  Widget _wide(
    BuildContext context,
    HostSetupState state,
    List<Widget> summary,
    Widget create,
  ) {
    final gutter = AppWebLayout.gutter(MediaQuery.sizeOf(context).width);
    return Stack(
      children: [
        SingleChildScrollView(
          key: const Key('setup.scroll'),
          child: LandingSection(
            top: _pageTop,
            bottom: 80,
            child: Padding(
              padding: const EdgeInsets.only(right: sidebarWidth + _sidebarGap),
              child: _Form(state: state),
            ),
          ),
        ),
        // Lets taps and scrolls through everywhere but the panel itself.
        Positioned.fill(
          child: Align(
            alignment: Alignment.topCenter,
            child: ConstrainedBox(
              constraints: const BoxConstraints(
                maxWidth: AppWebLayout.maxWidth,
              ),
              child: Padding(
                padding: EdgeInsets.fromLTRB(gutter, _pageTop, gutter, 24),
                child: Align(
                  alignment: Alignment.topRight,
                  child: SizedBox(
                    width: sidebarWidth,
                    child: LandingCard(
                      padding: const EdgeInsets.all(28),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          const _Label('Summary'),
                          const SizedBox(height: 20),
                          Flexible(
                            child: SingleChildScrollView(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: summary,
                              ),
                            ),
                          ),
                          const SizedBox(height: 8),
                          create,
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  /// One column, the summary after the form, and CREATE ROOM always in
  /// reach along the bottom.
  Widget _narrow(
    BuildContext context,
    HostSetupState state,
    List<Widget> summary,
    Widget create,
  ) {
    final gutter = AppWebLayout.gutter(MediaQuery.sizeOf(context).width);
    return Column(
      children: [
        Expanded(
          child: SingleChildScrollView(
            key: const Key('setup.scroll'),
            child: LandingSection(
              top: 28,
              bottom: 40,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  _Form(state: state),
                  const SizedBox(height: 32),
                  LandingCard(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const _Label('Summary'),
                        const SizedBox(height: 20),
                        ...summary,
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
        DecoratedBox(
          decoration: const BoxDecoration(
            color: AppColors.headerGlass,
            border: Border(top: BorderSide(color: AppColors.line)),
          ),
          child: SafeArea(
            top: false,
            child: Padding(
              padding: EdgeInsets.fromLTRB(gutter, 12, gutter, 12),
              child: SizedBox(width: double.infinity, child: create),
            ),
          ),
        ),
      ],
    );
  }
}

/// The website's header bar: brand home, the page name, and Back.
class _SetupHeader extends StatelessWidget {
  const _SetupHeader();

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.sizeOf(context).width;
    final gutter = AppWebLayout.gutter(width);
    return DecoratedBox(
      decoration: const BoxDecoration(
        color: AppColors.headerGlass,
        border: Border(bottom: BorderSide(color: AppColors.line)),
      ),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: AppWebLayout.maxWidth),
          child: SizedBox(
            height: AppWebLayout.headerHeight,
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: gutter),
              child: Row(
                children: [
                  Flexible(
                    child: FittedBox(
                      fit: BoxFit.scaleDown,
                      alignment: Alignment.centerLeft,
                      child: SiteBrand(
                        onTap: () => context.go(AppPaths.home),
                      ),
                    ),
                  ),
                  const Spacer(),
                  if (width >= AppBreakpoints.medium) ...[
                    Text(
                      'Host setup',
                      style: AppWebText.navLink.copyWith(
                        color: AppColors.chalkSoft,
                      ),
                    ),
                    const SizedBox(width: 16),
                  ],
                  LandingButton(
                    label: 'Back',
                    kind: LandingButtonKind.outline,
                    height: 44,
                    onPressed: () => context.go(AppPaths.home),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// The settings: rule, the game's numbers, and the questions.
class _Form extends StatelessWidget {
  final HostSetupState state;

  const _Form({required this.state});

  @override
  Widget build(BuildContext context) {
    final cubit = context.read<HostSetupCubit>();
    final width = MediaQuery.sizeOf(context).width;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('HOST SETUP', style: AppWebText.eyebrow),
        const SizedBox(height: 12),
        Text('NEW GAME', style: AppWebText.section(width)),
        const SizedBox(height: 12),
        Text(
          'Choose how the cut works and what to ask, then create the room. '
          'Players join with the code on your screen.',
          style: AppWebText.bodyLarge,
        ),
        const SizedBox(height: 32),
        _Section(
          title: 'Elimination rule',
          child: LayoutBuilder(
            builder: (context, box) {
              final row = box.maxWidth >= 560;
              final cards = [
                for (final (rule, name, desc) in HostSetupScreen.rules)
                  _RuleCard(
                    key: Key('rule.${rule.name}'),
                    name: name,
                    description: desc,
                    selected: state.rule == rule,
                    onTap: () => cubit.setRule(rule),
                  ),
              ];
              if (!row) {
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    for (final card in cards) ...[
                      if (card != cards.first) const SizedBox(height: 12),
                      card,
                    ],
                  ],
                );
              }
              return IntrinsicHeight(
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    for (final card in cards) ...[
                      if (card != cards.first) const SizedBox(width: 12),
                      Expanded(child: card),
                    ],
                  ],
                ),
              );
            },
          ),
        ),
        const SizedBox(height: 20),
        _Section(
          title: 'The game',
          child: Wrap(
            spacing: 40,
            runSpacing: 24,
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
        ),
        const SizedBox(height: 20),
        _Section(
          title: 'Questions',
          subtitle:
              'Type a topic and AI writes the questions for this game, or '
              'leave it empty for the built-in general knowledge.',
          child: _TopicSection(config: state.toConfig()),
        ),
      ],
    );
  }
}

/// A titled card grouping related settings.
class _Section extends StatelessWidget {
  final String title;
  final String? subtitle;
  final Widget child;

  const _Section({required this.title, required this.child, this.subtitle});

  @override
  Widget build(BuildContext context) => LandingCard(
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(title, style: AppWebText.itemTitle),
        if (subtitle != null) ...[
          const SizedBox(height: 6),
          Text(subtitle!, style: AppWebText.body),
        ],
        const SizedBox(height: 20),
        child,
      ],
    ),
  );
}

/// A picked setting in gold, with what it means underneath.
class _SummaryRow extends StatelessWidget {
  final SummaryItem item;

  const _SummaryRow({required this.item});

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.only(bottom: 18),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          item.title,
          style: AppWebText.stepTitle.copyWith(
            fontSize: 17,
            color: AppColors.gold,
          ),
        ),
        const SizedBox(height: 4),
        Text(item.detail, style: AppWebText.body),
      ],
    ),
  );
}

class _Label extends StatelessWidget {
  final String text;

  const _Label(this.text);

  @override
  Widget build(BuildContext context) => Text(
    text.toUpperCase(),
    style: AppWebText.cardEyebrow.copyWith(color: AppColors.chalkSoft),
  );
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
  Widget build(BuildContext context) => Semantics(
    selected: selected,
    button: true,
    child: Material(
      color: selected ? AppColors.green : AppColors.surfaceHigh,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppRadii.lg),
        side: BorderSide(
          color: selected ? AppColors.gold : AppColors.line,
          width: selected ? AppBorders.focus : AppBorders.hairline,
        ),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppRadii.lg),
        child: Padding(
          padding: const EdgeInsets.all(18),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(name, style: AppTextStyles.headline.copyWith(fontSize: 22)),
              const SizedBox(height: 6),
              Text(description, style: AppWebText.body),
            ],
          ),
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
      const SizedBox(height: 10),
      Wrap(
        spacing: 8,
        runSpacing: 8,
        children: [
          for (final v in values)
            _Choice(
              key: Key('pick.$label.$v'),
              text: '$v',
              selected: v == selected,
              onTap: () => onPick(v),
            ),
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
      const SizedBox(height: 10),
      Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _Choice(
            key: Key('pick.$label.on'),
            text: 'On',
            width: 72,
            selected: value,
            onTap: () => onChanged(true),
          ),
          const SizedBox(width: 8),
          _Choice(
            key: Key('pick.$label.off'),
            text: 'Off',
            width: 72,
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
    this.width = 56,
  });

  @override
  Widget build(BuildContext context) => Semantics(
    selected: selected,
    button: true,
    child: Material(
      color: selected ? AppColors.chalk : Colors.transparent,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppRadii.md),
        side: BorderSide(
          color: selected ? AppColors.chalk : AppColors.lineStrong,
          width: AppBorders.thin,
        ),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppRadii.md),
        child: SizedBox(
          width: width,
          height: AppSpacing.secondaryButtonHeight,
          child: Center(
            child: Text(
              text,
              style: AppTextStyles.headline.copyWith(
                fontSize: 20,
                color: selected ? AppColors.board : AppColors.chalk,
              ),
            ),
          ),
        ),
      ),
    ),
  );
}

/// Topic box, difficulty, how many, "Write questions", and the preview of
/// what the AI wrote. Stateful only to own the text controller.
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
          padding: EdgeInsets.symmetric(vertical: 12),
          child: PulsingDots(),
        );
      case PackStatus.unavailable:
        return Text(
          "AI questions aren't set up on this server, so the game uses the "
          'built-in questions.',
          style: AppWebText.body.copyWith(color: AppColors.muted),
        );
      case PackStatus.idle || PackStatus.generating || PackStatus.ready:
        break;
    }
    final generating = state.status == PackStatus.generating;
    final border = OutlineInputBorder(
      borderRadius: BorderRadius.circular(AppRadii.md),
      borderSide: const BorderSide(
        color: AppColors.lineStrong,
        width: AppBorders.thin,
      ),
    );
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
          style: AppTextStyles.input,
          decoration: InputDecoration(
            labelText: 'Topic',
            hintText: 'e.g. Nollywood, Premier League, Bible stories',
            hintStyle: AppTextStyles.input.copyWith(color: AppColors.faint),
            counterText: '',
            filled: true,
            fillColor: AppColors.boardDeep,
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 16,
            ),
            border: border,
            enabledBorder: border,
            disabledBorder: border,
            focusedBorder: border.copyWith(
              borderSide: const BorderSide(
                color: AppColors.gold,
                width: AppBorders.thin,
              ),
            ),
          ),
        ),
        const SizedBox(height: 20),
        Wrap(
          spacing: 40,
          runSpacing: 20,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const _Label('Difficulty'),
                const SizedBox(height: 10),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    for (final (d, label) in _difficulties)
                      _Choice(
                        key: Key('topic.difficulty.${d.name}'),
                        text: label,
                        width: 92,
                        selected: state.difficulty == d,
                        onTap: generating
                            ? () {}
                            : () => cubit.setDifficulty(d),
                      ),
                  ],
                ),
              ],
            ),
            _CountSlider(
              count: state.count,
              onChanged: generating ? null : cubit.setCount,
            ),
          ],
        ),
        const SizedBox(height: 20),
        Align(
          alignment: Alignment.centerLeft,
          child: LandingButton(
            buttonKey: const Key('topic.generate'),
            kind: LandingButtonKind.chalk,
            height: 48,
            label: generating
                ? 'Writing…'
                : state.pack == null
                ? 'Write ${state.count} questions'
                : 'Write new ones',
            onPressed: state.canGenerate
                ? () => cubit.generate(widget.config)
                : null,
          ),
        ),
        if (generating) ...[
          const SizedBox(height: 20),
          const LoadBar(width: 200),
          const SizedBox(height: 10),
          Text(
            'Writing your questions… usually 10–20 seconds.',
            style: AppWebText.body,
          ),
        ],
        if (state.error case final error?) ...[
          const SizedBox(height: 16),
          Text(
            error,
            key: const Key('topic.error'),
            style: AppWebText.body.copyWith(color: AppColors.errorText),
          ),
        ],
        if (state.pack case final pack? when !generating) ...[
          const SizedBox(height: 24),
          _PackPreview(pack: pack, config: widget.config),
        ],
      ],
    );
  }
}

/// How many questions to write: 10 to 40, in fives.
class _CountSlider extends StatelessWidget {
  final int count;
  final ValueChanged<int>? onChanged;

  const _CountSlider({required this.count, required this.onChanged});

  @override
  Widget build(BuildContext context) => ConstrainedBox(
    constraints: const BoxConstraints(maxWidth: 340),
    child: Column(
      // Stretch, so the count sits at the right end of the header.
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Wrap(
          alignment: WrapAlignment.spaceBetween,
          spacing: 12,
          children: [
            const _Label('How many'),
            Text(
              '$count questions',
              key: const Key('topic.count.value'),
              style: AppWebText.stepTitle.copyWith(fontSize: 16),
            ),
          ],
        ),
        SliderTheme(
          data: SliderTheme.of(context).copyWith(
            activeTrackColor: AppColors.gold,
            inactiveTrackColor: AppColors.lineStrong,
            thumbColor: AppColors.gold,
            overlayColor: AppColors.gold.withValues(alpha: AppOpacity.pressed),
            activeTickMarkColor: AppColors.goldInk,
            inactiveTickMarkColor: AppColors.muted,
            valueIndicatorColor: AppColors.gold,
            valueIndicatorTextStyle: AppWebText.button.copyWith(
              color: AppColors.goldInk,
              fontSize: 14,
            ),
          ),
          child: Slider(
            key: const Key('topic.count'),
            value: count.toDouble(),
            min: PackLimits.minCount.toDouble(),
            max: PackLimits.maxCount.toDouble(),
            divisions:
                (PackLimits.maxCount - PackLimits.minCount) ~/ PackLimits.step,
            label: '$count',
            semanticFormatterCallback: (v) => '${v.round()} questions',
            onChanged: onChanged == null ? null : (v) => onChanged!(v.round()),
          ),
        ),
        Text(
          'Rounds and the buzzer final together.',
          style: AppWebText.small,
        ),
      ],
    ),
  );
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
        _Label(title),
        const SizedBox(height: 8),
        for (final (i, q) in questions.indexed)
          Container(
            padding: const EdgeInsets.symmetric(vertical: 12),
            decoration: BoxDecoration(
              border: i == 0
                  ? null
                  : const Border(top: BorderSide(color: AppColors.line)),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        q.text,
                        style: AppWebText.bodyLarge.copyWith(
                          color: AppColors.chalk,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '✓ ${q.options[q.correctIndex]}',
                        style: AppWebText.body.copyWith(color: AppColors.mint),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                IconButton(
                  key: Key('pack.remove.${q.id}'),
                  tooltip: 'Remove this question',
                  onPressed: () => cubit.remove(q.id, config),
                  color: AppColors.muted,
                  icon: const Text('✕', style: TextStyle(fontSize: 18)),
                ),
              ],
            ),
          ),
      ],
    );
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.boardDeep,
        borderRadius: BorderRadius.circular(AppRadii.lg),
        border: Border.all(color: AppColors.line),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Wrap(
            alignment: WrapAlignment.spaceBetween,
            crossAxisAlignment: WrapCrossAlignment.center,
            spacing: 12,
            children: [
              Text(
                'Preview · ${rounds.length} round + ${finals.length} final',
                key: const Key('pack.count'),
                style: AppWebText.itemTitle,
              ),
              LandingLink(
                label: 'Use built-in instead',
                onTap: cubit.discard,
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            'Check them, and remove any you are unsure of. If they run out, '
            'the built-in questions fill in.',
            style: AppWebText.body,
          ),
          const SizedBox(height: 16),
          group('Rounds', rounds),
          const SizedBox(height: 16),
          group('Buzzer final', finals),
        ],
      ),
    );
  }
}
