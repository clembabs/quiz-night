// Renders the crest into the web app's favicon and home-screen icons.
//
//   cd quiz_night_flutter && flutter test tool/generate_icons_test.dart
//
// Lives outside test/ so it never runs with the normal suite.
import 'dart:io';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:quiz_night_flutter/core/theme/app_colors.dart';
import 'package:quiz_night_flutter/widgets/brand/crest.dart';

Future<void> _loadFonts() async {
  for (final (family, file) in [
    ('Bricolage', 'BricolageGrotesque-ExtraBold.ttf'),
    ('NotoSansAfr', 'NotoSansAfr-ExtraBold.ttf'),
  ]) {
    final bytes = File('assets/fonts/$file').readAsBytesSync();
    await (FontLoader(family)..addFont(Future.value(ByteData.sublistView(bytes))))
        .load();
  }
}

/// One icon: [size] square, crest [crestFraction] of the height, on [bg].
class _Icon {
  final String path;
  final int size;
  final double crestFraction;
  final Color? bg;

  const _Icon(this.path, this.size, this.crestFraction, {this.bg});
}

const _icons = [
  // Browser tab: crest only, as large as possible.
  _Icon('web/favicon.png', 64, 0.96),
  // Home screen / PWA: blackboard tile.
  _Icon('web/icons/Icon-192.png', 192, 0.78, bg: AppColors.board),
  _Icon('web/icons/Icon-512.png', 512, 0.78, bg: AppColors.board),
  // Maskable: keep the crest inside the 80% safe circle.
  _Icon('web/icons/Icon-maskable-192.png', 192, 0.56, bg: AppColors.board),
  _Icon('web/icons/Icon-maskable-512.png', 512, 0.56, bg: AppColors.board),
  // iOS home screen ignores transparency, so give it the board too.
  _Icon('web/icons/apple-touch-icon.png', 180, 0.74, bg: AppColors.board),
];

void main() {
  testWidgets('generate icons', (tester) async {
    await _loadFonts();
    for (final icon in _icons) {
      final key = GlobalKey();
      final s = icon.size.toDouble();
      final crestHeight = s * icon.crestFraction;
      tester.view.physicalSize = Size(s, s);
      tester.view.devicePixelRatio = 1;
      await tester.pumpWidget(
        Directionality(
          textDirection: TextDirection.ltr,
          child: RepaintBoundary(
            key: key,
            child: Container(
              width: s,
              height: s,
              color: icon.bg ?? Colors.transparent,
              alignment: Alignment.center,
              child: Crest(width: crestHeight * 64 / 76),
            ),
          ),
        ),
      );
      await tester.pump();
      final boundary =
          key.currentContext!.findRenderObject()! as RenderRepaintBoundary;
      await tester.runAsync(() async {
        final image = await boundary.toImage();
        final png = await image.toByteData(format: ui.ImageByteFormat.png);
        File(icon.path).writeAsBytesSync(png!.buffer.asUint8List());
      });
    }
    tester.view.reset();
  });
}
