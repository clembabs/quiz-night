import 'dart:io';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:quiz_night_client/quiz_night_client.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:quiz_night_flutter/core/theme/app_theme.dart';
import 'package:quiz_night_flutter/features/host_setup/host_setup_cubit.dart';
import 'package:quiz_night_flutter/features/host_setup/host_setup_screen.dart';
import 'package:quiz_night_flutter/features/host_setup/question_pack_cubit.dart';
import 'package:quiz_night_flutter/features/room/host/host_cut.dart';
import 'package:quiz_night_flutter/features/room/host/host_final.dart';
import 'package:quiz_night_flutter/features/room/host/host_lobby.dart';
import 'package:quiz_night_flutter/features/room/host/host_podium.dart';
import 'package:quiz_night_flutter/features/room/host/host_question.dart';
import 'package:quiz_night_flutter/features/room/host/host_reveal.dart';
import 'package:quiz_night_flutter/features/room/host/host_standings.dart';
import 'package:quiz_night_flutter/features/room/room_cubit.dart';
import 'package:quiz_night_flutter/widgets/qn/host_stage.dart';
import 'package:quiz_night_flutter/widgets/qn/session_clock.dart';

import '../fakes/fakes.dart';
import 'harness.dart';

const f = PlayerStatus.finalist;
const out = PlayerStatus.eliminated;

/// Screens the host view must fit without overflowing.
const windows = {
  'phone': Size(360, 640),
  'iphone': Size(390, 844),
  'tablet': Size(820, 1180),
  'projector': Size(1920, 1080),
};

/// With SHOT_DIR set, saves a real-font PNG per case; else checks overflow.
final shotDir = Platform.environment['SHOT_DIR'];

void main() {
  setUpAll(registerFallbacks);

  final later = DateTime.now().toUtc().add(const Duration(minutes: 5));
  List<PlayerView> crowd(int n, {PlayerStatus status = PlayerStatus.active}) =>
      [
        for (var i = 1; i <= n; i++)
          player(i, 'Player number $i', score: 9000 - i * 250, status: status),
      ];

  final screens = <String, Widget Function()>{
    'lobby': () => HostLobby(
      room: roomState(code: '4821', players: crowd(9)),
      appUrl: Uri.parse('https://quiz-night.serverpod.space/'),
    ),
    'lobby-locked': () => HostLobby(
      room: roomState(code: '4821', players: crowd(20)).copyWith(locked: true),
      appUrl: Uri.parse('https://quiz-night.serverpod.space/'),
    ),
    'question': () => HostQuestion(
      room: roomState(
        status: RoomStatus.question,
        round: 1,
        players: crowd(9),
        question: question(),
        questionEndsAt: later,
      ),
      clockOffset: Duration.zero,
    ),
    'reveal': () => HostReveal(
      room: roomState(
        status: RoomStatus.reveal,
        round: 1,
        players: crowd(9),
        question: question(revealed: true, answerCounts: [2, 5, 1, 1]),
      ),
    ),
    'standings': () => HostStandings(
      room: roomState(
        status: RoomStatus.reveal,
        round: 1,
        players: crowd(12),
        question: question(revealed: true),
      ),
      rankMoves: const {1: 2, 3: -1},
    ),
    'cut': () => HostCut(
      room: roomState(
        status: RoomStatus.elimination,
        round: 1,
        players: [
          ...crowd(6),
          player(7, 'Player number 7', status: out, eliminatedInRound: 1),
          player(8, 'Player number 8', status: out, eliminatedInRound: 1),
        ],
        lastElimination: cut(out: [8, 7], survivors: 6),
      ),
      createSequence: fastSequence,
    ),
    'final': () => HostFinal(
      room: roomState(
        status: RoomStatus.buzzerFinal,
        players: crowd(3, status: f),
        question: question(isFinal: true),
        questionEndsAt: later,
        buzzerHolderId: 2,
      ),
      clockOffset: Duration.zero,
    ),
    'podium-time-up': () => HostPodium(
      room: roomState(
        status: RoomStatus.finished,
        round: 2,
        players: crowd(8),
      ).copyWith(endReason: RoomEndReason.timeUp),
    ),
    'podium': () => HostPodium(
      room: roomState(
        status: RoomStatus.finished,
        players: [
          player(1, 'Ada', status: f, finalScore: 3000),
          player(2, 'Bolanle', status: f, finalScore: 2000),
          player(3, 'Chidi', status: f, finalScore: 1000),
          player(4, 'Dee', status: out, backedPlayerId: 1, shadowScore: 900),
        ],
      ),
    ),
  };

  for (final MapEntry(key: window, value: size) in windows.entries) {
    group('Given the host view on a $window (${size.width.toInt()}×'
        '${size.height.toInt()})', () {
      for (final MapEntry(key: name, value: build) in screens.entries) {
        testWidgets('when the $name screen shows then nothing overflows', (
          t,
        ) async {
          if (shotDir != null) await loadRealFonts();
          final cubit = MockRoomCubit();
          when(
            () => cubit.state,
          ).thenReturn(const RoomViewState(seat: hostSeat));
          final key = GlobalKey();
          await pumpScreen(
            t,
            RepaintBoundary(
              key: key,
              child: HostStage(
                topLabel: 'Round 1 · Question 3',
                code: '4821',
                actions: [HostTextButton(label: 'Leave', onPressed: () {})],
                // The game clock is in the header from Start onwards.
                clock: SessionClock(
                  endsAt: DateTime.now().toUtc().add(
                    const Duration(minutes: 24),
                  ),
                  clockOffset: Duration.zero,
                  large: true,
                ),
                child: build(),
              ),
            ),
            cubit: cubit,
            size: size,
          );
          for (var i = 0; i < 6; i++) {
            await t.pump(const Duration(seconds: 1));
          }
          expect(t.takeException(), isNull);
          expect(
            find
                .byType(HostLayout)
                .evaluate()
                .map(
                  (e) => (e.widget as HostLayout).portrait,
                ),
            everyElement(size.width < size.height),
          );
          if (shotDir case final dir?) {
            final boundary =
                key.currentContext!.findRenderObject()!
                    as RenderRepaintBoundary;
            await t.runAsync(() async {
              final image = await boundary.toImage(
                pixelRatio: size.width > 1000 ? 0.5 : 1,
              );
              final png = await image.toByteData(
                format: ui.ImageByteFormat.png,
              );
              File(
                '$dir/${window}_$name.png',
              ).writeAsBytesSync(png!.buffer.asUint8List());
            });
          }
        });
      }
    });
  }

  for (final MapEntry(key: window, value: size) in windows.entries) {
    testWidgets('Given the host setup on a $window when it shows then '
        'nothing overflows and CREATE ROOM can be reached', (t) async {
      t.view.physicalSize = size;
      t.view.devicePixelRatio = 1;
      addTearDown(t.view.reset);
      final cubit = HostSetupCubit(MockLobbyRepository(), MockSeatRepository())
        ..setRule(EliminationRule.autoScaled);
      addTearDown(cubit.close);
      // A long AI pack in the preview: the heaviest version of the screen.
      final questions = MockQuestionsRepository();
      when(() => questions.aiAvailable()).thenAnswer((_) async => true);
      when(
        () => questions.generatePack(any(), any(), any(), any()),
      ).thenAnswer((_) async => samplePack(rounds: 25, finals: 7));
      final packs = QuestionPackCubit(questions)..setTopic('Nollywood');
      addTearDown(packs.close);
      await packs.start();
      await packs.generate(RoomConfig());
      await t.pumpWidget(
        MaterialApp(
          theme: AppTheme.dark(),
          home: MultiBlocProvider(
            providers: [
              BlocProvider.value(value: cubit),
              BlocProvider.value(value: packs),
            ],
            child: const HostSetupScreen(),
          ),
        ),
      );
      await t.pump();
      expect(t.takeException(), isNull);
      await t.scrollUntilVisible(
        find.byKey(const Key('create.submit')),
        200,
        scrollable: find.byType(Scrollable).first,
      );
      expect(
        find.byKey(const Key('create.submit')).hitTestable(),
        findsOneWidget,
      );
    });
  }
}
