import 'package:quiz_night_server/src/generated/protocol.dart';
import 'package:quiz_night_server/src/security/guard.dart';
import 'package:test/test.dart';

import 'test_tools/serverpod_test_tools.dart';

Matcher throwsQuiz(QuizErrorCode code) =>
    throwsA(isA<QuizException>().having((e) => e.code, 'code', code));

void main() {
  setUp(() {
    Guard.reset();
    Guard.enabled = true;
  });
  tearDown(() {
    Guard.enabled = false;
    Guard.reset();
  });

  withServerpod('Given rate limits are on', (sb, endpoints) {
    test('when an address creates too many rooms then it is refused', () async {
      for (var i = 0; i < Limits.createRoom.max; i++) {
        await endpoints.room.createRoom(sb, RoomConfig());
      }
      await expectLater(
        endpoints.room.createRoom(sb, RoomConfig()),
        throwsQuiz(QuizErrorCode.rateLimited),
      );
    });

    test('when an address tries more than 6 wrong codes in a minute then '
        'it is blocked for 5 minutes, even for a real code', () async {
      final room = await endpoints.room.createRoom(sb, RoomConfig());
      final t0 = DateTime.now().toUtc();
      Guard.now = () => t0;
      for (var i = 0; i <= Limits.wrongCode.max; i++) {
        await expectLater(
          endpoints.room.joinRoom(sb, '0000$i', 'Guesser'),
          throwsQuiz(QuizErrorCode.roomNotFound),
        );
      }
      await expectLater(
        endpoints.room.joinRoom(sb, room.roomCode, 'Guesser'),
        throwsQuiz(QuizErrorCode.rateLimited),
      );

      Guard.now = () => t0.add(const Duration(minutes: 4));
      await expectLater(
        endpoints.room.joinRoom(sb, room.roomCode, 'Guesser'),
        throwsQuiz(QuizErrorCode.rateLimited),
      );

      Guard.now = () => t0.add(const Duration(minutes: 5));
      final joined = await endpoints.room.joinRoom(
        sb,
        room.roomCode,
        'Guesser',
      );
      expect(joined.roomCode, room.roomCode);
    });

    test('when an address mistypes a code a few times then it can still '
        'join', () async {
      final room = await endpoints.room.createRoom(sb, RoomConfig());
      for (var i = 0; i < 3; i++) {
        await expectLater(
          endpoints.room.joinRoom(sb, '0000$i', 'Ada'),
          throwsQuiz(QuizErrorCode.roomNotFound),
        );
      }
      final joined = await endpoints.room.joinRoom(sb, room.roomCode, 'Ada');
      expect(joined.roomCode, room.roomCode);
    });

    test('when one room gets too many join attempts then more are refused, '
        'while other rooms still take joins', () async {
      final room = await endpoints.room.createRoom(sb, RoomConfig());
      final other = await endpoints.room.createRoom(sb, RoomConfig());
      for (var i = 0; i < Limits.joinPerRoom.max; i++) {
        // Same nickname: the first joins, the rest fail on the name, but
        // every attempt counts against the room.
        try {
          await endpoints.room.joinRoom(sb, room.roomCode, 'Spam');
        } on QuizException catch (e) {
          expect(e.code, QuizErrorCode.nicknameTaken);
        }
      }
      await expectLater(
        endpoints.room.joinRoom(sb, room.roomCode, 'Spam 2'),
        throwsQuiz(QuizErrorCode.rateLimited),
      );
      final ok = await endpoints.room.joinRoom(sb, other.roomCode, 'Ada');
      expect(ok.roomCode, other.roomCode);
    });

    test('when a host token sends too many controls then it is refused, '
        'without slowing other hosts', () async {
      final a = await endpoints.room.createRoom(sb, RoomConfig());
      final b = await endpoints.room.createRoom(sb, RoomConfig());
      for (var i = 0; i < Limits.hostAction.max; i++) {
        // Fails on game rules (nobody joined), but still counts.
        try {
          await endpoints.room.startGame(sb, a.roomCode, a.hostToken);
        } on QuizException catch (e) {
          expect(e.code, isNot(QuizErrorCode.rateLimited));
        }
      }
      await expectLater(
        endpoints.room.startGame(sb, a.roomCode, a.hostToken),
        throwsQuiz(QuizErrorCode.rateLimited),
      );
      await expectLater(
        endpoints.room.startGame(sb, b.roomCode, b.hostToken),
        throwsA(
          isA<QuizException>().having(
            (e) => e.code,
            'code',
            isNot(QuizErrorCode.rateLimited),
          ),
        ),
      );
    });

    test('when a player floods answers then the token is refused', () async {
      final room = await endpoints.room.createRoom(sb, RoomConfig());
      final player = await endpoints.room.joinRoom(sb, room.roomCode, 'Ada');
      for (var i = 0; i < Limits.playerAction.max; i++) {
        try {
          await endpoints.answer.submitAnswer(sb, player.playerToken, 1, 0);
        } on QuizException catch (e) {
          expect(e.code, isNot(QuizErrorCode.rateLimited));
        }
      }
      await expectLater(
        endpoints.answer.submitAnswer(sb, player.playerToken, 1, 0),
        throwsQuiz(QuizErrorCode.rateLimited),
      );
    });

    test('when a room stream closes then its slot is given back', () async {
      final room = await endpoints.room.createRoom(sb, RoomConfig());
      final first = await endpoints.room.watchRoom(sb, room.roomCode).first;
      expect(first.code, room.roomCode);
      expect(Guard.streams.openFor('internal'), 0);
    });
  });
}
