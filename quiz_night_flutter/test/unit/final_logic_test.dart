import 'package:flutter_test/flutter_test.dart';
import 'package:quiz_night_client/quiz_night_client.dart';
import 'package:quiz_night_flutter/features/room/final/final_logic.dart';
import 'package:quiz_night_flutter/features/room/final/finalist_card.dart';
import 'package:quiz_night_flutter/features/room/final/podium_view.dart';
import 'package:quiz_night_flutter/features/room/round_logic.dart';

import '../fakes/fakes.dart';

const f = PlayerStatus.finalist;
const out = PlayerStatus.eliminated;

void main() {
  /// Ada leads the final, Bo is second on round score, Cy third.
  /// Dee backed Ada, Eve backed Bo, Fay backed nobody.
  RoomState finished() => roomState(
    status: RoomStatus.finished,
    players: [
      player(1, 'Bo', status: f, finalScore: 1000, score: 3000),
      player(2, 'Ada', status: f, finalScore: 2000, score: 1000),
      player(3, 'Cy', status: f, finalScore: 1000, score: 2000),
      player(4, 'Dee', status: out, backedPlayerId: 2, shadowScore: 900),
      player(5, 'Eve', status: out, backedPlayerId: 1, shadowScore: 2400),
      player(6, 'Fay', status: out),
    ],
  );

  group('Given final standings', () {
    test('when ranking then final score wins, round score breaks ties', () {
      expect(finalStandings(finished()).map((p) => p.nickname), [
        'Ada',
        'Bo',
        'Cy',
      ]);
    });

    test('when asking places then finalists are ranked, spectators null', () {
      final room = finished();
      expect(winnerOf(room)!.nickname, 'Ada');
      expect(finalPlaceOf(room, 1), 2);
      expect(finalPlaceOf(room, 4), isNull);
    });

    test('when listing backers then only those who picked that finalist', () {
      expect(backersOf(finished(), 2).map((p) => p.nickname), ['Dee']);
    });

    test('when finding the shadow champion then highest shadow score wins', () {
      expect(shadowChampion(finished())!.nickname, 'Eve');
    });

    test('when no spectator scored then there is no shadow champion', () {
      final room = roomState(
        players: [
          player(1, 'A', status: f),
          player(2, 'B', status: out),
        ],
      );
      expect(shadowChampion(room), isNull);
    });
  });

  group('Given the podium personal line', () {
    final room = finished();
    PlayerView p(int id) => room.players.firstWhere((x) => x.id == id);

    test('when the winner looks then they won', () {
      expect(PodiumView.personalLine(room, p(2)), 'You won Quiz Night!');
    });

    test('when another finalist looks then their place', () {
      expect(PodiumView.personalLine(room, p(3)), 'You finished #3');
    });

    test('when a spectator backed the winner then they called it', () {
      expect(PodiumView.personalLine(room, p(4)), 'You called it!');
    });

    test('when a spectator backed someone else then it says who', () {
      expect(PodiumView.personalLine(room, p(5)), 'You backed Bo');
    });

    test('when a spectator backed nobody or it is the host then no line', () {
      expect(PodiumView.personalLine(room, p(6)), isNull);
      expect(PodiumView.personalLine(room, null), isNull);
    });
  });

  group('Given an open final question', () {
    RoomState open({int? holder}) => roomState(
      status: RoomStatus.buzzerFinal,
      question: question(isFinal: true),
      buzzerHolderId: holder,
      players: [
        player(1, 'Ada', status: f),
        player(2, 'Bo', status: f, lockedOut: true),
        player(3, 'Cy', status: f),
        player(4, 'Dee', status: out),
      ],
    );
    PlayerView p(RoomState room, int id) =>
        room.players.firstWhere((x) => x.id == id);

    test('when nobody holds the buzzer then a free finalist can buzz', () {
      final room = open();
      expect(buzzerSeatFor(room, p(room, 1)), BuzzerSeat.canBuzz);
      expect(
        buzzerSeatFor(room, p(room, 1), buzzing: true),
        BuzzerSeat.buzzing,
      );
    });

    test('when I hold the buzzer then I am holding', () {
      final room = open(holder: 1);
      expect(buzzerSeatFor(room, p(room, 1)), BuzzerSeat.holding);
      expect(finalistTagFor(room, p(room, 1)), FinalistTag.buzzed);
    });

    test('when someone else holds it then I wait', () {
      final room = open(holder: 3);
      expect(buzzerSeatFor(room, p(room, 1)), BuzzerSeat.otherHolding);
    });

    test('when I answered wrong then I am locked out', () {
      final room = open(holder: 3);
      expect(buzzerSeatFor(room, p(room, 2)), BuzzerSeat.lockedOut);
      expect(finalistTagFor(room, p(room, 2)), FinalistTag.lockedOut);
    });

    test('when I am not a finalist then I spectate', () {
      final room = open();
      expect(buzzerSeatFor(room, p(room, 4)), BuzzerSeat.spectator);
      expect(buzzerSeatFor(room, null), BuzzerSeat.spectator);
    });

    test('when describing it then the status line names the holder', () {
      expect(finalStatusLine(open()), 'Buzz to answer!');
      expect(finalStatusLine(open(holder: 3)), 'Cy is answering…');
    });
  });

  group('Given a revealed final question', () {
    RoomState revealed({int? winner, int played = 1}) => roomState(
      status: RoomStatus.reveal,
      question: question(isFinal: true, revealed: true),
      finalQuestionCount: 3,
      finalQuestionsPlayed: played,
      buzzWinnerId: winner,
      players: [player(1, 'Ada', status: f)],
    );

    test('when someone got it then the line credits them', () {
      expect(finalStatusLine(revealed(winner: 1)), 'Ada got it! +1000');
      expect(
        finalistTagFor(revealed(winner: 1), revealed().players.first),
        FinalistTag.gotIt,
      );
    });

    test('when nobody got it then it says so', () {
      expect(finalStatusLine(revealed()), 'Nobody got it');
    });

    test('when final questions remain then the host goes to the next one', () {
      expect(hostStepFor(revealed(played: 2)), HostStep.nextQuestion);
    });

    test('when the last final question is done then show the podium', () {
      expect(hostStepFor(revealed(played: 3)), HostStep.showPodium);
    });
  });
}
