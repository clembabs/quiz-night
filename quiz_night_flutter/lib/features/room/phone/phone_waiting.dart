import 'package:flutter/material.dart';
import 'package:quiz_night_client/quiz_night_client.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_motion.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../widgets/brand/initial_badge.dart';
import '../../../widgets/qn/loaders.dart';
import '../../../widgets/qn/player_chip.dart';
import '../round_logic.dart';
import '../../../widgets/layout/app_scroll.dart';

/// What happens in this game, before it starts.
class _HowItWorks extends StatelessWidget {
  final RoomState room;

  const _HowItWorks({required this.room});

  @override
  Widget build(BuildContext context) => Container(
    key: const Key('waiting.howItWorks'),
    padding: const EdgeInsets.all(16),
    decoration: BoxDecoration(
      color: AppColors.green,
      borderRadius: BorderRadius.circular(16),
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'HOW IT WORKS',
          style: AppTextStyles.label.copyWith(
            color: AppColors.gold,
            fontSize: 12,
          ),
        ),
        const SizedBox(height: 6),
        Text(
          howItWorks(room),
          style: AppTextStyles.body.copyWith(fontSize: 15, height: 1.4),
        ),
      ],
    ),
  );
}

/// "You're in!": how it works, your chip, the count and everyone's badges.
class PhoneWaiting extends StatelessWidget {
  final RoomState room;
  final PlayerView? me;

  const PhoneWaiting({super.key, required this.room, required this.me});

  @override
  Widget build(BuildContext context) {
    final me = this.me;
    final byJoin = [...room.players]..sort((a, b) => a.id.compareTo(b.id));
    // Scrolls on short phones: how it works and a full room add up.
    return AppScroll(
      padding: const EdgeInsets.fromLTRB(20, 24, 20, 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TweenAnimationBuilder<double>(
                tween: Tween(begin: 0, end: 1),
                duration: AppDurations.slow,
                curve: AppCurves.stamp,
                builder: (context, t, child) => Opacity(
                  opacity: t.clamp(0.0, 1.0),
                  child: Transform.translate(
                    offset: Offset(0, 20 * (1 - t)),
                    child: child,
                  ),
                ),
                child: Text(
                  "YOU'RE IN!",
                  style: AppTextStyles.displayL.copyWith(fontSize: 48),
                ),
              ),
              const SizedBox(height: 14),
              if (me != null)
                PlayerChip(nickname: me.nickname, isYou: true, height: 52),
            ],
          ),
          const SizedBox(height: 24),
          _HowItWorks(room: room),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.baseline,
                  textBaseline: TextBaseline.alphabetic,
                  children: [
                    Text(
                      '${room.players.length}',
                      style: AppTextStyles.numeric.copyWith(fontSize: 36),
                    ),
                    const SizedBox(width: 8),
                    Flexible(
                      child: Text(
                        'players joined',
                        style: AppTextStyles.bodySoft.copyWith(fontSize: 16),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Wrap(
                  spacing: 6,
                  runSpacing: 6,
                  children: [
                    for (final p in byJoin.take(40))
                      InitialBadge(nickname: p.nickname),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    const PulsingDots(),
                    const SizedBox(width: 10),
                    Flexible(
                      child: Text(
                        'Waiting for the host to start',
                        style: AppTextStyles.body.copyWith(
                          fontSize: 15,
                          color: AppColors.muted,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
