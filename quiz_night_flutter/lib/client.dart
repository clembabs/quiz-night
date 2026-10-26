import 'dart:async';

import 'package:quiz_night_client/quiz_night_client.dart';
import 'package:serverpod_auth_idp_flutter/serverpod_auth_idp_flutter.dart';
import 'package:serverpod_flutter/serverpod_flutter.dart';

/// Server URL: `SERVER_URL` define, else config.json `apiUrl`, else localhost.
final serverUrl = getServerUrl();

/// The app's one Serverpod client; repositories in `lib/data/` wrap it.
late final Client client;

Future<void> initializeClient() async {
  client = Client(await serverUrl)
    ..connectivityMonitor = FlutterConnectivityMonitor()
    ..authSessionManager = FlutterAuthSessionManager();
  unawaited(client.auth.initialize());
}
