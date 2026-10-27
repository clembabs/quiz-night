import 'dart:js_interop';
import 'dart:typed_data';

import 'package:web/web.dart' as web;

import 'share_image.dart';

Future<ShareOutcome> shareImage(
  Uint8List png, {
  required String fileName,
  required String text,
}) async {
  try {
    final file = web.File(
      [png.toJS].toJS,
      fileName,
      web.FilePropertyBag(type: 'image/png'),
    );
    final data = web.ShareData(files: [file].toJS, text: text);
    final nav = web.window.navigator;
    if (_canShare(nav, data)) {
      try {
        await nav.share(data).toDart;
        return ShareOutcome.shared;
      } catch (e) {
        // Closing the share sheet rejects with an AbortError.
        if (e.toString().contains('AbortError')) return ShareOutcome.cancelled;
        rethrow;
      }
    }
    _download(file, fileName);
    return ShareOutcome.downloaded;
  } catch (_) {
    return ShareOutcome.failed;
  }
}

/// Whether this browser can share files (phones: yes; most desktops: no).
bool _canShare(web.Navigator nav, web.ShareData data) {
  try {
    return nav.canShare(data);
  } catch (_) {
    return false;
  }
}

/// Saves [blob] through a temporary link, as a click on it would.
void _download(web.Blob blob, String fileName) {
  final url = web.URL.createObjectURL(blob);
  final link = web.HTMLAnchorElement()
    ..href = url
    ..download = fileName;
  web.document.body?.append(link);
  link.click();
  link.remove();
  web.URL.revokeObjectURL(url);
}
