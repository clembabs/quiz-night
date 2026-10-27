import 'package:quiz_night_server/src/generated/protocol.dart';
import 'package:quiz_night_server/src/security/guard.dart';
import 'package:test/test.dart';

import 'test_tools/serverpod_test_tools.dart';

void main() {
  tearDown(() {
    Guard.enabled = false;
    Guard.reset();
  });

  withServerpod('Given the web app reports an error', (sb, endpoints) {
    test(
      'when it reports, even a huge stack, then the call succeeds',
      () async {
        await endpoints.diagnostics.reportError(
          sb,
          'Null check operator used on a null value',
          '#0 main (package:app/main.dart:1)\n' * 500,
          '/room/4821',
        );
      },
    );

    test('when one address floods reports then it is turned away', () async {
      Guard.enabled = true;
      for (var i = 0; i < Limits.clientError.max; i++) {
        await endpoints.diagnostics.reportError(sb, 'Oops $i', null, '/');
      }
      await expectLater(
        endpoints.diagnostics.reportError(sb, 'One more', null, '/'),
        throwsA(
          isA<QuizException>().having(
            (e) => e.code,
            'code',
            QuizErrorCode.rateLimited,
          ),
        ),
      );
    });
  });
}
