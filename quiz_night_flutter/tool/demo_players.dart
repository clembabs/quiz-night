// Fills a room with demo players for a rehearsal or a demo video. They join
// like phones do, through the public API, and guess at every question.
//
//   dart run tool/demo_players.dart --code K7QM --count 8
//   dart run tool/demo_players.dart --code K7QM --server http://localhost:8080
//
// Ctrl+C makes them leave.
import 'dart:async';
import 'dart:io';

import 'package:quiz_night_client/quiz_night_client.dart';

import 'demo_players/bot_brain.dart';

const _liveServer = 'https://quiznight.api.serverpod.space/';

/// Joins per room are limited to 20 a minute; leave room for real phones.
const _maxBots = 15;

Future<void> main(List<String> args) async {
  final options = _parse(args);
  final code = options['code']?.toUpperCase();
  if (code == null || code.isEmpty) {
    stderr.writeln(
      'Usage: dart run tool/demo_players.dart --code ROOM '
      '[--count 8] [--server URL]',
    );
    exitCode = 64;
    return;
  }
  final count = (int.tryParse(options['count'] ?? '') ?? 8).clamp(1, _maxBots);
  var server = options['server'] ?? _liveServer;
  if (!server.endsWith('/')) server = '$server/';
  if (!(Uri.tryParse(server)?.hasAuthority ?? false)) {
    stderr.writeln('--server needs a full URL, like http://localhost:8080');
    exitCode = 64;
    return;
  }

  final client = Client(server);
  final bots = <_Bot>[];

  for (final name in botNames) {
    if (bots.length == count) break;
    try {
      final joined = await client.room.joinRoom(code, name);
      bots.add(_Bot(name, joined, BotBrain(joined.playerId)));
      stdout.writeln('✓ $name joined');
    } on QuizException catch (e) {
      // A real player may have the name already; try the next one.
      if (e.code == QuizErrorCode.nicknameTaken) continue;
      stderr.writeln('✗ $name: ${e.message}');
      if (bots.isEmpty) {
        client.close();
        exitCode = 1;
        return;
      }
      break;
    } catch (e) {
      stderr.writeln('✗ Could not reach $server ($e)');
      client.close();
      exitCode = 1;
      return;
    }
    // Spaced out, so the lobby fills like people arriving.
    await Future<void>.delayed(const Duration(milliseconds: 400));
  }
  stdout.writeln(
    '${bots.length} demo players in room $code. Ctrl+C to make them leave.',
  );

  RoomState? latest;
  var done = false;

  /// Leaves the room; after the podium they stay, so it isn't spoiled.
  Future<void> leave({bool stay = false}) async {
    if (done) return;
    done = true;
    if (!stay) stdout.writeln('\nLeaving…');
    for (final bot in stay ? const <_Bot>[] : bots) {
      try {
        await client.room.leaveRoom(code, bot.joined.playerToken);
      } catch (_) {
        // The room may be gone already.
      }
    }
    client.close();
    exit(0);
  }

  ProcessSignal.sigint.watch().listen((_) => leave());

  Future<void> run(_Bot bot, BotMove move) async {
    await Future<void>.delayed(move.delay);
    final state = latest;
    if (done || state == null || !BotBrain.stillValid(move, state)) return;
    final token = bot.joined.playerToken;
    try {
      switch (move) {
        case AnswerMove(:final questionId, :final choice):
          await client.answer.submitAnswer(token, questionId, choice);
        case BuzzMove(:final questionId):
          final r = await client.buzzer.buzz(token, questionId);
          if (r.gotBuzzer) stdout.writeln('🔔 ${bot.name} buzzed');
        case BuzzAnswerMove(:final questionId, :final choice):
          final right = await client.buzzer.submitBuzzAnswer(
            token,
            questionId,
            choice,
          );
          stdout.writeln('${right ? '✓' : '✗'} ${bot.name} answered');
        case BackMove(:final finalistId):
          await client.buzzer.backFinalist(token, finalistId);
      }
    } on QuizException catch (e) {
      // Too late, someone else buzzed first, and so on: a real phone shrugs.
      stdout.writeln('· ${bot.name}: ${e.message}');
    } catch (e) {
      stderr.writeln('· ${bot.name}: $e');
    }
  }

  // One stream for every bot; it starts with a full snapshot, so a dropped
  // connection is picked up again where it left off.
  var backoff = const Duration(seconds: 1);
  while (!done) {
    try {
      await for (final state in client.room.watchRoom(code)) {
        backoff = const Duration(seconds: 1);
        final previous = latest?.status;
        latest = state;
        if (state.status != previous) stdout.writeln('— ${state.status.name}');
        for (final bot in bots) {
          for (final move in bot.brain.movesFor(state)) {
            unawaited(run(bot, move));
          }
        }
        if (state.status == RoomStatus.finished) {
          stdout.writeln('Game over.');
          await leave(stay: true);
        }
      }
    } on QuizException catch (e) {
      stderr.writeln('Room closed: ${e.message}');
      await leave();
    } catch (e) {
      stderr.writeln('Connection dropped ($e); reconnecting…');
    }
    if (done) break;
    await Future<void>.delayed(backoff);
    backoff = backoff * 2 > const Duration(seconds: 15)
        ? const Duration(seconds: 15)
        : backoff * 2;
  }
}

class _Bot {
  final String name;
  final JoinResult joined;
  final BotBrain brain;
  _Bot(this.name, this.joined, this.brain);
}

/// `--name value` pairs.
Map<String, String> _parse(List<String> args) => {
  for (var i = 0; i + 1 < args.length; i++)
    if (args[i].startsWith('--')) args[i].substring(2): args[i + 1],
};
