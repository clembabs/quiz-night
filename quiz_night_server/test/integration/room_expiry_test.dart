import 'package:quiz_night_server/src/game/room_service.dart';
import 'package:quiz_night_server/src/generated/protocol.dart';
import 'package:test/test.dart';

import 'test_tools/serverpod_test_tools.dart';

void main() {
  withServerpod('Given games and rooms of different ages', (sb, endpoints) {
    Future<CreateRoomResult> startedGame() async {
      final room = await endpoints.room.createRoom(
        sb,
        RoomConfig(questionsPerRound: 3),
      );
      await endpoints.room.joinRoom(sb, room.roomCode, 'Ada');
      await endpoints.room.joinRoom(sb, room.roomCode, 'Bo');
      await endpoints.room.startGame(sb, room.roomCode, room.hostToken);
      return room;
    }

    Future<Room> roomOf(String code) async => (await Room.db.findFirstRow(
      sb.build(),
      where: (t) => t.code.equals(code),
    ))!;

    test(
      'when a game starts then everyone sees when its 30 minutes end',
      () async {
        final room = await startedGame();
        final state = await endpoints.room.watchRoom(sb, room.roomCode).first;
        final started = (await roomOf(room.roomCode)).startedAt!;
        expect(state.sessionEndsAt, started.add(RoomService.sessionLength));
      },
    );

    test('when 30 minutes have passed since the start then the game ends as '
        'time up, keeping its scores', () async {
      final room = await startedGame();
      final now = DateTime.now().toUtc();

      // Not yet: one minute to go.
      expect(
        await RoomService.endExpired(
          sb.build(),
          now: now.add(RoomService.sessionLength - const Duration(minutes: 1)),
        ),
        0,
      );

      final ended = await RoomService.endExpired(
        sb.build(),
        now: now.add(RoomService.sessionLength + const Duration(seconds: 1)),
      );
      expect(ended, 1);
      final state = await endpoints.room.watchRoom(sb, room.roomCode).first;
      expect(state.status, RoomStatus.finished);
      expect(state.endReason, RoomEndReason.timeUp);
      expect(state.sessionEndsAt, isNull);
      // Nothing left open: no countdown, and the last question's answer shows.
      expect(state.questionEndsAt, isNull);
      expect(state.question?.correctIndex, isNotNull);
      expect(state.players, hasLength(2));
    });

    test('when a lobby sits idle for 30 minutes then it closes as inactive '
        'and nobody can join', () async {
      final room = await endpoints.room.createRoom(sb, RoomConfig());
      final ended = await RoomService.endExpired(
        sb.build(),
        now: DateTime.now().toUtc().add(
          RoomService.idleLimit + const Duration(seconds: 1),
        ),
      );
      expect(ended, 1);
      expect((await roomOf(room.roomCode)).endReason, RoomEndReason.inactive);
      await expectLater(
        endpoints.room.joinRoom(sb, room.roomCode, 'Late'),
        throwsA(
          isA<QuizException>().having(
            (e) => e.code,
            'code',
            QuizErrorCode.roomNotFound,
          ),
        ),
      );
    });

    test(
      'when something happens in the room then its idle clock restarts',
      () async {
        final room = await endpoints.room.createRoom(sb, RoomConfig());
        final created = (await roomOf(room.roomCode)).lastActivityAt;
        await Future<void>.delayed(const Duration(milliseconds: 20));
        await endpoints.room.joinRoom(sb, room.roomCode, 'Ada');
        final afterJoin = (await roomOf(room.roomCode)).lastActivityAt;
        expect(afterJoin.isAfter(created), isTrue);

        // Idle limit measured from the join: just under it, still open.
        expect(
          await RoomService.endExpired(
            sb.build(),
            now: afterJoin.add(
              RoomService.idleLimit - const Duration(seconds: 1),
            ),
          ),
          0,
        );
      },
    );

    test(
      'when a game is played to the podium then it ends as completed',
      () async {
        final room = await endpoints.room.createRoom(
          sb,
          RoomConfig(
            questionsPerRound: 1,
            finalistTarget: 2,
            finalQuestionCount: 1,
          ),
        );
        await endpoints.room.joinRoom(sb, room.roomCode, 'Ada');
        await endpoints.room.joinRoom(sb, room.roomCode, 'Bo');
        await endpoints.room.startGame(sb, room.roomCode, room.hostToken);
        // Reveal, end round (both finalists), final question, reveal, podium.
        for (var i = 0; i < 8; i++) {
          final s = await endpoints.room.watchRoom(sb, room.roomCode).first;
          if (s.status == RoomStatus.finished) break;
          switch (s.status) {
            case RoomStatus.question || RoomStatus.buzzerFinal:
              await endpoints.room.reveal(sb, room.roomCode, room.hostToken);
            case RoomStatus.reveal when !(s.question?.isFinal ?? false):
              await endpoints.room.endRound(sb, room.roomCode, room.hostToken);
            default:
              await endpoints.room.nextQuestion(
                sb,
                room.roomCode,
                room.hostToken,
              );
          }
        }
        final state = await endpoints.room.watchRoom(sb, room.roomCode).first;
        expect(state.status, RoomStatus.finished);
        expect(state.endReason, RoomEndReason.completed);
      },
    );
  });
}
