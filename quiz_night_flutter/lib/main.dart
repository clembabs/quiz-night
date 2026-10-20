import 'package:flutter/material.dart';

import 'app/quiz_night_app.dart';
import 'core/platform/screen_wake_lock.dart';
import 'client.dart';
import 'data/room_repositories.dart';
import 'data/seat_repository.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await initializeClient();
  final rooms = ServerpodRoomRepository(client);
  final code = Uri.base.queryParameters['code']?.trim().toUpperCase();
  runApp(
    QuizNightApp(
      lobby: rooms,
      game: rooms,
      seats: PrefsSeatRepository(),
      wakeLock: createScreenWakeLock(),
      initialCode: (code == null || code.isEmpty) ? null : code,
    ),
  );
}
