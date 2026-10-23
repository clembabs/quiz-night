import 'package:quiz_night_server/src/web/security_headers.dart';
import 'package:test/test.dart';

void main() {
  group('Given the API on Serverpod Cloud', () {
    final m = SecurityHeadersMiddleware(
      apiOrigin: Uri.parse('https://quiz-night.api.serverpod.space:443/'),
    );

    test('when building the CSP then the app may call and stream from the '
        'API, and load the engine from the CDN', () {
      final csp = m.contentSecurityPolicy;
      expect(
        csp,
        contains(
          "connect-src 'self' "
          'https://quiz-night.api.serverpod.space '
          'wss://quiz-night.api.serverpod.space',
        ),
      );
      expect(
        csp,
        contains(
          "script-src 'self' 'wasm-unsafe-eval' "
          'https://www.gstatic.com',
        ),
      );
      expect(csp, contains("frame-ancestors 'none'"));
      expect(csp, contains("object-src 'none'"));
      expect(csp, isNot(contains("'unsafe-eval'")));
    });

    test('when listing the headers then every protective header is set', () {
      expect(
        m.headers.keys,
        containsAll([
          'content-security-policy',
          'strict-transport-security',
          'x-content-type-options',
          'x-frame-options',
          'referrer-policy',
          'permissions-policy',
          'cross-origin-opener-policy',
        ]),
      );
      expect(m.headers['x-frame-options'], 'DENY');
      expect(m.headers['permissions-policy'], contains('camera=()'));
    });
  });

  group('Given the API in local development', () {
    test('when the port is not the default then it is kept, over ws', () {
      final csp = SecurityHeadersMiddleware(
        apiOrigin: Uri.parse('http://localhost:8080/'),
      ).contentSecurityPolicy;
      expect(csp, contains('http://localhost:8080 ws://localhost:8080'));
    });
  });
}
