import 'package:serverpod/serverpod.dart';

import '../ai/question_packs.dart';
import '../generated/protocol.dart';

/// AI-written questions for the host's setup screen. Rate limited inside
/// [QuestionPacks.generate] (3 an hour per address, 150 a day overall).
class QuestionsEndpoint extends Endpoint {
  /// Whether this server can write questions (an API key is set).
  Future<bool> aiAvailable(Session session) async => QuestionPacks.available;

  /// Writes [questionCount] questions (10-40) on [topic] for a game with
  /// [config].
  Future<PackDraft> generatePack(
    Session session,
    String topic,
    QuestionDifficulty difficulty,
    int questionCount,
    RoomConfig config,
  ) => QuestionPacks.generate(
    session,
    topic,
    difficulty,
    questionCount,
    config,
  );

  /// Drops one question from the host's pack.
  Future<PackDraft> removePackQuestion(
    Session session,
    int packId,
    String packToken,
    int questionId,
    RoomConfig config,
  ) => QuestionPacks.removeQuestion(
    session,
    packId,
    packToken,
    questionId,
    config,
  );
}
