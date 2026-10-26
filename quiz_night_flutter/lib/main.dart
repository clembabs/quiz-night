import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_web_plugins/url_strategy.dart';

import 'app/quiz_night_app.dart';
import 'core/platform/haptics.dart';
import 'core/platform/screen_wake_lock.dart';
import 'core/platform/sounds.dart';
import 'client.dart';
import 'data/questions_repository.dart';
import 'data/room_repositories.dart';
import 'data/seat_repository.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // Path URLs, not `/#/`; the server serves index.html for unknown paths.
  usePathUrlStrategy();
  _registerFontLicenses();
  await initializeClient();
  final rooms = ServerpodRoomRepository(client);
  runApp(
    QuizNightApp(
      lobby: rooms,
      game: rooms,
      seats: PrefsSeatRepository(),
      questions: ServerpodQuestionsRepository(client),
      wakeLock: createScreenWakeLock(),
      haptics: createHaptics(),
      sounds: createSounds(),
    ),
  );
}

/// Lists the bundled SIL OFL fonts on the licence page.
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
