import 'package:flutter/material.dart';
import 'package:quiz_night_client/quiz_night_client.dart';

import '../core/theme/app_colors.dart';
import '../core/theme/app_spacing.dart';
import '../core/theme/app_text_styles.dart';

/// Nickname chips in join order. [highlightId] marks "you".
class PlayerChips extends StatelessWidget {
  final List<PlayerView> players;
  final int? highlightId;
  final bool large;

  const PlayerChips({
    super.key,
    required this.players,
    this.highlightId,
    this.large = false,
  });

  @override
  Widget build(BuildContext context) {
    // The server sorts by score; in the lobby, join order reads better.
    final byJoin = [...players]..sort((a, b) => a.id.compareTo(b.id));
    return Wrap(
      spacing: AppSpacing.sm,
      runSpacing: AppSpacing.sm,
      children: [for (final p in byJoin) _chip(p)],
    );
  }

  Widget _chip(PlayerView p) {
    final isMe = p.id == highlightId;
    final style = large ? AppTextStyles.chipLarge : AppTextStyles.chip;
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: large ? AppSpacing.xl : AppSpacing.lg,
        vertical: large ? AppSpacing.md : AppSpacing.sm,
      ),
      decoration: BoxDecoration(
        color: isMe ? AppColors.gold : AppColors.surfaceHigh,
        borderRadius: BorderRadius.circular(AppRadii.pill),
      ),
      child: Text(
        p.nickname,
        style: style.copyWith(
          color: isMe ? AppColors.background : AppColors.text,
        ),
      ),
    );
  }
}
