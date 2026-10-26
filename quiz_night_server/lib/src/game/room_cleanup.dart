import 'dart:async';

import 'package:serverpod/serverpod.dart';

import '../generated/protocol.dart';

/// Deletes old rooms, so nicknames, answers and scores are kept for a day at
/// most, and room codes come free again. Players, questions, answers and
/// buzzes go with their room (the tables cascade).
abstract final class RoomCleanup {
  /// How long a room's data is kept. A game takes well under an hour, so a
  /// day leaves room for a late podium without keeping anything for long.
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

  /// Sweeps once now, then every [every], each in its own session. Returns
  /// the timer so the caller could stop it.
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
