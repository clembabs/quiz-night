import 'package:flutter/material.dart';
import 'package:quiz_night_client/quiz_night_client.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/theme/app_text_styles.dart';
import '../../widgets/common.dart';
import '../../widgets/player_chips.dart';

/// Phone view while waiting for the host to start.
class PlayerLobbyView extends StatelessWidget {
  final RoomState room;
  final PlayerView? me;

  const PlayerLobbyView({super.key, required this.room, required this.me});

  @override
  Widget build(BuildContext context) {
    final me = this.me;
    return CenteredContent(
      child: ListView(
        padding: AppSpacing.screenPadding,
        children: [
          const SizedBox(height: AppSpacing.xl),
          const Icon(
            Icons.check_circle_rounded,
            size: AppIconSizes.hero,
            color: AppColors.success,
          ),
          const SizedBox(height: AppSpacing.md),
          Text(
            "You're in${me == null ? '' : ', ${me.nickname}'}!",
            textAlign: TextAlign.center,
            style: AppTextStyles.heading,
          ),
          const SizedBox(height: AppSpacing.sm),
          const Text(
            'Waiting for the host to start…',
            textAlign: TextAlign.center,
            style: AppTextStyles.bodyMuted,
          ),
          const SizedBox(height: AppSpacing.xxl),
          Text(
            '${room.players.length} in the room',
            style: AppTextStyles.label,
          ),
          const SizedBox(height: AppSpacing.md),
          PlayerChips(players: room.players, highlightId: me?.id),
        ],
      ),
    );
  }
}
