import 'package:flutter_test/flutter_test.dart';
import 'package:quiz_night_client/quiz_night_client.dart';
import 'package:quiz_night_flutter/features/room/final/result_summary.dart';

import '../fakes/fakes.dart';

const f = PlayerStatus.finalist;
const out = PlayerStatus.eliminated;

void main() {
  /// Two cut rounds, then a final won by Ada. Dee backed Ada, Eve backed Bo.
  RoomState finished() => roomState(
    status: RoomStatus.finished,
    round: 3,
    lastElimination: cut(round: 2, out: [4], finalists: true),
    players: [
      player(1, 'Bo', status: f, finalScore: 1000, score: 3000),
      player(2, 'Ada', status: f, finalScore: 2000, score: 1000),
      player(3, 'Cy', status: f, finalScore: 500, score: 2000),
      player(
        4,
        'Dee',
        status: out,
        eliminatedInRound: 2,
        score: 800,
        backedPlayerId: 2,
        exitLine: 'Dee goes home still thinking about Ogun.',
      ),
      player(5, 'Eve', status: out, eliminatedInRound: 1, backedPlayerId: 1),
      player(6, 'Fay', status: out, eliminatedInRound: 1),
    ],
  );

  group('Given a finished game', () {
    test('when the winner looks then Champion, first of six, every round '
        'survived, round and final points', () {
      final r = resultFor(finished(), finished().players[1]);
      expect(r.place, 1);
      expect(r.playerCount, 6);
      expect(r.title, 'Champion');
      expect(r.champion, isTrue);
      expect(r.finalist, isTrue);
      expect(r.roundsSurvived, 2);
      expect(r.points, 1000);
      expect(r.finalPoints, 2000);
      expect(r.backedWinner, isNull);
      expect(r.hostLine, isNull);
    });

    test('when another finalist looks then Finalist, not champion', () {
      final r = resultFor(finished(), finished().players.first);
      expect(r.title, 'Finalist');
      expect(r.champion, isFalse);
      expect(r.place, 2);
    });

    test('when a player who backed the winner looks then their round, the '
        'backing and the host line', () {
      final r = resultFor(finished(), finished().players[3]);
      expect(r.title, 'Out in round 2');
      expect(r.finalist, isFalse);
      expect(r.finalPoints, isNull);
      expect(r.roundsSurvived, 1);
      expect(r.points, 800);
      expect(r.backedWinner, isTrue);
      expect(r.hostLine, 'Dee goes home still thinking about Ogun.');
    });

    test('when a player backed the wrong finalist, or nobody, then it says '
        'so, or nothing', () {
      expect(resultFor(finished(), finished().players[4]).backedWinner, false);
      expect(resultFor(finished(), finished().players[5]).backedWinner, null);
      expect(resultFor(finished(), finished().players[5]).roundsSurvived, 0);
    });
  });

  group('Given a game that ran out of time', () {
    test('when a player still in looks then it says time ran out', () {
      final room = roomState(
        status: RoomStatus.finished,
        round: 2,
        players: [
          player(1, 'Ada', score: 900),
          player(2, 'Bo', status: out, eliminatedInRound: 1),
        ],
      ).copyWith(endReason: RoomEndReason.timeUp);
      final r = resultFor(room, room.players.first);
      expect(r.title, "Still in at time's up");
      expect(r.roundsSurvived, 1);
      expect(r.points, 900);
    });
  });

  group('Given the share text', () {
    final site = Uri.parse('https://quiznight.serverpod.space/');

    test('when the champion shares then it says they won, with the site', () {
      final text = shareTextFor(
        resultFor(finished(), finished().players[1]),
        site,
      );
      expect(text, startsWith('I won Quiz Night! 🏆 (1st of 6)'));
      expect(text, contains('Survived 2 rounds.'));
      expect(text, endsWith('quiznight.serverpod.space'));
    });

    test('when a backer of the winner shares then it brags about that', () {
      final text = shareTextFor(
        resultFor(finished(), finished().players[3]),
        site,
      );
      expect(text, startsWith('I finished 4th of 6 at Quiz Night.'));
      expect(text, contains('Survived 1 round.'));
      expect(text, contains('I backed the winner.'));
    });
  });
}
