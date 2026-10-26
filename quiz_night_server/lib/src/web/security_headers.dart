import 'package:serverpod/serverpod.dart';

/// Protective headers on every page the web server sends: the Flutter app,
/// its files and the app config.
class SecurityHeadersMiddleware extends MiddlewareObject {
  /// The API server's public address (e.g. `https://quiz-night.api.serverpod.space`),
  /// which the app calls and opens its live room streams to.
  final Uri apiOrigin;

  const SecurityHeadersMiddleware({required this.apiOrigin});

  /// Flutter's rendering engine (CanvasKit) and its fallback fonts come from
  /// Google's CDN.
  static const _engine = 'https://www.gstatic.com';
  static const _fonts = 'https://fonts.gstatic.com';

  /// Where the page may load things from. Flutter web needs:
  /// - `'wasm-unsafe-eval'` to run the engine's WebAssembly;
  /// - `'unsafe-inline'` styles, which Flutter sets on its own elements and
  ///   index.html uses for the instant loading screen;
  /// - `blob:`/`data:` images and fonts, which the engine creates in memory.
  String get contentSecurityPolicy {
    final api = _origin(apiOrigin);
    final sockets = _origin(
      apiOrigin.replace(scheme: apiOrigin.scheme == 'https' ? 'wss' : 'ws'),
    );
    return [
      "default-src 'self'",
      "script-src 'self' 'wasm-unsafe-eval' $_engine",
      "style-src 'self' 'unsafe-inline'",
      "img-src 'self' data: blob:",
      "font-src 'self' data: $_fonts $_engine",
      "connect-src 'self' $api $sockets $_engine $_fonts",
      "worker-src 'self' blob:",
      "object-src 'none'",
      "base-uri 'self'",
      "form-action 'self'",
      // Nobody may frame the game (clickjacking a host's controls).
      "frame-ancestors 'none'",
    ].join('; ');
  }

  static String _origin(Uri uri) {
    final defaultPort = (uri.scheme == 'https' || uri.scheme == 'wss')
        ? 443
        : 80;
    final port = uri.hasPort && uri.port != defaultPort ? ':${uri.port}' : '';
    return '${uri.scheme}://${uri.host}$port';
  }

  /// The headers, for tests and the middleware.
  Map<String, String> get headers => {
    'content-security-policy': contentSecurityPolicy,
    // HTTPS only from here on (browsers ignore it over plain HTTP, so local
    // development is unaffected).
    'strict-transport-security': 'max-age=31536000; includeSubDomains',
    'x-content-type-options': 'nosniff',
    'x-frame-options': 'DENY',
    'referrer-policy': 'strict-origin-when-cross-origin',
    // Only what the game uses: the screen staying awake. No camera,
    // microphone, location or payments.
    'permissions-policy':
        'camera=(), microphone=(), geolocation=(), payment=(), usb=(), '
        'screen-wake-lock=(self)',
    'cross-origin-opener-policy': 'same-origin',
  };

  @override
  Handler call(Handler next) {
    final extra = headers;
    return (Request req) async {
      final result = await next(req);
      if (result is! Response) return result;
      return result.copyWith(
        headers: result.headers.transform((h) {
          for (final MapEntry(:key, :value) in extra.entries) {
            h[key] = [value];
          }
        }),
      );
    };
  }
}
