import 'package:serverpod/serverpod.dart';

import '../game/room_service.dart';
import '../generated/protocol.dart';

class AnswerEndpoint extends Endpoint {
  /// Active players score; eliminated players' answers count as shadow score.
  Future<AnswerResult> submitAnswer(
    Session session,
    String playerToken,
    int questionId,
    int choiceIndex,
  ) => RoomService.submitAnswer(session, playerToken, questionId, choiceIndex);
}
