import 'package:flutter_test/flutter_test.dart';
import 'package:quiz_night_flutter/core/observability/error_reporter.dart';

void main() {
  late List<(String, String?, String)> sent;
  ErrorReporter reporter({int max = 10, Object? failWith}) => ErrorReporter(
    (message, stack, route) async {
      sent.add((message, stack, route));
      if (failWith != null) throw failWith;
    },
    route: () => '/room/4821',
    maxPerLoad: max,
  );

  setUp(() => sent = []);

  group('Given the app hits an error', () {
    test('when reported then the server gets its type, message, stack and '
        'page', () {
      reporter().report(StateError('bad'), StackTrace.fromString('#0 main'));
      expect(sent.single.$1, 'StateError: Bad state: bad');
      expect(sent.single.$2, '#0 main');
      expect(sent.single.$3, '/room/4821');
    });

    test('when the same error repeats then it is sent once', () {
      final r = reporter();
      for (var i = 0; i < 5; i++) {
        r.report(StateError('again'), null);
      }
      expect(sent, hasLength(1));
    });

    test('when many different errors come then only the first ten go', () {
      final r = reporter();
      for (var i = 0; i < 25; i++) {
        r.report(StateError('error $i'), null);
      }
      expect(sent, hasLength(10));
    });

    test('when the server cannot be reached then nothing is thrown', () async {
      reporter(failWith: Exception('offline')).report(StateError('x'), null);
      await Future<void>.delayed(Duration.zero);
      expect(sent, hasLength(1));
    });
  });
}
