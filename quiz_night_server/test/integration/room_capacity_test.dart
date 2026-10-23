import 'package:quiz_night_server/src/game/room_service.dart';
import 'package:quiz_night_server/src/generated/protocol.dart';
import 'package:test/test.dart';

import 'test_tools/serverpod_test_tools.dart';

Matcher throwsQuiz(QuizErrorCode code) =>
    throwsA(isA<QuizException>().having((e) => e.code, 'code', code));

void main() {
  withServerpod('Given a room', (sb, endpoints) {
    test('when it holds the maximum players then the next join is refused '
        'as full', () async {
      final room = await endpoints.room.createRoom(sb, RoomConfig());
      for (var i = 0; i < RoomService.maxPlayers; i++) {
        await endpoints.room.joinRoom(sb, room.roomCode, 'P$i');
      }
      await expectLater(
        endpoints.room.joinRoom(sb, room.roomCode, 'One too many'),
        throwsQuiz(QuizErrorCode.roomFull),
      );
    });

    test('when the host removes a player in the lobby then they leave the '
        'room and their seat stops working', () async {
      final room = await endpoints.room.createRoom(sb, RoomConfig());
      final ada = await endpoints.room.joinRoom(sb, room.roomCode, 'Ada');
      final troll = await endpoints.room.joinRoom(sb, room.roomCode, 'Troll');

      await endpoints.room.removePlayer(
        sb,
        room.roomCode,
        room.hostToken,
        troll.playerId,
      );

      final state = await endpoints.room.watchRoom(sb, room.roomCode).first;
      expect(state.players.map((p) => p.nickname), ['Ada']);
      await expectLater(
        endpoints.room.rejoin(sb, room.roomCode, troll.playerToken),
        throwsQuiz(QuizErrorCode.playerNotFound),
      );
      // The nickname is free again.
      await endpoints.room.joinRoom(sb, room.roomCode, 'Troll');
      expect(ada.roomCode, room.roomCode);
    });

    test('when someone without the host token removes a player then it is '
        'refused', () async {
      final room = await endpoints.room.createRoom(sb, RoomConfig());
      final ada = await endpoints.room.joinRoom(sb, room.roomCode, 'Ada');
      await expectLater(
        endpoints.room.removePlayer(
          sb,
          room.roomCode,
          ada.playerToken,
          ada.playerId,
        ),
        throwsQuiz(QuizErrorCode.notHost),
      );
    });

    test('when the game has started then players can no longer be '
        'removed', () async {
      final room = await endpoints.room.createRoom(sb, RoomConfig());
      final ada = await endpoints.room.joinRoom(sb, room.roomCode, 'Ada');
      await endpoints.room.joinRoom(sb, room.roomCode, 'Bo');
      await endpoints.room.startGame(sb, room.roomCode, room.hostToken);
      await expectLater(
        endpoints.room.removePlayer(
          sb,
          room.roomCode,
          room.hostToken,
          ada.playerId,
        ),
        throwsQuiz(QuizErrorCode.invalidState),
      );
    });

    test('when the host removes a player from another room then it is '
        'refused', () async {
      final mine = await endpoints.room.createRoom(sb, RoomConfig());
      final other = await endpoints.room.createRoom(sb, RoomConfig());
      final stranger = await endpoints.room.joinRoom(sb, other.roomCode, 'Zed');
      await expectLater(
        endpoints.room.removePlayer(
          sb,
          mine.roomCode,
          mine.hostToken,
          stranger.playerId,
        ),
        throwsQuiz(QuizErrorCode.playerNotFound),
      );
    });
  });
}
