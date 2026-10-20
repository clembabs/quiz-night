import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../features/room/standings_logic.dart';
import '../brand/crest.dart';

/// Safe / In the danger zone / Finalist, with a crest-shaped icon.
class DangerIndicator extends StatelessWidget {
  final DangerStatus status;

  const DangerIndicator({super.key, required this.status});

  @override
  Widget build(BuildContext context) {
    final (bg, border, iconFg, icon, detailColor) = switch (status.kind) {
      DangerKind.safe => (
        AppColors.green,
        AppColors.greenLine,
        AppColors.greenInk,
        '✓',
        AppColors.mintPale,
      ),
      DangerKind.danger => (
        AppColors.maroonDeep,
        AppColors.wrong,
        AppColors.white,
        '!',
        AppColors.maroonPale,
      ),
      DangerKind.finalist => (
        AppColors.goldDeep,
        AppColors.gold,
        AppColors.goldInk,
        '★',
        AppColors.goldPale,
      ),
    };
    return Semantics(
      label: '${status.title}. ${status.detail}',
      excludeSemantics: true,
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: bg,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: border, width: 2),
        ),
        child: Row(
          children: [
            Crest(
              width: 34,
              fill: border,
              rim: border,
              child: Text(
                icon,
                style: AppTextStyles.chip.copyWith(
                  color: iconFg,
                  fontSize: 18,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    status.title,
                    style: AppTextStyles.chip.copyWith(
                      fontSize: 17,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    status.detail,
                    style: AppTextStyles.body.copyWith(
                      fontSize: 14,
                      color: detailColor,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
