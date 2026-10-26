import 'package:quiz_night_server/src/game/room_cleanup.dart';
import 'package:quiz_night_server/src/generated/protocol.dart';
import 'package:test/test.dart';

import 'test_tools/serverpod_test_tools.dart';

void main() {
  withServerpod('Given rooms of different ages', (sb, endpoints) {
    test('when the clean-up runs then rooms older than a day go, with their '
        'players, and newer ones stay', () async {
      final old = await endpoints.room.createRoom(sb, RoomConfig());
      await endpoints.room.joinRoom(sb, old.roomCode, 'Ada');
      final fresh = await endpoints.room.createRoom(sb, RoomConfig());
      await endpoints.room.joinRoom(sb, fresh.roomCode, 'Bo');

      final session = sb.build();
      final oldRoom = (await Room.db.findFirstRow(
        session,
        where: (t) => t.code.equals(old.roomCode),
      ))!;
      // Age the first room past the cut-off.
      await Room.db.updateRow(
        session,
        oldRoom.copyWith(
          createdAt: DateTime.now().toUtc().subtract(
            RoomCleanup.keepFor + const Duration(minutes: 1),
          ),
        ),
      );

      final deleted = await RoomCleanup.run(session);

      expect(deleted, 1);
      final rooms = await Room.db.find(session);
      expect(rooms.map((r) => r.code), [fresh.roomCode]);
      final players = await Player.db.find(session);
      expect(players.map((p) => p.nickname), ['Bo']);
    });

    test('when nothing is old enough then nothing is deleted', () async {
      await endpoints.room.createRoom(sb, RoomConfig());
      expect(await RoomCleanup.run(sb.build()), 0);
    });
  });
}
