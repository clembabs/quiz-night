import 'package:quiz_night_server/src/game/nickname.dart';
import 'package:test/test.dart';

void main() {
  group('Given a typed nickname', () {
    test('when it has zero-width or control characters then they are '
        'removed', () {
      expect(Nickname.clean('A\u200Bd\u200Da\u0007'), 'Ada');
      expect(Nickname.clean('\u202Enimda'), 'nimda');
    });

    test('when it has runs of spaces or new lines then they fold to one', () {
      expect(Nickname.clean('  Ada \n\t  Obi  '), 'Ada Obi');
    });

    test('when nothing printable is left then it is empty', () {
      expect(Nickname.clean('\u200B\u200C\u2060 '), isEmpty);
    });

    test('when it uses Nigerian letters or emoji then they are kept', () {
      expect(Nickname.clean('Ọlá Ṣẹ́gun'), 'Ọlá Ṣẹ́gun');
      expect(Nickname.clean('Ɗanjuma 🔥'), 'Ɗanjuma 🔥');
    });
  });

  group('Given the word filter', () {
    test('when a name contains a strong word anywhere then it is blocked', () {
      for (final name in ['shitlord', 'Big F u c k', 'sh1t', r'b!tch']) {
        expect(Nickname.isOffensive(name), isTrue, reason: name);
      }
    });

    test('when a spelling the list does not know is used then it gets '
        'through: the host can still remove the player', () {
      expect(Nickname.isOffensive('Fvck0ff'), isFalse);
    });

    test('when a short word stands alone then it is blocked', () {
      expect(Nickname.isOffensive('Big Ass'), isTrue);
      expect(Nickname.isOffensive('dick_99'), isTrue);
      expect(Nickname.isOffensive('n4zi'), isTrue);
    });

    test('when a short word hides inside an ordinary name then it is '
        'allowed', () {
      for (final name in [
        'Cassandra',
        'Dickens',
        'Glass',
        'Titus',
        'Essex',
        'Assumpta',
        'Ọlá',
        'Hitchcock fan',
      ]) {
        expect(Nickname.isOffensive(name), isFalse, reason: name);
      }
    });
  });
}
