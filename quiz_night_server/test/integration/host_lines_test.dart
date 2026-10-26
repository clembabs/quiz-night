import 'package:quiz_night_server/src/ai/host_lines.dart';
import 'package:quiz_night_server/src/generated/protocol.dart';
import 'package:test/test.dart';

import '../unit/host_lines_test.dart' show FakeWriter;
import 'game_flow_test.dart';
import 'test_tools/serverpod_test_tools.dart';

void main() {
  late FakeWriter fake;
  setUp(() => HostLines.writer = fake = FakeWriter());
  tearDown(() => HostLines.writer = null);

  withServerpod('Given a round where three answer wrong', (sb, endpoints) {
    late Game g;
    late Question q;

    setUp(() async {
      g = await setUpGame(
        sb,
        endpoints,
        players: 6,
        config: RoomConfig(questionsPerRound: 1, finalistTarget: 2),
      );
      await endpoints.room.startGame(sb, g.code, g.hostToken);
      q = await currentQuestion(sb, g.code);
      for (var i = 0; i < 6; i++) {
        await endpoints.answer.submitAnswer(
          sb,
          g.players[i].playerToken,
          q.id!,
          i < 3 ? q.correctIndex : wrong(q),
        );
      }
    });

    test('when the cut runs then each eliminated player gets the AI line, '
        'told the question they missed', () async {
      // Nicknames are P0..P5.
      fake.lines = {
        for (final (i, p) in g.players.indexed) p.playerId: 'P$i goes home.',
      };
      await endpoints.room.endRound(sb, g.code, g.hostToken);

      final out = await Player.db.find(
        sb.build(),
        where: (t) => t.status.equals(PlayerStatus.eliminated),
      );
      expect(out, hasLength(2));
      for (final p in out) {
        expect(p.exitLine, '${p.nickname} goes home.');
      }
      final asked = fake.requests.single;
      expect(
        asked.map((s) => s.playerId).toSet(),
        out.map((p) => p.id).toSet(),
      );
      expect(asked.first.missedQuestion, q.text);
      expect(asked.first.missedAnswer, q.options[q.correctIndex]);

      final state = await endpoints.room.watchRoom(sb, g.code).first;
      final views = state.players.where((p) => out.any((o) => o.id == p.id));
      expect(views.map((v) => v.exitLine), everyElement(endsWith('home.')));
      expect(
        state.players
            .where((p) => p.status != PlayerStatus.eliminated)
            .map((p) => p.exitLine),
        everyElement(isNull),
      );
    });

    test('when the AI fails then built-in lines are written instead, and a '
        'second endRound changes nothing', () async {
      fake.failWith = Exception('quota');
      await endpoints.room.endRound(sb, g.code, g.hostToken);
      await endpoints.room.endRound(sb, g.code, g.hostToken);

      final out = await Player.db.find(
        sb.build(),
        where: (t) => t.status.equals(PlayerStatus.eliminated),
      );
      for (final p in out) {
        expect(p.exitLine, contains(p.nickname));
      }
      expect(fake.requests, hasLength(1));
    });

    test('when the host rescues a player then their line is cleared', () async {
      await endpoints.room.endRound(sb, g.code, g.hostToken);
      final out = (await Player.db.find(
        sb.build(),
        where: (t) => t.status.equals(PlayerStatus.eliminated),
      )).first;
      expect(out.exitLine, isNotNull);

      await endpoints.room.useWildcard(sb, g.code, g.hostToken, out.id!);
      expect((await Player.db.findById(sb.build(), out.id!))!.exitLine, isNull);
    });
  });

  withServerpod('Given sudden death', (sb, endpoints) {
    test(
      'when a wrong answer knocks a player out then they get a line too',
      () async {
        final g = await setUpGame(
          sb,
          endpoints,
          players: 4,
          config: RoomConfig(
            eliminationRule: EliminationRule.suddenDeath,
            questionsPerRound: 2,
            finalistTarget: 2,
          ),
        );
        await endpoints.room.startGame(sb, g.code, g.hostToken);
        final q = await currentQuestion(sb, g.code);
        for (var i = 0; i < 4; i++) {
          await endpoints.answer.submitAnswer(
            sb,
            g.players[i].playerToken,
            q.id!,
            i == 3 ? wrong(q) : q.correctIndex,
          );
        }

        final p3 = await playerOf(sb, g.players[3]);
        expect(p3.status, PlayerStatus.eliminated);
        expect(p3.exitLine, contains('P3'));
      },
    );
  });
}
