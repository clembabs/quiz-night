import 'package:flutter/material.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:quiz_night_client/quiz_night_client.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../widgets/qn/loaders.dart';
import '../../../widgets/qn/player_chip.dart';
import '../round/host_step_button.dart';

/// The projector lobby: code + QR on the left, players arriving on the right.
class HostLobby extends StatelessWidget {
  final RoomState room;

  /// Address the QR and "go to" line point at; [Uri.base] in the app.
  final Uri appUrl;

  const HostLobby({super.key, required this.room, required this.appUrl});

  static const minPlayers = 2;

  /// Chips shown before collapsing into "+N more".
  static const maxChips = 24;

  /// The link the QR encodes: this app's address with the code pre-filled.
  static Uri joinUrl(Uri appUrl, String code) =>
      appUrl.removeFragment().replace(queryParameters: {'code': code});

  /// What to tell people to type: host and path, no scheme.
  static String shortAddress(Uri appUrl) {
    final path = appUrl.path == '/' ? '' : appUrl.path;
    final port = appUrl.hasPort && appUrl.port != 80 && appUrl.port != 443
        ? ':${appUrl.port}'
        : '';
    return '${appUrl.host}$port$path';
  }

  @override
  Widget build(BuildContext context) {
    final count = room.players.length;
    final byJoin = [...room.players]..sort((a, b) => a.id.compareTo(b.id));
    final shown = byJoin.take(maxChips).toList();
    return Row(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        SizedBox(
          width: 720,
          child: Container(
            padding: const EdgeInsets.all(48),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(28),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text.rich(
                  TextSpan(
                    text: 'Scan, or go to ',
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
                Text(
                  'ROOM CODE',
                  style: AppProjectorText.label.copyWith(
                    letterSpacing: 2.8,
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  room.code,
                  key: const Key('lobby.code'),
                  style: AppProjectorText.displayXl,
                ),
                const SizedBox(height: 28),
                Expanded(
                  child: AspectRatio(
                    aspectRatio: 1,
                    child: Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: AppColors.qrBackground,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: QrImageView(
                        data: joinUrl(appUrl, room.code).toString(),
                        padding: EdgeInsets.zero,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(width: 64),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.baseline,
                textBaseline: TextBaseline.alphabetic,
                children: [
                  Text(
                    '$count',
                    style: AppProjectorText.displayXl.copyWith(
                      fontSize: 160,
                      letterSpacing: 0,
                    ),
                  ),
                  const SizedBox(width: 20),
                  Text(
                    count == 1 ? 'player in' : 'players in',
                    style: AppProjectorText.title.copyWith(
                      fontSize: 48,
                      color: AppColors.chalkSoft,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 32),
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
                            constraints: const BoxConstraints(maxWidth: 420),
                            child: _PopIn(
                              key: ValueKey(p.id),
                              child: PlayerChip(
                                nickname: p.nickname,
                                height: 80,
                              ),
                            ),
                          ),
                        if (count > shown.length)
                          MoreChip(count: count - shown.length, height: 80),
                      ],
                    ),
                  ),
                ),
              const SizedBox(height: 24),
              Align(
                alignment: Alignment.bottomRight,
                child: HostStepButton(room: room, height: 120),
              ),
            ],
          ),
        ),
      ],
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
