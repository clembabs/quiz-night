import 'package:flutter_test/flutter_test.dart';
import 'package:quiz_night_client/quiz_night_client.dart';
import 'package:quiz_night_flutter/features/room/round_logic.dart';
import 'package:quiz_night_flutter/features/room/standings_logic.dart';

import '../fakes/fakes.dart';

/// Ten active players scoring 1000, 900 … 100; the line keeps [line].
RoomState tenPlayers({int? line = 7}) => roomState(
  status: RoomStatus.reveal,
  question: question(revealed: true),
  players: [
    for (var i = 1; i <= 10; i++) player(i, 'P$i', score: 1100 - i * 100),
  ],
).copyWith(projectedSurvivors: line);

PlayerView p(RoomState room, int id) =>
    room.players.firstWhere((x) => x.id == id);

void main() {
  group('Given the danger line at 7 of 10', () {
    final room = tenPlayers();

    test('when well above the line then safe, with places to spare', () {
      final s = dangerStatusFor(room, p(room, 2))!;
      expect(s.kind, DangerKind.safe);
      expect(s.detail, '5 places above the danger line');
    });

    test('when one place above the line then in the danger zone', () {
      final s = dangerStatusFor(room, p(room, 6))!;
      expect(s.kind, DangerKind.danger);
      expect(s.detail, '1 place above the danger line');
    });

    test('when on the last safe spot then right on the line', () {
      final s = dangerStatusFor(room, p(room, 7))!;
      expect(s.kind, DangerKind.danger);
      expect(s.detail, 'Right on the danger line');
    });

    test('when below the line then says how far below', () {
      final s = dangerStatusFor(room, p(room, 10))!;
      expect(s.kind, DangerKind.danger);
      expect(s.detail, '3 places below the danger line');
    });
  });

  group('Given no line to show', () {
    test('when sudden death or the final then there is no indicator', () {
      final room = tenPlayers(line: null);
      expect(dangerStatusFor(room, p(room, 1)), isNull);
    });

    test('when a spectator then there is no indicator', () {
      final room = roomState(
        players: [player(1, 'Out', status: PlayerStatus.eliminated)],
      ).copyWith(projectedSurvivors: 3);
      expect(dangerStatusFor(room, room.players.first), isNull);
    });

    test('when a finalist then it says they are through', () {
      final room = roomState(
        players: [player(1, 'F', status: PlayerStatus.finalist)],
      );
      expect(
        dangerStatusFor(room, room.players.first)!.kind,
        DangerKind.finalist,
      );
    });
  });

  group('Given final placements', () {
    final room = roomState(
      status: RoomStatus.finished,
      players: [
        player(1, 'Champ', status: PlayerStatus.finalist, finalScore: 3000),
        player(2, 'Runner', status: PlayerStatus.finalist, finalScore: 1000),
        player(
          3,
          'EarlyHigh',
          score: 900,
          status: PlayerStatus.eliminated,
          eliminatedInRound: 1,
        ),
        player(
          4,
          'Late',
          score: 100,
          status: PlayerStatus.eliminated,
          eliminatedInRound: 2,
        ),
        player(
          5,
          'EarlyLow',
          score: 50,
          status: PlayerStatus.eliminated,
          eliminatedInRound: 1,
        ),
      ],
    );

    test('when ranking then finalists, then later exits, then score', () {
      expect(finalPlacements(room).map((p) => p.nickname), [
        'Champ',
        'Runner',
        'Late',
        'EarlyHigh',
        'EarlyLow',
      ]);
      expect(placementOf(room, 4), 3);
      expect(placementOf(room, 99), isNull);
    });
  });

  group('Given ordinals', () {
    test('when formatting then teens and endings are right', () {
      expect([1, 2, 3, 4, 11, 12, 13, 21, 22, 23, 101, 111].map(ordinal), [
        '1st',
        '2nd',
        '3rd',
        '4th',
        '11th',
        '12th',
        '13th',
        '21st',
        '22nd',
        '23rd',
        '101st',
        '111th',
      ]);
    });
  });

  group('Given rank movement', () {
    test('when players swap then one goes up and one down', () {
      expect(rankMoves({1: 1, 2: 2, 3: 3}, {2: 1, 1: 2, 3: 3}), {
        2: 1,
        1: -1,
        3: 0,
      });
    });

    test('when a player is new then they have no movement', () {
      expect(rankMoves({1: 1}, {1: 1, 2: 2}), {1: 0});
    });

    test('when ranking a room then ids map to leaderboard places', () {
      expect(ranksOf(tenPlayers())[3], 3);
    });
  });

  group('Given the cut summary', () {
    test('when bottom 30% of 10 then three go home', () {
      expect(cutSummary(tenPlayers()), 'Bottom 30% go home · 3 of 10');
    });
  });

  group('Given the last question of a round is revealed', () {
    final room = roomState(
      status: RoomStatus.reveal,
      questionsPerRound: 1,
      question: question(revealed: true),
      players: [player(1, 'A')],
    ).copyWith(projectedSurvivors: 1);

    test('when the board is not up then the host shows standings first', () {
      expect(hostStepFor(room), HostStep.showStandings);
    });

    test('when the board is up then the host runs the cut', () {
      expect(hostStepFor(room, showingStandings: true), HostStep.endRound);
    });
  });
}
