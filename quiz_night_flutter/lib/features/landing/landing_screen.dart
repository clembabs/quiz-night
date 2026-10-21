import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_motion.dart';
import '../../widgets/brand/chalk_background.dart';
import 'widgets/game_preview.dart';
import 'widgets/hero_section.dart';
import 'widgets/info_sections.dart';
import 'widgets/landing_header.dart';

/// The website's front page: what Quiz Night is and how a game runs, with
/// the two ways in (join with a code, or host) right at the top.
class LandingScreen extends StatefulWidget {
  /// Opens the join form; [code] is what the visitor typed, if anything.
  final void Function(String? code) onJoin;
  final VoidCallback onHost;

  const LandingScreen({super.key, required this.onJoin, required this.onHost});

  @override
  State<LandingScreen> createState() => _LandingScreenState();
}

/// Stateful only to own the scroll controller and the section anchors.
class _LandingScreenState extends State<LandingScreen> {
  final _scroll = ScrollController();
  final _anchors = {for (final a in LandingAnchor.values) a: GlobalKey()};

  @override
  void dispose() {
    _scroll.dispose();
    super.dispose();
  }

  void _goTo(LandingAnchor anchor) {
    if (anchor == LandingAnchor.top) {
      _scroll.animateTo(
        0,
        duration: AppDurations.slow,
        curve: AppCurves.standard,
      );
      return;
    }
    final target = _anchors[anchor]!.currentContext;
    if (target == null) return;
    Scrollable.ensureVisible(
      target,
      duration: AppDurations.slow,
      curve: AppCurves.standard,
    );
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    backgroundColor: AppColors.board,
    body: ChalkBackground(
      spacing: 7,
      child: Column(
        children: [
          SafeArea(
            bottom: false,
            child: LandingHeader(
              onNavigate: _goTo,
              onJoin: () => widget.onJoin(null),
            ),
          ),
          Expanded(
            child: SingleChildScrollView(
              key: const Key('landing.scroll'),
              controller: _scroll,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  HeroSection(
                    onJoin: widget.onJoin,
                    onHost: widget.onHost,
                    onReadGuide: () => _goTo(LandingAnchor.teachers),
                  ),
                  const GamePreview(),
                  StepsSection(
                    onSeeWalkthrough: () => _goTo(LandingAnchor.how),
                  ),
                  WalkthroughSection(key: _anchors[LandingAnchor.how]),
                  const KnockedOutSection(),
                  TeachersSection(
                    key: _anchors[LandingAnchor.teachers],
                    onHost: widget.onHost,
                    onReadFaq: () => _goTo(LandingAnchor.faq),
                  ),
                  FaqSection(key: _anchors[LandingAnchor.faq]),
                  LandingFooter(
                    onHow: () => _goTo(LandingAnchor.how),
                    onTeachers: () => _goTo(LandingAnchor.teachers),
                    onFaq: () => _goTo(LandingAnchor.faq),
                    onJoin: () => widget.onJoin(null),
                    onHost: widget.onHost,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    ),
  );
}
