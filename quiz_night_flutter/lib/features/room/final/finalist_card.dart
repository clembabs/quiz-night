import 'package:flutter/material.dart';
import 'package:quiz_night_client/quiz_night_client.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_text_styles.dart';

/// What a finalist is doing on the current final question.
enum FinalistTag { none, buzzed, lockedOut, gotIt }

FinalistTag finalistTagFor(RoomState room, PlayerView finalist) {
  if (room.buzzWinnerId == finalist.id) return FinalistTag.gotIt;
  if (room.buzzerHolderId == finalist.id) return FinalistTag.buzzed;
  if (finalist.lockedOut) return FinalistTag.lockedOut;
  return FinalistTag.none;
}

/// A finalist's name, final score and buzzer status.
class FinalistCard extends StatelessWidget {
  final PlayerView finalist;
  final FinalistTag tag;
  final bool isMe;

  const FinalistCard({
    super.key,
    required this.finalist,
    required this.tag,
    this.isMe = false,
  });

  @override
  Widget build(BuildContext context) {
    final (border, tagColor, tagText) = switch (tag) {
      FinalistTag.buzzed => (AppColors.buzzer, AppColors.buzzer, 'BUZZED!'),
      FinalistTag.gotIt => (AppColors.success, AppColors.success, 'GOT IT'),
      FinalistTag.lockedOut => (
        AppColors.surfaceHigh,
        AppColors.muted,
        'LOCKED OUT',
      ),
      FinalistTag.none => (
        isMe ? AppColors.gold : AppColors.surfaceHigh,
        null,
        null,
      ),
    };
    return AnimatedOpacity(
      duration: const Duration(milliseconds: 200),
      opacity: tag == FinalistTag.lockedOut ? 0.5 : 1,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.all(AppSpacing.lg),
        decoration: BoxDecoration(
          color: AppColors.surface,
          border: Border.all(
            color: border,
            width: tag == FinalistTag.buzzed ? 5 : 2,
          ),
          borderRadius: BorderRadius.circular(AppRadii.lg),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              finalist.nickname,
              overflow: TextOverflow.ellipsis,
              style: AppTextStyles.finalistName,
            ),
            const SizedBox(height: AppSpacing.xs),
            Text('${finalist.finalScore}', style: AppTextStyles.finalScore),
            if (tagText != null) ...[
              const SizedBox(height: AppSpacing.sm),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.sm,
                  vertical: AppSpacing.xs,
                ),
                decoration: BoxDecoration(
                  color: tagColor,
                  borderRadius: BorderRadius.circular(AppRadii.pill),
                ),
                child: Text(tagText, style: AppTextStyles.statusTag),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

/// A row of [FinalistCard]s in standings order.
class FinalistRow extends StatelessWidget {
  final RoomState room;
  final List<PlayerView> finalists;
  final int? myId;

  const FinalistRow({
    super.key,
    required this.room,
    required this.finalists,
    this.myId,
  });

  @override
  Widget build(BuildContext context) => Row(
    children: [
      for (var i = 0; i < finalists.length; i++) ...[
        if (i > 0) const SizedBox(width: AppSpacing.md),
        Expanded(
          child: FinalistCard(
            finalist: finalists[i],
            tag: finalistTagFor(room, finalists[i]),
            isMe: finalists[i].id == myId,
          ),
        ),
      ],
    ],
  );
}
