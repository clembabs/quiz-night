import 'package:flutter/material.dart';
import 'package:quiz_night_client/quiz_night_client.dart';

import '../core/theme/app_spacing.dart';
import 'answer_option.dart';

/// The classic two-column A B / C D board for the projector.
class OptionsGrid extends StatelessWidget {
  final QuestionView question;

  /// Highlights a pick (e.g. the buzzer holder's answer) before reveal.
  final int? picked;

  const OptionsGrid({super.key, required this.question, this.picked});

  @override
  Widget build(BuildContext context) {
    final q = question;
    final tiles = [
      for (var i = 0; i < q.options.length; i++)
        AnswerOption(
          index: i,
          text: q.options[i],
          large: true,
          look: lookFor(index: i, correctIndex: q.correctIndex, picked: picked),
          votes: q.answerCounts?[i],
        ),
    ];
    return Column(
      children: [
        for (var row = 0; row < tiles.length; row += 2)
          Padding(
            padding: const EdgeInsets.only(bottom: AppSpacing.md),
            child: Row(
              children: [
                Expanded(child: tiles[row]),
                const SizedBox(width: AppSpacing.md),
                Expanded(
                  child: row + 1 < tiles.length
                      ? tiles[row + 1]
                      : const SizedBox.shrink(),
                ),
              ],
            ),
          ),
      ],
    );
  }
}
