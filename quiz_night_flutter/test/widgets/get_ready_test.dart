import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:quiz_night_flutter/widgets/qn/get_ready.dart';

void main() {
  group('Given a question that starts in 3 seconds', () {
    testWidgets('when it counts down then 3, 2, 1 cover the question, a tick '
        'each, then the question is free', (t) async {
      var taps = 0, ticks = 0;
      final start = DateTime.utc(2026, 1, 1, 12);
      var now = start;
      await t.pumpWidget(
        MaterialApp(
          home: GetReady(
            startsAt: start.add(const Duration(milliseconds: 2900)),
            clockOffset: Duration.zero,
            clock: () => now,
            onTick: () => ticks++,
            child: Center(
              child: TextButton(
                onPressed: () => taps++,
                child: const Text('Mars'),
              ),
            ),
          ),
        ),
      );
      String count() =>
          t.widget<Text>(find.byKey(const Key('getReady.count'))).data!;
      Future<void> advance(Duration d) async {
        now = now.add(d);
        await t.pump(const Duration(milliseconds: 150));
      }

      expect(count(), '3');
      await t.tap(find.text('Mars'), warnIfMissed: false);
      expect(taps, 0, reason: 'nothing can be pressed during the count');

      await advance(const Duration(seconds: 1));
      expect(count(), '2');
      await advance(const Duration(seconds: 1));
      expect(count(), '1');
      await advance(const Duration(seconds: 1));
      await t.pump(const Duration(milliseconds: 500));
      expect(find.byKey(const Key('getReady')), findsNothing);
      expect(ticks, 3);
      await t.tap(find.text('Mars'));
      expect(taps, 1);
    });

    test('when the server clock is ahead then the count uses its time', () {
      final now = DateTime.utc(2026, 1, 1, 12);
      final startsAt = now.add(const Duration(seconds: 3));
      expect(GetReady.secondsLeft(startsAt, Duration.zero, now), 3);
      // The server is 2 s ahead: only 1 s left by its clock.
      expect(
        GetReady.secondsLeft(startsAt, const Duration(seconds: 2), now),
        1,
      );
      expect(GetReady.secondsLeft(null, Duration.zero, now), 0);
    });
  });
}
