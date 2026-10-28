import 'package:quiz_night_server/src/generated/protocol.dart';
import 'package:test/test.dart';

import 'test_tools/serverpod_test_tools.dart';

void main() {
  withServerpod('Given a host creates a room', (sb, endpoints) {
    test('when it is a remote game then phones always get the question, '
        'and every screen is told it is remote', () async {
      final room = await endpoints.room.createRoom(
        sb,
        RoomConfig(remote: true, showQuestionOnPhones: false),
      );
      final state = await endpoints.room.watchRoom(sb, room.roomCode).first;
      expect(state.remote, isTrue);
      expect(state.showQuestionOnPhones, isTrue);
    });

    test('when it is in the room then the host choice stands', () async {
      final room = await endpoints.room.createRoom(
        sb,
        RoomConfig(showQuestionOnPhones: false),
      );
      final state = await endpoints.room.watchRoom(sb, room.roomCode).first;
      expect(state.remote, isFalse);
      expect(state.showQuestionOnPhones, isFalse);
    });
  });
}
