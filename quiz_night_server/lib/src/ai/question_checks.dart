import 'dart:math';

import 'question_generator.dart';

/// A question that passed [checkQuestions], with its options shuffled.
class CheckedQuestion {
  final String text;
  final List<String> options;
  final int correctIndex;
  final bool isFinal;

  const CheckedQuestion(
    this.text,
    this.options,
    this.correctIndex,
    this.isFinal,
  );
}

abstract final class QuestionLimits {
  static const minText = 8;
  static const maxText = 200;
  static const maxOption = 80;
}

final _spaces = RegExp(r'\s+');

/// The question names its own answer ("…pioneered by Afrobeat legend Fela
/// Kuti?" with the answer "Afrobeat"). Answers under 4 characters are left
/// alone to avoid false alarms; longer ones count when they appear as a
/// whole word or phrase.
bool _givesAnswerAway(String question, String answer) {
  final a = answer.toLowerCase().trim();
  if (a.length < 4) return false;
  final pattern = RegExp(
    '(^|[^\\p{L}\\p{N}])${RegExp.escape(a)}(\$|[^\\p{L}\\p{N}])',
    unicode: true,
  );
  return pattern.hasMatch(question.toLowerCase());
}

String _tidy(String s) => s.replaceAll(_spaces, ' ').trim();

/// Keeps only well-formed questions: text of a sensible length, exactly four
/// distinct non-empty options, a valid answer, and no repeats (of the
/// question, ignoring case). Options are shuffled, because models tend to
/// put the right answer in the same place.
List<CheckedQuestion> checkQuestions(
  Iterable<DraftQuestion> drafts, {
  Random? random,
}) {
  final rng = random ?? Random.secure();
  final seen = <String>{};
  final out = <CheckedQuestion>[];
  for (final d in drafts) {
    final text = _tidy(d.text);
    if (text.length < QuestionLimits.minText ||
        text.length > QuestionLimits.maxText) {
      continue;
    }
    final options = d.options.map(_tidy).toList();
    if (options.length != 4) continue;
    if (options.any((o) => o.isEmpty || o.length > QuestionLimits.maxOption)) {
      continue;
    }
    if (options.map((o) => o.toLowerCase()).toSet().length != 4) continue;
    if (d.correctIndex < 0 || d.correctIndex > 3) continue;
    final correct = options[d.correctIndex];
    if (_givesAnswerAway(text, correct)) continue;
    if (!seen.add(text.toLowerCase())) continue;

    final shuffled = [...options]..shuffle(rng);
    out.add(
      CheckedQuestion(text, shuffled, shuffled.indexOf(correct), d.isFinal),
    );
  }
  return out;
}
