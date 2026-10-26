import 'package:quiz_night_client/quiz_night_client.dart';

import 'app_failure.dart';
import 'room_repositories.dart';

/// AI-written questions for the host's setup screen.
abstract interface class QuestionsRepository {
  /// Whether the server can write questions (an AI key is set up).
  Future<bool> aiAvailable();

  /// Writes a question pack on [topic] sized for a game with [config].
  Future<PackDraft> generatePack(
    String topic,
    QuestionDifficulty difficulty,
    RoomConfig config,
  );

  /// Drops one question from [pack].
  Future<PackDraft> removeQuestion(
    PackDraft pack,
    int questionId,
    RoomConfig config,
  );
}

/// [QuestionsRepository] on the Serverpod client.
class ServerpodQuestionsRepository implements QuestionsRepository {
  final Client _client;

  ServerpodQuestionsRepository(this._client);

  @override
  Future<bool> aiAvailable() async {
    try {
      return await _client.questions.aiAvailable();
    } catch (_) {
      return false;
    }
  }

  @override
  Future<PackDraft> generatePack(
    String topic,
    QuestionDifficulty difficulty,
    RoomConfig config,
  ) => guardServerCall(
    () => _client.questions.generatePack(topic, difficulty, config),
  );

  @override
  Future<PackDraft> removeQuestion(
    PackDraft pack,
    int questionId,
    RoomConfig config,
  ) => guardServerCall(
    () => _client.questions.removePackQuestion(
      pack.packId,
      pack.packToken,
      questionId,
      config,
    ),
  );
}

/// No AI on this build (tests, or a server without a key).
class NoQuestionsRepository implements QuestionsRepository {
  const NoQuestionsRepository();

  @override
  Future<bool> aiAvailable() async => false;

  @override
  Future<PackDraft> generatePack(
    String topic,
    QuestionDifficulty difficulty,
    RoomConfig config,
  ) => throw const AppFailure('AI questions are not available');

  @override
  Future<PackDraft> removeQuestion(
    PackDraft pack,
    int questionId,
    RoomConfig config,
  ) => throw const AppFailure('AI questions are not available');
}
