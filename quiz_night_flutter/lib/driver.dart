// This file is never meant to be used on real apps, just for development.
// ignore: depend_on_referenced_packages
import 'package:flutter_driver/driver_extension.dart';

import 'main.dart' as app;

void main() {
  enableFlutterDriverExtension(
    // Text entry emulation is off for manual use; set true for agents.
    enableTextEntryEmulation: false,
  );
  app.main();
}
