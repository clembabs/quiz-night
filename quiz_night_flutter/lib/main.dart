import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'app/quiz_night_app.dart';
import 'core/platform/haptics.dart';
import 'core/platform/screen_wake_lock.dart';
import 'client.dart';
import 'data/room_repositories.dart';
import 'data/seat_repository.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  _registerFontLicenses();
  await initializeClient();
  final rooms = ServerpodRoomRepository(client);
  final code = Uri.base.queryParameters['code']?.trim().toUpperCase();
  runApp(
    QuizNightApp(
      lobby: rooms,
      game: rooms,
      seats: PrefsSeatRepository(),
      wakeLock: createScreenWakeLock(),
      haptics: createHaptics(),
      initialCode: (code == null || code.isEmpty) ? null : code,
    ),
  );
}

/// The bundled fonts are SIL Open Font License; list them in the app's
/// licence page alongside the package licences.
void _registerFontLicenses() {
  LicenseRegistry.addLicense(() async* {
    for (final (name, file) in [
      ('Bricolage Grotesque', 'Bricolage'),
      ('Figtree', 'Figtree'),
      ('Noto Sans', 'NotoSans'),
      ('Noto Sans Symbols 2', 'NotoSansSymbols2'),
    ]) {
      final text = await rootBundle.loadString(
        'assets/fonts/licenses/$file-OFL.txt',
      );
      yield LicenseEntryWithLineBreaks([name], text);
    }
  });
}
