import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_motion.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/theme/app_text_styles.dart';
import '../../features/room/round_logic.dart';
import '../brand/option_shape.dart';

/// Answer button states (design system "Answer button").
enum AnswerLook {
  /// Resting, tappable.
  idle,

  /// This player's locked-in pick: chalk outline.
  selected,

  /// Revealed as the right answer: green, ✓.
  correct,

  /// This player's wrong pick: red, struck through.
  wrong,

  /// Not chosen / not the answer: faded.
  dimmed,
}

/// Picks a look from the reveal and this player's pick.
AnswerLook answerLookFor({
  required int index,
  required int? correctIndex,
  required int? picked,
}) {
  if (correctIndex != null) {
    if (index == correctIndex) return AnswerLook.correct;
    if (index == picked) return AnswerLook.wrong;
    return AnswerLook.dimmed;
  }
  if (picked == null) return AnswerLook.idle;
  return index == picked ? AnswerLook.selected : AnswerLook.dimmed;
}

({Color bg, Color fg}) _colors(int index, AnswerLook look) => switch (look) {
  AnswerLook.correct => (bg: AppColors.correct, fg: AppColors.white),
  AnswerLook.wrong => (bg: AppColors.wrong, fg: AppColors.white),
  _ => (
    bg: AppColors.options[index % 4],
    fg: AppColors.optionInk[index % 4],
  ),
};

/// The dark square holding the option letter.
class OptionLetterTile extends StatelessWidget {
  final int index;
  final double size;

  const OptionLetterTile({super.key, required this.index, this.size = 40});

  @override
  Widget build(BuildContext context) => Container(
    width: size,
    height: size,
    alignment: Alignment.center,
    decoration: BoxDecoration(
      color: const Color(0x38000000),
      borderRadius: BorderRadius.circular(size * 0.23),
    ),
    child: Text(
      optionLetter(index),
      style: AppTextStyles.optionLetter.copyWith(fontSize: size * 0.55),
    ),
  );
}

/// A phone answer button: letter tile, shape, text, and a state tag.
class PhoneAnswerButton extends StatefulWidget {
  final int index;
  final String text;
  final AnswerLook look;
  final VoidCallback? onTap;

  const PhoneAnswerButton({
    super.key,
    required this.index,
    required this.text,
    this.look = AnswerLook.idle,
    this.onTap,
  });

  @override
  State<PhoneAnswerButton> createState() => _PhoneAnswerButtonState();
}

class _PhoneAnswerButtonState extends State<PhoneAnswerButton> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    final look = widget.look;
    final c = _colors(widget.index, look);
    final bg = _pressed && look == AnswerLook.idle
        ? AppColors.optionPressed[widget.index % 4]
        : c.bg;
    final tag = switch (look) {
      AnswerLook.selected => 'Locked',
      AnswerLook.correct => '✓ Correct',
      AnswerLook.wrong => '✕ Wrong',
      _ => null,
    };
    return Semantics(
      button: widget.onTap != null,
      label:
          'Option ${optionLetter(widget.index)}, '
          '${optionShapeName(widget.index)}: ${widget.text}'
          '${tag == null ? '' : ', $tag'}',
      excludeSemantics: true,
      child: GestureDetector(
        onTapDown: widget.onTap == null
            ? null
            : (_) => setState(() => _pressed = true),
        onTapCancel: () => setState(() => _pressed = false),
        onTapUp: (_) => setState(() => _pressed = false),
        onTap: widget.onTap,
        child: AnimatedOpacity(
          duration: AppDurations.normal,
          opacity: look == AnswerLook.dimmed ? 0.4 : 1,
          child: AnimatedScale(
            duration: AppDurations.instant,
            scale: _pressed && look == AnswerLook.idle
                ? 0.97
                : look == AnswerLook.correct
                ? 1.03
                : 1,
            child: Container(
              constraints: const BoxConstraints(minHeight: 56),
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
              decoration: BoxDecoration(
                color: bg,
                borderRadius: BorderRadius.circular(AppRadii.lg),
                border:
                    look == AnswerLook.selected || look == AnswerLook.correct
                    ? Border.all(
                        color: AppColors.chalk,
                        width: AppBorders.focus,
                      )
                    : null,
              ),
              child: Row(
                children: [
                  OptionLetterTile(index: widget.index),
                  const SizedBox(width: 12),
                  OptionShape(index: widget.index, color: c.fg),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      widget.text,
                      style: AppTextStyles.optionText.copyWith(
                        color: c.fg,
                        fontSize: 18,
                        height: 1.2,
                        decoration: look == AnswerLook.wrong
                            ? TextDecoration.lineThrough
                            : null,
                        decorationColor: c.fg,
                      ),
                    ),
                  ),
                  if (tag != null) ...[
                    const SizedBox(width: 8),
                    Text(
                      tag.toUpperCase(),
                      style: AppTextStyles.label.copyWith(
                        color: c.fg,
                        fontSize: 13,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// A compact chip of one option (the "you picked" summary).
class OptionChip extends StatelessWidget {
  final int index;
  final String text;

  const OptionChip({super.key, required this.index, required this.text});

  @override
  Widget build(BuildContext context) {
    final fg = AppColors.optionInk[index % 4];
    return Container(
      padding: const EdgeInsets.fromLTRB(10, 10, 16, 10),
      decoration: BoxDecoration(
        color: AppColors.options[index % 4],
        borderRadius: BorderRadius.circular(AppRadii.lg),
        border: Border.all(color: AppColors.chalk, width: AppBorders.focus),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          OptionLetterTile(index: index, size: 36),
          const SizedBox(width: 12),
          OptionShape(index: index, color: fg, size: 14),
          const SizedBox(width: 12),
          Flexible(
            child: Text(
              text,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: AppTextStyles.optionText.copyWith(color: fg, fontSize: 18),
            ),
          ),
        ],
      ),
    );
  }
}

/// A projector answer tile for a 1920×1080 canvas.
class HostAnswerTile extends StatelessWidget {
  final int index;
  final String text;
  final AnswerLook look;

  const HostAnswerTile({
    super.key,
    required this.index,
    required this.text,
    this.look = AnswerLook.idle,
  });

  @override
  Widget build(BuildContext context) {
    final c = _colors(index, look);
    return AnimatedOpacity(
      duration: AppDurations.slow,
      opacity: look == AnswerLook.dimmed ? AppOpacity.dimmed : 1,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 40),
        decoration: BoxDecoration(
          color: c.bg,
          borderRadius: BorderRadius.circular(28),
        ),
        child: Row(
          children: [
            OptionLetterTile(index: index, size: 96),
            const SizedBox(width: 28),
            OptionShape(index: index, color: c.fg, size: 36),
            const SizedBox(width: 28),
            Expanded(
              child: Text(
                text,
                style: AppTextStyles.optionText.copyWith(
                  color: c.fg,
                  fontSize: 52,
                  height: 1.15,
                ),
              ),
            ),
            if (look == AnswerLook.correct)
              Text(
                '✓',
                style: AppTextStyles.numeric.copyWith(
                  color: c.fg,
                  fontSize: 48,
                ),
              ),
          ],
        ),
      ),
    );
  }
}
