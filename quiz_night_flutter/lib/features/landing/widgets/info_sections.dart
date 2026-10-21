import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../widgets/brand/chalk_background.dart';
import '../../../widgets/brand/crest.dart';
import '../../../widgets/layout/responsive_grid.dart';
import '../../../widgets/qn/player_chip.dart';
import '../landing_content.dart';
import '../landing_cubit.dart';
import 'landing_parts.dart';

/// "How a game runs": four numbered cards.
class StepsSection extends StatelessWidget {
  final VoidCallback onSeeWalkthrough;

  const StepsSection({super.key, required this.onSeeWalkthrough});

  @override
  Widget build(BuildContext context) => LandingSection(
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SectionHeading(title: 'How a game runs'),
        const SizedBox(height: 28),
        ResponsiveGrid(
          minItemWidth: 220,
          children: [
            for (var i = 0; i < LandingContent.steps.length; i++)
              LandingCard(
                radius: 16,
                padding: const EdgeInsets.all(22),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('${i + 1}', style: AppWebText.stepNumber),
                    const SizedBox(height: 10),
                    Text(
                      LandingContent.steps[i].title,
                      style: AppWebText.stepTitle,
                    ),
                    const SizedBox(height: 10),
                    Text(
                      LandingContent.steps[i].detail,
                      style: AppWebText.body,
                    ),
                  ],
                ),
              ),
          ],
        ),
        const SizedBox(height: 16),
        LandingLink(
          label: 'See the full walkthrough',
          onTap: onSeeWalkthrough,
          style: AppWebText.link.copyWith(fontSize: 16),
        ),
      ],
    ),
  );
}

/// "How it works": the player and host walkthroughs behind two tabs.
class WalkthroughSection extends StatelessWidget {
  const WalkthroughSection({super.key});

  @override
  Widget build(BuildContext context) {
    final tab = context.select((LandingCubit c) => c.state.tab);
    final steps = tab == WalkthroughTab.players
        ? LandingContent.forPlayers
        : LandingContent.forHosts;
    return LandingSection(
      maxWidth: 960,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SectionHeading(
            eyebrow: 'How it works',
            title: 'One screen at the front. A phone in every hand.',
          ),
          const SizedBox(height: 32),
          const FittedBox(
            fit: BoxFit.scaleDown,
            alignment: Alignment.centerLeft,
            child: _Tabs(),
          ),
          const SizedBox(height: 16),
          for (var i = 0; i < steps.length; i++)
            Container(
              padding: const EdgeInsets.symmetric(vertical: 22),
              decoration: const BoxDecoration(
                border: Border(top: BorderSide(color: AppColors.line)),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Crest(
                    width: 48,
                    child: Text(
                      '${i + 1}',
                      style: AppTextStyles.headline.copyWith(fontSize: 20),
                    ),
                  ),
                  const SizedBox(width: 18),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(steps[i].title, style: AppWebText.itemTitle),
                        const SizedBox(height: 6),
                        Text(
                          steps[i].detail,
                          style: AppWebText.bodyLarge.copyWith(fontSize: 16),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}

class _Tabs extends StatelessWidget {
  const _Tabs();

  @override
  Widget build(BuildContext context) {
    final cubit = context.read<LandingCubit>();
    final tab = context.select((LandingCubit c) => c.state.tab);
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          for (final (t, label) in const [
            (WalkthroughTab.players, 'For players'),
            (WalkthroughTab.hosts, 'For hosts'),
          ])
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 2),
              child: Semantics(
                selected: tab == t,
                child: TextButton(
                  key: Key('landing.tab.${t.name}'),
                  onPressed: () => cubit.pickTab(t),
                  style: TextButton.styleFrom(
                    minimumSize: const Size(0, 44),
                    padding: const EdgeInsets.symmetric(horizontal: 18),
                    backgroundColor: tab == t
                        ? AppColors.chalk
                        : Colors.transparent,
                    foregroundColor: tab == t
                        ? AppColors.board
                        : AppColors.chalkSoft,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(9),
                    ),
                  ),
                  child: Text(
                    label,
                    style: AppWebText.navLink.copyWith(
                      fontWeight: FontWeight.w700,
                      color: tab == t ? AppColors.board : AppColors.chalkSoft,
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

/// "Knocked out? Keep playing." on a green board, with sample chips.
class KnockedOutSection extends StatelessWidget {
  const KnockedOutSection({super.key});

  static const _chips = [
    ('Adéwálé', _Chip.finalist),
    ('Ngọzi', _Chip.active),
    ('Ɗanjuma', _Chip.active),
    ('Chiọma', _Chip.active),
    ('Ṣeun', _Chip.out),
    ('Ɓala', _Chip.out),
  ];

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.sizeOf(context).width;
    return LandingSection(
      bottom: 72,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(24),
        child: ChalkBackground(
          color: AppColors.green,
          spacing: 6,
          child: Padding(
            padding: EdgeInsets.all((width * 0.05).clamp(28, 56)),
            child: ResponsiveGrid(
              minItemWidth: 300,
              gap: 28,
              equalHeights: false,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      LandingContent.knockedOutTitle.toUpperCase(),
                      style: AppWebText.section(width).copyWith(
                        fontSize: (width * 0.036).clamp(28, 40),
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      LandingContent.knockedOut,
                      style: AppWebText.bodyLarge.copyWith(
                        color: AppColors.mintPale,
                      ),
                    ),
                  ],
                ),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    for (final (name, kind) in _chips)
                      PlayerChip(
                        nickname: name,
                        isFinalist: kind == _Chip.finalist,
                        isEliminated: kind == _Chip.out,
                      ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

enum _Chip { finalist, active, out }

/// "For teachers": the three cut rules, then the hosting guide cards.
class TeachersSection extends StatelessWidget {
  final VoidCallback onHost;
  final VoidCallback onReadFaq;

  const TeachersSection({
    super.key,
    required this.onHost,
    required this.onReadFaq,
  });

  @override
  Widget build(BuildContext context) => LandingSection(
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SectionHeading(eyebrow: 'For teachers', title: 'Hosting guide'),
        const SizedBox(height: 14),
        ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 760),
          child: Text(
            'Everything you need to run a game for a class, a house '
            'competition or a school quiz night.',
            style: AppWebText.bodyLarge.copyWith(fontSize: 18),
          ),
        ),
        const SizedBox(height: 32),
        Text('THREE WAYS TO CUT', style: AppWebText.footerHeading),
        const SizedBox(height: 12),
        ResponsiveGrid(
          minItemWidth: 240,
          children: [
            for (final r in LandingContent.rules)
              LandingCard(
                radius: 16,
                padding: const EdgeInsets.all(20),
                borderColor: AppColors.line,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(r.title, style: AppWebText.stepTitle),
                    const SizedBox(height: 6),
                    Text(r.detail, style: AppWebText.body),
                  ],
                ),
              ),
          ],
        ),
        const SizedBox(height: 16),
        ResponsiveGrid(
          // Two a row on desktop, so the four cards make a square.
          minItemWidth: 400,
          gap: 16,
          children: [
            for (final g in LandingContent.guide)
              LandingCard(
                radius: 18,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      g.kicker.toUpperCase(),
                      style: AppWebText.cardEyebrow.copyWith(
                        color: AppColors.mint,
                      ),
                    ),
                    const SizedBox(height: 14),
                    Text(
                      g.title.toUpperCase(),
                      style: AppWebText.cardTitle.copyWith(fontSize: 24),
                    ),
                    const SizedBox(height: 14),
                    for (final item in g.items)
                      Padding(
                        padding: const EdgeInsets.only(bottom: 10),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            SizedBox(
                              width: 30,
                              child: Text(
                                '✓',
                                style: AppWebText.body.copyWith(
                                  color: AppColors.gold,
                                  fontWeight: FontWeight.w800,
                                ),
                              ),
                            ),
                            Expanded(
                              child: Text(item, style: AppWebText.body),
                            ),
                          ],
                        ),
                      ),
                  ],
                ),
              ),
          ],
        ),
        const SizedBox(height: 28),
        Wrap(
          spacing: 12,
          runSpacing: 12,
          children: [
            LandingButton(label: 'Start hosting', onPressed: onHost),
            LandingButton(
              label: 'Read the FAQ',
              kind: LandingButtonKind.outline,
              onPressed: onReadFaq,
            ),
          ],
        ),
      ],
    ),
  );
}

/// Questions and answers, each opening in place.
class FaqSection extends StatelessWidget {
  const FaqSection({super.key});

  @override
  Widget build(BuildContext context) {
    final cubit = context.read<LandingCubit>();
    final open = context.select((LandingCubit c) => c.state.openFaq);
    return LandingSection(
      maxWidth: 820,
      bottom: 72,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const SectionHeading(title: 'Questions'),
          for (var g = 0; g < LandingContent.faq.length; g++) ...[
            const SizedBox(height: 28),
            Text(
              LandingContent.faq[g].name.toUpperCase(),
              style: AppWebText.cardEyebrow.copyWith(color: AppColors.gold),
            ),
            const SizedBox(height: 12),
            for (var i = 0; i < LandingContent.faq[g].items.length; i++)
              _FaqItem(
                faq: LandingContent.faq[g].items[i],
                open: open.contains('$g-$i'),
                onToggle: () => cubit.toggleFaq('$g-$i'),
              ),
          ],
        ],
      ),
    );
  }
}

class _FaqItem extends StatelessWidget {
  final Faq faq;
  final bool open;
  final VoidCallback onToggle;

  const _FaqItem({
    required this.faq,
    required this.open,
    required this.onToggle,
  });

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.only(bottom: 8),
    child: Material(
      color: AppColors.surface,
      borderRadius: BorderRadius.circular(14),
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Semantics(
            expanded: open,
            child: InkWell(
              onTap: onToggle,
              child: ConstrainedBox(
                constraints: const BoxConstraints(minHeight: 60),
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 16,
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: Text(
                          faq.question,
                          style: AppWebText.faqQuestion,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Text(
                        open ? '−' : '+',
                        style: AppWebText.faqQuestion.copyWith(
                          fontSize: 22,
                          color: AppColors.gold,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
          if (open)
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 18),
              child: Text(
                faq.answer,
                style: AppWebText.bodyLarge.copyWith(fontSize: 16),
              ),
            ),
        ],
      ),
    ),
  );
}

/// Brand, links to the sections, and the year.
class LandingFooter extends StatelessWidget {
  final VoidCallback onHow;
  final VoidCallback onTeachers;
  final VoidCallback onFaq;
  final VoidCallback onJoin;
  final VoidCallback onHost;

  const LandingFooter({
    super.key,
    required this.onHow,
    required this.onTeachers,
    required this.onFaq,
    required this.onJoin,
    required this.onHost,
  });

  @override
  Widget build(BuildContext context) {
    Widget column(String heading, List<(String, VoidCallback)> links) => Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(heading.toUpperCase(), style: AppWebText.footerHeading),
        const SizedBox(height: 8),
        for (final (label, onTap) in links)
          InkWell(
            onTap: onTap,
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 6),
              child: Text(
                label,
                style: AppWebText.body.copyWith(fontSize: 15),
              ),
            ),
          ),
      ],
    );
    return DecoratedBox(
      decoration: const BoxDecoration(
        color: AppColors.boardDeep,
        border: Border(top: BorderSide(color: AppColors.line)),
      ),
      child: LandingSection(
        top: 40,
        bottom: 32,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            ResponsiveGrid(
              minItemWidth: 180,
              gap: 28,
              equalHeights: false,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'QUIZ NIGHT',
                      style: AppWebText.brand.copyWith(fontSize: 20),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      LandingContent.footerTagline,
                      style: AppWebText.small.copyWith(fontSize: 14),
                    ),
                  ],
                ),
                column('Product', [
                  ('How it works', onHow),
                  ('For teachers', onTeachers),
                ]),
                column('Play', [
                  ('Join a game', onJoin),
                  ('Host a game', onHost),
                ]),
                column('Help', [('FAQ', onFaq)]),
              ],
            ),
            const SizedBox(height: 28),
            Container(
              padding: const EdgeInsets.only(top: 20),
              decoration: const BoxDecoration(
                border: Border(top: BorderSide(color: AppColors.line)),
              ),
              child: Text('© 2026 Quiz Night', style: AppWebText.small),
            ),
          ],
        ),
      ),
    );
  }
}
