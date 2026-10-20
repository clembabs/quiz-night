import 'package:flutter/material.dart';

import '../core/theme/app_colors.dart';
import '../core/theme/app_spacing.dart';
import '../core/theme/app_text_styles.dart';
import '../features/room/round_logic.dart';

/// How an option looks right now.
enum OptionLook {
  /// Open question, nothing picked yet.
  idle,

  /// This player's pick.
  picked,

  /// Not picked, while another option is.
  faded,

  /// Revealed as the right answer.
  correct,

  /// Revealed, not the right answer.
  wrong,
}

/// A coloured answer tile: letter, text and, after reveal, the vote count.
class AnswerOption extends StatelessWidget {
  final int index;
  final String text;
  final OptionLook look;
  final int? votes;
  final bool large;
  final VoidCallback? onTap;

  const AnswerOption({
    super.key,
    required this.index,
    required this.text,
    this.look = OptionLook.idle,
    this.votes,
    this.large = false,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final base = AppColors.options[index % AppColors.options.length];
    final dim = look == OptionLook.faded || look == OptionLook.wrong;
    final border = switch (look) {
      OptionLook.picked => Border.all(color: AppColors.text, width: 4),
      OptionLook.correct => Border.all(color: AppColors.success, width: 6),
      _ => null,
    };

    return Semantics(
      button: onTap != null,
      label: 'Option ${optionLetter(index)}: $text',
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(AppRadii.sm),
          child: Ink(
            decoration: BoxDecoration(
              color: Color.alphaBlend(
                dim ? AppColors.dimmed : Colors.transparent,
                base,
              ),
              border: border,
              borderRadius: BorderRadius.circular(AppRadii.sm),
            ),
            padding: EdgeInsets.all(large ? AppSpacing.xl : AppSpacing.lg),
            child: Row(
              children: [
                Text(optionLetter(index), style: AppTextStyles.optionLetter),
                const SizedBox(width: AppSpacing.md),
                Expanded(
                  child: Text(
                    text,
                    style: large
                        ? AppTextStyles.optionTextLarge
                        : AppTextStyles.optionText,
                  ),
                ),
                if (look == OptionLook.correct)
                  const Icon(Icons.check_circle, color: AppColors.onOption),
                if (votes != null) ...[
                  const SizedBox(width: AppSpacing.sm),
                  Text('$votes', style: AppTextStyles.optionCount),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// Picks each option's [OptionLook] from the reveal and this player's pick.
OptionLook lookFor({
  required int index,
  required int? correctIndex,
  required int? picked,
}) {
  if (correctIndex != null) {
    return index == correctIndex ? OptionLook.correct : OptionLook.wrong;
  }
  if (picked == null) return OptionLook.idle;
  return index == picked ? OptionLook.picked : OptionLook.faded;
}
