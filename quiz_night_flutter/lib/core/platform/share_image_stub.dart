import 'dart:typed_data';

import 'share_image.dart';

Future<ShareOutcome> shareImage(
  Uint8List png, {
  required String fileName,
  required String text,
}) async => ShareOutcome.failed;
