import 'dart:async';

import 'package:serverpod/serverpod.dart';

import 'room_service.dart';

/// Every 30s, ends overdue games and idle rooms ([RoomService.endExpired]).
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
