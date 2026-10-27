import 'dart:typed_data';

import 'share_image_stub.dart'
    if (dart.library.js_interop) 'share_image_web.dart'
    as impl;

/// How handing over the image went.
enum ShareOutcome {
  /// The phone's share sheet took it.
  shared,

  /// No file sharing here (most desktops): it was downloaded instead.
  downloaded,

  /// The player closed the share sheet.
  cancelled,

  failed,
}

/// Shares [png] with [text] through the system share sheet, or downloads it
/// as [fileName] where files can't be shared. Never throws.
Future<ShareOutcome> shareImage(
  Uint8List png, {
  required String fileName,
  required String text,
}) => impl.shareImage(png, fileName: fileName, text: text);
