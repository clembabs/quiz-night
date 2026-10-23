import 'dart:io';

import 'package:bloc_test/bloc_test.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:quiz_night_flutter/core/platform/haptics.dart';
import 'package:quiz_night_flutter/core/theme/app_theme.dart';
import 'package:quiz_night_flutter/features/room/cut_reveal/reveal_sequence_cubit.dart';
import 'package:quiz_night_flutter/features/room/room_cubit.dart';
import 'package:quiz_night_flutter/widgets/qn/host_stage.dart';

class MockRoomCubit extends MockCubit<RoomViewState> implements RoomCubit {}

/// Records which haptic tokens were played.
class RecordingHaptics implements Haptics {
  final played = <HapticToken>[];

  @override
  bool enabled = true;

  @override
  void play(HapticToken token) => played.add(token);
}

/// A reveal sequence on a 1 s intro and 1 s per name.
RevealSequenceCubit fastSequence(int total) => RevealSequenceCubit(
  total: total,
  intro: const Duration(seconds: 1),
  step: const Duration(seconds: 1),
);

/// Pumps [child] with the app theme, a [RoomCubit] and [Haptics] in scope.
Future<void> pumpScreen(
  WidgetTester tester,
  Widget child, {
  required RoomCubit cubit,
  Haptics? haptics,
  Size size = const Size(360, 780),
}) async {
  tester.view.physicalSize = size;
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.reset);
  await tester.pumpWidget(
    RepositoryProvider<Haptics>.value(
      value: haptics ?? SilentHaptics(),
      child: MaterialApp(
        theme: AppTheme.dark(),
        home: BlocProvider<RoomCubit>.value(
          value: cubit,
          child: Scaffold(body: child),
        ),
      ),
    ),
  );
}

/// Pumps a host screen on the full 1920×1080 projector canvas.
Future<void> pumpHost(
  WidgetTester tester,
  Widget child, {
  required RoomCubit cubit,
}) => pumpScreen(
  tester,
  HostStage(topLabel: 'Test', code: '4821', child: child),
  cubit: cubit,
  size: hostCanvas,
);

/// Loads the app's bundled fonts (and their fallbacks) so renders match the
/// real app, instead of the test font's blocks. For screenshot runs only:
/// layout tests keep the wider test font, which catches more overflows.
Future<void> loadRealFonts() async {
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
      final bytes = File('assets/fonts/$file').readAsBytesSync();
      loader.addFont(Future.value(ByteData.sublistView(bytes)));
    }
    await loader.load();
  }
}
