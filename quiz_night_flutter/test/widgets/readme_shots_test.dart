import 'dart:io';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:quiz_night_client/quiz_night_client.dart';
import 'package:quiz_night_flutter/data/seat.dart';
import 'package:quiz_night_flutter/features/room/cut_reveal/reveal_sequence_cubit.dart';
import 'package:quiz_night_flutter/features/room/final/result_summary.dart';
import 'package:quiz_night_flutter/features/room/host/host_cut.dart';
import 'package:quiz_night_flutter/features/room/host/host_final.dart';
import 'package:quiz_night_flutter/features/room/host/host_lobby.dart';
import 'package:quiz_night_flutter/features/room/host/host_podium.dart';
import 'package:quiz_night_flutter/features/room/host/host_question.dart';
import 'package:quiz_night_flutter/features/room/host/host_standings.dart';
import 'package:quiz_night_flutter/features/room/phone/phone_cut.dart';
import 'package:quiz_night_flutter/features/room/phone/phone_final.dart';
import 'package:quiz_night_flutter/features/room/phone/phone_question.dart';
import 'package:quiz_night_flutter/features/room/phone/result_card.dart';
import 'package:quiz_night_flutter/features/room/room_cubit.dart';
import 'package:quiz_night_flutter/widgets/qn/host_stage.dart';
import 'package:quiz_night_flutter/widgets/qn/phone_frame.dart';
import 'package:quiz_night_flutter/widgets/qn/session_clock.dart';

import '../fakes/fakes.dart';
import 'harness.dart';

/// The README's screenshots, with realistic names and questions. With
/// SHOT_DIR set they are saved there with the real fonts (`make shots`);
/// otherwise this only checks that each screen lays out.
final shotDir = Platform.environment['SHOT_DIR'];

const f = PlayerStatus.finalist;
const out = PlayerStatus.eliminated;
const phone = Size(390, 844);

const names = [
  'Ada', 'Bolanle', 'Chidi', 'Dayo', 'Efe', 'Funmi', 'Gbenga', 'Hadiza', //
  'Ifeoma', 'Jide', 'Kemi', 'Lola',
];

List<PlayerView> crowd(int n, {int top = 9400}) => [
  for (var i = 0; i < n; i++) player(i + 1, names[i], score: top - i * 640),
];

QuestionView redPlanet({bool revealed = false, bool isFinal = false}) =>
    QuestionView(
      id: 10,
      round: 2,
      indexInRound: 3,
      isFinal: isFinal,
      text: isFinal
          ? 'Which country hosted the first FIFA World Cup in 1930?'
          : 'Which planet is known as the Red Planet?',
      options: isFinal
          ? const ['Brazil', 'Uruguay', 'Italy', 'England']
          : const ['Venus', 'Mars', 'Jupiter', 'Mercury'],
      timeLimitSeconds: 20,
      correctIndex: revealed ? 1 : null,
    );

void main() {
  setUpAll(registerFallbacks);
  final soon = DateTime.now().toUtc().add(const Duration(seconds: 14));
  final gameClock = DateTime.now().toUtc().add(const Duration(minutes: 21));

  final projector = <String, (String, Widget Function())>{
    'projector-lobby': (
      'Lobby',
      () => HostLobby(
        room: roomState(code: '4821', players: crowd(9)),
        appUrl: Uri.parse('https://quiznight.serverpod.space/'),
      ),
    ),
    'projector-question': (
      'Round 2 · Question 3 of 5',
      () => HostQuestion(
        room: roomState(
          status: RoomStatus.question,
          round: 2,
          players: [
            for (final (i, p) in crowd(9).indexed)
              p.copyWith(hasAnswered: i.isEven),
          ],
          question: redPlanet(),
          questionEndsAt: soon,
        ),
        clockOffset: Duration.zero,
      ),
    ),
    'projector-standings': (
      'Leaderboard',
      () => HostStandings(
        room: roomState(
          status: RoomStatus.reveal,
          round: 2,
          players: crowd(9),
          question: redPlanet(revealed: true),
        ).copyWith(projectedSurvivors: 6),
        rankMoves: const {2: 1, 3: -1, 7: 2},
      ),
    ),
    'projector-cut': (
      'Round 2 · elimination',
      () => HostCut(
        room: roomState(
          status: RoomStatus.elimination,
          round: 2,
          players: [
            ...crowd(6),
            player(
              7,
              'Gbenga',
              status: out,
              eliminatedInRound: 2,
              score: 3200,
              exitLine: 'Gbenga, three sides were just too many for round two.',
            ),
            player(
              8,
              'Hadiza',
              status: out,
              eliminatedInRound: 2,
              score: 2900,
              exitLine: 'Jupiter remains a mystery for Hadiza. Safe home!',
            ),
          ],
          lastElimination: cut(round: 2, out: [8, 7], survivors: 6),
        ),
        createSequence: (n) => RevealSequenceCubit(total: n)..skip(),
      ),
    ),
    'projector-final': (
      'Final',
      () => HostFinal(
        room: roomState(
          status: RoomStatus.buzzerFinal,
          players: [
            player(1, 'Ada', status: f, finalScore: 1000),
            player(2, 'Bolanle', status: f),
            player(3, 'Chidi', status: f, finalScore: 1000),
          ],
          question: redPlanet(isFinal: true),
          questionEndsAt: soon,
          buzzerHolderId: 2,
          finalQuestionsPlayed: 1,
        ),
        clockOffset: Duration.zero,
      ),
    ),
    'projector-podium': (
      'Results',
      () => HostPodium(
        room: roomState(
          status: RoomStatus.finished,
          players: [
            player(1, 'Ada', status: f, finalScore: 3000),
            player(2, 'Bolanle', status: f, finalScore: 2000),
            player(3, 'Chidi', status: f, finalScore: 1000),
            player(4, 'Dayo', status: out, backedPlayerId: 1, shadowScore: 900),
            player(5, 'Efe', status: out, backedPlayerId: 1, shadowScore: 600),
            player(6, 'Funmi', status: out, backedPlayerId: 3),
          ],
        ),
      ),
    ),
  };

  final me = player(4, 'Dayo', score: 6000);
  final phones = <String, (String, Widget Function())>{
    'phone-question': (
      'Round 2',
      () => PhoneQuestion(
        room: roomState(
          status: RoomStatus.question,
          round: 2,
          players: [...crowd(3), me],
          question: redPlanet(),
          questionEndsAt: soon,
        ),
        me: me,
        myChoice: null,
        clockOffset: Duration.zero,
      ),
    ),
    'phone-eliminated': (
      'Round 2',
      () {
        final gone = player(
          8,
          'Hadiza',
          status: out,
          eliminatedInRound: 2,
          exitLine: 'Jupiter remains a mystery for Hadiza. Safe home!',
        );
        return PhoneCut(
          room: roomState(
            status: RoomStatus.elimination,
            round: 2,
            players: [...crowd(6), gone],
            lastElimination: cut(round: 2, out: [8], survivors: 6),
          ),
          me: gone,
          createSequence: (n) => RevealSequenceCubit(total: n)..skip(),
        );
      },
    ),
    'phone-buzzer': (
      'Final',
      () {
        final finalist = player(2, 'Bolanle', status: f);
        return PhoneBuzzer(
          room: roomState(
            status: RoomStatus.buzzerFinal,
            players: [
              player(1, 'Ada', status: f),
              finalist,
            ],
            question: redPlanet(isFinal: true),
            questionEndsAt: soon,
          ),
          me: finalist,
          myChoice: null,
          buzzing: false,
        );
      },
    ),
  };

  Future<void> save(WidgetTester t, GlobalKey key, String name, double ratio) =>
      t.runAsync(() async {
        final boundary =
            key.currentContext!.findRenderObject()! as RenderRepaintBoundary;
        final image = await boundary.toImage(pixelRatio: ratio);
        final png = await image.toByteData(format: ui.ImageByteFormat.png);
        File('$shotDir/$name.png').writeAsBytesSync(png!.buffer.asUint8List());
      });

  Future<MockRoomCubit> room(Seat seat) async {
    final cubit = MockRoomCubit();
    when(() => cubit.state).thenReturn(RoomViewState(seat: seat));
    return cubit;
  }

  for (final MapEntry(key: name, value: (label, build)) in projector.entries) {
    testWidgets('README $name lays out', (t) async {
      if (shotDir != null) await loadRealFonts();
      final key = GlobalKey();
      await pumpScreen(
        t,
        RepaintBoundary(
          key: key,
          child: HostStage(
            topLabel: label,
            code: '4821',
            actions: [HostTextButton(label: 'Leave', onPressed: () {})],
            // No game clock before the start or after the end.
            clock: name == 'projector-lobby' || name == 'projector-podium'
                ? null
                : SessionClock(
                    endsAt: gameClock,
                    clockOffset: Duration.zero,
                    large: true,
                  ),
            child: build(),
          ),
        ),
        cubit: await room(hostSeat),
        size: hostCanvas,
      );
      for (var i = 0; i < 4; i++) {
        await t.pump(const Duration(seconds: 1));
      }
      expect(t.takeException(), isNull);
      if (shotDir != null) await save(t, key, name, 2 / 3);
    });
  }

  for (final MapEntry(key: name, value: (phase, build)) in phones.entries) {
    testWidgets('README $name lays out', (t) async {
      if (shotDir != null) await loadRealFonts();
      final key = GlobalKey();
      await pumpScreen(
        t,
        RepaintBoundary(
          key: key,
          child: PhoneFrame(code: '4821', phase: phase, child: build()),
        ),
        cubit: await room(playerSeat),
        size: phone,
      );
      for (var i = 0; i < 4; i++) {
        await t.pump(const Duration(seconds: 1));
      }
      expect(t.takeException(), isNull);
      if (shotDir != null) await save(t, key, name, 2);
    });
  }

  testWidgets('README result card lays out', (t) async {
    if (shotDir != null) await loadRealFonts();
    final key = GlobalKey();
    await t.pumpWidget(
      MaterialApp(
        home: Center(
          child: RepaintBoundary(
            key: key,
            child: const ResultCard(
              site: 'quiznight.serverpod.space',
              result: ResultSummary(
                place: 5,
                playerCount: 12,
                nickname: 'Hadiza',
                title: 'Out in round 2',
                champion: false,
                roundsSurvived: 1,
                points: 2900,
                backedWinner: true,
                hostLine: 'Jupiter remains a mystery for Hadiza. Safe home!',
              ),
            ),
          ),
        ),
      ),
    );
    expect(t.takeException(), isNull);
    if (shotDir != null) await save(t, key, 'result-card', 2);
  });
}
