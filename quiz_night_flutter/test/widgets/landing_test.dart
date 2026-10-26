import 'dart:io';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:mocktail/mocktail.dart';
import 'package:quiz_night_flutter/app/quiz_night_app.dart';
import 'package:quiz_night_flutter/core/theme/app_theme.dart';
import 'package:quiz_night_flutter/features/landing/landing_screen.dart';

import '../fakes/fakes.dart';
import 'harness.dart';

/// Widths the page must fit; tall so the whole page lays out at once.
const widths = {
  'phone': 360.0,
  'iphone': 390.0,
  'tablet': 820.0,
  'desktop': 1440.0,
};

/// With SHOT_DIR set, saves a real-font full-page PNG per width.
final shotDir = Platform.environment['SHOT_DIR'];

/// The whole app at [location], with no saved seat.
Future<GoRouter> _open(WidgetTester t, Size size, String location) async {
  t.view.physicalSize = size;
  t.view.devicePixelRatio = 1;
  addTearDown(t.view.reset);
  final seats = MockSeatRepository();
  when(() => seats.load()).thenAnswer((_) async => null);
  await t.pumpWidget(
    QuizNightApp(
      lobby: MockLobbyRepository(),
      game: MockGameRepository(),
      seats: seats,
      initialLocation: location,
    ),
  );
  await t.pumpAndSettle();
  return GoRouter.of(t.element(find.byType(Scaffold).first));
}

String _path(GoRouter router) =>
    router.routerDelegate.currentConfiguration.uri.toString();

/// Each website page and what identifies it.
final pages = <String, (Widget, String)>{
  'home': (const HomePage(), 'SURVIVE THE ROUND. WIN THE NIGHT.'),
  'how': (const HowItWorksPage(), 'HOW IT WORKS'),
  'hosting': (const HostingGuidePage(), 'HOSTING GUIDE'),
  'faq': (const FaqPage(), 'QUESTIONS'),
};

void main() {
  for (final MapEntry(key: page, value: (widget, _)) in pages.entries) {
    for (final MapEntry(key: name, value: width) in widths.entries) {
      testWidgets('Given the $page page on a $name ($width wide) when it '
          'shows then nothing overflows', (t) async {
        if (shotDir != null) await loadRealFonts();
        final key = GlobalKey();
        t.view.physicalSize = Size(width, 9000);
        t.view.devicePixelRatio = 1;
        addTearDown(t.view.reset);
        await t.pumpWidget(
          RepaintBoundary(
            key: key,
            child: MaterialApp(
              debugShowCheckedModeBanner: false,
              theme: AppTheme.dark(),
              home: widget,
            ),
          ),
        );
        await t.pumpAndSettle();
        expect(t.takeException(), isNull);

        if (shotDir case final dir?) {
          // Crop to the page's real height.
          const pageHeight = 9000.0;
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
                '$dir/${page}_${name}_$i.png',
              ).writeAsBytesSync(png!.buffer.asUint8List());
            }
          });
        }
      });
    }
  }

  group('Given the hero join card', () {
    testWidgets('when the code is incomplete then Join game is disabled', (
      t,
    ) async {
      await _open(t, const Size(390, 844), '/');
      await t.enterText(find.byKey(const Key('landing.code')), '48');
      await t.pump();
      final button = t.widget<FilledButton>(
        find.byKey(const Key('landing.join')),
      );
      expect(button.onPressed, isNull);
    });

    testWidgets('when four digits are typed then Join game goes to '
        '/join with that code', (t) async {
      final router = await _open(t, const Size(390, 844), '/');
      await t.enterText(find.byKey(const Key('landing.code')), '4821');
      await t.pump();
      await t.ensureVisible(find.byKey(const Key('landing.join')));
      await t.tap(find.byKey(const Key('landing.join')));
      await t.pumpAndSettle();
      expect(_path(router), '/join?code=4821');
      final code = t.widget<TextField>(find.byKey(const Key('join.code')));
      expect(code.controller!.text, '4821');
    });
  });

  testWidgets('Given the hero when Start hosting is tapped then /host '
      'opens', (t) async {
    final router = await _open(t, const Size(1440, 900), '/');
    await t.ensureVisible(find.byKey(const Key('landing.host')));
    await t.tap(find.byKey(const Key('landing.host')));
    await t.pumpAndSettle();
    expect(_path(router), '/host');
    expect(find.text('NEW GAME'), findsOneWidget);
  });

  group('Given the header on a desktop', () {
    for (final (key, path, heading) in const [
      ('nav.how', '/how-it-works', 'HOW IT WORKS'),
      ('nav.hosting', '/hosting', 'HOSTING GUIDE'),
      ('nav.faq', '/faq', 'QUESTIONS'),
    ]) {
      testWidgets('when $key is tapped then $path opens', (t) async {
        final router = await _open(t, const Size(1440, 900), '/');
        await t.tap(find.byKey(Key(key)));
        await t.pumpAndSettle();
        expect(_path(router), path);
        expect(find.text(heading), findsOneWidget);
      });
    }
  });

  testWidgets('Given /how-it-works when For hosts is picked then the host '
      'steps show', (t) async {
    await _open(t, const Size(1440, 900), '/how-it-works');
    await t.tap(find.byKey(const Key('landing.tab.hosts')));
    await t.pump();
    expect(find.text('Put it on the big screen'), findsOneWidget);
    expect(find.text('Survive the cut'), findsNothing);
  });

  testWidgets('Given /faq when a question is tapped then its answer opens '
      'and closes', (t) async {
    await _open(t, const Size(1440, 900), '/faq');
    const q = 'Do players need an account?';
    await t.tap(find.text(q));
    await t.pump();
    expect(find.textContaining('only enter a room code'), findsOneWidget);
    await t.tap(find.text(q));
    await t.pump();
    expect(find.textContaining('only enter a room code'), findsNothing);
  });

  testWidgets('Given a phone when Menu is tapped then the page links show '
      'and one opens its page', (t) async {
    final router = await _open(t, const Size(390, 844), '/');
    expect(find.byKey(const Key('nav.faq.menu')), findsNothing);
    await t.tap(find.byKey(const Key('landing.menu')));
    await t.pump();
    await t.tap(find.byKey(const Key('nav.faq.menu')));
    await t.pumpAndSettle();
    expect(_path(router), '/faq');
    expect(find.byKey(const Key('nav.faq.menu')), findsNothing);
  });

  testWidgets('Given an unknown address when it opens then the not-found '
      'page links home', (t) async {
    final router = await _open(t, const Size(1440, 900), '/nowhere');
    expect(find.text('THERE’S NOTHING AT THIS ADDRESS'), findsOneWidget);
    await t.tap(find.text('Go to the home page'));
    await t.pumpAndSettle();
    expect(_path(router), '/');
  });
}
