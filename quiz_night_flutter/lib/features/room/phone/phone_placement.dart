import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:quiz_night_client/quiz_night_client.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_motion.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../widgets/qn/notices.dart';
import '../../../widgets/qn/standings_row.dart';
import '../final/final_logic.dart';
import '../room_cubit.dart';
import '../standings_logic.dart';

/// The phone at the end: final placement, title and a line about the winner
/// and who you backed.
class PhonePlacement extends StatelessWidget {
  final RoomState room;
  final PlayerView? me;

  const PhonePlacement({super.key, required this.room, required this.me});

  /// "CHAMPION", "FINALIST" or "ELIMINATED · ROUND 2".
  static String titleFor(RoomState room, PlayerView me) {
    // Still in when the game stopped early.
    if (me.status == PlayerStatus.active && endedEarly(room)) {
      return room.endReason == RoomEndReason.timeUp
          ? "Time's up"
          : 'Room closed';
    }
    if (me.status == PlayerStatus.finalist) {
      return finalPlaceOf(room, me.id) == 1 ? 'Champion' : 'Finalist';
    }
    return 'Eliminated · Round ${me.eliminatedInRound ?? room.round}';
  }

  /// The sentence under the title.
  static String detailFor(RoomState room, PlayerView me) {
    if (me.status == PlayerStatus.active && endedEarly(room)) {
      final place = placementOf(room, me.id) ?? room.players.length;
      return 'You finished ${ordinal(place)} with ${formatScore(me.score)} '
          'points.';
    }
    final winner = winnerOf(room);
    final winLine = winner == null
        ? ''
        : endedEarly(room) && winner.status != PlayerStatus.finalist
        ? '${winner.nickname} was ahead with '
              '${formatScore(winner.score)} points when the game stopped.'
        : '${winner.nickname} wins Quiz Night with '
              '${formatScore(winner.finalScore)} final points.';
    if (me.status == PlayerStatus.finalist) {
      return me.id == winner?.id
          ? 'You win Quiz Night with ${formatScore(me.finalScore)} final points.'
          : winLine;
    }
    final shadow = 'Shadow score ${formatScore(me.shadowScore)}.';
    final backed = me.backedPlayerId;
    if (backed == null) return '$shadow Back a finalist next time.';
    if (backed == winner?.id) {
      return 'You backed the winner, ${winner!.nickname}. $shadow';
    }
    return 'You backed ${nicknameOf(room, backed)}. '
        '${winner?.nickname ?? 'Someone else'} won. $shadow';
  }

  @override
  Widget build(BuildContext context) {
    final me = this.me;
    if (me == null) return const SizedBox.shrink();
    final place = placementOf(room, me.id) ?? room.players.length;
    final champion =
        me.status == PlayerStatus.finalist && finalPlaceOf(room, me.id) == 1;
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 24, 24, 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Scales down rather than overflowing on a small phone (the
          // "time's up" notice adds a few lines).
          Expanded(
            child: LayoutBuilder(
              builder: (context, c) => Center(
                child: FittedBox(
                  fit: BoxFit.scaleDown,
                  child: SizedBox(
                    width: c.maxWidth,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        if (endNoticeFor(room) case final notice?) ...[
                          QnBanner(kind: BannerKind.info, text: notice),
                          const SizedBox(height: 20),
                        ],
                        Text(
                          endedEarly(room)
                              ? 'RESULTS SO FAR'
                              : 'FINAL PLACEMENT',
                          style: AppTextStyles.eyebrow.copyWith(
                            color: AppColors.muted,
                            letterSpacing: 1.6,
                          ),
                        ),
                        const SizedBox(height: 12),
                        TweenAnimationBuilder<double>(
                          tween: Tween(begin: 0.6, end: 1),
                          duration: const Duration(milliseconds: 600),
                          curve: AppCurves.stamp,
                          builder: (context, s, child) =>
                              Transform.scale(scale: s, child: child),
                          child: Text(
                            ordinal(place),
                            key: const Key('placement.place'),
                            style: AppTextStyles.displayXl.copyWith(
                              fontSize: 120,
                              height: 0.9,
                              color: champion
                                  ? AppColors.gold
                                  : AppColors.chalk,
                            ),
                          ),
                        ),
                        const SizedBox(height: 12),
                        Text(
                          titleFor(room, me).toUpperCase(),
                          textAlign: TextAlign.center,
                          style: AppTextStyles.headline.copyWith(fontSize: 30),
                        ),
                        const SizedBox(height: 12),
                        ConstrainedBox(
                          constraints: const BoxConstraints(maxWidth: 300),
                          child: Text(
                            detailFor(room, me),
                            key: const Key('placement.detail'),
                            textAlign: TextAlign.center,
                            style: AppTextStyles.bodySoft,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
          SizedBox(
            height: 48,
            child: OutlinedButton(
              onPressed: context.read<RoomCubit>().leave,
              child: const Text('Done'),
            ),
          ),
        ],
      ),
    );
  }
}
