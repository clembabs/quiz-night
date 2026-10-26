import 'package:fake_async/fake_async.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:quiz_night_flutter/features/room/cut_reveal/cut_reveal_scope.dart';
import 'package:quiz_night_flutter/features/room/cut_reveal/reveal_sequence_cubit.dart';

import '../fakes/fakes.dart';

const intro = Duration(seconds: 2);
const step = Duration(seconds: 1);
const lastHold = Duration(seconds: 3);

RevealSequenceCubit sequence(int total) => RevealSequenceCubit(
  total: total,
  intro: intro,
  step: step,
  lastHold: lastHold,
);

void main() {
  group('Given a cut with three players out', () {
    test('when time passes then names appear one by one, then done', () {
      fakeAsync((time) {
        final cubit = sequence(3)..start();
        expect(cubit.state.phase, RevealPhase.intro);
        expect(cubit.state.revealed, 0);

        time.elapse(intro);
        expect(cubit.state.phase, RevealPhase.revealing);
        expect(cubit.state.revealed, 1);

        time.elapse(step);
        expect(cubit.state.revealed, 2);
        expect(cubit.state.waitingForLast, isTrue);

        // The last name waits longer.
        time.elapse(step);
        expect(cubit.state.revealed, 2);
        time.elapse(lastHold - step);
        expect(cubit.state.revealed, 3);
        expect(cubit.state.waitingForLast, isFalse);
        expect(cubit.state.isDone, isFalse, reason: 'holds on the last name');

        time.elapse(step);
        expect(cubit.state.isDone, isTrue);
        cubit.close();
      });
    });

    test('when skipping then everything is revealed at once', () {
      fakeAsync((time) {
        final cubit = sequence(3)..start();
        cubit.skip();
        expect(cubit.state.isDone, isTrue);
        expect(cubit.state.revealed, 3);

        // The pending timer must not move it backwards.
        time.elapse(const Duration(seconds: 10));
        expect(cubit.state.revealed, 3);
        cubit.close();
      });
    });

    test('when closed mid-reveal then no further states are emitted', () {
      fakeAsync((time) {
        final cubit = sequence(3)..start();
        time.elapse(intro);
        cubit.close();
        time.elapse(const Duration(seconds: 10));
        expect(cubit.state.revealed, 1);
      });
    });
  });

  group('Given a cut with nobody out', () {
    test('when the intro ends then it is done', () {
      fakeAsync((time) {
        final cubit = sequence(0)..start();
        time.elapse(intro);
        expect(cubit.state.isDone, isTrue);
        cubit.close();
      });
    });
  });

  group('Given fateRevealed', () {
    final event = cut(out: [7, 8]);
    RevealSequenceState at(int revealed, {bool done = false}) =>
        RevealSequenceState(
          phase: done ? RevealPhase.done : RevealPhase.revealing,
          revealed: revealed,
          total: 2,
        );

    test('when my name has not come up yet then it is hidden', () {
      expect(fateRevealed(event: event, myId: 8, sequence: at(1)), isFalse);
    });

    test('when my name has come up then it is known', () {
      expect(fateRevealed(event: event, myId: 7, sequence: at(1)), isTrue);
    });

    test('when I am safe then it is only known once the reveal is done', () {
      expect(fateRevealed(event: event, myId: 1, sequence: at(2)), isFalse);
      expect(
        fateRevealed(event: event, myId: 1, sequence: at(2, done: true)),
        isTrue,
      );
    });
  });
}
