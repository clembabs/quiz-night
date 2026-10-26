import 'dart:io';

import 'package:serverpod/serverpod.dart';

/// Cache busting config, used in WidgetRoutes for asset paths.
final cacheBustingConfig = CacheBustingConfig(
  mountPrefix: '/web',
  fileSystemRoot: Directory(Uri(path: 'web/static').toFilePath()),
);
