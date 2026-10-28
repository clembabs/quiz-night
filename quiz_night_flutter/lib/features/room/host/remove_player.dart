import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:quiz_night_client/quiz_night_client.dart';

import '../../../core/theme/app_colors.dart';
import '../room_cubit.dart';

/// Asks before removing [player] (a joke nickname, a stranger, a bot), at
/// any point in the game.
Future<void> confirmRemovePlayer(
  BuildContext context,
  PlayerView player,
) async {
  final cubit = context.read<RoomCubit>();
  final inGame = cubit.state.room?.status != RoomStatus.lobby;
  final ok = await showDialog<bool>(
    context: context,
    builder: (context) => AlertDialog(
      title: Text('Remove ${player.nickname}?'.toUpperCase()),
      content: Text(
        inGame
            ? 'They leave the game now, with their points. Their phone shows '
                  'that they were removed. Lock the room to stop them joining '
                  'again.'
            : 'Their phone will show that they were removed. They can join '
                  'again with the room code.',
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context, false),
          child: const Text('Keep'),
        ),
        FilledButton(
          key: const Key('remove.confirm'),
          onPressed: () => Navigator.pop(context, true),
          style: FilledButton.styleFrom(
            backgroundColor: AppColors.maroon,
            foregroundColor: AppColors.white,
          ),
          child: const Text('Remove'),
        ),
      ],
    ),
  );
  if (ok == true) await cubit.removePlayer(player.id);
}
