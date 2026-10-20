import 'package:serverpod/serverpod.dart';

import '../game/room_service.dart';
import '../generated/protocol.dart';

/// The buzzer final.
class BuzzerEndpoint extends Endpoint {
  /// Claims the buzzer; only the first valid buzz wins.
  Future<BuzzResult> buzz(
    Session session,
    String playerToken,
    int questionId,
  ) => RoomService.buzz(session, playerToken, questionId);

  /// Answers while holding the buzzer. Returns whether it was correct.
  Future<bool> submitBuzzAnswer(
    Session session,
    String playerToken,
    int questionId,
    int choiceIndex,
  ) => RoomService.submitBuzzAnswer(
    session,
    playerToken,
    questionId,
    choiceIndex,
  );

  /// An eliminated player picks the finalist they think will win.
  Future<void> backFinalist(
    Session session,
    String playerToken,
    int finalistId,
  ) => RoomService.backFinalist(session, playerToken, finalistId);
}
