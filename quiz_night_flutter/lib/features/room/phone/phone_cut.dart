import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:quiz_night_client/quiz_night_client.dart';

import '../../../core/platform/haptics.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_motion.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../widgets/brand/crest.dart';
import '../../../widgets/brand/initial_badge.dart';
import '../../../widgets/qn/celebrations.dart';
import '../../../widgets/qn/loaders.dart';
import '../../../widgets/qn/notices.dart';
import '../../../widgets/qn/standings_row.dart';
import '../cut_reveal/cut_reveal_scope.dart';
import '../cut_reveal/reveal_sequence_cubit.dart';
import '../final/final_logic.dart';
import '../room_cubit.dart';
import '../round_logic.dart';
import '../standings_logic.dart';

/// Background a phone cut screen paints behind itself.
Color cutBackground(
  CutOutcome outcome, {
  required bool fateKnown,
  required bool keepWatching,
}) {
  if (!fateKnown) return AppColors.board;
  return switch (outcome) {
    CutOutcome.survived || CutOutcome.finalist => AppColors.green,
    CutOutcome.out => keepWatching ? AppColors.board : AppColors.maroonDarkest,
    CutOutcome.alreadyOut => AppColors.board,
  };
}

/// The phone during a cut: suspense until your fate shows, then You
/// survived / Eliminated, then (for spectators) back a finalist.
class PhoneCut extends StatelessWidget {
  final RoomState room;
  final PlayerView? me;
  final int? myBackedId;
  final bool keepWatching;

  /// Overridable for tests.
  final RevealSequenceCubit Function(int total)? createSequence;

  const PhoneCut({
    super.key,
    required this.room,
    required this.me,
    this.myBackedId,
    this.keepWatching = false,
    this.createSequence,
  });

  @override
  Widget build(BuildContext context) {
    final event = room.lastElimination;
    final outcome = cutOutcomeFor(room, me);
    return CutRevealScope(
      event: event,
      createCubit: createSequence,
      builder: (context, seq) {
        final known =
            outcome == CutOutcome.alreadyOut ||
            fateRevealed(event: event, myId: me?.id, sequence: seq);
        final bg = cutBackground(
          outcome,
          fateKnown: known,
          keepWatching: keepWatching,
        );
        final Widget body;
        if (!known) {
          body = _Suspense(sequence: seq);
        } else if (outcome == CutOutcome.survived ||
            outcome == CutOutcome.finalist) {
          body = _Survived(
            room: room,
            finalist: outcome == CutOutcome.finalist,
          );
        } else if (outcome == CutOutcome.out && !keepWatching) {
          body = _Eliminated(room: room, me: me!);
        } else if (seq.isDone && _canBack(room)) {
          body = BackFinalist(room: room, me: me, backedId: myBackedId);
        } else {
          body = _Spectating(room: room, me: me);
        }
        return AnimatedContainer(
          duration: const Duration(milliseconds: 500),
          color: bg,
          child: _FateHaptic(known: known, outcome: outcome, child: body),
        );
      },
    );
  }

  static bool _canBack(RoomState room) =>
      room.finalQuestionsPlayed == 0 &&
      room.players.any((p) => p.status == PlayerStatus.finalist);
}

/// Celebrate or drop, once, when this player's fate first shows.
class _FateHaptic extends StatefulWidget {
  final bool known;
  final CutOutcome outcome;
  final Widget child;

  const _FateHaptic({
    required this.known,
    required this.outcome,
    required this.child,
  });

  @override
  State<_FateHaptic> createState() => _FateHapticState();
}

class _FateHapticState extends State<_FateHaptic> {
  bool _played = false;

  void _maybePlay() {
    if (_played || !widget.known) return;
    _played = true;
    final token = switch (widget.outcome) {
      CutOutcome.survived || CutOutcome.finalist => HapticToken.celebrate,
      CutOutcome.out => HapticToken.heavy,
      CutOutcome.alreadyOut => null,
    };
    if (token != null) context.read<Haptics>().play(token);
  }

  @override
  void initState() {
    super.initState();
    _maybePlay();
  }

  @override
  void didUpdateWidget(_FateHaptic old) {
    super.didUpdateWidget(old);
    _maybePlay();
  }

  @override
  Widget build(BuildContext context) => widget.child;
}

/// "Are you safe?", with a buzz each time a name drops on the big screen.
class _Suspense extends StatefulWidget {
  final RevealSequenceState sequence;

  const _Suspense({required this.sequence});

  @override
  State<_Suspense> createState() => _SuspenseState();
}

class _SuspenseState extends State<_Suspense> {
  @override
  void didUpdateWidget(_Suspense old) {
    super.didUpdateWidget(old);
    if (widget.sequence.revealed > old.sequence.revealed) {
      context.read<Haptics>().play(HapticToken.medium);
    }
  }

  @override
  Widget build(BuildContext context) {
    final sequence = widget.sequence;
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Crest(width: 72),
            const SizedBox(height: 24),
            Text(
              'ARE YOU SAFE?',
              textAlign: TextAlign.center,
              style: AppTextStyles.displayL.copyWith(color: AppColors.gold),
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const PulsingDots(),
                const SizedBox(width: 10),
                Flexible(
                  child: Text(
                    switch (sequence) {
                      RevealSequenceState(phase: RevealPhase.intro) =>
                        'Look at the big screen…',
                      RevealSequenceState(waitingForLast: true) =>
                        'One name left…',
                      _ => '${sequence.revealed} of ${sequence.total} revealed',
                    },
                    style: AppTextStyles.body.copyWith(color: AppColors.muted),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _Survived extends StatelessWidget {
  final RoomState room;
  final bool finalist;

  const _Survived({required this.room, required this.finalist});

  @override
  Widget build(BuildContext context) {
    final event = room.lastElimination;
    final total =
        (event?.survivorsCount ?? 0) + (event?.eliminatedPlayerIds.length ?? 0);
    final detail = finalist
        ? 'Through to the buzzer final · ${event?.survivorsCount ?? 0} finalists'
        : 'Through to Round ${room.round + 1} · '
              '${event?.survivorsCount ?? 0} of $total go on';
    return Stack(
      alignment: Alignment.center,
      children: [
        const Align(alignment: Alignment(0, -0.16), child: ShapeBurst()),
        Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TweenAnimationBuilder<double>(
                tween: Tween(begin: 0.6, end: 1),
                duration: const Duration(milliseconds: 500),
                curve: AppCurves.stamp,
                builder: (context, s, child) =>
                    Transform.scale(scale: s, child: child),
                child: Crest(
                  width: 96,
                  fill: AppColors.board,
                  child: Text(
                    finalist ? '★' : '✓',
                    style: AppTextStyles.displayL.copyWith(
                      fontSize: 44,
                      color: AppColors.gold,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 14),
              Text(
                finalist ? "YOU'RE IN\nTHE FINAL" : 'YOU\nSURVIVED',
                textAlign: TextAlign.center,
                style: AppTextStyles.displayL.copyWith(
                  fontSize: 52,
                  height: 0.95,
                ),
              ),
              const SizedBox(height: 14),
              Text(
                detail,
                textAlign: TextAlign.center,
                style: AppTextStyles.body.copyWith(
                  fontSize: 17,
                  color: const Color(0xFFE3F2E8),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _Eliminated extends StatelessWidget {
  final RoomState room;
  final PlayerView me;

  const _Eliminated({required this.room, required this.me});

  @override
  Widget build(BuildContext context) {
    final place = placementOf(room, me.id);
    final event = room.lastElimination;
    final bubble =
        event != null &&
        event.tieBrokenBySpeed &&
        event.eliminatedPlayerIds.isNotEmpty &&
        event.eliminatedPlayerIds.last == me.id;
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 24, 20, 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Expanded(
            child: TweenAnimationBuilder<double>(
              tween: Tween(begin: 0, end: 1),
              duration: AppDurations.dramatic,
              curve: AppCurves.accelerate,
              builder: (context, t, child) => Opacity(
                opacity: t,
                child: Transform.translate(
                  offset: Offset(0, -60 * (1 - t)),
                  child: child,
                ),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const OutStamp(),
                  const SizedBox(height: 16),
                  Text(
                    'ELIMINATED',
                    style: AppTextStyles.displayL.copyWith(fontSize: 44),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Out in Round ${me.eliminatedInRound ?? room.round}'
                    '${place == null ? '' : ' · finished ${ordinal(place)}'}'
                    '${bubble ? '\nLost a tie at the line on answer speed' : ''}',
                    textAlign: TextAlign.center,
                    style: AppTextStyles.body.copyWith(
                      fontSize: 17,
                      color: AppColors.maroonPale,
                    ),
                  ),
                ],
              ),
            ),
          ),
          SizedBox(
            height: 56,
            child: OutlinedButton(
              key: const Key('cut.keepWatching'),
              onPressed: context.read<RoomCubit>().keepWatchingAsSpectator,
              style: OutlinedButton.styleFrom(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
              child: Text(
                'Keep watching as spectator',
                style: AppTextStyles.button.copyWith(fontSize: 17),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _Spectating extends StatelessWidget {
  final RoomState room;
  final PlayerView? me;

  const _Spectating({required this.room, required this.me});

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.fromLTRB(16, 8, 16, 20),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        QnBanner(
          kind: BannerKind.eliminated,
          text:
              'Spectating · eliminated in Round '
              '${me?.eliminatedInRound ?? room.round}',
        ),
        Expanded(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const PulsingDots(size: 10),
              const SizedBox(height: 16),
              Text(
                'Watch the big screen',
                style: AppTextStyles.title,
              ),
              const SizedBox(height: 6),
              Text(
                'Your answers next round count for a shadow score.',
                textAlign: TextAlign.center,
                style: AppTextStyles.bodySoft.copyWith(fontSize: 15),
              ),
            ],
          ),
        ),
      ],
    ),
  );
}

/// Spectators pick the finalist they think will win.
class BackFinalist extends StatelessWidget {
  final RoomState room;
  final PlayerView? me;
  final int? backedId;

  const BackFinalist({
    super.key,
    required this.room,
    required this.me,
    required this.backedId,
  });

  @override
  Widget build(BuildContext context) {
    final cubit = context.read<RoomCubit>();
    final haptics = context.read<Haptics>();
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          QnBanner(
            kind: BannerKind.eliminated,
            text:
                'You were eliminated in Round '
                '${me?.eliminatedInRound ?? room.round}',
          ),
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'BACK A FINALIST',
                  style: AppTextStyles.displayL.copyWith(fontSize: 32),
                ),
                const SizedBox(height: 4),
                Text(
                  'Pick before the final starts. Bragging rights only.',
                  style: AppTextStyles.bodySoft.copyWith(fontSize: 15),
                ),
              ],
            ),
          ),
          for (final f in finalistsByJoin(room)) ...[
            _BackOption(
              finalist: f,
              backed: f.id == backedId,
              onTap: () {
                haptics.play(HapticToken.light);
                cubit.backFinalist(f.id);
              },
            ),
            const SizedBox(height: 10),
          ],
        ],
      ),
    );
  }
}

class _BackOption extends StatelessWidget {
  final PlayerView finalist;
  final bool backed;
  final VoidCallback onTap;

  const _BackOption({
    required this.finalist,
    required this.backed,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) => Material(
    color: backed ? AppColors.goldDeep : AppColors.surface,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(14),
      side: BorderSide(
        color: backed ? AppColors.gold : AppColors.line,
        width: 3,
      ),
    ),
    child: InkWell(
      key: Key('back.${finalist.id}'),
      onTap: onTap,
      borderRadius: BorderRadius.circular(14),
      child: ConstrainedBox(
        constraints: const BoxConstraints(minHeight: 68),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 14),
          child: Row(
            children: [
              InitialBadge(nickname: finalist.nickname, size: 44),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      finalist.nickname,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: AppTextStyles.chip.copyWith(
                        fontSize: 18,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    Text(
                      '${formatScore(finalist.score)} pts',
                      style: AppTextStyles.caption.copyWith(fontSize: 13),
                    ),
                  ],
                ),
              ),
              if (backed)
                Text(
                  '★ Backing',
                  style: AppTextStyles.label.copyWith(
                    fontSize: 13,
                    fontWeight: FontWeight.w800,
                    color: AppColors.gold,
                  ),
                ),
            ],
          ),
        ),
      ),
    ),
  );
}
