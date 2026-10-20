import 'package:flutter_test/flutter_test.dart';
import 'package:quiz_night_client/quiz_night_client.dart';
import 'package:quiz_night_flutter/features/room/round_logic.dart';
import 'package:quiz_night_flutter/widgets/qn/answer_button.dart';

import '../fakes/fakes.dart';

void main() {
  group('Given hostStepFor', () {
    test('when in the lobby then the step is start', () {
      expect(hostStepFor(roomState()), HostStep.startGame);
    });

    test('when a question is open then the step is reveal', () {
      final room = roomState(status: RoomStatus.question, question: question());
      expect(hostStepFor(room), HostStep.reveal);
    });

    test('when revealed mid-round then the step is next question', () {
      final room = roomState(
        status: RoomStatus.reveal,
        question: question(indexInRound: 2, revealed: true),
      );
      expect(hostStepFor(room), HostStep.nextQuestion);
    });

    test('when the last question of the round is revealed then end round', () {
      final room = roomState(
        status: RoomStatus.reveal,
        questionsPerRound: 3,
        question: question(indexInRound: 3, revealed: true),
      );
      expect(hostStepFor(room), HostStep.endRound);
    });

    test('when sudden death leaves only finalists then end round early', () {
      final room = roomState(
        status: RoomStatus.reveal,
        rule: EliminationRule.suddenDeath,
        finalistTarget: 2,
        question: question(indexInRound: 1, revealed: true),
        players: [
          player(1, 'A'),
          player(2, 'B'),
          player(3, 'C', status: PlayerStatus.eliminated),
        ],
      );
      expect(hostStepFor(room), HostStep.endRound);
    });

    test('when a cut did not decide finalists then next round', () {
      final room = roomState(
        status: RoomStatus.elimination,
        lastElimination: cut(),
      );
      expect(hostStepFor(room), HostStep.nextRound);
    });

    test('when a cut decided finalists then start the final', () {
      final room = roomState(
        status: RoomStatus.elimination,
        lastElimination: cut(finalists: true),
      );
      expect(hostStepFor(room), HostStep.startFinal);
    });

    test('when finished then there is no step', () {
      expect(
        hostStepFor(roomState(status: RoomStatus.finished)),
        HostStep.none,
      );
    });
  });

  group('Given a leaderboard', () {
    final room = roomState(
      players: [
        player(1, 'Low', score: 100),
        player(2, 'Out', score: 900, status: PlayerStatus.eliminated),
        player(3, 'High', score: 500),
        player(4, 'TieLate', score: 100),
      ],
    );

    test('when ranking then eliminated players are left out', () {
      expect(leaderboard(room).map((p) => p.nickname), [
        'High',
        'Low',
        'TieLate',
      ]);
    });

    test('when asking a rank then it is 1-based, null if eliminated', () {
      expect(rankOf(room, 3), 1);
      expect(rankOf(room, 4), 3);
      expect(rankOf(room, 2), isNull);
    });
  });

  group('Given answer counting', () {
    test('when some active players answered then only they count', () {
      final room = roomState(
        players: [
          player(1, 'A', hasAnswered: true),
          player(2, 'B'),
          player(
            3,
            'Spectator',
            hasAnswered: true,
            status: PlayerStatus.eliminated,
          ),
        ],
      );
      expect(answeredCount(room), 1);
      expect(activeCount(room), 2);
    });
  });

  group('Given timeLeft', () {
    final endsAt = DateTime.utc(2026, 1, 1, 12, 0, 20);

    test('when clocks agree then it is the plain difference', () {
      expect(
        timeLeft(
          endsAt: endsAt,
          clockOffset: Duration.zero,
          localNow: DateTime.utc(2026, 1, 1, 12, 0, 5),
        ),
        const Duration(seconds: 15),
      );
    });

    test('when the phone clock is 3s behind then it follows the server', () {
      // Server time = local + 3s.
      expect(
        timeLeft(
          endsAt: endsAt,
          clockOffset: const Duration(seconds: 3),
          localNow: DateTime.utc(2026, 1, 1, 12, 0, 5),
        ),
        const Duration(seconds: 12),
      );
    });

    test('when past the deadline then it is zero, never negative', () {
      expect(
        timeLeft(
          endsAt: endsAt,
          clockOffset: Duration.zero,
          localNow: DateTime.utc(2026, 1, 1, 12, 1),
        ),
        Duration.zero,
      );
    });
  });

  group('Given answer looks', () {
    test('when nothing is picked then all are idle', () {
      expect(
        answerLookFor(index: 0, correctIndex: null, picked: null),
        AnswerLook.idle,
      );
    });

    test('when one is picked then it is selected and others dim', () {
      expect(
        answerLookFor(index: 2, correctIndex: null, picked: 2),
        AnswerLook.selected,
      );
      expect(
        answerLookFor(index: 0, correctIndex: null, picked: 2),
        AnswerLook.dimmed,
      );
    });

    test('when revealed then the answer is correct, a wrong pick is wrong '
        'and the rest dim', () {
      expect(
        answerLookFor(index: 1, correctIndex: 1, picked: 2),
        AnswerLook.correct,
      );
      expect(
        answerLookFor(index: 2, correctIndex: 1, picked: 2),
        AnswerLook.wrong,
      );
      expect(
        answerLookFor(index: 3, correctIndex: 1, picked: 2),
        AnswerLook.dimmed,
      );
    });

    test('when labelling then options are A to D', () {
      expect([0, 1, 2, 3].map(optionLetter), ['A', 'B', 'C', 'D']);
    });
  });

  group('Given a player verdict', () {
    test('when points were scored then it is correct', () {
      expect(
        verdictFor(me: player(1, 'A', lastPoints: 800), myChoice: 1),
        PlayerVerdict.correct,
      );
    });

    test('when an answer scored zero then it is wrong', () {
      expect(
        verdictFor(me: player(1, 'A', lastPoints: 0), myChoice: 0),
        PlayerVerdict.wrong,
      );
    });

    test('when nothing was answered then it is no answer', () {
      expect(
        verdictFor(me: player(1, 'A'), myChoice: null),
        PlayerVerdict.noAnswer,
      );
    });
  });

  group('Given a cut outcome', () {
    final room = roomState(status: RoomStatus.elimination, round: 2);

    test('when still active then survived', () {
      expect(cutOutcomeFor(room, player(1, 'A')), CutOutcome.survived);
    });

    test('when made the final then finalist', () {
      expect(
        cutOutcomeFor(room, player(1, 'A', status: PlayerStatus.finalist)),
        CutOutcome.finalist,
      );
    });

    test('when eliminated this round then out', () {
      final me = player(
        1,
        'A',
        status: PlayerStatus.eliminated,
        eliminatedInRound: 2,
      );
      expect(cutOutcomeFor(room, me), CutOutcome.out);
    });

    test('when eliminated earlier then already out', () {
      final me = player(
        1,
        'A',
        status: PlayerStatus.eliminated,
        eliminatedInRound: 1,
      );
      expect(cutOutcomeFor(room, me), CutOutcome.alreadyOut);
    });
  });
}
