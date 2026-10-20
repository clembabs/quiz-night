import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:quiz_night_client/quiz_night_client.dart';

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

/// The projector cut: a suspense beat, names stamped OUT one by one, then
/// "13 SURVIVE" (or the finalists' desks when the final is next).
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
          RevealPhase.revealing => 'Going home…',
          RevealPhase.done =>
            finalists ? 'Meet your finalists' : 'Round ${room.round} is over',
        };
        final showDesks = seq.isDone && finalists;
        final portrait = HostLayout.isPortrait(context);
        return Column(
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
                  : _Cards(
                      players: out,
                      stamped: seq.revealed,
                      wildcard: seq.isDone && canUseWildcard(room),
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
        );
      },
    );
  }
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
  Widget build(BuildContext context) {
    final badge = compact ? 80.0 : 110.0;
    return AnimatedContainer(
      duration: AppDurations.normal,
      decoration: BoxDecoration(
        color: out ? AppColors.maroonDarkest : AppColors.surface,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: out ? AppColors.maroon : AppColors.line,
          width: 4,
        ),
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
                  eliminated: out,
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
                      decoration: out ? TextDecoration.lineThrough : null,
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
          Positioned.fill(
            child: IgnorePointer(
              child: AnimatedOpacity(
                duration: const Duration(milliseconds: 120),
                opacity: out ? 1 : 0,
                child: AnimatedScale(
                  duration:
                      AppDurations.normal + const Duration(milliseconds: 50),
                  curve: AppCurves.stamp,
                  scale: out ? 1 : 1.6,
                  child: Center(
                    child: OutStamp(fontSize: compact ? 36 : 48, tilt: -12),
                  ),
                ),
              ),
            ),
          ),
          if (wildcard && out)
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
