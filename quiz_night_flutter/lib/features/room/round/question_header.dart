import 'package:flutter/material.dart';
import 'package:quiz_night_client/quiz_night_client.dart';

import '../../../core/theme/app_text_styles.dart';

/// "ROUND 2 · QUESTION 3 OF 5".
class QuestionHeader extends StatelessWidget {
  final RoomState room;

  const QuestionHeader({super.key, required this.room});

  static String textFor(RoomState room) {
    final q = room.question;
    if (q == null) return 'ROUND ${room.round}';
    if (q.isFinal) {
      return 'FINAL · QUESTION ${q.indexInRound} OF ${room.finalQuestionCount}';
    }
    return 'ROUND ${q.round} · QUESTION ${q.indexInRound} OF '
        '${room.questionsPerRound}';
  }

  @override
  Widget build(BuildContext context) =>
      Text(textFor(room), style: AppTextStyles.roundLabel);
}
