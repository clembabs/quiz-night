import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../app/app_paths.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../widgets/brand/chalk_background.dart';
import 'landing_cubit.dart';
import 'widgets/game_preview.dart';
import 'widgets/hero_section.dart';
import 'widgets/info_sections.dart';
import 'widgets/landing_header.dart';
import 'widgets/landing_parts.dart';
import '../../widgets/layout/app_scroll.dart';

/// A website page: header, [sections] and footer, each page with its own URL.
class SiteScaffold extends StatelessWidget {
  final SitePage? current;
  final List<Widget> Function(BuildContext context) sections;

  const SiteScaffold({
    super.key,
    required this.current,
    required this.sections,
  });

  @override
  Widget build(BuildContext context) => BlocProvider(
    create: (_) => LandingCubit(),
    child: Builder(
      builder: (context) => Scaffold(
        backgroundColor: AppColors.board,
        body: ChalkBackground(
          spacing: 7,
          child: Column(
            children: [
              SafeArea(
                bottom: false,
                child: LandingHeader(
                  current: current,
                  onNavigate: (page) => context.go(page.path),
                  onJoin: () => context.go(AppPaths.join),
                ),
              ),
              Expanded(
                child: AppScroll(
                  key: const Key('landing.scroll'),
                  // So the footer sits at the bottom of a short page.
                  fillViewport: true,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: sections(context),
                      ),
                      LandingFooter(
                        onHow: () => context.go(AppPaths.howItWorks),
                        onHostingGuide: () => context.go(AppPaths.hosting),
                        onFaq: () => context.go(AppPaths.faq),
                        onJoin: () => context.go(AppPaths.join),
                        onHost: () => context.go(AppPaths.host),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    ),
  );
}

/// `/`: what Quiz Night is, the two ways in, and a taste of the game.
class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) => SiteScaffold(
    current: SitePage.home,
    sections: (context) => [
      HeroSection(
        onJoin: (code) => context.go(AppPaths.joinWith(code)),
        onHost: () => context.go(AppPaths.host),
        onReadGuide: () => context.go(AppPaths.hosting),
      ),
      const GamePreview(),
      StepsSection(
        onSeeWalkthrough: () => context.go(AppPaths.howItWorks),
      ),
      const KnockedOutSection(),
    ],
  );
}

/// `/how-it-works`: the player and host walkthroughs.
class HowItWorksPage extends StatelessWidget {
  const HowItWorksPage({super.key});

  @override
  Widget build(BuildContext context) => SiteScaffold(
    current: SitePage.how,
    sections: (context) => const [
      WalkthroughSection(),
      GamePreview(),
      KnockedOutSection(),
    ],
  );
}

/// `/hosting`: the hosting guide.
class HostingGuidePage extends StatelessWidget {
  const HostingGuidePage({super.key});

  @override
  Widget build(BuildContext context) => SiteScaffold(
    current: SitePage.hosting,
    sections: (context) => [
      HostingGuideSection(
        onHost: () => context.go(AppPaths.host),
        onReadFaq: () => context.go(AppPaths.faq),
      ),
    ],
  );
}

/// `/faq`: questions and answers.
class FaqPage extends StatelessWidget {
  const FaqPage({super.key});

  @override
  Widget build(BuildContext context) => SiteScaffold(
    current: SitePage.faq,
    sections: (context) => const [FaqSection()],
  );
}

/// Any URL the app doesn't know.
class NotFoundPage extends StatelessWidget {
  const NotFoundPage({super.key});

  @override
  Widget build(BuildContext context) => SiteScaffold(
    current: null,
    sections: (context) => [
      LandingSection(
        top: 96,
        bottom: 120,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SectionHeading(
              eyebrow: 'Not found',
              title: 'There’s nothing at this address',
            ),
            const SizedBox(height: 16),
            Text(
              'The link may be old, or mistyped. Room codes go on the join '
              'page.',
              style: AppWebText.bodyLarge,
            ),
            const SizedBox(height: 28),
            Wrap(
              spacing: 12,
              runSpacing: 12,
              children: [
                LandingButton(
                  label: 'Go to the home page',
                  onPressed: () => context.go(AppPaths.home),
                ),
                LandingButton(
                  label: 'Join a game',
                  kind: LandingButtonKind.outline,
                  onPressed: () => context.go(AppPaths.join),
                ),
              ],
            ),
          ],
        ),
      ),
    ],
  );
}
