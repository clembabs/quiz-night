import 'package:quiz_night_server/src/security/tokens.dart';
import 'package:test/test.dart';

void main() {
  group('Given a stored host token', () {
    const stored = '0123456789abcdef0123456789abcdef';

    test('when the same token is presented then it matches', () {
      expect(tokensMatch(stored, '0123456789abcdef0123456789abcdef'), isTrue);
    });

    test('when it differs anywhere or in length then it does not', () {
      expect(tokensMatch(stored, 'x123456789abcdef0123456789abcdef'), isFalse);
      expect(tokensMatch(stored, '0123456789abcdef0123456789abcdex'), isFalse);
      expect(tokensMatch(stored, '0123456789abcdef'), isFalse);
      expect(tokensMatch(stored, ''), isFalse);
    });

    test('when the room has no token then nothing matches', () {
      expect(tokensMatch(null, ''), isFalse);
      expect(tokensMatch(null, stored), isFalse);
    });
  });
}
