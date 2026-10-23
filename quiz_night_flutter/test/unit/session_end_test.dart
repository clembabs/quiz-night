import 'package:flutter_test/flutter_test.dart';
import 'package:quiz_night_client/quiz_night_client.dart';
import 'package:quiz_night_flutter/core/theme/app_colors.dart';
import 'package:quiz_night_flutter/features/room/final/final_logic.dart';
import 'package:quiz_night_flutter/features/room/phone/phone_placement.dart';
import 'package:quiz_night_flutter/features/room/standings_logic.dart';
import 'package:quiz_night_flutter/widgets/qn/session_clock.dart';

import '../fakes/fakes.dart';

const out = PlayerStatus.eliminated;

void main() {
  group('Given the session clock', () {
    test('when formatting time left then it reads mm:ss', () {
      expect(
        SessionClock.format(const Duration(minutes: 24, seconds: 3)),
        '24:03',
      );
      expect(SessionClock.format(Duration.zero), '00:00');
    });

    test('when time runs low then it turns gold, then red', () {
      expect(
        SessionClock.colorFor(const Duration(minutes: 20)),
        AppColors.chalkSoft,
      );
      expect(SessionClock.colorFor(const Duration(minutes: 4)), AppColors.gold);
      expect(
        SessionClock.colorFor(const Duration(seconds: 30)),
        AppColors.errorText,
      );
    });
  });

  group('Given a game that ran out of time in round 2', () {
    final room = roomState(
      status: RoomStatus.finished,
      round: 2,
      players: [
        player(1, 'Ada', score: 1200),
        player(2, 'Bo', score: 3100),
        player(3, 'Cy', score: 2500),
        player(4, 'Dee', score: 4000, status: out, eliminatedInRound: 1),
      ],
    ).copyWith(endReason: RoomEndReason.timeUp);

    test('when ranking then players still in go first, by score so far', () {
      expect(endedEarly(room), isTrue);
      expect(closedBeforeStart(room), isFalse);
      expect(finalStandings(room).map((p) => p.nickname), ['Bo', 'Cy', 'Ada']);
      expect(
        finalPlacements(room).map((p) => p.nickname),
        ['Bo', 'Cy', 'Ada', 'Dee'],
        reason: 'everyone once, the knocked-out player last',
      );
      expect(winnerOf(room)!.nickname, 'Bo');
    });

    test('when a phone shows its result then it says time is up and the '
        'place so far', () {
      final cy = room.players[2];
      expect(PhonePlacement.titleFor(room, cy), "Time's up");
      expect(
        PhonePlacement.detailFor(room, cy),
        'You finished 2nd with 2,500 points.',
      );
      expect(endNoticeFor(room), startsWith("Time's up"));
    });
  });

  group('Given rooms that ended other ways', () {
    test(
      'when a lobby closed for inactivity then it closed before starting',
      () {
        final lobby = roomState(
          status: RoomStatus.finished,
          players: [player(1, 'Ada')],
        ).copyWith(endReason: RoomEndReason.inactive);
        expect(closedBeforeStart(lobby), isTrue);
        expect(endNoticeFor(lobby), contains('30 minutes without activity'));
      },
    );

    test('when a game was played to the podium then nothing is "so far"', () {
      final done = roomState(status: RoomStatus.finished).copyWith(
        endReason: RoomEndReason.completed,
      );
      expect(endedEarly(done), isFalse);
      expect(endNoticeFor(done), isNull);
    });
  });
}
