import 'package:serverpod/serverpod.dart';

import '../ai/question_packs.dart';
import '../generated/protocol.dart';

/// AI-written questions for the host's setup screen. Rate limited inside
/// [QuestionPacks.generate] (5 an hour per address, 300 a day overall).
class QuestionsEndpoint extends Endpoint {
  /// Whether this server can write questions (an API key is set).
  Future<bool> aiAvailable(Session session) async => QuestionPacks.available;

  /// Writes a question pack on [topic] sized for a game with [config].
  Future<PackDraft> generatePack(
    Session session,
    String topic,
    QuestionDifficulty difficulty,
    RoomConfig config,
  ) => QuestionPacks.generate(session, topic, difficulty, config);

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
