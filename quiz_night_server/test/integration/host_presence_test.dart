import 'package:quiz_night_server/src/game/room_service.dart';
import 'package:quiz_night_server/src/generated/protocol.dart';
import 'package:test/test.dart';

import 'test_tools/serverpod_test_tools.dart';

void main() {
  withServerpod('Given a game whose host disconnects', (sb, endpoints) {
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

    Future<RoomState> stateOf(String code) =>
        endpoints.room.watchRoom(sb, code).first;

    test('when the host drops then players see when the game will end, '
        '30 seconds on', () async {
      final room = await startedGame();
      final id = (await roomOf(room.roomCode)).id!;
      final since = await RoomService.hostDisconnected(sb.build(), id);
      final state = await stateOf(room.roomCode);
      expect(state.hostAwayUntil, since!.add(RoomService.hostGrace));
      expect(state.status, RoomStatus.question);
    });

    test('when the host comes back in time then the countdown clears and '
        'the game goes on', () async {
      final room = await startedGame();
      final id = (await roomOf(room.roomCode)).id!;
      final since = (await RoomService.hostDisconnected(sb.build(), id))!;
      await RoomService.hostConnected(sb.build(), id);
      expect((await stateOf(room.roomCode)).hostAwayUntil, isNull);

      // The old countdown no longer counts.
      final ended = await RoomService.endIfHostGone(
        sb.build(),
        id,
        since,
        now: since.add(RoomService.hostGrace + const Duration(seconds: 1)),
      );
      expect(ended, isFalse);
      expect((await roomOf(room.roomCode)).status, RoomStatus.question);
    });

    test('when the host stays away past 30 seconds then the game ends for '
        'everyone as host left, keeping scores', () async {
      final room = await startedGame();
      final id = (await roomOf(room.roomCode)).id!;
      final since = (await RoomService.hostDisconnected(sb.build(), id))!;

      // Not yet.
      expect(
        await RoomService.endIfHostGone(
          sb.build(),
          id,
          since,
          now: since.add(const Duration(seconds: 29)),
        ),
        isFalse,
      );

      expect(
        await RoomService.endIfHostGone(
          sb.build(),
          id,
          since,
          now: since.add(RoomService.hostGrace),
        ),
        isTrue,
      );
      final state = await stateOf(room.roomCode);
      expect(state.status, RoomStatus.finished);
      expect(state.endReason, RoomEndReason.hostLeft);
      expect(state.hostAwayUntil, isNull);
      expect(state.questionEndsAt, isNull);
      expect(state.players, hasLength(2));
    });

    test('when the timer is missed then the expiry sweep ends it', () async {
      final room = await startedGame();
      final id = (await roomOf(room.roomCode)).id!;
      final since = (await RoomService.hostDisconnected(sb.build(), id))!;
      final ended = await RoomService.endExpired(
        sb.build(),
        now: since.add(RoomService.hostGrace + const Duration(seconds: 1)),
      );
      expect(ended, 1);
      expect(
        (await roomOf(room.roomCode)).endReason,
        RoomEndReason.hostLeft,
      );
    });

    test('when the host is away in the lobby then it also ends', () async {
      final room = await endpoints.room.createRoom(sb, RoomConfig());
      final id = (await roomOf(room.roomCode)).id!;
      final since = (await RoomService.hostDisconnected(sb.build(), id))!;
      await RoomService.endIfHostGone(
        sb.build(),
        id,
        since,
        now: since.add(RoomService.hostGrace),
      );
      final state = await stateOf(room.roomCode);
      expect(state.status, RoomStatus.finished);
      expect(state.round, 0);
    });

    test('when the game is already over then a dropped host changes '
        'nothing', () async {
      final room = await startedGame();
      await endpoints.room.endGame(sb, room.roomCode, room.hostToken);
      final id = (await roomOf(room.roomCode)).id!;
      expect(await RoomService.hostDisconnected(sb.build(), id), isNull);
    });

    test(
      'when the host taps Stop hosting then the game ends at once',
      () async {
        final room = await startedGame();
        await endpoints.room.endGame(sb, room.roomCode, room.hostToken);
        final state = await stateOf(room.roomCode);
        expect(state.status, RoomStatus.finished);
        expect(state.endReason, RoomEndReason.hostLeft);
      },
    );

    test('when someone without the host token tries to end it then they '
        'are refused', () async {
      final room = await startedGame();
      await expectLater(
        endpoints.room.endGame(sb, room.roomCode, 'not-the-host'),
        throwsA(
          isA<QuizException>().having(
            (e) => e.code,
            'code',
            QuizErrorCode.notHost,
          ),
        ),
      );
    });

    test('when the host watches as host then they are counted present, '
        'clearing an old countdown', () async {
      final room = await startedGame();
      final id = (await roomOf(room.roomCode)).id!;
      await RoomService.hostDisconnected(sb.build(), id);
      final first = await endpoints.room
          .watchRoomAsHost(sb, room.roomCode, room.hostToken)
          .first;
      // The snapshot is taken after the host is marked back.
      expect(first.hostAwayUntil, isNull);
    });

    test('when a non-host opens the host stream then it is refused', () async {
      final room = await startedGame();
      await expectLater(
        endpoints.room.watchRoomAsHost(sb, room.roomCode, 'nope').first,
        throwsA(isA<QuizException>()),
      );
    });
  });
}
