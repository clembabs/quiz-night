import 'dart:io';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:quiz_night_flutter/core/theme/app_theme.dart';
import 'package:quiz_night_flutter/features/landing/landing_cubit.dart';
import 'package:quiz_night_flutter/features/landing/landing_screen.dart';

/// Window widths the page must fit, with a tall height so the whole page
/// lays out at once.
const widths = {
  'phone': 360.0,
  'iphone': 390.0,
  'tablet': 820.0,
  'desktop': 1440.0,
};

/// With SHOT_DIR set, renders in the real fonts and saves a full-page PNG
/// per width, for checking the layout by eye.
final shotDir = Platform.environment['SHOT_DIR'];

Future<void> _loadRealFonts() async {
  for (final (family, files) in [
    ('Bricolage', ['BricolageGrotesque-ExtraBold.ttf']),
    (
      'Figtree',
      ['Figtree-Regular.ttf', 'Figtree-Bold.ttf', 'Figtree-ExtraBold.ttf'],
    ),
    (
      'NotoSansAfr',
      [
        'NotoSansAfr-Regular.ttf',
        'NotoSansAfr-Bold.ttf',
        'NotoSansAfr-ExtraBold.ttf',
      ],
    ),
    ('NotoSansSymbols', ['NotoSansSymbols-Regular.ttf']),
  ]) {
    final loader = FontLoader(family);
    for (final file in files) {
      loader.addFont(
        Future.value(
          ByteData.sublistView(File('assets/fonts/$file').readAsBytesSync()),
        ),
      );
    }
    await loader.load();
  }
}

class _Calls {
  final joins = <String?>[];
  int hosts = 0;
}

Future<_Calls> _pump(WidgetTester t, Size size, {LandingCubit? cubit}) async {
  t.view.physicalSize = size;
  t.view.devicePixelRatio = 1;
  addTearDown(t.view.reset);
  final calls = _Calls();
  final landing = cubit ?? LandingCubit();
  addTearDown(landing.close);
  await t.pumpWidget(
    MaterialApp(
      theme: AppTheme.dark(),
      home: BlocProvider.value(
        value: landing,
        child: LandingScreen(
          onJoin: calls.joins.add,
          onHost: () => calls.hosts++,
        ),
      ),
    ),
  );
  await t.pumpAndSettle();
  return calls;
}

void main() {
  for (final MapEntry(key: name, value: width) in widths.entries) {
    testWidgets('Given the landing page on a $name ($width wide) when it '
        'shows then nothing overflows', (t) async {
      if (shotDir != null) await _loadRealFonts();
      final key = GlobalKey();
      t.view.physicalSize = Size(width, 9000);
      t.view.devicePixelRatio = 1;
      addTearDown(t.view.reset);
      final landing = LandingCubit();
      addTearDown(landing.close);
      await t.pumpWidget(
        RepaintBoundary(
          key: key,
          child: MaterialApp(
            debugShowCheckedModeBanner: false,
            theme: AppTheme.dark(),
            home: BlocProvider.value(
              value: landing,
              child: LandingScreen(onJoin: (_) {}, onHost: () {}),
            ),
          ),
        ),
      );
      await t.pumpAndSettle();
      expect(t.takeException(), isNull);

      if (shotDir case final dir?) {
        // Crop to the page's real height.
        final scroll = t.widget<SingleChildScrollView>(
          find.byKey(const Key('landing.scroll')),
        );
        final pageHeight = scroll.controller!.position.maxScrollExtent == 0
            ? t.getSize(find.byType(LandingScreen)).height
            : 9000.0;
        final content = t.getSize(
          find
              .descendant(
                of: find.byKey(const Key('landing.scroll')),
                matching: find.byType(Column),
              )
              .first,
        );
        final boundary =
            key.currentContext!.findRenderObject()! as RenderRepaintBoundary;
        await t.runAsync(() async {
          final image = await boundary.toImage();
          final h = (content.height + 70).clamp(0, pageHeight).toDouble();
          // Slices of at most 1500 px, easier to look at than one long page.
          for (var y = 0.0, i = 0; y < h; y += 1500, i++) {
            final sliceH = (h - y).clamp(0, 1500).toDouble();
            final recorder = ui.PictureRecorder();
            Canvas(recorder).drawImageRect(
              image,
              Rect.fromLTWH(0, y, width, sliceH),
              Rect.fromLTWH(0, 0, width, sliceH),
              Paint(),
            );
            final out = await recorder.endRecording().toImage(
              width.toInt(),
              sliceH.toInt(),
            );
            final png = await out.toByteData(format: ui.ImageByteFormat.png);
            File(
              '$dir/landing_${name}_$i.png',
            ).writeAsBytesSync(png!.buffer.asUint8List());
          }
        });
      }
    });
  }

  group('Given the hero join card', () {
    testWidgets('when the code is incomplete then Join game is disabled', (
      t,
    ) async {
      final calls = await _pump(t, const Size(390, 844));
      await t.enterText(find.byKey(const Key('landing.code')), '48');
      await t.pump();
      final button = t.widget<FilledButton>(
        find.byKey(const Key('landing.join')),
      );
      expect(button.onPressed, isNull);
      expect(calls.joins, isEmpty);
    });

    testWidgets('when four digits are typed then Join game opens the join '
        'form with that code', (t) async {
      final calls = await _pump(t, const Size(390, 844));
      await t.enterText(find.byKey(const Key('landing.code')), '4821');
      await t.pump();
      await t.ensureVisible(find.byKey(const Key('landing.join')));
      await t.tap(find.byKey(const Key('landing.join')));
      expect(calls.joins, ['4821']);
    });
  });

  testWidgets('Given the hero when Start hosting is tapped then hosting '
      'opens', (t) async {
    final calls = await _pump(t, const Size(1440, 900));
    await t.ensureVisible(find.byKey(const Key('landing.host')));
    await t.tap(find.byKey(const Key('landing.host')));
    expect(calls.hosts, 1);
  });

  testWidgets('Given the walkthrough when For hosts is picked then the host '
      'steps show', (t) async {
    await _pump(t, const Size(1440, 900));
    await t.scrollUntilVisible(
      find.byKey(const Key('landing.tab.hosts')),
      300,
      scrollable: find.byType(Scrollable).first,
    );
    await t.tap(find.byKey(const Key('landing.tab.hosts')));
    await t.pump();
    expect(find.text('Put it on the projector'), findsOneWidget);
    expect(find.text('Survive the cut'), findsNothing);
  });

  testWidgets('Given the FAQ when a question is tapped then its answer opens '
      'and closes', (t) async {
    await _pump(t, const Size(1440, 900));
    const q = 'Do players need an account?';
    await t.scrollUntilVisible(
      find.text(q),
      300,
      scrollable: find.byType(Scrollable).first,
    );
    await t.tap(find.text(q));
    await t.pump();
    expect(find.textContaining('only enter a room code'), findsOneWidget);
    await t.tap(find.text(q));
    await t.pump();
    expect(find.textContaining('only enter a room code'), findsNothing);
  });

  testWidgets('Given a phone when Menu is tapped then the section links show '
      'and one scrolls the page', (t) async {
    await _pump(t, const Size(390, 844));
    final menuLink = find.widgetWithText(TextButton, 'For teachers');
    expect(menuLink, findsNothing);
    await t.tap(find.byKey(const Key('landing.menu')));
    await t.pump();
    expect(menuLink, findsOneWidget);
    await t.tap(find.widgetWithText(TextButton, 'FAQ'));
    await t.pumpAndSettle();
    // The menu closed and the FAQ heading scrolled into view.
    expect(menuLink, findsNothing);
    expect(find.text('QUESTIONS').hitTestable(), findsOneWidget);
  });
}
