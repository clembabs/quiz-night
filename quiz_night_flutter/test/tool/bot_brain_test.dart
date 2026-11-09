import 'dart:math';

import 'package:flutter_test/flutter_test.dart';
import 'package:quiz_night_client/quiz_night_client.dart';

import '../../tool/demo_players/bot_brain.dart';
import '../fakes/fakes.dart';

const f = PlayerStatus.finalist;
const out = PlayerStatus.eliminated;

BotBrain brain({double buzzChance = 1}) =>
    BotBrain(1, random: Random(7), buzzChance: buzzChance);

void main() {
  group('Given a round question', () {
    final now = DateTime.utc(2026, 1, 1);
    final asked = roomState(
      status: RoomStatus.question,
      players: [player(1, 'Ada')],
      question: question(),
      serverTime: now,
    ).copyWith(questionStartsAt: now.add(const Duration(seconds: 3)));

    test('when it opens then the bot answers once, after the 3-2-1', () {
      final b = brain();
      final moves = b.movesFor(asked);
      expect(moves, hasLength(1));
      final move = moves.single as AnswerMove;
      expect(move.questionId, 10);
      expect(move.choice, inInclusiveRange(0, 3));
      expect(move.delay, greaterThan(const Duration(seconds: 3)));
      expect(move.delay, lessThan(const Duration(seconds: 3 + 20)));
      // A second snapshot of the same question asks for nothing new.
      expect(b.movesFor(asked), isEmpty);
    });

    test('when the bot has left then it does nothing', () {
      final gone = asked.copyWith(
        players: [player(1, 'Ada').copyWith(left: true)],
      );
      expect(brain().movesFor(gone), isEmpty);
    });

    test('when it is eliminated then it still answers, for a shadow score', () {
      final spectator = asked.copyWith(
        players: [player(1, 'Ada', status: out)],
      );
      expect(brain().movesFor(spectator).single, isA<AnswerMove>());
    });

    test('when the reveal arrives first then the answer is dropped', () {
      final move = brain().movesFor(asked).single;
      expect(BotBrain.stillValid(move, asked), isTrue);
      expect(
        BotBrain.stillValid(
          move,
          asked.copyWith(status: RoomStatus.reveal),
        ),
        isFalse,
      );
    });
  });

  group('Given the buzzer final', () {
    RoomState finalQ({int? holder, bool lockedOut = false}) => roomState(
      status: RoomStatus.buzzerFinal,
      players: [
        player(1, 'Ada', status: f, lockedOut: lockedOut),
        player(2, 'Bolanle', status: f),
      ],
      question: question(id: 30, isFinal: true),
      buzzerHolderId: holder,
    );

    test('when the buzzer is free then the finalist buzzes once', () {
      final b = brain();
      expect(b.movesFor(finalQ()).single, isA<BuzzMove>());
      expect(b.movesFor(finalQ()), isEmpty);
    });

    test('when someone else holds it then the buzz is dropped', () {
      final move = brain().movesFor(finalQ()).single;
      expect(BotBrain.stillValid(move, finalQ(holder: 2)), isFalse);
    });

    test('when the bot holds the buzzer then it answers once', () {
      final b = brain();
      final move = b.movesFor(finalQ(holder: 1)).single as BuzzAnswerMove;
      expect(move.questionId, 30);
      expect(b.movesFor(finalQ(holder: 1)), isEmpty);
    });

    test('when locked out then it does not buzz again', () {
      expect(brain().movesFor(finalQ(lockedOut: true)), isEmpty);
    });

    test('when it decides to sit one out then it does not buzz', () {
      expect(brain(buzzChance: 0).movesFor(finalQ()), isEmpty);
    });
  });

  group('Given the bot is knocked out and the finalists are known', () {
    RoomState cut({int played = 0}) => roomState(
      status: RoomStatus.elimination,
      players: [
        player(1, 'Ada', status: out),
        player(2, 'Bolanle', status: f),
        player(3, 'Chidi', status: f),
      ],
      finalQuestionsPlayed: played,
    );

    test('when the final has not started then it backs one finalist once', () {
      final b = brain();
      final move = b.movesFor(cut()).single as BackMove;
      expect(move.finalistId, anyOf(2, 3));
      expect(b.movesFor(cut()), isEmpty);
    });

    test('when the final has started then it is too late', () {
      expect(brain().movesFor(cut(played: 1)), isEmpty);
    });
  });
}
