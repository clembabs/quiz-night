import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/theme/app_text_styles.dart';
import '../brand/initial_badge.dart';

/// A player's chip: initial badge and nickname. States: default, you (gold
/// ring), finalist, eliminated (struck, faded).
class PlayerChip extends StatelessWidget {
  final String nickname;
  final bool isYou;
  final bool isFinalist;
  final bool isEliminated;

  /// Chip height: 40 on phones, 52 for "you" on the waiting screen, 80 on
  /// the projector lobby.
  final double height;

  const PlayerChip({
    super.key,
    required this.nickname,
    this.isYou = false,
    this.isFinalist = false,
    this.isEliminated = false,
    this.height = 40,
  });

  @override
  Widget build(BuildContext context) {
    final badge = height * 0.78;
    return Opacity(
      opacity: isEliminated ? 0.55 : 1,
      child: Container(
        height: height,
        padding: EdgeInsets.fromLTRB(
          height * 0.12,
          0,
          height * 0.38,
          0,
        ),
        decoration: BoxDecoration(
          color: isFinalist ? AppColors.goldDeep : AppColors.surfaceHigh,
          borderRadius: BorderRadius.circular(AppRadii.full),
          border: Border.all(
            color: isYou || isFinalist ? AppColors.gold : Colors.transparent,
            width: height >= 60 ? 3 : 2,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            InitialBadge(
              nickname: nickname,
              size: badge,
              eliminated: isEliminated,
            ),
            SizedBox(width: height * 0.2),
            Flexible(
              child: Text(
                nickname,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: AppTextStyles.chip.copyWith(
                  fontSize: height * 0.4,
                  decoration: isEliminated ? TextDecoration.lineThrough : null,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// "+42 more" dashed chip.
class MoreChip extends StatelessWidget {
  final int count;
  final double height;

  const MoreChip({super.key, required this.count, this.height = 40});

  @override
  Widget build(BuildContext context) => Container(
    height: height,
    padding: EdgeInsets.symmetric(horizontal: height * 0.35),
    alignment: Alignment.center,
    decoration: BoxDecoration(
      borderRadius: BorderRadius.circular(AppRadii.full),
      border: Border.all(
        color: AppColors.chalk.withValues(alpha: 0.3),
        width: 2,
      ),
    ),
    child: Text(
      '+$count more',
      style: AppTextStyles.chip.copyWith(
        fontSize: height * 0.38,
        color: AppColors.chalkSoft,
      ),
    ),
  );
}
