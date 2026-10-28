import 'package:flutter_test/flutter_test.dart';
import 'package:quiz_night_client/quiz_night_client.dart';
import 'package:quiz_night_flutter/features/room/final/final_logic.dart';
import 'package:quiz_night_flutter/features/room/phone/phone_placement.dart';
import 'package:quiz_night_flutter/features/room/round_logic.dart';

import '../fakes/fakes.dart';

const f = PlayerStatus.finalist;
const out = PlayerStatus.eliminated;

void main() {
  /// Ada leads, Bo second, Cy third; Dee backed Ada, Eve Bo, Fay nobody.
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

  group('Given the phone placement wording', () {
    final room = finished();
    PlayerView p(int id) => room.players.firstWhere((x) => x.id == id);

    test('when the winner looks then they are champion', () {
      expect(PhonePlacement.titleFor(room, p(2)), 'Champion');
      expect(
        PhonePlacement.detailFor(room, p(2)),
        'You win Quiz Night! 1,000 round points, 2,000 in the final.',
      );
    });

    test('when another finalist looks then they are a finalist', () {
      expect(PhonePlacement.titleFor(room, p(3)), 'Finalist');
      expect(PhonePlacement.detailFor(room, p(3)), contains('Ada wins'));
      expect(
        PhonePlacement.detailFor(room, p(3)),
        endsWith('You: 2,000 round points, 1,000 in the final.'),
      );
    });

    test('when a spectator backed the winner then it says so', () {
      expect(
        PhonePlacement.detailFor(room, p(4)),
        'You backed the winner, Ada. 0 points, shadow score 900.',
      );
    });

    test('when a spectator backed someone else then it says who', () {
      expect(
        PhonePlacement.detailFor(room, p(5)),
        'You backed Bo. Ada won. 0 points, shadow score 2,400.',
      );
    });

    test('when a spectator backed nobody, with no shadow score, then it '
        'nudges them and leaves the zero out', () {
      expect(
        PhonePlacement.detailFor(room, p(6)),
        '0 points. Back a finalist next time.',
      );
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
      expect(deskStateFor(room, p(room, 1)), DeskState.buzzedFirst);
    });

    test('when someone else holds it then I wait', () {
      final room = open(holder: 3);
      expect(buzzerSeatFor(room, p(room, 1)), BuzzerSeat.otherHolding);
    });

    test('when I answered wrong then I am locked out', () {
      final room = open(holder: 3);
      expect(buzzerSeatFor(room, p(room, 2)), BuzzerSeat.lockedOut);
      expect(deskStateFor(room, p(room, 2)), DeskState.lockedOut);
    });

    test('when I am not a finalist then I spectate', () {
      final room = open();
      expect(buzzerSeatFor(room, p(room, 4)), BuzzerSeat.spectator);
      expect(buzzerSeatFor(room, null), BuzzerSeat.spectator);
    });

    test('when describing it then the status line names the holder, or who '
        'just missed', () {
      // Bo answered wrong: everyone is told, and buzzing reopens.
      expect(
        finalStatusLine(open()),
        'Bo got it wrong and is locked out. Buzz to answer!',
      );
      expect(finalStatusLine(open(holder: 3)), 'Cy is answering…');
    });

    test('when two have missed then both are named', () {
      final room = open().copyWith(
        players: [
          for (final x in open().players)
            x.id == 1 ? x.copyWith(lockedOut: true) : x,
        ],
      );
      expect(lockoutLine(room), 'Ada and Bo got it wrong and are locked out.');
      expect(namesList(['Ada', 'Bo', 'Cy']), 'Ada, Bo and Cy');
    });

    test('when nobody has missed then it just invites a buzz', () {
      final room = roomState(
        status: RoomStatus.buzzerFinal,
        question: question(isFinal: true),
        players: [
          player(1, 'Ada', status: f),
          player(2, 'Bo', status: f),
        ],
      );
      expect(finalStatusLine(room), 'Buzz to answer!');
      expect(lockoutLine(room), isNull);
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
        deskStateFor(revealed(winner: 1), revealed().players.first),
        DeskState.gotIt,
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
