import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_text_styles.dart';

/// One eliminated name, sliding in when it is revealed.
class EliminatedNameTile extends StatelessWidget {
  final String nickname;

  /// The last name revealed: the player who nearly survived.
  final bool isBubble;

  /// Shown on the host's tile once the reveal is over.
  final Widget? trailing;

  static const entry = Duration(milliseconds: 450);

  const EliminatedNameTile({
    super.key,
    required this.nickname,
    this.isBubble = false,
    this.trailing,
  });

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0, end: 1),
      duration: entry,
      curve: Curves.easeOutBack,
      builder: (context, t, child) => Opacity(
        opacity: t.clamp(0.0, 1.0),
        child: Transform.translate(
          offset: Offset(0, (1 - t) * 24),
          child: Transform.scale(scale: 0.9 + 0.1 * t, child: child),
        ),
      ),
      child: Container(
        margin: const EdgeInsets.only(bottom: AppSpacing.md),
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.xl,
          vertical: AppSpacing.lg,
        ),
        decoration: BoxDecoration(
          color: AppColors.eliminated,
          border: Border.all(color: AppColors.danger, width: 2),
          borderRadius: BorderRadius.circular(AppRadii.sm),
        ),
        child: Row(
          children: [
            const Icon(Icons.close_rounded, color: AppColors.danger, size: 32),
            const SizedBox(width: AppSpacing.md),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(nickname, style: AppTextStyles.revealName),
                  if (isBubble)
                    const Text('SO CLOSE', style: AppTextStyles.bubbleTag),
                ],
              ),
            ),
            ?trailing,
          ],
        ),
      ),
    );
  }
}
