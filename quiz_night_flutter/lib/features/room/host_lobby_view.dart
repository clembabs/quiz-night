import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:quiz_night_client/quiz_night_client.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/theme/app_text_styles.dart';
import '../../widgets/player_chips.dart';
import 'room_cubit.dart';

/// Projector view while players join: code, QR, live player list, Start.
class HostLobbyView extends StatelessWidget {
  final RoomState room;

  const HostLobbyView({super.key, required this.room});

  static const minPlayers = 2;

  /// The link the QR encodes: this app's address with the code pre-filled.
  static Uri joinUrl(Uri appUrl, String code) =>
      appUrl.removeFragment().replace(queryParameters: {'code': code});

  @override
  Widget build(BuildContext context) {
    final url = joinUrl(Uri.base, room.code);
    return LayoutBuilder(
      builder: (context, constraints) {
        final join = _JoinPanel(code: room.code, url: url);
        final players = _PlayersPanel(room: room);
        if (constraints.maxWidth >= AppSpacing.wideBreakpoint) {
          return Padding(
            padding: const EdgeInsets.all(AppSpacing.xxl),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(child: Center(child: join)),
                const SizedBox(width: AppSpacing.xxl),
                Expanded(child: SingleChildScrollView(child: players)),
              ],
            ),
          );
        }
        return ListView(
          padding: AppSpacing.screenPadding,
          children: [
            join,
            const SizedBox(height: AppSpacing.xxl),
            players,
          ],
        );
      },
    );
  }
}

class _JoinPanel extends StatelessWidget {
  final String code;
  final Uri url;

  const _JoinPanel({required this.code, required this.url});

  bool get _isLocal => url.host == 'localhost' || url.host == '127.0.0.1';

  @override
  Widget build(BuildContext context) => Column(
    mainAxisSize: MainAxisSize.min,
    children: [
      const Text(
        'Scan to join, or enter the code',
        style: AppTextStyles.bodyMuted,
      ),
      const SizedBox(height: AppSpacing.lg),
      Container(
        padding: const EdgeInsets.all(AppSpacing.lg),
        decoration: BoxDecoration(
          color: AppColors.qrBackground,
          borderRadius: BorderRadius.circular(AppRadii.lg),
        ),
        child: QrImageView(data: url.toString(), size: 240),
      ),
      const SizedBox(height: AppSpacing.xl),
      SelectableText(code, style: AppTextStyles.roomCode),
      SelectableText(url.toString(), style: AppTextStyles.caption),
      if (_isLocal)
        const Padding(
          padding: EdgeInsets.only(top: AppSpacing.sm),
          child: Text(
            'localhost link: phones can only join once deployed (Milestone 8).',
            textAlign: TextAlign.center,
            style: AppTextStyles.error,
          ),
        ),
    ],
  );
}

class _PlayersPanel extends StatelessWidget {
  final RoomState room;

  const _PlayersPanel({required this.room});

  @override
  Widget build(BuildContext context) {
    final count = room.players.length;
    final canStart = count >= HostLobbyView.minPlayers;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          count == 0
              ? 'Waiting for players…'
              : '$count player${count == 1 ? '' : 's'} in',
          style: AppTextStyles.heading,
        ),
        const SizedBox(height: AppSpacing.lg),
        PlayerChips(players: room.players, large: true),
        const SizedBox(height: AppSpacing.xxl),
        FilledButton.icon(
          onPressed: canStart ? context.read<RoomCubit>().startGame : null,
          icon: const Icon(Icons.play_arrow_rounded),
          label: Text(
            canStart
                ? 'Start the game'
                : 'Need at least ${HostLobbyView.minPlayers} players',
          ),
        ),
      ],
    );
  }
}
