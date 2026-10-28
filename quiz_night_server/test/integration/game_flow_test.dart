import 'dart:async';

import 'package:quiz_night_server/src/generated/protocol.dart';
import 'package:test/test.dart';

import 'test_tools/serverpod_test_tools.dart';

/// A test room with a host and some joined players.
class Game {
  final String code;
  final String hostToken;
  final List<JoinResult> players;
  Game(this.code, this.hostToken, this.players);
}

Future<Game> setUpGame(
  TestSessionBuilder sb,
  TestEndpoints endpoints, {
  int players = 5,
  RoomConfig? config,
}) async {
  final created = await endpoints.room.createRoom(
    sb,
    config ??
        RoomConfig(
          questionsPerRound: 1,
          finalistTarget: 3,
          finalQuestionCount: 1,
        ),
  );
  final joined = <JoinResult>[];
  for (var i = 0; i < players; i++) {
    joined.add(await endpoints.room.joinRoom(sb, created.roomCode, 'P$i'));
  }
  return Game(created.roomCode, created.hostToken, joined);
}

Future<Room> roomOf(TestSessionBuilder sb, String code) async => (await Room.db
    .findFirstRow(sb.build(), where: (t) => t.code.equals(code)))!;

Future<Question> currentQuestion(TestSessionBuilder sb, String code) async {
  final room = await roomOf(sb, code);
  return (await Question.db.findById(sb.build(), room.currentQuestionId!))!;
}

Future<Player> playerOf(TestSessionBuilder sb, JoinResult j) async =>
    (await Player.db.findById(sb.build(), j.playerId))!;

int wrong(Question q) => (q.correctIndex + 1) % q.options.length;

Matcher throwsQuiz(QuizErrorCode code) =>
    throwsA(isA<QuizException>().having((e) => e.code, 'code', code));

void main() {
  withServerpod('Given a 5-player room aiming for 3 finalists', (
    sb,
    endpoints,
  ) {
    test('when playing a full game then the bottom two are cut, '
        'the final is buzzed and the podium shows backers', () async {
      final g = await setUpGame(sb, endpoints);
      await endpoints.room.startGame(sb, g.code, g.hostToken);

      // Round 1: P0-P2 answer correctly, P3-P4 wrong.
      final q = await currentQuestion(sb, g.code);
      for (var i = 0; i < 5; i++) {
        final choice = i < 3 ? q.correctIndex : wrong(q);
        await endpoints.answer.submitAnswer(
          sb,
          g.players[i].playerToken,
          q.id!,
          choice,
        );
      }

      // Everyone answered, so the server revealed early.
      expect((await roomOf(sb, g.code)).status, RoomStatus.reveal);
      expect(
        (await playerOf(sb, g.players[0])).score,
        greaterThanOrEqualTo(500),
      );
      expect((await playerOf(sb, g.players[4])).score, 0);

      await endpoints.room.endRound(sb, g.code, g.hostToken);
      final room = await roomOf(sb, g.code);
      expect(room.status, RoomStatus.elimination);
      expect(room.lastElimination!.finalistsDecided, isTrue);
      expect(room.lastElimination!.eliminatedPlayerIds.toSet(), {
        g.players[3].playerId,
        g.players[4].playerId,
      });
      for (var i = 0; i < 3; i++) {
        expect(
          (await playerOf(sb, g.players[i])).status,
          PlayerStatus.finalist,
        );
      }
      expect(
        (await playerOf(sb, g.players[3])).status,
        PlayerStatus.eliminated,
      );

      // Spectator P3 backs P0.
      await endpoints.buzzer.backFinalist(
        sb,
        g.players[3].playerToken,
        g.players[0].playerId,
      );

      // Buzzer final: P0 buzzes and answers correctly.
      await endpoints.room.nextQuestion(sb, g.code, g.hostToken);
      expect((await roomOf(sb, g.code)).status, RoomStatus.buzzerFinal);
      final fq = await currentQuestion(sb, g.code);
      expect(fq.isFinal, isTrue);
      final buzz = await endpoints.buzzer.buzz(
        sb,
        g.players[0].playerToken,
        fq.id!,
      );
      expect(buzz.gotBuzzer, isTrue);
      final correct = await endpoints.buzzer.submitBuzzAnswer(
        sb,
        g.players[0].playerToken,
        fq.id!,
        fq.correctIndex,
      );
      expect(correct, isTrue);
      expect((await playerOf(sb, g.players[0])).finalScore, 1000);
      final revealed = await endpoints.room.watchRoom(sb, g.code).first;
      expect(revealed.status, RoomStatus.reveal);
      expect(revealed.buzzWinnerId, g.players[0].playerId);
      expect(revealed.question!.correctIndex, fq.correctIndex);

      // Last final question done -> podium.
      await endpoints.room.nextQuestion(sb, g.code, g.hostToken);
      expect((await roomOf(sb, g.code)).status, RoomStatus.finished);

      final state = await endpoints.room.watchRoom(sb, g.code).first;
      expect(state.status, RoomStatus.finished);
      expect(state.players.first.id, g.players[0].playerId);
      final backer = state.players.firstWhere(
        (p) => p.id == g.players[3].playerId,
      );
      expect(backer.backedPlayerId, g.players[0].playerId);
    });
  });

  withServerpod('Given a question is open', (sb, endpoints) {
    late Game g;
    late Question q;

    setUp(() async {
      g = await setUpGame(sb, endpoints, players: 3);
      await endpoints.room.startGame(sb, g.code, g.hostToken);
      q = await currentQuestion(sb, g.code);
    });

    test('when watching then the correct answer is not sent', () async {
      final state = await endpoints.room.watchRoom(sb, g.code).first;
      expect(state.status, RoomStatus.question);
      expect(state.question!.correctIndex, isNull);
      expect(state.question!.answerCounts, isNull);
      expect(state.questionEndsAt, isNotNull);
    });

    test('when revealed then the correct answer and counts are sent', () async {
      await endpoints.answer.submitAnswer(
        sb,
        g.players[0].playerToken,
        q.id!,
        q.correctIndex,
      );
      await endpoints.room.reveal(sb, g.code, g.hostToken);
      final state = await endpoints.room.watchRoom(sb, g.code).first;
      expect(state.question!.correctIndex, q.correctIndex);
      expect(state.question!.answerCounts![q.correctIndex], 1);
    });

    test('when answering twice then the second is rejected', () async {
      await endpoints.answer.submitAnswer(
        sb,
        g.players[0].playerToken,
        q.id!,
        q.correctIndex,
      );
      await expectLater(
        endpoints.answer.submitAnswer(
          sb,
          g.players[0].playerToken,
          q.id!,
          wrong(q),
        ),
        throwsQuiz(QuizErrorCode.alreadyAnswered),
      );
    });

    test('when answering after the deadline then it is rejected', () async {
      final room = await roomOf(sb, g.code);
      await Room.db.updateRow(
        sb.build(),
        room.copyWith(
          questionEndsAt: DateTime.now().toUtc().subtract(
            const Duration(seconds: 2),
          ),
        ),
      );
      await expectLater(
        endpoints.answer.submitAnswer(
          sb,
          g.players[0].playerToken,
          q.id!,
          q.correctIndex,
        ),
        throwsQuiz(QuizErrorCode.tooLate),
      );
    });

    test(
      'when answering with an out-of-range choice then it is rejected',
      () async {
        await expectLater(
          endpoints.answer.submitAnswer(sb, g.players[0].playerToken, q.id!, 9),
          throwsQuiz(QuizErrorCode.invalidInput),
        );
      },
    );

    test('when a non-host reveals then it is rejected', () async {
      await expectLater(
        endpoints.room.reveal(sb, g.code, 'not-the-host-token'),
        throwsQuiz(QuizErrorCode.notHost),
      );
    });

    test('when someone joins before the first cut then they play', () async {
      final late = await endpoints.room.joinRoom(sb, g.code, 'Late');
      final p = await playerOf(sb, late);
      expect(p.status, PlayerStatus.active);
      expect(p.eliminatedInRound, isNull);
    });

    test(
      'when the host has locked the room then late joiners are refused',
      () async {
        await endpoints.room.setLocked(sb, g.code, g.hostToken, true);
        await expectLater(
          endpoints.room.joinRoom(sb, g.code, 'Late'),
          throwsQuiz(QuizErrorCode.roomLocked),
        );
      },
    );
  });

  withServerpod('Given a round has been revealed', (sb, endpoints) {
    late Game g;

    setUp(() async {
      g = await setUpGame(
        sb,
        endpoints,
        players: 6,
        config: RoomConfig(questionsPerRound: 1, finalistTarget: 2),
      );
      await endpoints.room.startGame(sb, g.code, g.hostToken);
      final q = await currentQuestion(sb, g.code);
      for (var i = 0; i < 6; i++) {
        await endpoints.answer.submitAnswer(
          sb,
          g.players[i].playerToken,
          q.id!,
          i < 3 ? q.correctIndex : wrong(q),
        );
      }
    });

    test(
      'when ending the round twice then players are cut only once',
      () async {
        await endpoints.room.endRound(sb, g.code, g.hostToken);
        await endpoints.room.endRound(sb, g.code, g.hostToken);
        final players = await Player.db.find(sb.build());
        // 30% of 6 = 2 cut, 4 remain.
        expect(
          players.where((p) => p.status == PlayerStatus.eliminated),
          hasLength(2),
        );
        expect(
          players.where((p) => p.status == PlayerStatus.active),
          hasLength(4),
        );
      },
    );

    test(
      'when an eliminated player answers then it only counts as shadow',
      () async {
        await endpoints.room.endRound(sb, g.code, g.hostToken);
        final out = (await Player.db.find(
          sb.build(),
          where: (t) => t.status.equals(PlayerStatus.eliminated),
        )).first;
        final token = g.players
            .firstWhere((p) => p.playerId == out.id)
            .playerToken;

        await endpoints.room.nextQuestion(sb, g.code, g.hostToken);
        final q = await currentQuestion(sb, g.code);
        final result = await endpoints.answer.submitAnswer(
          sb,
          token,
          q.id!,
          q.correctIndex,
        );
        expect(result.isShadow, isTrue);
        final after = (await Player.db.findById(sb.build(), out.id!))!;
        expect(after.score, out.score);
        expect(after.shadowScore, greaterThan(0));
      },
    );

    test(
      'when the host uses the wildcard then the player is back, once',
      () async {
        await endpoints.room.endRound(sb, g.code, g.hostToken);
        final out = (await Player.db.find(
          sb.build(),
          where: (t) => t.status.equals(PlayerStatus.eliminated),
        )).first;
        await endpoints.room.useWildcard(sb, g.code, g.hostToken, out.id!);
        expect(
          (await Player.db.findById(sb.build(), out.id!))!.status,
          PlayerStatus.active,
        );
        await expectLater(
          endpoints.room.useWildcard(sb, g.code, g.hostToken, out.id!),
          throwsQuiz(QuizErrorCode.notAllowed),
        );
      },
    );
  });

  withServerpod('Given a lobby', (sb, endpoints) {
    test('when a nickname is reused in any case then it is rejected', () async {
      final g = await setUpGame(sb, endpoints, players: 1);
      await expectLater(
        endpoints.room.joinRoom(sb, g.code, 'p0'),
        throwsQuiz(QuizErrorCode.nicknameTaken),
      );
    });

    test('when starting with one player then it is rejected', () async {
      final g = await setUpGame(sb, endpoints, players: 1);
      await expectLater(
        endpoints.room.startGame(sb, g.code, g.hostToken),
        throwsQuiz(QuizErrorCode.invalidState),
      );
    });

    test(
      'when a player rejoins with their token then they get the same id',
      () async {
        final g = await setUpGame(sb, endpoints, players: 1);
        final again = await endpoints.room.rejoin(
          sb,
          g.code,
          g.players[0].playerToken,
        );
        expect(again.playerId, g.players[0].playerId);
      },
    );

    test(
      'when watching and a player joins then the lobby updates live',
      () async {
        final created = await endpoints.room.createRoom(sb, RoomConfig());
        final states = endpoints.room.watchRoom(sb, created.roomCode);
        final received = <RoomState>[];
        final snapshot = Completer<void>();
        final update = Completer<void>();
        final sub = states.listen((s) {
          received.add(s);
          if (!snapshot.isCompleted) {
            snapshot.complete();
          } else if (!update.isCompleted) {
            update.complete();
          }
        });
        await snapshot.future;

        await endpoints.room.joinRoom(sb, created.roomCode, 'Ada');
        await update.future.timeout(const Duration(seconds: 5));
        await sub.cancel();

        expect(received.first.players, isEmpty);
        expect(received.last.players.map((p) => p.nickname), ['Ada']);
      },
    );
  });

  withServerpod('Given a new room', (sb, endpoints) {
    test(
      'when the game has finished then joining says it does not exist',
      () async {
        final g = await setUpGame(sb, endpoints, players: 2);
        final room = await roomOf(sb, g.code);
        await Room.db.updateRow(
          sb.build(),
          room.copyWith(status: RoomStatus.finished),
        );
        await expectLater(
          endpoints.room.joinRoom(sb, g.code, 'Late'),
          throwsQuiz(QuizErrorCode.roomNotFound),
        );
      },
    );

    test('when created then the code is 4 digits', () async {
      for (var i = 0; i < 5; i++) {
        final created = await endpoints.room.createRoom(sb, RoomConfig());
        expect(created.roomCode, matches(RegExp(r'^\d{4}$')));
      }
    });

    test(
      'when the host hides questions on phones then the state says so',
      () async {
        final created = await endpoints.room.createRoom(
          sb,
          RoomConfig(showQuestionOnPhones: false),
        );
        final state = await endpoints.room
            .watchRoom(sb, created.roomCode)
            .first;
        expect(state.showQuestionOnPhones, isFalse);
      },
    );

    test(
      'when the host does not choose then phones show the question',
      () async {
        final created = await endpoints.room.createRoom(sb, RoomConfig());
        final state = await endpoints.room
            .watchRoom(sb, created.roomCode)
            .first;
        expect(state.showQuestionOnPhones, isTrue);
      },
    );
  });

  withServerpod('Given the danger line', (sb, endpoints) {
    test('when in the lobby then there is no projection', () async {
      final g = await setUpGame(sb, endpoints, players: 5);
      final state = await endpoints.room.watchRoom(sb, g.code).first;
      expect(state.projectedSurvivors, isNull);
    });

    test(
      'when a bottom-30% round is running then it matches the real cut',
      () async {
        // 10 players: 30% cut leaves 7, and the real cut must agree.
        final g = await setUpGame(
          sb,
          endpoints,
          players: 10,
          config: RoomConfig(questionsPerRound: 1, finalistTarget: 3),
        );
        await endpoints.room.startGame(sb, g.code, g.hostToken);
        var state = await endpoints.room.watchRoom(sb, g.code).first;
        expect(state.projectedSurvivors, 7);

        final q = await currentQuestion(sb, g.code);
        for (final p in g.players) {
          await endpoints.answer.submitAnswer(sb, p.playerToken, q.id!, 0);
        }
        state = await endpoints.room.watchRoom(sb, g.code).first;
        expect(state.status, RoomStatus.reveal);
        expect(state.projectedSurvivors, 7);

        await endpoints.room.endRound(sb, g.code, g.hostToken);
        final active = await Player.db.count(
          sb.build(),
          where: (t) => t.status.equals(PlayerStatus.active),
        );
        expect(active, 7);
      },
    );

    test('when sudden death then there is no line to show', () async {
      final g = await setUpGame(
        sb,
        endpoints,
        players: 5,
        config: RoomConfig(eliminationRule: EliminationRule.suddenDeath),
      );
      await endpoints.room.startGame(sb, g.code, g.hostToken);
      final state = await endpoints.room.watchRoom(sb, g.code).first;
      expect(state.projectedSurvivors, isNull);
    });
  });

  // Concurrent transactions need real commits, not the per-test rollback.
  withServerpod(
    'Given the buzzer final with 3 finalists',
    (sb, endpoints) {
      late Game g;
      late Question fq;

      setUp(() async {
        g = await setUpGame(
          sb,
          endpoints,
          players: 3,
          config: RoomConfig(
            questionsPerRound: 1,
            finalistTarget: 3,
            finalQuestionCount: 2,
          ),
        );
        await endpoints.room.startGame(sb, g.code, g.hostToken);
        final q = await currentQuestion(sb, g.code);
        for (final p in g.players) {
          await endpoints.answer.submitAnswer(sb, p.playerToken, q.id!, 0);
        }
        await endpoints.room.endRound(sb, g.code, g.hostToken);
        await endpoints.room.nextQuestion(sb, g.code, g.hostToken);
        fq = await currentQuestion(sb, g.code);
      });

      test('when all finalists buzz at once then exactly one wins', () async {
        final results = await Future.wait([
          for (final p in g.players)
            endpoints.buzzer.buzz(sb, p.playerToken, fq.id!),
        ]);
        expect(results.where((r) => r.gotBuzzer), hasLength(1));
        final room = await roomOf(sb, g.code);
        final winner = g.players[results.indexWhere((r) => r.gotBuzzer)];
        expect(room.buzzerHolderId, winner.playerId);
      });

      test('when the holder answers wrong then they are locked out '
          'and another finalist can buzz', () async {
        final first = await endpoints.buzzer.buzz(
          sb,
          g.players[0].playerToken,
          fq.id!,
        );
        expect(first.gotBuzzer, isTrue);
        final correct = await endpoints.buzzer.submitBuzzAnswer(
          sb,
          g.players[0].playerToken,
          fq.id!,
          wrong(fq),
        );
        expect(correct, isFalse);

        final again = await endpoints.buzzer.buzz(
          sb,
          g.players[0].playerToken,
          fq.id!,
        );
        expect(again.gotBuzzer, isFalse);
        expect(again.reason, 'Locked out');

        final second = await endpoints.buzzer.buzz(
          sb,
          g.players[1].playerToken,
          fq.id!,
        );
        expect(second.gotBuzzer, isTrue);
      });

      test('when a non-holder answers then it is rejected', () async {
        await endpoints.buzzer.buzz(sb, g.players[0].playerToken, fq.id!);
        await expectLater(
          endpoints.buzzer.submitBuzzAnswer(
            sb,
            g.players[1].playerToken,
            fq.id!,
            fq.correctIndex,
          ),
          throwsQuiz(QuizErrorCode.notAllowed),
        );
      });

      test(
        'when every finalist is locked out then the question is revealed',
        () async {
          for (final p in g.players) {
            await endpoints.buzzer.buzz(sb, p.playerToken, fq.id!);
            await endpoints.buzzer.submitBuzzAnswer(
              sb,
              p.playerToken,
              fq.id!,
              wrong(fq),
            );
          }
          expect((await roomOf(sb, g.code)).status, RoomStatus.reveal);
          final state = await endpoints.room.watchRoom(sb, g.code).first;
          expect(state.buzzWinnerId, isNull);
        },
      );
    },
    rollbackDatabase: RollbackDatabase.disabled,
  );
}
