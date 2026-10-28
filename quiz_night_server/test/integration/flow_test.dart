import 'package:quiz_night_server/src/game/room_service.dart';
import 'package:quiz_night_server/src/generated/protocol.dart';
import 'package:test/test.dart';

import 'game_flow_test.dart';
import 'test_tools/serverpod_test_tools.dart';

void main() {
  withServerpod('Given a round has had its cut', (sb, endpoints) {
    test('when someone joins then they watch as a spectator, marked as a late '
        'joiner', () async {
      final g = await setUpGame(
        sb,
        endpoints,
        players: 6,
        config: RoomConfig(questionsPerRound: 1, finalistTarget: 2),
      );
      await endpoints.room.startGame(sb, g.code, g.hostToken);
      final q = await currentQuestion(sb, g.code);
      for (var i = 0; i < 6; i++) {
        await endpoints.answer.submitAnswer(
          sb,
          g.players[i].playerToken,
          q.id!,
          i < 3 ? q.correctIndex : wrong(q),
        );
      }
      await endpoints.room.endRound(sb, g.code, g.hostToken);

      final late = await endpoints.room.joinRoom(sb, g.code, 'Late');
      final p = await playerOf(sb, late);
      expect(p.status, PlayerStatus.eliminated);
      expect(p.eliminatedInRound, 0, reason: '0 means joined late');
    });
  });

  withServerpod('Given the 3-2-1 before each question', (sb, endpoints) {
    setUp(() => RoomService.getReady = const Duration(seconds: 3));
    tearDown(() => RoomService.getReady = Duration.zero);

    test('when a question starts then answers open after the countdown, and '
        'every screen is told when', () async {
      final g = await setUpGame(sb, endpoints, players: 2);
      final before = DateTime.now().toUtc();
      await endpoints.room.startGame(sb, g.code, g.hostToken);
      final q = await currentQuestion(sb, g.code);

      final state = await endpoints.room.watchRoom(sb, g.code).first;
      final starts = state.questionStartsAt!;
      expect(
        starts.difference(before).inMilliseconds,
        greaterThanOrEqualTo(2900),
      );
      expect(
        state.questionEndsAt!.difference(starts),
        Duration(seconds: q.timeLimitSeconds),
      );

      await expectLater(
        endpoints.answer.submitAnswer(
          sb,
          g.players.first.playerToken,
          q.id!,
          q.correctIndex,
        ),
        throwsQuiz(QuizErrorCode.tooEarly),
      );
    });
  });
}
