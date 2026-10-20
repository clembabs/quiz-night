import 'package:flutter/material.dart';
import 'package:quiz_night_client/quiz_night_client.dart';

import '../core/theme/app_colors.dart';
import '../core/theme/app_spacing.dart';
import '../core/theme/app_text_styles.dart';

/// "Spectating · shadow score N" strip for eliminated players.
class SpectatorBanner extends StatelessWidget {
  final PlayerView me;

  const SpectatorBanner({super.key, required this.me});

  /// Whether [me] should see the banner.
  static bool appliesTo(PlayerView? me) =>
      me?.status == PlayerStatus.eliminated;

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(
      horizontal: AppSpacing.lg,
      vertical: AppSpacing.sm,
    ),
    decoration: BoxDecoration(
      color: AppColors.surfaceHigh,
      borderRadius: BorderRadius.circular(AppRadii.pill),
    ),
    child: Row(
      children: [
        const Icon(Icons.visibility_rounded, color: AppColors.muted, size: 18),
        const SizedBox(width: AppSpacing.sm),
        Expanded(
          child: Text(
            "Spectating · shadow score ${me.shadowScore}",
            style: AppTextStyles.banner,
          ),
        ),
      ],
    ),
  );
}
