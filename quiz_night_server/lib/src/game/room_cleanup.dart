import 'dart:async';

import 'package:serverpod/serverpod.dart';

import '../generated/protocol.dart';

/// Deletes day-old rooms (data cascades), freeing codes and player data.
abstract final class RoomCleanup {
  /// A game takes under an hour; a day allows a late podium, keeps little.
  static const keepFor = Duration(hours: 24);

  /// How often the server sweeps.
  static const every = Duration(hours: 1);

  /// Deletes rooms created before `now - keepFor`. Returns how many.
  static Future<int> run(Session session, {DateTime? now}) async {
    final cutoff = (now ?? DateTime.now().toUtc()).subtract(keepFor);
    final deleted = await Room.db.deleteWhere(
      session,
      where: (t) => t.createdAt < cutoff,
    );
    // Question packs, used or not, go on the same schedule.
    await QuestionPack.db.deleteWhere(
      session,
      where: (t) => t.createdAt < cutoff,
    );
    return deleted.length;
  }

  /// Sweeps now and every [every], each in a fresh session. Returns the timer.
  static Timer schedule(Serverpod pod) {
    Future<void> sweep() async {
      final session = await pod.createSession(enableLogging: false);
      try {
        final count = await run(session);
        if (count > 0) session.log('Deleted $count rooms older than a day');
      } catch (e, st) {
        session.log(
          'Room clean-up failed',
          level: LogLevel.error,
          exception: e,
          stackTrace: st,
        );
      } finally {
        await session.close();
      }
    }

    unawaited(sweep());
    return Timer.periodic(every, (_) => unawaited(sweep()));
  }
}
