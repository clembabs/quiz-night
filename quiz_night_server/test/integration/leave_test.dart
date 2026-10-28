import 'package:quiz_night_server/src/generated/protocol.dart';
import 'package:test/test.dart';

import 'game_flow_test.dart';
import 'test_tools/serverpod_test_tools.dart';

void main() {
  withServerpod('Given a question is open with three players', (
    sb,
    endpoints,
  ) {
    late Game g;
    late Question q;

    setUp(() async {
      g = await setUpGame(
        sb,
        endpoints,
        players: 3,
        config: RoomConfig(questionsPerRound: 2, finalistTarget: 2),
      );
      await endpoints.room.startGame(sb, g.code, g.hostToken);
      q = await currentQuestion(sb, g.code);
    });

    test('when one leaves and the others answer then the question reveals '
        'without waiting for them', () async {
      await endpoints.room.leaveRoom(sb, g.code, g.players[2].playerToken);
      for (final p in g.players.take(2)) {
        await endpoints.answer.submitAnswer(
          sb,
          p.playerToken,
          q.id!,
          q.correctIndex,
        );
      }
      expect((await roomOf(sb, g.code)).status, RoomStatus.reveal);

      final state = await endpoints.room.watchRoom(sb, g.code).first;
      final left = state.players.firstWhere(
        (p) => p.id == g.players[2].playerId,
      );
      expect(left.left, isTrue);
      expect(
        state.players.where((p) => p.id != left.id).map((p) => p.left),
        everyElement(isFalse),
      );
    });

    test('when the last one still to answer leaves then it reveals', () async {
      for (final p in g.players.take(2)) {
        await endpoints.answer.submitAnswer(
          sb,
          p.playerToken,
          q.id!,
          q.correctIndex,
        );
      }
      expect((await roomOf(sb, g.code)).status, RoomStatus.question);
      await endpoints.room.leaveRoom(sb, g.code, g.players[2].playerToken);
      expect((await roomOf(sb, g.code)).status, RoomStatus.reveal);
    });

    test('when a player who left rejoins then they are back in', () async {
      final p = g.players[2];
      await endpoints.room.leaveRoom(sb, g.code, p.playerToken);
      expect((await playerOf(sb, p)).leftAt, isNotNull);
      await endpoints.room.rejoin(sb, g.code, p.playerToken);
      expect((await playerOf(sb, p)).leftAt, isNull);
    });
  });
}
