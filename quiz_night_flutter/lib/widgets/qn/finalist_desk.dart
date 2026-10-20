import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_motion.dart';
import '../../core/theme/app_text_styles.dart';
import '../../features/room/final/final_logic.dart';
import '../brand/initial_badge.dart';

String deskStatusLabel(DeskState s) => switch (s) {
  DeskState.ready => 'Ready',
  DeskState.buzzedFirst => 'Buzzed first',
  DeskState.lockedOut => 'Locked out',
  DeskState.gotIt => 'Got it',
};

({Color pillBg, Color pillFg, Color ring, Color desk}) deskColors(
  DeskState s,
) => switch (s) {
  DeskState.buzzedFirst => (
    pillBg: AppColors.gold,
    pillFg: AppColors.goldInk,
    ring: AppColors.gold,
    desk: AppColors.goldDeep,
  ),
  DeskState.gotIt => (
    pillBg: AppColors.correct,
    pillFg: AppColors.white,
    ring: AppColors.correct,
    desk: AppColors.green,
  ),
  DeskState.lockedOut => (
    pillBg: AppColors.slate,
    pillFg: AppColors.muted,
    ring: AppColors.slate,
    desk: AppColors.surface,
  ),
  DeskState.ready => (
    pillBg: AppColors.green,
    pillFg: AppColors.mintPale,
    ring: AppColors.greenLine,
    desk: AppColors.surface,
  ),
};

/// The projector's finalist desk: status pill, big avatar, desk with name and
/// score. Sized for the 1920×1080 canvas.
class FinalistDesk extends StatelessWidget {
  final String nickname;
  final String score;
  final DeskState state;

  const FinalistDesk({
    super.key,
    required this.nickname,
    required this.score,
    required this.state,
  });

  @override
  Widget build(BuildContext context) {
    final c = deskColors(state);
    // Laid out at a fixed design width and scaled down to whatever space the
    // screen gives it (the final has less room than "Meet your finalists").
    return FittedBox(
      fit: BoxFit.scaleDown,
      alignment: Alignment.bottomCenter,
      child: SizedBox(width: designWidth, child: _desk(c)),
    );
  }

  /// Width the desk is designed at on the 1920 canvas.
  static const designWidth = 520.0;

  Widget _desk(({Color pillBg, Color pillFg, Color ring, Color desk}) c) {
    return AnimatedOpacity(
      duration: AppDurations.normal,
      opacity: state == DeskState.lockedOut ? 0.45 : 1,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          AnimatedScale(
            duration: AppDurations.normal,
            curve: AppCurves.stamp,
            scale: state == DeskState.buzzedFirst ? 1.12 : 1,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 10),
              decoration: BoxDecoration(
                color: c.pillBg,
                borderRadius: BorderRadius.circular(999),
              ),
              child: Text(
                deskStatusLabel(state).toUpperCase(),
                style: AppTextStyles.label.copyWith(
                  fontSize: 32,
                  fontWeight: FontWeight.w800,
                  color: c.pillFg,
                ),
              ),
            ),
          ),
          const SizedBox(height: 24),
          Container(
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: c.ring, width: 8),
            ),
            child: InitialBadge(nickname: nickname, size: 180),
          ),
          const SizedBox(height: 24),
          Container(
            height: 200,
            width: double.infinity,
            decoration: BoxDecoration(
              color: c.desk,
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(24),
              ),
              border: Border(top: BorderSide(color: c.ring, width: 10)),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  nickname,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: AppTextStyles.headline.copyWith(fontSize: 56),
                ),
                Text(
                  score,
                  style: AppTextStyles.numeric.copyWith(
                    fontSize: 40,
                    color: AppColors.chalkSoft,
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

/// The phone's compact finalist row (spectators watching the final).
class FinalistRowTile extends StatelessWidget {
  final String nickname;
  final DeskState state;

  const FinalistRowTile({
    super.key,
    required this.nickname,
    required this.state,
  });

  @override
  Widget build(BuildContext context) {
    final c = deskColors(state);
    return Opacity(
      opacity: state == DeskState.lockedOut ? 0.45 : 1,
      child: Container(
        constraints: const BoxConstraints(minHeight: 56),
        padding: const EdgeInsets.symmetric(horizontal: 14),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            InitialBadge(nickname: nickname, size: 36),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                nickname,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: AppTextStyles.chip.copyWith(fontSize: 17),
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: c.pillBg,
                borderRadius: BorderRadius.circular(999),
              ),
              child: Text(
                deskStatusLabel(state),
                style: AppTextStyles.label.copyWith(
                  fontSize: 12,
                  fontWeight: FontWeight.w800,
                  color: c.pillFg,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
