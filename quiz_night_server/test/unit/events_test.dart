import 'package:quiz_night_server/src/generated/protocol.dart';
import 'package:quiz_night_server/src/observability/events.dart';
import 'package:test/test.dart';

void main() {
  group('Given a game event', () {
    test('when formatted then it is the event then key=value pairs', () {
      expect(
        Events.format('round.cut', {
          'room': '4821',
          'round': 2,
          'out': 3,
          'finalists': false,
          'ms': const Duration(milliseconds: 41),
          'rule': EliminationRule.bottomPercent,
        }),
        'round.cut room=4821 round=2 out=3 finalists=false ms=41 '
        'rule=bottomPercent',
      );
    });

    test('when a value is null then the field is left out', () {
      expect(
        Events.format('game.finished', {'minutes': null}),
        'game.finished',
      );
    });

    test(
      'when a value has spaces or quotes then it is quoted, on one line',
      () {
        expect(
          Events.format('client.error', {'message': 'Bad "state"\n  here'}),
          r'client.error message="Bad \"state\" here"',
        );
      },
    );

    test('when a value is very long then it is cut', () {
      final line = Events.format('client.error', {'message': 'x' * 500});
      expect(line, hasLength('client.error message='.length + 200 + 1));
      expect(line, endsWith('…'));
    });
  });
}
