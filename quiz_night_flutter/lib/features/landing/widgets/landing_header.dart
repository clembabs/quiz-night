import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../widgets/brand/crest.dart';
import '../landing_cubit.dart';
import 'landing_parts.dart';

/// The parts of the page the header links to.
enum LandingAnchor {
  top('Home'),
  how('How it works'),
  teachers('For teachers'),
  faq('FAQ');

  final String label;
  const LandingAnchor(this.label);
}

/// Brand on the left; links and "Join a game" on wide screens, a Menu
/// button that opens them underneath on narrow ones.
class LandingHeader extends StatelessWidget {
  final ValueChanged<LandingAnchor> onNavigate;
  final VoidCallback onJoin;

  const LandingHeader({
    super.key,
    required this.onNavigate,
    required this.onJoin,
  });

  static const _links = [
    LandingAnchor.how,
    LandingAnchor.teachers,
    LandingAnchor.faq,
  ];

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
                      // Shrinks rather than pushing the Menu button off a
                      // very narrow phone.
                      Flexible(
                        child: FittedBox(
                          fit: BoxFit.scaleDown,
                          alignment: Alignment.centerLeft,
                          child: _Brand(
                            onTap: () => onNavigate(LandingAnchor.top),
                          ),
                        ),
                      ),
                      const Spacer(),
                      if (wide) ...[
                        for (final a in _links)
                          TextButton(
                            onPressed: () => onNavigate(a),
                            style: TextButton.styleFrom(
                              foregroundColor: AppColors.chalkSoft,
                              padding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 8,
                              ),
                            ),
                            child: Text(a.label, style: AppWebText.navLink),
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
                      for (final a in LandingAnchor.values)
                        TextButton(
                          onPressed: () {
                            cubit.closeMenu();
                            onNavigate(a);
                          },
                          style: TextButton.styleFrom(
                            alignment: Alignment.centerLeft,
                            minimumSize: const Size.fromHeight(48),
                            foregroundColor: AppColors.chalkSoft,
                          ),
                          child: Text(
                            a.label,
                            style: AppWebText.navLink.copyWith(fontSize: 17),
                          ),
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

class _Brand extends StatelessWidget {
  final VoidCallback onTap;

  const _Brand({required this.onTap});

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
