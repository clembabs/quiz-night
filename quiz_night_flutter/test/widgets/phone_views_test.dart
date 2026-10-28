import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:quiz_night_client/quiz_night_client.dart';
import 'package:quiz_night_flutter/core/platform/haptics.dart';
import 'package:quiz_night_flutter/core/platform/share_image.dart';
import 'package:quiz_night_flutter/features/room/phone/phone_cut.dart';
import 'package:quiz_night_flutter/features/room/phone/phone_final.dart';
import 'package:quiz_night_flutter/features/room/phone/phone_placement.dart';
import 'package:quiz_night_flutter/features/room/phone/phone_question.dart';
import 'package:quiz_night_flutter/features/room/phone/phone_result.dart';
import 'package:quiz_night_flutter/features/room/phone/phone_waiting.dart';
import 'package:quiz_night_flutter/features/room/room_cubit.dart';

import '../fakes/fakes.dart';
import 'harness.dart';

const f = PlayerStatus.finalist;
const out = PlayerStatus.eliminated;

void main() {
  setUpAll(registerFallbacks);

  late MockRoomCubit cubit;
  late RecordingHaptics haptics;
  final later = DateTime.now().toUtc().add(const Duration(minutes: 5));

  setUp(() {
    cubit = MockRoomCubit();
    haptics = RecordingHaptics();
    when(() => cubit.state).thenReturn(const RoomViewState(seat: playerSeat));
    when(() => cubit.submitAnswer(any())).thenAnswer((_) async {});
    when(() => cubit.buzz()).thenAnswer((_) async {});
    when(() => cubit.submitBuzzAnswer(any())).thenAnswer((_) async {});
    when(() => cubit.backFinalist(any())).thenAnswer((_) async {});
    when(() => cubit.leave()).thenAnswer((_) async {});
  });

  Future<void> pump(WidgetTester t, Widget child) =>
      pumpScreen(t, child, cubit: cubit, haptics: haptics);

  group('Given the lobby', () {
    testWidgets('when waiting then you see you are in and the live count', (
      t,
    ) async {
      final me = player(1, 'Ọlá');
      await pump(
        t,
        PhoneWaiting(
          room: roomState(players: [me, player(2, 'Bo')]),
          me: me,
        ),
      );
      await t.pump(const Duration(seconds: 1));

      expect(find.text("YOU'RE IN!"), findsOneWidget);
      expect(find.text('Ọlá'), findsOneWidget);
      expect(find.text('players joined'), findsOneWidget);
      expect(find.text('Waiting for the host to start'), findsOneWidget);
      expect(
        find.textContaining('the bottom 30% go home'),
        findsOneWidget,
        reason: 'the rules are explained before the game',
      );
    });
  });

  group('Given an open question', () {
    RoomState open({bool showText = true, DateTime? endsAt}) => roomState(
      status: RoomStatus.question,
      question: question(),
      questionEndsAt: endsAt ?? later,
      players: [player(1, 'Ada'), player(2, 'Bo', hasAnswered: true)],
    ).copyWith(showQuestionOnPhones: showText);

    testWidgets('when tapping an option then it is sent with a haptic', (
      t,
    ) async {
      final room = open();
      await pump(
        t,
        PhoneQuestion(
          room: room,
          me: room.players.first,
          myChoice: null,
          clockOffset: Duration.zero,
        ),
      );
      await t.pump(const Duration(seconds: 1));

      expect(find.text('Capital of France?'), findsOneWidget);
      await t.tap(find.byKey(const Key('answer.1')));
      verify(() => cubit.submitAnswer(1)).called(1);
      expect(haptics.played, contains(HapticToken.medium));
    });

    testWidgets('when the host hides questions then the phone points at the '
        'big screen', (t) async {
      final room = open(showText: false);
      await pump(
        t,
        PhoneQuestion(
          room: room,
          me: room.players.first,
          myChoice: null,
          clockOffset: Duration.zero,
        ),
      );
      expect(find.text('Question is on the big screen'), findsOneWidget);
      expect(find.text('Capital of France?'), findsNothing);
    });

    testWidgets('when locked in then shows your pick and who has answered', (
      t,
    ) async {
      final room = open();
      await pump(
        t,
        PhoneQuestion(
          room: room,
          me: room.players.first,
          myChoice: 1,
          clockOffset: Duration.zero,
        ),
      );
      await t.pump(const Duration(seconds: 1));

      expect(find.text('ANSWER LOCKED IN'), findsOneWidget);
      expect(find.text('Paris'), findsOneWidget);
      expect(find.text('1/2 answered · waiting for others'), findsOneWidget);
    });

    testWidgets('when time runs out without an answer then too late', (
      t,
    ) async {
      final room = open(endsAt: DateTime.now().toUtc());
      await pump(
        t,
        PhoneQuestion(
          room: room,
          me: room.players.first,
          myChoice: null,
          clockOffset: Duration.zero,
        ),
      );
      await t.pump(const Duration(milliseconds: 200));
      expect(find.text('TOO LATE'), findsOneWidget);
    });

    testWidgets('when a spectator plays along then the banner says so', (
      t,
    ) async {
      final spectator = player(1, 'Cy', status: out, eliminatedInRound: 1);
      final room = open().copyWith(players: [spectator]);
      await pump(
        t,
        PhoneQuestion(
          room: room,
          me: spectator,
          myChoice: null,
          clockOffset: Duration.zero,
        ),
      );
      expect(
        find.text(
          'Eliminated in Round 1 · answers count for a shadow score',
        ),
        findsOneWidget,
      );
    });
  });

  group('Given a reveal', () {
    RoomState revealed(PlayerView me, {int? line}) => roomState(
      status: RoomStatus.reveal,
      question: question(revealed: true),
      players: [me, for (var i = 2; i <= 10; i++) player(i, 'P$i', score: 100)],
    ).copyWith(projectedSurvivors: line);

    testWidgets('when right then Correct, the points, rank and safe status', (
      t,
    ) async {
      final me = player(1, 'Ada', score: 1800, lastPoints: 850);
      await pump(
        t,
        PhoneResult(room: revealed(me, line: 7), me: me, myChoice: 1, move: 2),
      );
      await t.pump(const Duration(seconds: 2));

      expect(find.text('CORRECT'), findsOneWidget);
      expect(find.text('+850'), findsOneWidget);
      expect(find.text('1st'), findsOneWidget);
      expect(find.text('▲2'), findsOneWidget);
      expect(find.text('Safe'), findsOneWidget);
      expect(haptics.played, [HapticToken.success]);
    });

    testWidgets('when wrong then says the answer and plays the error haptic', (
      t,
    ) async {
      final me = player(1, 'Ada', lastPoints: 0);
      await pump(t, PhoneResult(room: revealed(me), me: me, myChoice: 0));
      await t.pump(const Duration(seconds: 2));

      expect(find.text('WRONG'), findsOneWidget);
      expect(find.text('+0 · answer was Paris'), findsOneWidget);
      expect(haptics.played, [HapticToken.error]);
    });

    testWidgets('when a spectator was right then the points are shadow', (
      t,
    ) async {
      final me = player(
        1,
        'Cy',
        status: out,
        eliminatedInRound: 1,
        lastPoints: 800,
        shadowScore: 1800,
      );
      await pump(t, PhoneResult(room: revealed(me), me: me, myChoice: 1));
      await t.pump(const Duration(seconds: 2));

      expect(find.text('+800 shadow'), findsOneWidget);
      expect(find.text('SHADOW SCORE'), findsOneWidget);
    });
  });

  group('Given a cut', () {
    RoomState cutRoom({bool finalists = false}) => roomState(
      status: RoomStatus.elimination,
      round: 1,
      lastElimination: cut(out: [3], survivors: 2, finalists: finalists),
      players: [
        player(1, 'Ada', status: finalists ? f : PlayerStatus.active),
        player(2, 'Bo', status: finalists ? f : PlayerStatus.active),
        player(3, 'Cy', status: out, eliminatedInRound: 1),
      ],
    );

    testWidgets('when your fate is not out yet then you wait in suspense', (
      t,
    ) async {
      final room = cutRoom();
      await pump(
        t,
        PhoneCut(
          room: room,
          me: room.players.first,
          createSequence: fastSequence,
        ),
      );
      expect(find.text('ARE YOU SAFE?'), findsOneWidget);
    });

    testWidgets('when you survive then the green screen and a celebration', (
      t,
    ) async {
      final room = cutRoom();
      await pump(
        t,
        PhoneCut(
          room: room,
          me: room.players.first,
          createSequence: fastSequence,
        ),
      );
      await t.pump(const Duration(seconds: 1));
      await t.pump(const Duration(seconds: 1));
      await t.pump(const Duration(seconds: 1));

      expect(find.text('YOU\nSURVIVED'), findsOneWidget);
      // Survivors see who went home, not just their own fate.
      expect(find.byKey(const Key('cut.goingHome')), findsOneWidget);
      expect(find.text('✕ Cy'), findsOneWidget);
      // A buzz as the name dropped, then the celebration.
      expect(haptics.played, [HapticToken.medium, HapticToken.celebrate]);
    });

    testWidgets('when you are out then the stamp, and you can keep watching', (
      t,
    ) async {
      when(() => cubit.keepWatchingAsSpectator()).thenReturn(null);
      final room = cutRoom();
      await pump(
        t,
        PhoneCut(room: room, me: room.players[2], createSequence: fastSequence),
      );
      await t.pump(const Duration(seconds: 1));
      await t.pump(const Duration(seconds: 1));

      expect(find.text('ELIMINATED'), findsOneWidget);
      expect(find.text('✕ OUT'), findsOneWidget);
      expect(find.byKey(const Key('cut.spectatorHint')), findsOneWidget);
      expect(haptics.played, [HapticToken.heavy]);
      await t.tap(find.byKey(const Key('cut.keepWatching')));
      verify(() => cubit.keepWatchingAsSpectator()).called(1);
    });

    testWidgets('when the host line arrives then the eliminated player sees '
        'it in quotes', (t) async {
      final room = cutRoom();
      await pump(
        t,
        PhoneCut(room: room, me: room.players[2], createSequence: fastSequence),
      );
      await t.pump(const Duration(seconds: 1));
      await t.pump(const Duration(seconds: 1));
      expect(find.textContaining('“'), findsNothing);

      final withLine = room.copyWith(
        players: [
          ...room.players.take(2),
          room.players[2].copyWith(exitLine: 'Cy packs up the pencil case.'),
        ],
      );
      await pump(
        t,
        PhoneCut(
          room: withLine,
          me: withLine.players[2],
          createSequence: fastSequence,
        ),
      );
      await t.pump(const Duration(seconds: 1));
      await t.pump(const Duration(seconds: 1));
      await t.pumpAndSettle();
      expect(find.text('“Cy packs up the pencil case.”'), findsOneWidget);
    });

    testWidgets('when finalists are set and you keep watching then you can '
        'back one', (t) async {
      final room = cutRoom(finalists: true);
      await pump(
        t,
        PhoneCut(
          room: room,
          me: room.players[2],
          myBackedId: 2,
          keepWatching: true,
          createSequence: fastSequence,
        ),
      );
      for (var i = 0; i < 3; i++) {
        await t.pump(const Duration(seconds: 1));
      }

      expect(find.text('BACK A FINALIST'), findsOneWidget);
      expect(find.text('★ Backing'), findsOneWidget);
      await t.tap(find.byKey(const Key('back.1')));
      verify(() => cubit.backFinalist(1)).called(1);
    });
  });

  group('Given the buzzer final', () {
    RoomState finalRoom({int? holder, bool lockedOut = false}) => roomState(
      status: RoomStatus.buzzerFinal,
      question: question(isFinal: true),
      questionEndsAt: later,
      buzzerHolderId: holder,
      players: [
        player(1, 'Ada', status: f, lockedOut: lockedOut),
        player(2, 'Bo', status: f),
        player(3, 'Cy', status: out, eliminatedInRound: 1),
      ],
    );

    String prompt(WidgetTester t) =>
        t.widget<Text>(find.byKey(const Key('final.prompt'))).data!;

    testWidgets('when free to buzz then pressing BUZZ buzzes', (t) async {
      final room = finalRoom();
      await pump(
        t,
        PhoneBuzzer(
          room: room,
          me: room.players.first,
          myChoice: null,
          buzzing: false,
        ),
      );
      expect(find.text('BUZZ'), findsOneWidget);
      await t.press(find.byKey(const Key('buzz')));
      verify(() => cubit.buzz()).called(1);
    });

    testWidgets('when holding the buzzer then the options appear to tap', (
      t,
    ) async {
      final room = finalRoom(holder: 1);
      await pump(
        t,
        PhoneBuzzer(
          room: room,
          me: room.players.first,
          myChoice: null,
          buzzing: false,
        ),
      );
      expect(find.text('FIRST!'), findsOneWidget);
      await t.tap(find.byKey(const Key('final.answer.1')));
      verify(() => cubit.submitBuzzAnswer(1)).called(1);
    });

    testWidgets('when someone else buzzed then their name is on the buzzer', (
      t,
    ) async {
      final room = finalRoom(holder: 2);
      await pump(
        t,
        PhoneBuzzer(
          room: room,
          me: room.players.first,
          myChoice: null,
          buzzing: false,
        ),
      );
      expect(find.text('BO'), findsOneWidget);
      expect(prompt(t), 'If Bo is wrong, buzzing reopens.');
      await t.press(find.byKey(const Key('buzz')));
      verifyNever(() => cubit.buzz());
    });

    testWidgets('when another finalist misses then the others are told and '
        'feel it', (t) async {
      Widget buzzer(RoomState room) => PhoneBuzzer(
        room: room,
        me: room.players[1],
        myChoice: null,
        buzzing: false,
      );
      await pump(t, buzzer(finalRoom()));
      expect(prompt(t), 'Buzz first when you know the answer.');

      await pump(t, buzzer(finalRoom(lockedOut: true)));
      expect(prompt(t), 'Ada got it wrong. Buzz now!');
      expect(haptics.played, contains(HapticToken.medium));
    });

    testWidgets('when locked out then the buzzer is locked', (t) async {
      final room = finalRoom(lockedOut: true);
      await pump(
        t,
        PhoneBuzzer(
          room: room,
          me: room.players.first,
          myChoice: null,
          buzzing: false,
        ),
      );
      expect(find.text('LOCKED'), findsOneWidget);
    });

    testWidgets('when a spectator watches then they see desks and who they '
        'backed', (t) async {
      final room = finalRoom(holder: 1);
      await pump(
        t,
        PhoneWatching(room: room, me: room.players[2], myBackedId: 2),
      );
      expect(find.text('Buzzed first'), findsOneWidget);
      expect(find.text('You backed Bo'), findsOneWidget);
      expect(prompt(t), 'Ada is answering…');
    });
  });

  group('Given the game is over', () {
    final room = roomState(
      status: RoomStatus.finished,
      players: [
        player(1, 'Ada', status: f, finalScore: 3000),
        player(2, 'Bo', status: f, finalScore: 1000),
        player(3, 'Cy', status: out, eliminatedInRound: 1, backedPlayerId: 1),
      ],
    );

    testWidgets('when the champion looks then 1st and Champion', (t) async {
      await pump(t, PhonePlacement(room: room, me: room.players.first));
      await t.pump(const Duration(seconds: 1));
      expect(find.text('1st'), findsOneWidget);
      expect(find.text('CHAMPION'), findsOneWidget);
    });

    testWidgets('when a spectator looks then their place and Done leaves', (
      t,
    ) async {
      await pump(t, PhonePlacement(room: room, me: room.players[2]));
      await t.pump(const Duration(seconds: 1));
      expect(find.text('3rd'), findsOneWidget);
      expect(find.text('ELIMINATED · ROUND 1'), findsOneWidget);
      await t.tap(find.text('Done'));
      verify(() => cubit.leave()).called(1);
    });

    testWidgets('when sharing the result then the card goes to the share sheet '
        'as a full-size PNG, with the brag text', (t) async {
      Uint8List? sentPng;
      String? sentText;
      Future<ShareOutcome> share(
        Uint8List png, {
        required String fileName,
        required String text,
      }) async {
        sentPng = png;
        sentText = text;
        return ShareOutcome.shared;
      }

      await pump(
        t,
        PhonePlacement(room: room, me: room.players.first, share: share),
      );
      await t.pump(const Duration(seconds: 1));
      await t.tap(find.byKey(const Key('placement.share')));
      await t.pumpAndSettle();
      expect(find.byKey(const Key('card.place')), findsOneWidget);
      expect(find.text('CHAMPION'), findsNWidgets(2));

      await t.tap(find.byKey(const Key('card.share')));
      // Encoding the image needs real time, not the test clock.
      await t.runAsync(() => Future<void>.delayed(const Duration(seconds: 1)));
      await t.pump();
      expect(sentText, startsWith('I won Quiz Night!'));
      // PNG signature, at 1080 wide (3× the 360 design).
      expect(sentPng!.sublist(1, 4), 'PNG'.codeUnits);
      final width = ByteData.sublistView(sentPng!, 16, 20).getUint32(0);
      expect(width, 1080);
      expect(find.byKey(const Key('card.status')), findsNothing);
    });

    testWidgets('when the browser can only download then the sheet says it '
        'was saved', (t) async {
      Future<ShareOutcome> share(
        Uint8List png, {
        required String fileName,
        required String text,
      }) async => ShareOutcome.downloaded;

      await pump(
        t,
        PhonePlacement(room: room, me: room.players[2], share: share),
      );
      await t.pump(const Duration(seconds: 1));
      await t.tap(find.byKey(const Key('placement.share')));
      await t.pumpAndSettle();
      expect(find.text('OUT IN ROUND 1'), findsOneWidget);
      expect(find.text('✓ Backed the winner'), findsOneWidget);

      await t.tap(find.byKey(const Key('card.share')));
      await t.runAsync(() => Future<void>.delayed(const Duration(seconds: 1)));
      await t.pump();
      expect(
        t.widget<Text>(find.byKey(const Key('card.status'))).data,
        startsWith('Saved to your downloads'),
      );
    });
  });
}
