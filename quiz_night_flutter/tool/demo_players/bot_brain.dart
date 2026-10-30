import 'dart:math';

import 'package:quiz_night_client/quiz_night_client.dart';

/// Something a demo player does, [delay] after the state that prompted it.
sealed class BotMove {
  final Duration delay;
  const BotMove(this.delay);
}

class AnswerMove extends BotMove {
  final int questionId;
  final int choice;
  const AnswerMove(super.delay, this.questionId, this.choice);
}

class BuzzMove extends BotMove {
  final int questionId;
  const BuzzMove(super.delay, this.questionId);
}

class BuzzAnswerMove extends BotMove {
  final int questionId;
  final int choice;
  const BuzzAnswerMove(super.delay, this.questionId, this.choice);
}

class BackMove extends BotMove {
  final int finalistId;
  const BackMove(super.delay, this.finalistId);
}

/// One demo player's choices. It never sees the right answer (the server
/// keeps it until the reveal), so it guesses, like a real player might.
class BotBrain {
  final int playerId;
  final Random _random;

  /// Chance of buzzing on a final question; not every finalist dives in.
  final double buzzChance;

  final _answered = <int>{};
  final _buzzed = <int>{};
  final _buzzAnswered = <int>{};
  var _backed = false;

  BotBrain(this.playerId, {Random? random, this.buzzChance = 0.6})
    : _random = random ?? Random();

  /// The moves [state] calls for that this player hasn't made yet.
  List<BotMove> movesFor(RoomState state) {
    final me = state.players.where((p) => p.id == playerId).firstOrNull;
    if (me == null || me.left) return const [];
    final q = state.question;
    final moves = <BotMove>[];

    // Answers open after the 3-2-1; wait for it on the server's clock.
    Duration untilOpen() {
      final starts = state.questionStartsAt;
      if (starts == null) return Duration.zero;
      final left = starts.difference(state.serverTime);
      return left.isNegative ? Duration.zero : left;
    }

    if (state.status == RoomStatus.question &&
        q != null &&
        !q.isFinal &&
        !me.hasAnswered &&
        _answered.add(q.id)) {
      // Most answer within the first two thirds, some cut it close.
      final ms = 1500 + _random.nextInt(q.timeLimitSeconds * 650);
      moves.add(
        AnswerMove(
          untilOpen() + Duration(milliseconds: ms),
          q.id,
          _random.nextInt(q.options.length),
        ),
      );
    }

    if (state.status == RoomStatus.buzzerFinal &&
        q != null &&
        q.isFinal &&
        q.correctIndex == null) {
      final holding = state.buzzerHolderId == playerId;
      if (holding && _buzzAnswered.add(q.id)) {
        moves.add(
          BuzzAnswerMove(
            Duration(milliseconds: 1500 + _random.nextInt(2500)),
            q.id,
            _random.nextInt(q.options.length),
          ),
        );
      } else if (me.status == PlayerStatus.finalist &&
          !me.lockedOut &&
          state.buzzerHolderId == null &&
          _buzzed.add(q.id) &&
          _random.nextDouble() < buzzChance) {
        moves.add(
          BuzzMove(
            untilOpen() + Duration(milliseconds: 2000 + _random.nextInt(6000)),
            q.id,
          ),
        );
      }
    }

    // Knocked out and the finalists are known: back one before the final.
    final finalists = state.players
        .where((p) => p.status == PlayerStatus.finalist)
        .toList();
    if (me.status == PlayerStatus.eliminated &&
        finalists.isNotEmpty &&
        state.finalQuestionsPlayed == 0 &&
        !_backed) {
      _backed = true;
      moves.add(
        BackMove(
          Duration(milliseconds: 3000 + _random.nextInt(7000)),
          finalists[_random.nextInt(finalists.length)].id,
        ),
      );
    }
    return moves;
  }

  /// Whether [move] still makes sense in [state], checked just before it runs.
  static bool stillValid(BotMove move, RoomState state) {
    final q = state.question;
    return switch (move) {
      AnswerMove(:final questionId) =>
        state.status == RoomStatus.question && q?.id == questionId,
      BuzzMove(:final questionId) =>
        state.status == RoomStatus.buzzerFinal &&
            q?.id == questionId &&
            q?.correctIndex == null &&
            state.buzzerHolderId == null,
      BuzzAnswerMove(:final questionId) =>
        state.status == RoomStatus.buzzerFinal && q?.id == questionId,
      BackMove() => state.finalQuestionsPlayed == 0,
    };
  }
}

/// Names for the demo players; real-sounding so the big screen looks right.
const botNames = [
  'Ada', 'Bolanle', 'Chidi', 'Dayo', 'Efe', 'Funmi', 'Gbenga', 'Hadiza', //
  'Ifeoma', 'Jide', 'Kemi', 'Lola', 'Musa', 'Ngozi', 'Ola',
];
