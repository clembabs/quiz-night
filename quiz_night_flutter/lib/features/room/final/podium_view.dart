import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:quiz_night_client/quiz_night_client.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../widgets/common.dart';
import '../room_cubit.dart';
import 'final_logic.dart';

/// The end of the game: podium, who backed the winner, shadow champion.
/// [me] is null on the host's screen.
class PodiumView extends StatelessWidget {
  final RoomState room;
  final PlayerView? me;

  const PodiumView({super.key, required this.room, this.me});

  /// A personal line for a player's phone, or null.
  static String? personalLine(RoomState room, PlayerView? me) {
    if (me == null) return null;
    final place = finalPlaceOf(room, me.id);
    if (place == 1) return 'You won Quiz Night!';
    if (place != null) return 'You finished #$place';
    final winner = winnerOf(room);
    final backed = me.backedPlayerId;
    if (backed == null) return null;
    if (backed == winner?.id) return 'You called it!';
    return 'You backed ${nicknameOf(room, backed) ?? 'someone else'}';
  }

  @override
  Widget build(BuildContext context) {
    final standings = finalStandings(room);
    final winner = standings.firstOrNull;
    final backers = winner == null
        ? <PlayerView>[]
        : backersOf(room, winner.id);
    final shadow = shadowChampion(room);
    final personal = personalLine(room, me);

    return CenteredContent(
      maxWidth: AppSpacing.formMaxWidth,
      child: ListView(
        padding: AppSpacing.screenPadding,
        children: [
          const Icon(
            Icons.emoji_events_rounded,
            size: AppIconSizes.hero,
            color: AppColors.gold,
          ),
          Text(
            winner == null ? 'Game over' : '${winner.nickname} wins!',
            textAlign: TextAlign.center,
            style: AppTextStyles.revealIntro,
          ),
          if (personal != null) ...[
            const SizedBox(height: AppSpacing.sm),
            Text(
              personal,
              key: const Key('podium.personal'),
              textAlign: TextAlign.center,
              style: AppTextStyles.heading,
            ),
          ],
          const SizedBox(height: AppSpacing.xxl),
          _Podium(standings: standings),
          for (var i = 3; i < standings.length; i++)
            Padding(
              padding: const EdgeInsets.only(top: AppSpacing.sm),
              child: Text(
                '${i + 1}. ${standings[i].nickname} · ${standings[i].finalScore}',
                textAlign: TextAlign.center,
                style: AppTextStyles.body,
              ),
            ),
          const SizedBox(height: AppSpacing.xxl),
          if (winner != null)
            _Fact(
              icon: Icons.favorite_rounded,
              text: backers.isEmpty
                  ? 'Nobody backed ${winner.nickname}'
                  : 'Backed the winner: '
                        '${backers.map((p) => p.nickname).join(', ')}',
            ),
          if (shadow != null)
            _Fact(
              icon: Icons.visibility_rounded,
              text:
                  'Shadow champion: ${shadow.nickname} '
                  '(${shadow.shadowScore})',
            ),
          const SizedBox(height: AppSpacing.xl),
          OutlinedButton(
            onPressed: context.read<RoomCubit>().leave,
            child: const Text('Done'),
          ),
        ],
      ),
    );
  }
}

class _Fact extends StatelessWidget {
  final IconData icon;
  final String text;

  const _Fact({required this.icon, required this.text});

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.only(bottom: AppSpacing.md),
    child: Row(
      children: [
        Icon(icon, color: AppColors.gold),
        const SizedBox(width: AppSpacing.md),
        Expanded(child: Text(text, style: AppTextStyles.label)),
      ],
    ),
  );
}

/// Classic 2-1-3 podium blocks.
class _Podium extends StatelessWidget {
  final List<PlayerView> standings;

  const _Podium({required this.standings});

  static const _colors = [AppColors.gold, AppColors.silver, AppColors.bronze];

  @override
  Widget build(BuildContext context) {
    // Display order left to right: 2nd, 1st, 3rd.
    final order = [1, 0, 2].where((i) => i < standings.length);
    return Row(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        for (final place in order)
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xs),
              child: Column(
                children: [
                  Text(
                    standings[place].nickname,
                    textAlign: TextAlign.center,
                    overflow: TextOverflow.ellipsis,
                    style: AppTextStyles.podiumName,
                  ),
                  Text(
                    '${standings[place].finalScore}',
                    style: AppTextStyles.finalScore,
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  Container(
                    height: AppSpacing.podiumHeights[place],
                    alignment: Alignment.topCenter,
                    padding: const EdgeInsets.only(top: AppSpacing.md),
                    decoration: BoxDecoration(
                      color: _colors[place],
                      borderRadius: const BorderRadius.vertical(
                        top: Radius.circular(AppRadii.sm),
                      ),
                    ),
                    child: Text(
                      '${place + 1}',
                      style: AppTextStyles.podiumPlace,
                    ),
                  ),
                ],
              ),
            ),
          ),
      ],
    );
  }
}
