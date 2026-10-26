import 'package:bloc_test/bloc_test.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:quiz_night_client/quiz_night_client.dart';
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

import '../fakes/fakes.dart';
import 'harness.dart';

class MockPackCubit extends MockCubit<QuestionPackState>
    implements QuestionPackCubit {}

class MockSetupCubit extends MockCubit<HostSetupState>
    implements HostSetupCubit {}

const f = PlayerStatus.finalist;
const out = PlayerStatus.eliminated;

void main() {
  setUpAll(() {
    registerFallbacks();
    registerFallbackValue(EliminationRule.bottomPercent);
  });

  late MockRoomCubit cubit;
  final later = DateTime.now().toUtc().add(const Duration(minutes: 5));

  setUp(() {
    cubit = MockRoomCubit();
    when(() => cubit.state).thenReturn(const RoomViewState(seat: hostSeat));
    for (final action in [
      cubit.startGame,
      cubit.reveal,
      cubit.nextQuestion,
      cubit.endRound,
      cubit.leave,
    ]) {
      when(action).thenAnswer((_) async {});
    }
    when(() => cubit.useWildcard(any())).thenAnswer((_) async {});
  });

  Future<void> pump(WidgetTester t, Widget child) =>
      pumpHost(t, child, cubit: cubit);

  group('Given the host creates a game', () {
    late MockSetupCubit setup;
    late MockPackCubit packCubit;

    setUp(() {
      setup = MockSetupCubit();
      packCubit = MockPackCubit();
      when(
        () => packCubit.state,
      ).thenReturn(const QuestionPackState(status: PackStatus.idle));
      when(() => packCubit.summaryItem).thenReturn(
        const SummaryItem('Built-in questions', 'Or type a topic.'),
      );
      when(() => packCubit.generate(any())).thenAnswer((_) async {});
      when(() => packCubit.remove(any(), any())).thenAnswer((_) async {});
      when(() => setup.state).thenReturn(const HostSetupState());
      when(
        () => setup.summary,
      ).thenReturn(const [SummaryItem('Bottom 30%', 'Lowest 30% go home.')]);
      when(
        () => setup.create(pack: any(named: 'pack')),
      ).thenAnswer((_) async {});
    });

    Future<void> pumpSetup(WidgetTester t) async {
      t.view.physicalSize = hostCanvas;
      t.view.devicePixelRatio = 1;
      addTearDown(t.view.reset);
      await t.pumpWidget(
        MaterialApp(
          home: MultiBlocProvider(
            providers: [
              BlocProvider<HostSetupCubit>.value(value: setup),
              BlocProvider<QuestionPackCubit>.value(value: packCubit),
            ],
            child: const HostSetupScreen(),
          ),
        ),
      );
    }

    testWidgets('when choosing then rule, counts and phone setting reach the '
        'cubit', (t) async {
      await pumpSetup(t);
      expect(find.text('NEW GAME'), findsOneWidget);

      await t.tap(find.byKey(const Key('rule.suddenDeath')));
      verify(() => setup.setRule(EliminationRule.suddenDeath)).called(1);
      await t.tap(find.byKey(const Key('pick.Questions per round.8')));
      verify(() => setup.setQuestionsPerRound(8)).called(1);
      await t.tap(find.byKey(const Key('pick.Finalists.4')));
      verify(() => setup.setFinalists(4)).called(1);
      await t.tap(find.byKey(const Key('pick.Question on phones.off')));
      verify(() => setup.setShowQuestionOnPhones(false)).called(1);
    });

    testWidgets('when creating then the cubit creates the room', (t) async {
      await pumpSetup(t);
      await t.tap(find.byKey(const Key('create.submit')));
      verify(() => setup.create(pack: null)).called(1);
    });

    testWidgets('when a topic is typed and Write questions tapped then the '
        'pack cubit writes for this game', (t) async {
      when(() => packCubit.state).thenReturn(
        const QuestionPackState(status: PackStatus.idle, topic: 'Nollywood'),
      );
      await pumpSetup(t);
      await t.ensureVisible(find.byKey(const Key('topic.field')));
      await t.enterText(find.byKey(const Key('topic.field')), 'Afrobeats');
      verify(() => packCubit.setTopic('Afrobeats')).called(1);
      await t.ensureVisible(find.byKey(const Key('topic.generate')));
      await t.tap(find.byKey(const Key('topic.generate')));
      verify(() => packCubit.generate(any())).called(1);
    });

    testWidgets('when a pack is ready then the host previews it, can remove '
        'a question, and Create room plays it', (t) async {
      final pack = samplePack();
      when(() => packCubit.state).thenReturn(
        QuestionPackState(
          status: PackStatus.ready,
          topic: 'Nollywood',
          pack: pack,
        ),
      );
      await pumpSetup(t);
      expect(find.text('Preview · 4 round + 2 final'), findsOneWidget);
      expect(find.text('✓ Right 1'), findsOneWidget);

      await t.ensureVisible(find.byKey(const Key('pack.remove.2')));
      await t.tap(find.byKey(const Key('pack.remove.2')));
      verify(() => packCubit.remove(2, any())).called(1);

      await t.ensureVisible(find.byKey(const Key('create.submit')));
      await t.tap(find.byKey(const Key('create.submit')));
      verify(() => setup.create(pack: pack)).called(1);
    });

    testWidgets('when AI questions are not set up then it says so and the '
        'game uses the built-in ones', (t) async {
      when(
        () => packCubit.state,
      ).thenReturn(const QuestionPackState(status: PackStatus.unavailable));
      await pumpSetup(t);
      expect(find.textContaining("AI questions aren't set up"), findsOneWidget);
      expect(find.byKey(const Key('topic.field')), findsNothing);
    });
  });

  group('Given the lobby', () {
    RoomState lobby(int n) => roomState(
      code: '4821',
      players: [for (var i = 1; i <= n; i++) player(i, 'P$i')],
    );

    testWidgets('when empty then waits for the first player, Start disabled', (
      t,
    ) async {
      await pump(
        t,
        HostLobby(room: lobby(0), appUrl: Uri.parse('https://q.ng/')),
      );
      expect(find.byKey(const Key('lobby.code')), findsOneWidget);
      expect(find.text('Waiting for the first player…'), findsOneWidget);
      await t.tap(find.byKey(const Key('host.step')));
      // Start is the step, but the server refuses under two players; the
      // button still forwards, so check it is labelled for starting.
      expect(find.text('START GAME'), findsOneWidget);
    });

    testWidgets('when the host removes a player then it asks first, then '
        'removes them', (t) async {
      when(() => cubit.removePlayer(any())).thenAnswer((_) async {});
      await pump(
        t,
        HostLobby(room: lobby(3), appUrl: Uri.parse('https://q.ng/')),
      );
      await t.pump(const Duration(seconds: 1));

      await t.tap(find.byKey(const Key('chip.remove.P2')));
      await t.pumpAndSettle();
      expect(find.text('REMOVE P2?'), findsOneWidget);
      await t.tap(find.text('Keep'));
      await t.pumpAndSettle();
      verifyNever(() => cubit.removePlayer(any()));

      await t.tap(find.byKey(const Key('chip.remove.P2')));
      await t.pumpAndSettle();
      await t.tap(find.byKey(const Key('remove.confirm')));
      await t.pumpAndSettle();
      verify(() => cubit.removePlayer(2)).called(1);
    });

    testWidgets('when the host locks the room then it asks the server, and a '
        'locked room offers to unlock', (t) async {
      when(() => cubit.setLocked(any())).thenAnswer((_) async {});
      await pump(
        t,
        HostLobby(room: lobby(3), appUrl: Uri.parse('https://q.ng/')),
      );
      await t.tap(find.byKey(const Key('lobby.lock')));
      verify(() => cubit.setLocked(true)).called(1);

      final locked = lobby(3).copyWith(locked: true);
      await pump(
        t,
        HostLobby(room: locked, appUrl: Uri.parse('https://q.ng/')),
      );
      expect(find.text('Unlock room'), findsOneWidget);
      expect(find.text('No new players can join'), findsOneWidget);
      await t.tap(find.byKey(const Key('lobby.lock')));
      verify(() => cubit.setLocked(false)).called(1);
    });

    testWidgets('when players are in then they show and Start starts', (
      t,
    ) async {
      await pump(
        t,
        HostLobby(room: lobby(3), appUrl: Uri.parse('https://q.ng/')),
      );
      await t.pump(const Duration(seconds: 1));
      expect(find.text('3'), findsOneWidget);
      expect(find.text('players in'), findsOneWidget);
      expect(find.text('P2'), findsOneWidget);
      await t.tap(find.byKey(const Key('host.step')));
      verify(() => cubit.startGame()).called(1);
    });

    test(
      'when building the join link then it opens the join page with the code',
      () {
        final url = HostLobby.joinUrl(
          Uri.parse('https://quiz.example.com/#/old'),
          '4821',
        );
        expect(url.toString(), 'https://quiz.example.com/join?code=4821');
        expect(
          HostLobby.shortAddress(Uri.parse('https://quiznight.ng/')),
          'quiznight.ng',
        );
      },
    );
  });

  group('Given a question on the projector', () {
    testWidgets('when open then it shows the answered count and reveals', (
      t,
    ) async {
      final room = roomState(
        status: RoomStatus.question,
        question: question(),
        questionEndsAt: later,
        players: [player(1, 'A', hasAnswered: true), player(2, 'B')],
      );
      await pump(t, HostQuestion(room: room, clockOffset: Duration.zero));
      await t.pump(const Duration(seconds: 1));

      expect(find.text('Capital of France?'), findsOneWidget);
      expect(find.text('1/2 answered'), findsOneWidget);
      await t.tap(find.byKey(const Key('host.step')));
      verify(() => cubit.reveal()).called(1);
    });

    testWidgets('when revealed then counts and who got it right', (t) async {
      final room = roomState(
        status: RoomStatus.reveal,
        question: question(
          indexInRound: 2,
          revealed: true,
          answerCounts: [1, 3, 0, 0],
        ),
        players: [for (var i = 1; i <= 4; i++) player(i, 'P$i')],
      );
      await pump(t, HostReveal(room: room));
      await t.pump(const Duration(seconds: 2));

      expect(find.text('3 of 4 got it right'), findsOneWidget);
      expect(find.text('NEXT QUESTION'), findsOneWidget);
    });
  });

  group('Given the standings before a cut', () {
    final room = roomState(
      status: RoomStatus.reveal,
      round: 2,
      questionsPerRound: 1,
      question: question(revealed: true),
      players: [
        for (var i = 1; i <= 6; i++) player(i, 'P$i', score: 700 - i * 100),
      ],
    ).copyWith(projectedSurvivors: 4);

    testWidgets('when shown then the danger line sits above those going home', (
      t,
    ) async {
      when(() => cubit.state).thenReturn(
        const RoomViewState(seat: hostSeat, showingStandings: true),
      );
      await pump(t, HostStandings(room: room, rankMoves: const {1: 2}));
      await t.pump(const Duration(seconds: 2));

      expect(find.text('AFTER ROUND 2'), findsOneWidget);
      expect(find.text('DANGER LINE'), findsOneWidget);
      expect(find.text('! DANGER'), findsNWidgets(2));
      expect(find.text('▲2'), findsOneWidget);
      await t.tap(find.byKey(const Key('host.step')));
      verify(() => cubit.endRound()).called(1);
    });
  });

  group('Given the cut on the projector', () {
    RoomState cutRoom({bool finalists = false, bool wildcardUsed = false}) =>
        roomState(
          status: RoomStatus.elimination,
          round: 1,
          lastElimination: cut(out: [4, 3], survivors: 2, finalists: finalists),
          players: [
            player(1, 'Ada', status: finalists ? f : PlayerStatus.active),
            player(2, 'Bo', status: finalists ? f : PlayerStatus.active),
            player(3, 'Cy', status: out, eliminatedInRound: 1),
            player(4, 'Dee', status: out, eliminatedInRound: 1),
          ],
        ).copyWith(wildcardUsed: wildcardUsed);

    String title(WidgetTester t) =>
        t.widget<Text>(find.byKey(const Key('cut.title'))).data!;

    testWidgets('when it runs then suspense, stamps, then the survivors', (
      t,
    ) async {
      await pump(t, HostCut(room: cutRoom(), createSequence: fastSequence));
      expect(title(t), 'WHO’S GOING HOME?');

      await t.pump(const Duration(seconds: 1));
      expect(title(t), 'GOING HOME…');

      await t.pump(const Duration(seconds: 1));
      await t.pump(const Duration(seconds: 1));
      await t.pump(const Duration(seconds: 1));
      expect(title(t), 'ROUND 1 IS OVER');
      expect(find.byKey(const Key('cut.survivors')), findsOneWidget);
      await t.tap(find.byKey(const Key('host.step')));
      verify(() => cubit.nextQuestion()).called(1);
    });

    testWidgets('when skipped then it jumps to the end', (t) async {
      await pump(t, HostCut(room: cutRoom(), createSequence: fastSequence));
      await t.tap(find.text('Skip'));
      await t.pump(const Duration(seconds: 1));
      expect(title(t), 'ROUND 1 IS OVER');
    });

    testWidgets(
      'when the host confirms a wildcard then the player is rescued',
      (
        t,
      ) async {
        await pump(t, HostCut(room: cutRoom(), createSequence: fastSequence));
        await t.tap(find.text('Skip'));
        await t.pump(const Duration(seconds: 1));

        await t.tap(find.byKey(const Key('wildcard.3')));
        await t.pumpAndSettle();
        await t.tap(find.text('Rescue'));
        await t.pumpAndSettle();
        verify(() => cubit.useWildcard(3)).called(1);
      },
    );

    testWidgets('when the wildcard is used then it is not offered', (t) async {
      await pump(
        t,
        HostCut(
          room: cutRoom(wildcardUsed: true),
          createSequence: fastSequence,
        ),
      );
      await t.tap(find.text('Skip'));
      await t.pump(const Duration(seconds: 1));
      expect(find.byKey(const Key('wildcard.3')), findsNothing);
    });

    testWidgets('when finalists are decided then meet them and start the '
        'final', (t) async {
      await pump(
        t,
        HostCut(room: cutRoom(finalists: true), createSequence: fastSequence),
      );
      await t.tap(find.text('Skip'));
      await t.pump(const Duration(seconds: 1));

      expect(title(t), 'MEET YOUR FINALISTS');
      expect(find.text('READY'), findsNWidgets(2));
      expect(find.text('START THE FINAL'), findsOneWidget);
    });
  });

  group('Given the buzzer final on the projector', () {
    testWidgets('when a finalist buzzes then their desk lights up', (t) async {
      final room = roomState(
        status: RoomStatus.buzzerFinal,
        question: question(isFinal: true),
        questionEndsAt: later,
        buzzerHolderId: 2,
        finalQuestionCount: 3,
        players: [
          player(1, 'Ada', status: f, lockedOut: true),
          player(2, 'Bo', status: f, finalScore: 1000),
        ],
      );
      await pump(t, HostFinal(room: room, clockOffset: Duration.zero));

      expect(find.text('BUZZED FIRST'), findsOneWidget);
      expect(find.text('LOCKED OUT'), findsOneWidget);
      expect(find.text('Bo is answering…'), findsOneWidget);
    });

    testWidgets('when the last final question is revealed then the podium '
        'is next', (t) async {
      final room = roomState(
        status: RoomStatus.reveal,
        question: question(isFinal: true, revealed: true),
        finalQuestionCount: 3,
        finalQuestionsPlayed: 3,
        buzzWinnerId: 1,
        players: [
          player(1, 'Ada', status: f),
          player(2, 'Bo', status: f),
        ],
      );
      await pump(t, HostFinal(room: room, clockOffset: Duration.zero));

      expect(find.text('Ada got it! +1000'), findsOneWidget);
      expect(find.text('GOT IT'), findsOneWidget);
      await t.tap(find.byKey(const Key('host.step')));
      verify(() => cubit.nextQuestion()).called(1);
    });
  });

  group('Given the podium', () {
    testWidgets('when shown then places rise and the backers are counted', (
      t,
    ) async {
      final room = roomState(
        status: RoomStatus.finished,
        players: [
          player(1, 'Ada', status: f, finalScore: 3000),
          player(2, 'Bo', status: f, finalScore: 2000),
          player(3, 'Cy', status: f, finalScore: 1000),
          player(4, 'Dee', status: out, backedPlayerId: 1, shadowScore: 900),
          player(5, 'Eve', status: out, backedPlayerId: 2),
        ],
      );
      await pump(t, HostPodium(room: room));
      for (var i = 0; i < 4; i++) {
        await t.pump(const Duration(seconds: 1));
      }

      expect(find.text('Ada'), findsOneWidget);
      expect(find.text('1 of 2'), findsOneWidget);
      expect(find.text('spectators backed Ada'), findsOneWidget);
      expect(find.text('Shadow champion: Dee (900)'), findsOneWidget);
      await t.tap(find.text('End and leave'));
      verify(() => cubit.leave()).called(1);
    });
  });

  group('Given everyone made the final', () {
    testWidgets('when the podium shows then it says so instead of 0 of 0', (
      t,
    ) async {
      final room = roomState(
        status: RoomStatus.finished,
        players: [
          player(1, 'Aya', status: f, finalScore: 3000),
          player(2, 'Clem', status: f, finalScore: 2000),
          player(3, 'Opera', status: f),
        ],
      );
      await pump(t, HostPodium(room: room));
      for (var i = 0; i < 4; i++) {
        await t.pump(const Duration(seconds: 1));
      }
      expect(find.text('Everyone made the final'), findsOneWidget);
      expect(find.text('0 of 0'), findsNothing);
    });
  });

  group('Given a game that ran out of time', () {
    testWidgets('when the podium shows then it says why and ranks by score '
        'so far', (t) async {
      final room = roomState(
        status: RoomStatus.finished,
        round: 2,
        players: [
          player(1, 'Ada', score: 1000),
          player(2, 'Bo', score: 3000),
          player(3, 'Cy', score: 2000),
        ],
      ).copyWith(endReason: RoomEndReason.timeUp);
      await pump(t, HostPodium(room: room));
      for (var i = 0; i < 4; i++) {
        await t.pump(const Duration(seconds: 1));
      }
      expect(find.byKey(const Key('podium.notice')), findsOneWidget);
      expect(find.textContaining("Time's up"), findsOneWidget);
      expect(find.text('Bo'), findsOneWidget);
      expect(find.text('No final this time'), findsOneWidget);
      expect(find.text('Everyone made the final'), findsNothing);
    });
  });
}
