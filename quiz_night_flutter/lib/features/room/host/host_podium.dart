import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:quiz_night_client/quiz_night_client.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../widgets/qn/celebrations.dart';
import '../../../widgets/qn/host_stage.dart';
import '../../../widgets/qn/player_chip.dart';
import '../../../widgets/qn/standings_row.dart';
import '../final/final_logic.dart';
import '../room_cubit.dart';

/// The projector podium: blocks rise 3rd → 2nd → 1st, then who backed the
/// winner.
class HostPodium extends StatelessWidget {
  final RoomState room;

  const HostPodium({super.key, required this.room});

  /// Display order left to right (2nd, 1st, 3rd), heights and rise delays.
  static const _slots = [
    (place: 2, height: 230.0, delay: Duration(milliseconds: 900)),
    (place: 1, height: 320.0, delay: Duration(milliseconds: 1700)),
    (place: 3, height: 170.0, delay: Duration(milliseconds: 200)),
  ];

  @override
  Widget build(BuildContext context) {
    final standings = finalStandings(room);
    final winner = standings.firstOrNull;
    final backers = winner == null
        ? <PlayerView>[]
        : backersOf(room, winner.id);
    final spectators = room.players
        .where((p) => p.status == PlayerStatus.eliminated)
        .length;
    final shadow = shadowChampion(room);
    return Row(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Expanded(
          flex: 15,
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              for (final s in _slots)
                if (s.place <= standings.length) ...[
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      child: PodiumBlock(
                        place: s.place,
                        nickname: standings[s.place - 1].nickname,
                        score: formatScore(standings[s.place - 1].finalScore),
                        height: s.height,
                        delay: s.delay,
                      ),
                    ),
                  ),
                ],
            ],
          ),
        ),
        const SizedBox(width: 64),
        Expanded(
          flex: 10,
          child: _FadeInLate(
            child: Container(
              padding: const EdgeInsets.all(48),
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(28),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'WHO BACKED THE WINNER',
                    style: AppProjectorText.label.copyWith(letterSpacing: 2.8),
                  ),
                  const SizedBox(height: 28),
                  Text(
                    spectators == 0
                        ? 'Everyone made the final'
                        : '${backers.length} of $spectators',
                    key: const Key('podium.backers'),
                    style: AppTextStyles.displayXl.copyWith(
                      fontSize: spectators == 0 ? 56 : 72,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    spectators == 0
                        ? 'Nobody was knocked out, so there was no one left '
                              'to back a finalist.'
                        : winner == null
                        ? 'No winner'
                        : '${spectators == 1 ? 'spectator' : 'spectators'} '
                              'backed ${winner.nickname}',
                    style: AppProjectorText.bodySoft,
                  ),
                  const SizedBox(height: 28),
                  Expanded(
                    child: SingleChildScrollView(
                      child: Wrap(
                        spacing: 12,
                        runSpacing: 12,
                        children: [
                          for (final b in backers)
                            PlayerChip(nickname: b.nickname, height: 64),
                        ],
                      ),
                    ),
                  ),
                  if (shadow != null) ...[
                    Text(
                      'Shadow champion: ${shadow.nickname} '
                      '(${formatScore(shadow.shadowScore)})',
                      style: AppProjectorText.caption.copyWith(fontSize: 28),
                    ),
                    const SizedBox(height: 20),
                  ],
                  Align(
                    alignment: Alignment.centerRight,
                    child: HostTextButton(
                      label: 'End and leave',
                      onPressed: context.read<RoomCubit>().leave,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}

/// The backers panel appears after the podium has risen.
class _FadeInLate extends StatelessWidget {
  final Widget child;

  const _FadeInLate({required this.child});

  @override
  Widget build(BuildContext context) {
    if (MediaQuery.disableAnimationsOf(context)) return child;
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0, end: 1),
      duration: const Duration(milliseconds: 3100),
      builder: (context, t, child) =>
          Opacity(opacity: ((t - 0.84) / 0.16).clamp(0.0, 1.0), child: child),
      child: child,
    );
  }
}
