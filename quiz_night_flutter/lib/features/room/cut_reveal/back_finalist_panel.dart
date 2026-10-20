import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:quiz_night_client/quiz_night_client.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_text_styles.dart';
import '../room_cubit.dart';

/// Lets a spectator back the finalist they think will win.
class BackFinalistPanel extends StatelessWidget {
  final RoomState room;
  final int? backedId;

  const BackFinalistPanel({
    super.key,
    required this.room,
    required this.backedId,
  });

  /// Spectators can back someone once finalists exist and the final has not
  /// started.
  static bool isOpen(RoomState room, PlayerView? me) =>
      me?.status == PlayerStatus.eliminated &&
      room.finalQuestionsPlayed == 0 &&
      room.players.any((p) => p.status == PlayerStatus.finalist);

  @override
  Widget build(BuildContext context) {
    final finalists = room.players
        .where((p) => p.status == PlayerStatus.finalist)
        .toList();
    final backed = finalists.where((p) => p.id == backedId).firstOrNull;
    final cubit = context.read<RoomCubit>();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          backed == null
              ? 'Who will win? Back a finalist'
              : "You're backing ${backed.nickname}",
          textAlign: TextAlign.center,
          style: AppTextStyles.label,
        ),
        const SizedBox(height: AppSpacing.xs),
        const Text(
          'Revealed on the podium.',
          textAlign: TextAlign.center,
          style: AppTextStyles.caption,
        ),
        const SizedBox(height: AppSpacing.md),
        for (final f in finalists)
          Padding(
            padding: const EdgeInsets.only(bottom: AppSpacing.sm),
            child: f.id == backedId
                ? FilledButton.icon(
                    key: Key('back.${f.id}'),
                    onPressed: () {},
                    icon: const Icon(Icons.favorite_rounded),
                    label: Text(f.nickname),
                  )
                : OutlinedButton(
                    key: Key('back.${f.id}'),
                    onPressed: () => cubit.backFinalist(f.id),
                    style: OutlinedButton.styleFrom(
                      side: const BorderSide(color: AppColors.gold),
                    ),
                    child: Text(f.nickname),
                  ),
          ),
      ],
    );
  }
}
