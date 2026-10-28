import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:quiz_night_client/quiz_night_client.dart';

import '../../../core/platform/haptics.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_motion.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../widgets/qn/danger_indicator.dart';
import '../../../widgets/qn/notices.dart';
import '../../../widgets/qn/standings_row.dart';
import '../round_logic.dart';
import '../standings_logic.dart';

/// After a reveal: Correct / Wrong, score, rank and the danger line.
class PhoneResult extends StatefulWidget {
  final RoomState room;
  final PlayerView? me;
  final int? myChoice;

  /// Places this player moved at this reveal.
  final int? move;

  const PhoneResult({
    super.key,
    required this.room,
    required this.me,
    required this.myChoice,
    this.move,
  });

  @override
  State<PhoneResult> createState() => _PhoneResultState();
}

/// Stateful only to play the verdict haptic once.
class _PhoneResultState extends State<PhoneResult> {
  @override
  void initState() {
    super.initState();
    final verdict = verdictFor(me: widget.me, myChoice: widget.myChoice);
    context.read<Haptics>().play(
      verdict == PlayerVerdict.correct
          ? HapticToken.success
          : HapticToken.error,
    );
  }

  @override
  Widget build(BuildContext context) {
    final room = widget.room;
    final me = widget.me;
    final q = room.question!;
    final verdict = verdictFor(me: me, myChoice: widget.myChoice);
    final spectator = me?.status == PlayerStatus.eliminated;
    final points = me?.lastPoints ?? 0;
    final correct = q.correctIndex;
    final answer = correct == null || correct >= q.options.length
        ? ''
        : q.options[correct];
    final rank = me == null ? null : rankOf(room, me.id);
    final danger = me == null ? null : dangerStatusFor(room, me);

    final (bg, fg, icon, title, pts) = switch (verdict) {
      PlayerVerdict.correct => (
        AppColors.correct,
        AppColors.white,
        '✓',
        'Correct',
        spectator ? '+$points shadow' : '+$points',
      ),
      PlayerVerdict.wrong => (
        AppColors.maroonDeep,
        const Color(0xFFFFD9DC),
        '✕',
        'Wrong',
        '+0 · answer was $answer',
      ),
      PlayerVerdict.noAnswer => (
        AppColors.surfaceHigh,
        AppColors.chalk,
        '0',
        'No answer',
        '+0 · answer was $answer',
      ),
    };

    final score = spectator ? me?.shadowScore ?? 0 : me?.score ?? 0;
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (spectator) ...[
            QnBanner(
              kind: BannerKind.eliminated,
              text:
                  '${_capital(outIn(room, me))} · answers count for a shadow '
                  'score',
            ),
            const SizedBox(height: 12),
          ],
          _Shake(
            enabled: verdict != PlayerVerdict.correct,
            child: Container(
              constraints: const BoxConstraints(minHeight: 220),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: bg,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    icon,
                    style: AppTextStyles.displayXl.copyWith(
                      fontSize: 56,
                      color: fg,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    title.toUpperCase(),
                    style: AppTextStyles.displayL.copyWith(color: fg),
                  ),
                  const SizedBox(height: 8),
                  _FloatIn(
                    child: Text(
                      pts,
                      textAlign: TextAlign.center,
                      style: AppTextStyles.numeric.copyWith(
                        fontSize: verdict == PlayerVerdict.correct ? 30 : 20,
                        color: fg,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _StatTile(
                  label: spectator ? 'SHADOW SCORE' : 'SCORE',
                  child: _CountUp(
                    from: verdict == PlayerVerdict.correct
                        ? score - points
                        : score,
                    to: score,
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _StatTile(
                  label: 'RANK',
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.baseline,
                    textBaseline: TextBaseline.alphabetic,
                    children: [
                      Text(
                        spectator || rank == null ? '—' : ordinal(rank),
                        style: AppTextStyles.numeric.copyWith(fontSize: 30),
                      ),
                      if (!spectator && rank != null) ...[
                        const SizedBox(width: 6),
                        Text(
                          moveLabel(widget.move),
                          style: AppTextStyles.label.copyWith(
                            fontWeight: FontWeight.w800,
                            color: moveColor(widget.move),
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ),
            ],
          ),
          if (danger != null) ...[
            const SizedBox(height: 12),
            DangerIndicator(status: danger),
          ],
          // No shared leaderboard on a call: the top of it comes here.
          if (room.remote) ...[
            const SizedBox(height: 12),
            TopThree(room: room, meId: me?.id),
          ],
        ],
      ),
    );
  }
}

/// The top three right now, for remote games with no big screen.
class TopThree extends StatelessWidget {
  final RoomState room;
  final int? meId;

  const TopThree({super.key, required this.room, this.meId});

  @override
  Widget build(BuildContext context) {
    final top = leaderboard(room).take(3).toList();
    if (top.isEmpty) return const SizedBox.shrink();
    return Container(
      key: const Key('result.topThree'),
      padding: const EdgeInsets.fromLTRB(14, 12, 14, 6),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            'TOP 3',
            style: AppTextStyles.label.copyWith(
              color: AppColors.muted,
              fontSize: 12,
            ),
          ),
          const SizedBox(height: 6),
          for (final (i, p) in top.indexed)
            Padding(
              padding: const EdgeInsets.only(bottom: 6),
              child: Row(
                children: [
                  SizedBox(
                    width: 28,
                    child: Text(
                      '${i + 1}',
                      style: AppTextStyles.numeric.copyWith(fontSize: 18),
                    ),
                  ),
                  Expanded(
                    child: Text(
                      p.id == meId ? '${p.nickname} (you)' : p.nickname,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: AppTextStyles.chip.copyWith(
                        fontSize: 15,
                        color: p.id == meId ? AppColors.gold : null,
                      ),
                    ),
                  ),
                  Text(
                    formatScore(p.score),
                    style: AppTextStyles.numeric.copyWith(fontSize: 16),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}

class _StatTile extends StatelessWidget {
  final String label;
  final Widget child;

  const _StatTile({required this.label, required this.child});

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.all(14),
    decoration: BoxDecoration(
      color: AppColors.surface,
      borderRadius: BorderRadius.circular(14),
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: AppTextStyles.label.copyWith(
            fontSize: 12,
            fontWeight: FontWeight.w800,
            color: AppColors.muted,
          ),
        ),
        const SizedBox(height: 2),
        // Big numbers shrink rather than overflow on narrow phones.
        FittedBox(
          fit: BoxFit.scaleDown,
          alignment: Alignment.centerLeft,
          child: child,
        ),
      ],
    ),
  );
}

/// Counts the score up after the points float in.
class _CountUp extends StatelessWidget {
  final int from;
  final int to;

  const _CountUp({required this.from, required this.to});

  @override
  Widget build(BuildContext context) {
    final style = AppTextStyles.numeric.copyWith(fontSize: 30);
    if (MediaQuery.disableAnimationsOf(context) || from == to) {
      return Text(formatScore(to), style: style);
    }
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0, end: 1),
      duration: const Duration(milliseconds: 1400),
      curve: const Interval(0.43, 1, curve: AppCurves.standard),
      builder: (context, t, _) =>
          Text(formatScore((from + (to - from) * t).round()), style: style),
    );
  }
}

class _FloatIn extends StatelessWidget {
  final Widget child;

  const _FloatIn({required this.child});

  @override
  Widget build(BuildContext context) {
    if (MediaQuery.disableAnimationsOf(context)) return child;
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0, end: 1),
      duration: AppDurations.dramatic,
      curve: const Interval(0.33, 1, curve: AppCurves.decelerate),
      builder: (context, t, child) => Opacity(
        opacity: t,
        child: Transform.translate(
          offset: Offset(0, 24 * (1 - t)),
          child: child,
        ),
      ),
      child: child,
    );
  }
}

/// A quick left-right shake for wrong answers.
class _Shake extends StatelessWidget {
  final bool enabled;
  final Widget child;

  const _Shake({required this.enabled, required this.child});

  @override
  Widget build(BuildContext context) {
    if (!enabled || MediaQuery.disableAnimationsOf(context)) return child;
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0, end: 1),
      duration: AppDurations.slow,
      builder: (context, t, child) => Transform.translate(
        offset: Offset(t >= 1 ? 0 : ((t * 20).round().isOdd ? -5 : 5), 0),
        child: child,
      ),
      child: child,
    );
  }
}

String _capital(String s) =>
    s.isEmpty ? s : s[0].toUpperCase() + s.substring(1);
