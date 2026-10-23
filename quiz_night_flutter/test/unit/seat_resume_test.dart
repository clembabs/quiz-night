import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:quiz_night_flutter/app/seat_resume.dart';

import '../fakes/fakes.dart';

void main() {
  setUpAll(registerFallbacks);

  late MockLobbyRepository lobby;
  late MockSeatRepository seats;
  late SeatResume resume;

  setUp(() {
    lobby = MockLobbyRepository();
    seats = MockSeatRepository();
    resume = SeatResume(lobby, seats);
    when(() => seats.clear()).thenAnswer((_) async {});
  });

  Future<String?> at(String location) =>
      resume.redirectFor(Uri.parse(location));

  group('Given no saved seat', () {
    test('when the home page opens then it stays', () async {
      when(() => seats.load()).thenAnswer((_) async => null);
      expect(await at('/'), isNull);
      verifyNever(() => lobby.isSeatLive(any()));
    });
  });

  group('Given a saved seat in room ABCD', () {
    setUp(() => when(() => seats.load()).thenAnswer((_) async => playerSeat));

    test('when its game is live then home, join and host go back in', () async {
      when(() => lobby.isSeatLive(playerSeat)).thenAnswer((_) async => true);
      expect(await at('/'), '/room/ABCD');
      expect(await at('/join'), '/room/ABCD');
      expect(await at('/join?code=ABCD'), '/room/ABCD');
      expect(await at('/host'), '/room/ABCD');
    });

    test('when its game is over or gone then it is forgotten', () async {
      when(() => lobby.isSeatLive(playerSeat)).thenAnswer((_) async => false);
      expect(await at('/'), isNull);
      verify(() => seats.clear()).called(1);
    });

    test('when a QR for another room opens then that room wins', () async {
      expect(await at('/join?code=4821'), isNull);
      verifyNever(() => lobby.isSeatLive(any()));
    });

    test('when a website page opens then there is no check at all', () async {
      expect(await at('/faq'), isNull);
      expect(await at('/room/ABCD'), isNull);
      verifyNever(() => seats.load());
      verifyNever(() => lobby.isSeatLive(any()));
    });
  });
}
