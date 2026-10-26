import '../generated/protocol.dart';

/// A question as the generator wrote it, before checking.
class DraftQuestion {
  final String text;
  final List<String> options;
  final int correctIndex;
  final bool isFinal;

  const DraftQuestion({
    required this.text,
    required this.options,
    required this.correctIndex,
    required this.isFinal,
  });
}

/// What to write.
class GenerationRequest {
  final String topic;
  final QuestionDifficulty difficulty;
  final int roundCount;
  final int finalCount;

  const GenerationRequest({
    required this.topic,
    required this.difficulty,
    required this.roundCount,
    required this.finalCount,
  });
}

/// The provider declined the topic (its safety rules).
class GenerationRefused implements Exception {
  final String reason;
  const GenerationRefused(this.reason);
  @override
  String toString() => 'GenerationRefused: $reason';
}

/// The provider failed: network, timeout, quota, or an unusable reply.
class GenerationFailed implements Exception {
  final String reason;
  const GenerationFailed(this.reason);
  @override
  String toString() => 'GenerationFailed: $reason';
}

/// Writes quiz questions on a topic. Swappable, so the provider is a
/// setting and tests use a fake that never calls a paid or rate-limited API.
abstract interface class QuestionGenerator {
  Future<List<DraftQuestion>> generate(GenerationRequest request);
}
