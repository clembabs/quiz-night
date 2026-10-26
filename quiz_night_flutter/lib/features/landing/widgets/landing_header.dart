import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../app/app_paths.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../widgets/brand/crest.dart';
import '../landing_cubit.dart';
import 'landing_parts.dart';

/// The website's pages, in menu order.
enum SitePage {
  home('Home', AppPaths.home),
  how('How it works', AppPaths.howItWorks),
  hosting('For hosts', AppPaths.hosting),
  faq('FAQ', AppPaths.faq);

  final String label;
  final String path;
  const SitePage(this.label, this.path);
}

/// Brand, plus links on wide screens or a Menu button on narrow ones.
class LandingHeader extends StatelessWidget {
  /// The page being shown, highlighted in the links; null on "not found".
  final SitePage? current;
  final ValueChanged<SitePage> onNavigate;
  final VoidCallback onJoin;

  const LandingHeader({
    super.key,
    required this.current,
    required this.onNavigate,
    required this.onJoin,
  });

  static const _links = [SitePage.how, SitePage.hosting, SitePage.faq];

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.sizeOf(context).width;
    final wide = width >= AppWebLayout.wideNav;
    final gutter = AppWebLayout.gutter(width);
    final menuOpen = context.select((LandingCubit c) => c.state.menuOpen);
    final cubit = context.read<LandingCubit>();

    return DecoratedBox(
      decoration: const BoxDecoration(
        color: AppColors.headerGlass,
        border: Border(bottom: BorderSide(color: AppColors.line)),
      ),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: AppWebLayout.maxWidth),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              SizedBox(
                height: AppWebLayout.headerHeight,
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: gutter),
                  child: Row(
                    children: [
                      // Keeps the Menu button on screen on narrow phones.
                      Flexible(
                        child: FittedBox(
                          fit: BoxFit.scaleDown,
                          alignment: Alignment.centerLeft,
                          child: SiteBrand(
                            key: const Key('site.home'),
                            onTap: () => onNavigate(SitePage.home),
                          ),
                        ),
                      ),
                      const Spacer(),
                      if (wide) ...[
                        for (final a in _links)
                          _NavLink(
                            page: a,
                            active: a == current,
                            onTap: () => onNavigate(a),
                          ),
                        const SizedBox(width: 8),
                        LandingButton(
                          label: 'Join a game',
                          height: 44,
                          onPressed: onJoin,
                        ),
                      ] else
                        LandingButton(
                          buttonKey: const Key('landing.menu'),
                          label: menuOpen ? 'Close' : 'Menu',
                          kind: LandingButtonKind.outline,
                          height: 44,
                          onPressed: cubit.toggleMenu,
                        ),
                    ],
                  ),
                ),
              ),
              if (!wide && menuOpen)
                Container(
                  padding: EdgeInsets.fromLTRB(gutter, 8, gutter, 20),
                  decoration: const BoxDecoration(
                    border: Border(top: BorderSide(color: AppColors.line)),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      for (final a in SitePage.values)
                        _NavLink(
                          page: a,
                          active: a == current,
                          large: true,
                          onTap: () {
                            cubit.closeMenu();
                            onNavigate(a);
                          },
                        ),
                      const SizedBox(height: 8),
                      LandingButton(
                        label: 'Join a game',
                        onPressed: () {
                          cubit.closeMenu();
                          onJoin();
                        },
                      ),
                    ],
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

/// A header link; the current page is lit.
class _NavLink extends StatelessWidget {
  final SitePage page;
  final bool active;
  final bool large;
  final VoidCallback onTap;

  const _NavLink({
    required this.page,
    required this.active,
    required this.onTap,
    this.large = false,
  });

  @override
  Widget build(BuildContext context) => Semantics(
    link: true,
    selected: active,
    child: TextButton(
      key: Key('nav.${page.name}${large ? '.menu' : ''}'),
      onPressed: onTap,
      style: TextButton.styleFrom(
        alignment: large ? Alignment.centerLeft : Alignment.center,
        minimumSize: large ? const Size.fromHeight(48) : const Size(0, 40),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        backgroundColor: active ? AppColors.navActive : Colors.transparent,
        foregroundColor: active ? AppColors.chalk : AppColors.chalkSoft,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(large ? 10 : 8),
        ),
      ),
      child: Text(
        page.label,
        style: AppWebText.navLink.copyWith(
          fontSize: large ? 17 : 15,
          color: active ? AppColors.chalk : AppColors.chalkSoft,
        ),
      ),
    ),
  );
}

/// The crest and "QUIZ NIGHT", linking home.
class SiteBrand extends StatelessWidget {
  final VoidCallback onTap;

  const SiteBrand({super.key, required this.onTap});

  @override
  Widget build(BuildContext context) => Semantics(
    button: true,
    label: 'Quiz Night home',
    child: InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(AppRadii.sm),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Crest(width: 34),
          const SizedBox(width: 10),
          Text('QUIZ NIGHT', style: AppWebText.brand),
        ],
      ),
    ),
  );
}
