import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:quiz_night_client/quiz_night_client.dart';

import '../../../core/platform/share_image.dart';
import '../../../core/platform/site_url.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_motion.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../widgets/qn/notices.dart';
import '../../../widgets/qn/standings_row.dart';
import '../final/final_logic.dart';
import '../final/result_summary.dart';
import '../room_cubit.dart';
import '../round_logic.dart';
import '../standings_logic.dart';
import 'result_card.dart';

/// The phone at the end: placement, title, the winner and who you backed.
class PhonePlacement extends StatelessWidget {
  final RoomState room;
  final PlayerView? me;

  /// Overridable for tests.
  final ImageSharer share;

  const PhonePlacement({
    super.key,
    required this.room,
    required this.me,
    this.share = shareImage,
  });

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
    if (joinedLate(me)) return 'Spectator · joined late';
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
      final yours =
          '${formatScore(me.score)} round points, '
          '${formatScore(me.finalScore)} in the final.';
      return me.id == winner?.id
          ? 'You win Quiz Night! $yours'
          : '$winLine You: $yours';
    }
    // Round points always; a shadow score only once one was earned (a 0
    // reads like a bug).
    final points = [
      '${formatScore(me.score)} points',
      if (me.shadowScore > 0) 'shadow score ${formatScore(me.shadowScore)}',
    ].join(', ');
    final backed = me.backedPlayerId;
    if (backed == null) return '$points. Back a finalist next time.';
    if (backed == winner?.id) {
      return 'You backed the winner, ${winner!.nickname}. $points.';
    }
    return 'You backed ${nicknameOf(room, backed)}. '
        '${winner?.nickname ?? 'Someone else'} won. $points.';
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
          // Scales down on small phones (the "time's up" notice adds lines).
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
                        // No podium on a shared screen: the top three here.
                        if (room.remote) ...[
                          const SizedBox(height: 20),
                          _FinalTop(room: room, meId: me.id),
                        ],
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
          SizedBox(
            height: 56,
            child: FilledButton(
              key: const Key('placement.share'),
              onPressed: () => ResultCardSheet.show(
                context,
                result: resultFor(room, me),
                site: siteRoot(),
                share: share,
              ),
              child: const Text('Share my result'),
            ),
          ),
          const SizedBox(height: 10),
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

/// The final's top three with their final points, for remote games.
class _FinalTop extends StatelessWidget {
  final RoomState room;
  final int meId;

  const _FinalTop({required this.room, required this.meId});

  @override
  Widget build(BuildContext context) {
    final top = finalStandings(room).take(3).toList();
    if (top.isEmpty) return const SizedBox.shrink();
    const medals = ['1st', '2nd', '3rd'];
    return Container(
      key: const Key('placement.finalTop'),
      width: 300,
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 6),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          for (final (i, p) in top.indexed)
            Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Row(
                children: [
                  SizedBox(
                    width: 44,
                    child: Text(
                      medals[i],
                      style: AppTextStyles.numeric.copyWith(
                        fontSize: 18,
                        color: i == 0 ? AppColors.gold : null,
                      ),
                    ),
                  ),
                  Expanded(
                    child: Text(
                      p.id == meId ? '${p.nickname} (you)' : p.nickname,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: AppTextStyles.chip.copyWith(fontSize: 16),
                    ),
                  ),
                  Text(
                    formatScore(p.finalScore),
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
