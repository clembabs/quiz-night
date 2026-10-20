import 'package:flutter/material.dart';
import 'package:quiz_night_client/quiz_night_client.dart';

import '../core/theme/app_colors.dart';
import '../core/theme/app_spacing.dart';
import '../core/theme/app_text_styles.dart';

/// Ranked rows: position, name, points from the last question, total.
class LeaderboardList extends StatelessWidget {
  /// Already ranked, best first.
  final List<PlayerView> players;
  final int? highlightId;

  /// How many rows to show; null shows everyone.
  final int? limit;

  const LeaderboardList({
    super.key,
    required this.players,
    this.highlightId,
    this.limit,
  });

  @override
  Widget build(BuildContext context) {
    final shown = limit == null ? players : players.take(limit!).toList();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        for (var i = 0; i < shown.length; i++) _row(i + 1, shown[i]),
      ],
    );
  }

  Widget _row(int position, PlayerView p) {
    final gain = p.lastPoints ?? 0;
    return Container(
      margin: const EdgeInsets.only(bottom: AppSpacing.sm),
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.lg,
        vertical: AppSpacing.md,
      ),
      decoration: BoxDecoration(
        color: p.id == highlightId ? AppColors.surfaceHigh : AppColors.surface,
        border: p.id == highlightId
            ? Border.all(color: AppColors.gold, width: 2)
            : null,
        borderRadius: BorderRadius.circular(AppRadii.sm),
      ),
      child: Row(
        children: [
          SizedBox(
            width: 36,
            child: Text('$position', style: AppTextStyles.rank),
          ),
          Expanded(
            child: Text(
              p.nickname,
              overflow: TextOverflow.ellipsis,
              style: AppTextStyles.leaderName,
            ),
          ),
          if (gain > 0)
            Padding(
              padding: const EdgeInsets.only(right: AppSpacing.md),
              child: Text('+$gain', style: AppTextStyles.leaderGain),
            ),
          Text('${p.score}', style: AppTextStyles.leaderScore),
        ],
      ),
    );
  }
}
