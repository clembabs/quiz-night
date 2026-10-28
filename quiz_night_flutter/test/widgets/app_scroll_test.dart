import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:quiz_night_flutter/widgets/brand/chalk_background.dart';
import 'package:quiz_night_flutter/widgets/layout/app_scroll.dart';

Future<void> _pump(WidgetTester t, Widget child) => t.pumpWidget(
  MaterialApp(
    scrollBehavior: const AppScrollBehavior(),
    home: Scaffold(body: SizedBox(height: 600, child: child)),
  ),
);

void main() {
  testWidgets('Given a short page when it fills the viewport then the footer '
      'sits at the bottom', (t) async {
    await _pump(
      t,
      const AppScroll(
        padding: EdgeInsets.all(20),
        fillViewport: true,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [Text('top'), Text('footer')],
        ),
      ),
    );
    // 600 tall, less the 20 of padding below.
    expect(t.getBottomLeft(find.text('footer')).dy, 580);
    expect(t.takeException(), isNull);
  });

  testWidgets('Given a long page when dragged then it scrolls and the '
      'keyboard goes away', (t) async {
    await _pump(
      t,
      AppScroll(
        child: Column(
          children: [
            const TextField(key: Key('field')),
            for (var i = 0; i < 40; i++)
              SizedBox(height: 60, child: Text('row $i')),
          ],
        ),
      ),
    );
    await t.tap(find.byKey(const Key('field')));
    await t.pump();
    expect(FocusManager.instance.primaryFocus?.context, isNotNull);

    await t.drag(find.byType(AppScroll), const Offset(0, -400));
    await t.pumpAndSettle();
    expect(find.text('row 0').hitTestable(), findsNothing);
    expect(
      t.widget<EditableText>(find.byType(EditableText)).focusNode.hasFocus,
      isFalse,
    );
  });

  testWidgets('Given Android when overscrolled then it glows instead of '
      'stretching', (t) async {
    debugDefaultTargetPlatformOverride = TargetPlatform.android;
    await _pump(t, const AppScroll(child: SizedBox(height: 2000)));
    expect(find.byType(GlowingOverscrollIndicator), findsOneWidget);
    expect(find.byType(StretchingOverscrollIndicator), findsNothing);
    debugDefaultTargetPlatformOverride = null;
  });

  testWidgets('Given the chalk background when a large board is painted then '
      'it lays out', (t) async {
    await _pump(
      t,
      const FittedBox(
        child: SizedBox(
          width: 1920,
          height: 1080,
          child: ChalkBackground(spacing: 12, child: SizedBox.expand()),
        ),
      ),
    );
    expect(t.takeException(), isNull);
  });
}
