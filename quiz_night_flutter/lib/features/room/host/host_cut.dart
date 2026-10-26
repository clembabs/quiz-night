import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:quiz_night_client/quiz_night_client.dart';

import '../../../core/platform/sounds.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_motion.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../widgets/brand/initial_badge.dart';
import '../../../widgets/qn/finalist_desk.dart';
import '../../../widgets/qn/host_stage.dart';
import '../../../widgets/qn/notices.dart';
import '../../../widgets/qn/standings_row.dart';
import '../cut_reveal/cut_reveal_scope.dart';
import '../cut_reveal/reveal_sequence_cubit.dart';
import '../final/final_logic.dart';
import '../room_cubit.dart';
import '../round/host_step_button.dart';

/// The projector cut as a show: face-down cards flip to names stamped OUT.
class HostCut extends StatelessWidget {
  final RoomState room;

  /// Overridable for tests.
  final RevealSequenceCubit Function(int total)? createSequence;

  const HostCut({super.key, required this.room, this.createSequence});

  static bool canUseWildcard(RoomState room) =>
      !room.wildcardUsed && room.finalQuestionsPlayed == 0;

  @override
  Widget build(BuildContext context) {
    final event = room.lastElimination;
    final byId = {for (final p in room.players) p.id: p};
    final out = [
      for (final id in event?.eliminatedPlayerIds ?? const <int>[]) ?byId[id],
    ];
    final finalists = event?.finalistsDecided ?? false;

    return CutRevealScope(
      event: event,
      createCubit: createSequence,
      builder: (context, seq) {
        final title = switch (seq.phase) {
          RevealPhase.intro =>
            out.isEmpty ? 'Is anyone going home?' : 'Who’s going home?',
          RevealPhase.revealing when seq.waitingForLast =>
            'And the last one going home…',
          RevealPhase.revealing => 'Going home…',
          RevealPhase.done =>
            finalists ? 'Meet your finalists' : 'Round ${room.round} is over',
        };
        final showDesks = seq.isDone && finalists;
        final portrait = HostLayout.isPortrait(context);
        return _CutSounds(
          sequence: seq,
          anyoneOut: out.isNotEmpty,
          finalists: finalists,
          child: Column(
            children: [
              Text(
                title.toUpperCase(),
                key: const Key('cut.title'),
                textAlign: TextAlign.center,
                style: AppTextStyles.displayXl.copyWith(
                  fontSize: portrait ? 72 : 96,
                ),
              ),
              SizedBox(height: portrait ? 40 : 56),
              Expanded(
                child: showDesks
                    ? _Desks(room: room)
                    : _Shake(
                        trigger: seq.revealed,
                        child: _Cards(
                          players: out,
                          stamped: seq.revealed,
                          wildcard: seq.isDone && canUseWildcard(room),
                        ),
                      ),
              ),
              if (seq.isDone && !showDesks) ...[
                _Survive(count: event?.survivorsCount ?? 0),
                if (event?.tieBrokenBySpeed ?? false)
                  Text(
                    'A tie at the cutoff was broken by answer speed.',
                    style: AppProjectorText.caption,
                  ),
              ],
              const SizedBox(height: 24),
              Align(
                alignment: Alignment.centerRight,
                child: seq.isDone
                    ? HostStepButton(room: room)
                    : HostTextButton(
                        label: 'Skip',
                        onPressed: context.read<RevealSequenceCubit>().skip,
                      ),
              ),
            ],
          ),
        );
      },
    );
  }
}

/// Plays the cut's drumroll, stamps and closing chime as [sequence] moves.
class _CutSounds extends StatefulWidget {
  final RevealSequenceState sequence;
  final bool anyoneOut;
  final bool finalists;
  final Widget child;

  const _CutSounds({
    required this.sequence,
    required this.anyoneOut,
    required this.finalists,
    required this.child,
  });

  @override
  State<_CutSounds> createState() => _CutSoundsState();
}

class _CutSoundsState extends State<_CutSounds> {
  late final Sounds _sounds = Sounds.of(context);

  @override
  void initState() {
    super.initState();
    if (widget.sequence.phase == RevealPhase.intro && widget.anyoneOut) {
      _sounds.play(SoundCue.drumroll);
    }
  }

  @override
  void didUpdateWidget(_CutSounds old) {
    super.didUpdateWidget(old);
    final was = old.sequence;
    final now = widget.sequence;
    if (now.isDone && !was.isDone) {
      _sounds
        ..stop()
        ..play(widget.finalists ? SoundCue.fanfare : SoundCue.survive);
    } else if (now.revealed > was.revealed) {
      _sounds.play(SoundCue.stamp);
      if (now.waitingForLast) _sounds.play(SoundCue.drumroll);
    }
  }

  @override
  void dispose() {
    _sounds.stop();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => widget.child;
}

/// Jolts [child] sideways each time [trigger] goes up: the stamp landing.
class _Shake extends StatelessWidget {
  final int trigger;
  final Widget child;

  const _Shake({required this.trigger, required this.child});

  @override
  Widget build(BuildContext context) => TweenAnimationBuilder<double>(
    // A new key per stamp restarts the shake from the start.
    key: ValueKey(trigger),
    tween: Tween(begin: trigger == 0 ? 1 : 0, end: 1),
    duration: const Duration(milliseconds: 380),
    builder: (context, t, child) => Transform.translate(
      // A decaying wobble: three swings, gone by the end.
      offset: Offset(sin(t * pi * 6) * 14 * (1 - t), 0),
      child: child,
    ),
    child: child,
  );
}

class _Cards extends StatelessWidget {
  final List<PlayerView> players;
  final int stamped;
  final bool wildcard;

  const _Cards({
    required this.players,
    required this.stamped,
    required this.wildcard,
  });

  @override
  Widget build(BuildContext context) {
    if (players.isEmpty) {
      return Center(
        child: Text(
          'Nobody goes home this round',
          style: AppProjectorText.title.copyWith(color: AppColors.chalkSoft),
        ),
      );
    }
    final portrait = HostLayout.isPortrait(context);
    final cols = portrait
        ? (players.length <= 6 ? 2 : 3)
        : (players.length <= 10 ? 5 : 8);
    final height = players.length <= (portrait ? 4 : 5) ? 300.0 : 220.0;
    return LayoutBuilder(
      builder: (context, c) {
        const gap = 28.0;
        final width = (c.maxWidth - gap * (cols - 1)) / cols;
        return SingleChildScrollView(
          child: Wrap(
            alignment: WrapAlignment.center,
            spacing: gap,
            runSpacing: gap,
            children: [
              for (var i = 0; i < players.length; i++)
                SizedBox(
                  width: width,
                  height: height,
                  child: _OutCard(
                    player: players[i],
                    out: i < stamped,
                    wildcard: wildcard,
                    compact: height < 300,
                  ),
                ),
            ],
          ),
        );
      },
    );
  }
}

class _OutCard extends StatelessWidget {
  final PlayerView player;
  final bool out;
  final bool wildcard;
  final bool compact;

  const _OutCard({
    required this.player,
    required this.out,
    required this.wildcard,
    required this.compact,
  });

  Future<void> _rescue(BuildContext context) async {
    final cubit = context.read<RoomCubit>();
    final ok = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Rescue ${player.nickname}?'.toUpperCase()),
        content: const Text('The wildcard can only be used once per game.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Rescue'),
          ),
        ],
      ),
    );
    if (ok == true) await cubit.useWildcard(player.id);
  }

  @override
  Widget build(BuildContext context) => AnimatedSwitcher(
    duration: const Duration(milliseconds: 420),
    transitionBuilder: _flip,
    child: out
        ? KeyedSubtree(key: const ValueKey('front'), child: _front(context))
        : _FaceDown(key: const ValueKey('back'), compact: compact),
  );

  /// Turns the card over: the old face folds away, the new one unfolds.
  static Widget _flip(Widget child, Animation<double> animation) =>
      AnimatedBuilder(
        animation: animation,
        child: child,
        builder: (context, child) {
          // Each face shows for its half of the turn only.
          final t = animation.value;
          final angle = (1 - t) * pi;
          return Opacity(
            opacity: t < 0.5 ? 0 : 1,
            child: Transform(
              alignment: Alignment.center,
              transform: Matrix4.identity()
                ..setEntry(3, 2, 0.001)
                ..rotateY(angle > pi / 2 ? 0 : angle),
              child: child,
            ),
          );
        },
      );

  Widget _front(BuildContext context) {
    final badge = compact ? 80.0 : 110.0;
    return Container(
      decoration: BoxDecoration(
        color: AppColors.maroonDarkest,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: AppColors.maroon, width: 4),
      ),
      child: Stack(
        children: [
          Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                InitialBadge(
                  nickname: player.nickname,
                  size: badge,
                  eliminated: true,
                ),
                SizedBox(height: compact ? 12 : 20),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  child: Text(
                    player.nickname,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: AppTextStyles.chip.copyWith(
                      fontSize: compact ? 32 : 44,
                      fontWeight: FontWeight.w800,
                      decoration: TextDecoration.lineThrough,
                      decorationColor: AppColors.wrong,
                      decorationThickness: 3,
                    ),
                  ),
                ),
                Text(
                  formatScore(player.score),
                  style: AppProjectorText.caption.copyWith(fontSize: 26),
                ),
              ],
            ),
          ),
          // The stamp slams down just after the card has turned.
          Positioned.fill(
            child: IgnorePointer(
              child: TweenAnimationBuilder<double>(
                tween: Tween(begin: 0, end: 1),
                duration: const Duration(milliseconds: 700),
                builder: (context, t, child) {
                  final s = const Interval(
                    0.45,
                    1,
                    curve: AppCurves.stamp,
                  ).transform(t);
                  return Opacity(
                    opacity: t < 0.45 ? 0 : 1,
                    child: Transform.scale(scale: 1.8 - 0.8 * s, child: child),
                  );
                },
                child: Center(
                  child: OutStamp(fontSize: compact ? 36 : 48, tilt: -12),
                ),
              ),
            ),
          ),
          if (wildcard)
            Positioned(
              right: 12,
              top: 12,
              child: Material(
                color: AppColors.goldDeep,
                shape: StadiumBorder(
                  side: BorderSide(color: AppColors.gold, width: 2),
                ),
                child: InkWell(
                  key: Key('wildcard.${player.id}'),
                  customBorder: const StadiumBorder(),
                  onTap: () => _rescue(context),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 6,
                    ),
                    child: Text(
                      '★ Wildcard',
                      style: AppProjectorText.caption.copyWith(
                        fontSize: 22,
                        color: AppColors.goldPale,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

/// A card not yet turned: who is on it stays secret until their turn.
class _FaceDown extends StatelessWidget {
  final bool compact;

  const _FaceDown({super.key, required this.compact});

  @override
  Widget build(BuildContext context) => Container(
    decoration: BoxDecoration(
      color: AppColors.surface,
      borderRadius: BorderRadius.circular(24),
      border: Border.all(color: AppColors.line, width: 4),
    ),
    child: Center(
      child: Text(
        '?',
        style: AppTextStyles.displayXl.copyWith(
          fontSize: compact ? 88 : 120,
          color: AppColors.chalk.withValues(alpha: 0.25),
        ),
      ),
    ),
  );
}

class _Survive extends StatelessWidget {
  final int count;

  const _Survive({required this.count});

  @override
  Widget build(BuildContext context) => TweenAnimationBuilder<double>(
    tween: Tween(begin: 0.7, end: 1),
    duration: const Duration(milliseconds: 600),
    curve: AppCurves.stamp,
    builder: (context, s, child) => Opacity(
      opacity: ((s - 0.7) / 0.3).clamp(0.0, 1.0),
      child: Transform.scale(scale: s, child: child),
    ),
    // Shrinks rather than overflows on a narrow phone.
    child: FittedBox(
      fit: BoxFit.scaleDown,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.baseline,
        textBaseline: TextBaseline.alphabetic,
        children: [
          Text(
            '$count',
            key: const Key('cut.survivors'),
            style: AppTextStyles.displayXl.copyWith(
              fontSize: 180,
              height: 0.9,
              color: AppColors.mint,
            ),
          ),
          const SizedBox(width: 24),
          Text(
            'SURVIVE',
            style: AppTextStyles.displayXl.copyWith(fontSize: 80),
          ),
        ],
      ),
    ),
  );
}

/// "Meet your finalists": the desks, before the first final question.
class _Desks extends StatelessWidget {
  final RoomState room;

  const _Desks({required this.room});

  @override
  Widget build(BuildContext context) => Column(
    children: [
      Text(
        'First to buzz answers on their phone. A wrong answer locks you out.',
        textAlign: TextAlign.center,
        style: AppProjectorText.bodySoft.copyWith(fontSize: 40),
      ),
      const SizedBox(height: 40),
      Expanded(child: FinalistDesks(room: room)),
    ],
  );
}

/// The finalists' desks in a row (shared with the final).
class FinalistDesks extends StatelessWidget {
  final RoomState room;

  const FinalistDesks({super.key, required this.room});

  @override
  Widget build(BuildContext context) {
    final finalists = finalistsByJoin(room);
    return Row(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        for (var i = 0; i < finalists.length; i++) ...[
          if (i > 0) const SizedBox(width: 40),
          Expanded(
            child: FinalistDesk(
              nickname: finalists[i].nickname,
              score: formatScore(finalists[i].finalScore),
              state: deskStateFor(room, finalists[i]),
              layoutWidth: HostLayout.isPortrait(context)
                  ? FinalistDesk.compactWidth
                  : FinalistDesk.designWidth,
            ),
          ),
        ],
      ],
    );
  }
}
