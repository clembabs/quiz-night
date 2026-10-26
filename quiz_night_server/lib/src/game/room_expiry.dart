import 'dart:async';

import 'package:serverpod/serverpod.dart';

import 'room_service.dart';

/// Checks every half minute for games past their 30 minutes and rooms idle
/// for 30 minutes, and ends them (see [RoomService.endExpired]), so a
/// forgotten room stops costing the server anything.
abstract final class RoomExpiry {
  static const every = Duration(seconds: 30);

  static Timer schedule(Serverpod pod) => Timer.periodic(every, (_) async {
    final session = await pod.createSession(enableLogging: false);
    try {
      await RoomService.endExpired(session);
    } catch (e, st) {
      session.log(
        'Ending expired rooms failed',
        level: LogLevel.error,
        exception: e,
        stackTrace: st,
      );
    } finally {
      await session.close();
    }
  });
}
