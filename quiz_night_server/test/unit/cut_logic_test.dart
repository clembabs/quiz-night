import 'package:quiz_night_server/src/game/cut_logic.dart';
import 'package:quiz_night_server/src/generated/protocol.dart';
import 'package:test/test.dart';

List<CutCandidate> players(List<int> scores, {List<int>? times}) => [
  for (var i = 0; i < scores.length; i++)
    CutCandidate(
      id: i + 1,
      score: scores[i],
      totalCorrectAnswerMs: times?[i] ?? 0,
    ),
];

int survivors(
  int active, {
  EliminationRule rule = EliminationRule.bottomPercent,
  double percent = 0.3,
  int target = 3,
  int starting = 20,
  int rounds = 3,
  int round = 1,
}) => survivorsAfterRound(
  activeCount: active,
  rule: rule,
  eliminationPercent: percent,
  finalistTarget: target,
  startingPlayers: starting,
  roundsBeforeFinal: rounds,
  round: round,
);

void main() {
  group('Given ranking', () {
    test('when scores differ then higher score ranks first', () {
      final ranked = rankCandidates(players([100, 300, 200]));
      expect(ranked.map((c) => c.id), [2, 3, 1]);
    });

    test('when scores tie then faster total time ranks first', () {
      final ranked = rankCandidates(
        players([500, 500, 500], times: [3000, 1000, 2000]),
      );
      expect(ranked.map((c) => c.id), [2, 3, 1]);
    });

    test('when score and time tie then lower id ranks first', () {
      final ranked = rankCandidates(players([500, 500]));
      expect(ranked.map((c) => c.id), [1, 2]);
    });
  });

  group('Given bottomPercent at 30%', () {
    test('when 10 active then 7 survive', () {
      expect(survivors(10), 7);
    });

    test('when 20 active then 14 survive', () {
      expect(survivors(20), 14);
    });

    test('when 4 active and target 3 then 3 survive', () {
      expect(survivors(4), 3);
    });

    test('when 5 active and target 3 then never cuts below target', () {
      // 30% of 5 rounds to 2 -> 3, exactly the target.
      expect(survivors(5), 3);
    });

    test('when percent rounds to zero then still cuts one', () {
      expect(survivors(6, percent: 0.05), 5);
    });

    test('when active is already at target then nobody is cut', () {
      expect(survivors(3), 3);
    });

    test('when percent is huge then stops at target', () {
      expect(survivors(10, percent: 0.9), 3);
    });
  });

  group('Given the min-2 rule', () {
    test('when target is 1 then at least 2 survive', () {
      expect(survivors(5, target: 1, percent: 0.9), 2);
    });

    test('when only 2 active then nobody is cut', () {
      expect(survivors(2, target: 1), 2);
    });

    test('when only 1 active then nobody is cut', () {
      expect(survivors(1, target: 1), 1);
    });
  });

  group('Given autoScaled with 20 players, 3 rounds, target 3', () {
    test('when computing keep fraction then about 53% survive per round', () {
      final keep = autoScaledKeepFraction(
        startingPlayers: 20,
        finalistTarget: 3,
        roundsBeforeFinal: 3,
      );
      expect(keep, closeTo(0.5313, 0.001));
    });

    test('when playing all rounds then goes 20 -> 11 -> 6 -> 3', () {
      var active = 20;
      final history = [active];
      for (var round = 1; round <= 3; round++) {
        active = survivors(
          active,
          rule: EliminationRule.autoScaled,
          round: round,
        );
        history.add(active);
      }
      expect(history, [20, 11, 6, 3]);
    });

    test('when more rounds than planned then cuts straight to target', () {
      expect(survivors(6, rule: EliminationRule.autoScaled, round: 4), 3);
    });

    test('when a player was rescued then still cuts at least one', () {
      // Schedule says 11 after round 1; with only 11 active we still cut.
      expect(survivors(11, rule: EliminationRule.autoScaled, round: 1), 10);
    });
  });

  group('Given autoScaled with a small room', () {
    test('when 6 players and 3 rounds then reaches 3 at the end', () {
      var active = 6;
      for (var round = 1; round <= 3; round++) {
        active = survivors(
          active,
          rule: EliminationRule.autoScaled,
          starting: 6,
          round: round,
        );
      }
      expect(active, 3);
    });

    test('when starting at the target then nobody is cut', () {
      expect(survivors(3, rule: EliminationRule.autoScaled, starting: 3), 3);
    });
  });

  group('Given suddenDeath rule at end of round', () {
    test('when computing round cut then nobody is cut', () {
      expect(survivors(10, rule: EliminationRule.suddenDeath), 10);
    });
  });

  group('Given cutToSize', () {
    test('when cutting then lowest scores go, reveal order worst first', () {
      final result = cutToSize(players([400, 100, 300, 200, 500]), 3);
      expect(result.survivorIds, [5, 1, 3]);
      expect(result.eliminatedIds, [2, 4]);
      expect(result.tieBrokenBySpeed, isFalse);
    });

    test('when tied at the cutoff then faster player survives', () {
      final result = cutToSize(
        players([900, 500, 500], times: [1000, 6000, 4000]),
        2,
      );
      expect(result.survivorIds, [1, 3]);
      expect(result.eliminatedIds, [2]);
      expect(result.tieBrokenBySpeed, isTrue);
    });

    test('when tied but not at the cutoff then no tie is reported', () {
      final result = cutToSize(players([900, 900, 100]), 2);
      expect(result.tieBrokenBySpeed, isFalse);
    });

    test('when asked to keep more than exist then nobody is cut', () {
      final result = cutToSize(players([1, 2]), 5);
      expect(result.eliminatedIds, isEmpty);
    });
  });

  group('Given computeRoundCut with everyone on zero', () {
    test('when cutting then still never eliminates everyone', () {
      final result = computeRoundCut(
        active: players([0, 0, 0, 0]),
        rule: EliminationRule.bottomPercent,
        eliminationPercent: 1.0,
        finalistTarget: 1,
        startingPlayers: 4,
        roundsBeforeFinal: 3,
        round: 1,
      );
      expect(result.survivorIds, hasLength(2));
      expect(result.eliminatedIds, hasLength(2));
    });
  });

  group('Given sudden death after a question', () {
    test('when some are wrong then all wrong players go out', () {
      final result = computeSuddenDeathCut(
        active: players([100, 200, 300, 400]),
        correctIds: {1, 2},
      );
      expect(result.survivorIds.toSet(), {1, 2});
      expect(result.eliminatedIds, [3, 4]);
    });

    test('when everyone is wrong then the top 2 are spared', () {
      final result = computeSuddenDeathCut(
        active: players([100, 200, 300, 400]),
        correctIds: {},
      );
      expect(result.survivorIds, [4, 3]);
      expect(result.eliminatedIds, [1, 2]);
    });

    test('when only one is right then the best wrong player is spared', () {
      final result = computeSuddenDeathCut(
        active: players([100, 200, 300]),
        correctIds: {1},
      );
      expect(result.survivorIds.toSet(), {1, 3});
      expect(result.eliminatedIds, [2]);
    });
  });

  group('Given scoring', () {
    test('when answering instantly then scores 1000', () {
      expect(
        pointsForAnswer(correct: true, elapsedMs: 0, timeLimitSeconds: 20),
        1000,
      );
    });

    test('when answering at half time then scores 500', () {
      expect(
        pointsForAnswer(correct: true, elapsedMs: 10000, timeLimitSeconds: 20),
        500,
      );
    });

    test('when answering at the buzzer then floors at 500', () {
      expect(
        pointsForAnswer(correct: true, elapsedMs: 19900, timeLimitSeconds: 20),
        500,
      );
    });

    test('when answering quickly then scales with time left', () {
      expect(
        pointsForAnswer(correct: true, elapsedMs: 4000, timeLimitSeconds: 20),
        800,
      );
    });

    test('when wrong then scores 0', () {
      expect(
        pointsForAnswer(correct: false, elapsedMs: 0, timeLimitSeconds: 20),
        0,
      );
    });
  });
}
