import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:quiz_night_client/quiz_night_client.dart';

import '../../../app/app_paths.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../widgets/qn/host_stage.dart';
import '../../../widgets/qn/loaders.dart';
import '../../../widgets/qn/notices.dart';
import '../../../widgets/qn/player_chip.dart';
import '../room_cubit.dart';
import '../round/host_step_button.dart';
import '../round_logic.dart';

/// The projector lobby: code + QR on the left, players arriving on the right.
class HostLobby extends StatelessWidget {
  final RoomState room;

  /// Address the QR and "go to" line point at; [Uri.base] in the app.
  final Uri appUrl;

  const HostLobby({super.key, required this.room, required this.appUrl});

  static const minPlayers = 2;

  /// Chips shown before collapsing into "+N more".
  static const maxChips = 24;

  /// The link the QR encodes: the join page with the code pre-filled.
  static Uri joinUrl(Uri appUrl, String code) =>
      appUrl.removeFragment().replace(
        path: AppPaths.join,
        queryParameters: {'code': code},
      );

  /// What to tell people to type: host and path, no scheme.
  static String shortAddress(Uri appUrl) {
    final path = appUrl.path == '/' ? '' : appUrl.path;
    final port = appUrl.hasPort && appUrl.port != 80 && appUrl.port != 443
        ? ':${appUrl.port}'
        : '';
    return '${appUrl.host}$port$path';
  }

  /// "ROOM CODE" and the code itself, shrunk to fit when [scaleDown].
  Widget _code({bool scaleDown = false}) {
    final code = Text(
      room.code,
      key: const Key('lobby.code'),
      style: AppProjectorText.displayXl,
    );
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'ROOM CODE',
          style: AppProjectorText.label.copyWith(letterSpacing: 2.8),
        ),
        const SizedBox(height: 12),
        if (scaleDown) FittedBox(fit: BoxFit.scaleDown, child: code) else code,
      ],
    );
  }

  /// The join link on the clipboard, to paste into a call's chat.
  Future<void> _copyLink(BuildContext context) async {
    await Clipboard.setData(
      ClipboardData(text: joinUrl(appUrl, room.code).toString()),
    );
    if (!context.mounted) return;
    showToast(
      context,
      'Join link copied. Paste it in the chat.',
      kind: ToastKind.success,
    );
  }

  /// Asks before removing [player] (a joke nickname, a duplicate phone).
  static Future<void> _confirmRemove(
    BuildContext context,
    PlayerView player,
  ) async {
    final cubit = context.read<RoomCubit>();
    final ok = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Remove ${player.nickname}?'.toUpperCase()),
        content: const Text(
          'Their phone will show that they were removed. They can join again '
          'with the room code.',
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

  @override
  Widget build(BuildContext context) {
    final count = room.players.length;
    final byJoin = [...room.players]..sort((a, b) => a.id.compareTo(b.id));
    final shown = byJoin.take(maxChips).toList();
    final portrait = HostLayout.isPortrait(context);
    final qr = Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.qrBackground,
        borderRadius: BorderRadius.circular(20),
      ),
      child: QrImageView(
        data: joinUrl(appUrl, room.code).toString(),
        padding: EdgeInsets.zero,
      ),
    );
    return HostSplit(
      firstFlex: 720,
      secondFlex: 992,
      portraitFill: HostSplitFill.second,
      first: Container(
        padding: const EdgeInsets.all(48),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(28),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text.rich(
              TextSpan(
                text: room.remote
                    ? 'Share the link, or go to '
                    : 'Scan, or go to ',
                children: [
                  TextSpan(
                    text: shortAddress(appUrl),
                    style: const TextStyle(
                      color: AppColors.chalk,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ],
              ),
              style: AppProjectorText.bodySoft,
            ),
            const SizedBox(height: 28),
            if (portrait)
              // A phone has the width for code and QR side by side.
              Row(
                children: [
                  Expanded(child: _code(scaleDown: true)),
                  const SizedBox(width: 24),
                  SizedBox.square(dimension: 280, child: qr),
                ],
              )
            else
              _code(),
            if (!portrait) ...[
              const SizedBox(height: 28),
              Expanded(child: AspectRatio(aspectRatio: 1, child: qr)),
            ],
          ],
        ),
      ),
      second: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.baseline,
            textBaseline: TextBaseline.alphabetic,
            children: [
              Text(
                '$count',
                style: AppProjectorText.displayXl.copyWith(
                  fontSize: portrait ? 120 : 160,
                  letterSpacing: 0,
                ),
              ),
              const SizedBox(width: 20),
              Flexible(
                child: Text(
                  count == 1 ? 'player in' : 'players in',
                  maxLines: 2,
                  style: AppProjectorText.title.copyWith(
                    fontSize: 48,
                    color: AppColors.chalkSoft,
                  ),
                ),
              ),
            ],
          ),
          // The projector has room to explain; a host's phone does not.
          if (!portrait) ...[
            const SizedBox(height: 8),
            Text(
              howItWorks(room),
              key: const Key('lobby.howItWorks'),
              maxLines: 3,
              overflow: TextOverflow.ellipsis,
              style: AppProjectorText.bodySoft.copyWith(fontSize: 28),
            ),
          ],
          const SizedBox(height: 28),
          if (count == 0)
            Expanded(
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(28),
                  border: Border.all(
                    color: AppColors.chalk.withValues(alpha: 0.2),
                    width: 4,
                  ),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const PulsingDots(size: 18),
                    const SizedBox(height: 20),
                    Text(
                      'Waiting for the first player…',
                      style: AppProjectorText.bodySoft.copyWith(
                        fontSize: 44,
                      ),
                    ),
                  ],
                ),
              ),
            )
          else
            Expanded(
              child: SingleChildScrollView(
                child: Wrap(
                  spacing: 16,
                  runSpacing: 16,
                  children: [
                    for (final p in shown)
                      ConstrainedBox(
                        // Two a row on a phone.
                        constraints: BoxConstraints(
                          maxWidth: portrait ? 350 : 420,
                        ),
                        child: _PopIn(
                          key: ValueKey(p.id),
                          child: PlayerChip(
                            nickname: p.nickname,
                            height: 80,
                            onRemove: () => _confirmRemove(context, p),
                          ),
                        ),
                      ),
                    if (count > shown.length)
                      MoreChip(count: count - shown.length, height: 80),
                  ],
                ),
              ),
            ),
          SizedBox(height: portrait ? 12 : 24),
          // Lock stops strangers using the code on screen; Start stays main.
          Wrap(
            alignment: WrapAlignment.spaceBetween,
            crossAxisAlignment: WrapCrossAlignment.center,
            spacing: 20,
            runSpacing: 16,
            children: [
              Wrap(
                crossAxisAlignment: WrapCrossAlignment.center,
                spacing: 20,
                runSpacing: 8,
                children: [
                  HostTextButton(
                    key: const Key('lobby.copyLink'),
                    label: 'Copy join link',
                    onPressed: () => _copyLink(context),
                  ),
                  HostTextButton(
                    key: const Key('lobby.lock'),
                    label: room.locked ? 'Unlock room' : 'Lock room',
                    onPressed: () =>
                        context.read<RoomCubit>().setLocked(!room.locked),
                  ),
                  // "Unlock room" already says it on a phone; room to spare
                  // on the projector for the why.
                  if (room.locked && !portrait)
                    Text(
                      'No new players can join',
                      style: AppProjectorText.bodySoft.copyWith(fontSize: 28),
                    ),
                ],
              ),
              HostStepButton(room: room, height: 120),
            ],
          ),
        ],
      ),
    );
  }
}

/// Chips pop in with the stamp curve as players join.
class _PopIn extends StatelessWidget {
  final Widget child;

  const _PopIn({super.key, required this.child});

  @override
  Widget build(BuildContext context) => TweenAnimationBuilder<double>(
    tween: Tween(begin: 0.6, end: 1),
    duration: const Duration(milliseconds: 400),
    curve: const Cubic(0.34, 1.56, 0.64, 1),
    builder: (context, s, child) => Opacity(
      opacity: ((s - 0.6) / 0.4).clamp(0.0, 1.0),
      child: Transform.scale(scale: s, child: child),
    ),
    child: child,
  );
}
