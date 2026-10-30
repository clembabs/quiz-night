import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../core/platform/haptics.dart';
import '../../core/platform/sounds.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_motion.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/theme/app_text_styles.dart';
import '../brand/chalk_background.dart';
import '../brand/crest.dart';
import 'notices.dart';

/// Phone layout: centred column (max 480), safe areas, header, overlay.
class PhoneFrame extends StatelessWidget {
  final Widget child;

  /// Room code and phase label ("Lobby", "Round 2"…); null hides header.
  final String? code;
  final String? phase;

  /// Page colour: blackboard, or green / maroon for survived / out.
  final Color background;
  final bool reconnecting;
  final VoidCallback? onLeave;

  /// Time left in the game, in a slim row under the header.
  final Widget? clock;

  /// A card over the screen that blocks it, e.g. the host disconnected.
  final Widget? notice;

  const PhoneFrame({
    super.key,
    required this.child,
    this.code,
    this.phase,
    this.background = AppColors.board,
    this.reconnecting = false,
    this.onLeave,
    this.clock,
    this.notice,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 500),
      color: background,
      child: ChalkBackground(
        color: Colors.transparent,
        child: SafeArea(
          child: Stack(
            children: [
              Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(
                    maxWidth: AppSpacing.playerColumn,
                  ),
                  child: Column(
                    children: [
                      if (code != null)
                        PhoneHeader(
                          code: code!,
                          phase: phase ?? '',
                          onLeave: onLeave,
                        ),
                      if (code != null && clock != null)
                        Padding(
                          padding: const EdgeInsets.only(bottom: 4),
                          child: Center(child: clock),
                        ),
                      Expanded(child: child),
                    ],
                  ),
                ),
              ),
              if (reconnecting)
                Positioned.fill(
                  child: AnimatedOpacity(
                    duration: AppDurations.fast,
                    opacity: 1,
                    child: Container(
                      color: AppColors.scrim,
                      alignment: Alignment.topCenter,
                      padding: const EdgeInsets.only(top: 64),
                      child: const ReconnectingPill(),
                    ),
                  ),
                )
              else if (notice != null)
                Positioned.fill(
                  child: Container(
                    color: AppColors.scrim,
                    alignment: Alignment.center,
                    child: notice,
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Crest, room code, phase label, and the Sound toggle.
class PhoneHeader extends StatefulWidget {
  final String code;
  final String phase;
  final VoidCallback? onLeave;

  const PhoneHeader({
    super.key,
    required this.code,
    required this.phase,
    this.onLeave,
  });

  @override
  State<PhoneHeader> createState() => _PhoneHeaderState();
}

class _PhoneHeaderState extends State<PhoneHeader> {
  Haptics? get _haptics {
    try {
      return context.read<Haptics>();
    } catch (_) {
      return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    final haptics = _haptics;
    final soundOn = haptics?.enabled ?? true;
    return SizedBox(
      height: 48,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Row(
          children: [
            const Crest(width: 22),
            const SizedBox(width: 8),
            Text(
              widget.code,
              style: AppTextStyles.numeric.copyWith(
                fontSize: 15,
                letterSpacing: 0.9,
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                widget.phase,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: AppTextStyles.caption.copyWith(fontSize: 13),
              ),
            ),
            _Pill(
              label: soundOn ? 'Sound on' : 'Muted',
              onTap: haptics == null
                  ? null
                  // Mutes the buzz and, in remote games, the cut's sounds.
                  : () => setState(() {
                      haptics.enabled = !soundOn;
                      Sounds.of(context).enabled = !soundOn;
                    }),
            ),
            if (widget.onLeave != null) ...[
              const SizedBox(width: 6),
              _Pill(label: 'Leave', onTap: widget.onLeave),
            ],
          ],
        ),
      ),
    );
  }
}

class _Pill extends StatelessWidget {
  final String label;
  final VoidCallback? onTap;

  const _Pill({required this.label, this.onTap});

  @override
  Widget build(BuildContext context) => Semantics(
    button: true,
    child: InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(AppRadii.full),
      child: Container(
        height: 40,
        constraints: const BoxConstraints(minWidth: 48),
        padding: const EdgeInsets.symmetric(horizontal: 10),
        alignment: Alignment.center,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(AppRadii.full),
          border: Border.all(color: AppColors.chalk.withValues(alpha: 0.2)),
        ),
        child: Text(
          label,
          style: AppTextStyles.label.copyWith(fontSize: 12, letterSpacing: 0),
        ),
      ),
    ),
  );
}
