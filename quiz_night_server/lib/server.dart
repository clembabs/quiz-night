import 'dart:io';

import 'package:serverpod_auth_idp_server/core.dart';
import 'package:serverpod_cloud_storage/serverpod_cloud_storage.dart';

import 'src/ai/host_lines.dart';
import 'src/ai/question_packs.dart';
import 'src/cache_busting.dart';
import 'src/game/room_cleanup.dart';
import 'src/game/room_expiry.dart';
import 'src/game/room_service.dart';
import 'src/generated/serverpod.dart';
import 'src/security/guard.dart';
import 'src/web/routes/app_config_route.dart';
import 'src/web/security_headers.dart';

/// Starts the server: the API, the web app at `/`, and room cleanup jobs.
void run(List<String> args) async {
  final pod = Serverpod(args);

  pod.initializeAuthServices(
    tokenManagerBuilders: [JwtConfigFromPasswords()],
    // No sign-in yet: room tokens identify players and hosts. The email
    // provider was removed so its endpoints can't send mail on our account.
    identityProviderBuilders: [],
  );

  pod.webServer.addRoute(
    StaticRoute.withCacheBusting(cacheBustingConfig),
    cacheBustingConfig.mountPrefix,
  );

  // Protective headers (CSP, HSTS, no framing...) on every web page.
  pod.webServer.addMiddleware(
    SecurityHeadersMiddleware(apiOrigin: pod.config.apiServer.apiUrl).call,
    '/',
  );

  // Tells the web app where the API is (see lib/client.dart in the app).
  pod.webServer.addRoute(
    AppConfigRoute(apiConfig: pod.config.apiServer),
    '/assets/assets/config.json',
  );

  final appDir = Directory(Uri(path: 'web/app').toFilePath());
  if (appDir.existsSync()) {
    pod.webServer.addRoute(
      FlutterRoute(
        appDir,
        enableWasmHeaders: false,
        // CDN keeps the web build a day (cleared on deploy); browsers re-check
        // each minute (names aren't hashed); index.html is never cached.
        cacheControlFactory: (_, _) => CacheControlHeader(
          publicCache: true,
          maxAge: 60,
          sMaxAge: 86400,
        ),
      ),
      '/',
    );
  } else {
    // No web build yet (`make build-web`): a page saying so.
    final defaultRoute = StaticRoute.file(
      File(
        Uri(path: 'web/pages/build_flutter_app.html').toFilePath(),
      ),
    );

    pod.webServer.addMiddleware(
      FallbackMiddleware(
        fallback: defaultRoute,
        on: (response) => response.statusCode == 404,
      ).call,
      '/',
    );

    pod.webServer.addRoute(
      defaultRoute,
      '/**',
    );
  }

  pod.addCloudStorage(
    await ServerpodCloudProvider.private(
      fallback: () => DatabaseCloudStorage('private'),
    ),
  );
  pod.addCloudStorage(
    await ServerpodCloudProvider.public(
      fallback: () => DatabaseCloudStorage('public'),
    ),
  );

  // Reveal questions server-side when their deadline passes.
  RoomService.autoRevealEnabled = true;

  // Rate limits on every endpoint (see lib/src/security/guard.dart).
  Guard.enabled = true;

  // AI questions and host lines, if the geminiApiKey password is set.
  QuestionPacks.configure(pod);
  HostLines.configure(pod);

  await pod.start();

  // Delete rooms (and their players' data) after a day.
  RoomCleanup.schedule(pod);

  // End games after 30 minutes, and rooms idle for 30 minutes.
  RoomExpiry.schedule(pod);
}
