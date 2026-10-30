import 'dart:async';

import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/theme/app_text_styles.dart';
import 'loaders.dart';

/// Banner kinds from the design system.
enum BannerKind {
  /// Maroon: "You were eliminated…".
  eliminated,

  /// Gold: "Game already started…", tiebreak notes.
  warning,

  /// Blue: "Question is on the big screen".
  info,
}

/// An inline banner: an icon glyph and a sentence.
class QnBanner extends StatelessWidget {
  final BannerKind kind;
  final String text;

  const QnBanner({super.key, required this.kind, required this.text});

  @override
  Widget build(BuildContext context) {
    final (bg, fg, icon) = switch (kind) {
      BannerKind.eliminated => (
        AppColors.maroonDeep,
        AppColors.maroonPale,
        '✕',
      ),
      BannerKind.warning => (AppColors.goldDeep, AppColors.goldPale, '!'),
      BannerKind.info => (AppColors.info, AppColors.infoText, 'i'),
    };
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            icon,
            style: AppTextStyles.banner.copyWith(
              color: fg,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              text,
              style: AppTextStyles.banner.copyWith(color: fg, fontSize: 14),
            ),
          ),
        ],
      ),
    );
  }
}

/// "Reconnecting… answers are safe" pill.
class ReconnectingPill extends StatelessWidget {
  /// Projector size, for the host screen.
  final bool large;

  const ReconnectingPill({super.key, this.large = false});

  @override
  Widget build(BuildContext context) => Container(
    padding: large
        ? const EdgeInsets.symmetric(horizontal: 40, vertical: 20)
        : const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
    decoration: BoxDecoration(
      color: AppColors.surfaceHigh,
      borderRadius: BorderRadius.circular(AppRadii.full),
      border: Border.all(color: AppColors.chalk.withValues(alpha: 0.2)),
      boxShadow: const [
        BoxShadow(
          color: Color(0x59000000),
          blurRadius: 16,
          offset: Offset(0, 6),
        ),
      ],
    ),
    child: Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        PulsingDots(size: large ? 18 : 7),
        SizedBox(width: large ? 20 : 10),
        Text(
          'Reconnecting…',
          style: AppTextStyles.chip.copyWith(fontSize: large ? 32 : 15),
        ),
        SizedBox(width: large ? 16 : 8),
        Text(
          'answers are safe',
          style: AppTextStyles.caption.copyWith(fontSize: large ? 24 : 13),
        ),
      ],
    ),
  );
}

/// The teacher's red "✕ OUT" stamp, tilted.
class OutStamp extends StatelessWidget {
  final double fontSize;

  /// Degrees of tilt; the design uses -8 on phones and -12 on the projector.
  final double tilt;

  const OutStamp({super.key, this.fontSize = 44, this.tilt = -8});

  @override
  Widget build(BuildContext context) => Transform.rotate(
    angle: tilt * 3.14159 / 180,
    child: Container(
      padding: EdgeInsets.symmetric(
        horizontal: fontSize * 0.42,
        vertical: fontSize * 0.14,
      ),
      decoration: BoxDecoration(
        color: AppColors.board.withValues(alpha: 0.6),
        border: Border.all(color: AppColors.wrong, width: fontSize * 0.14),
        borderRadius: BorderRadius.circular(fontSize * 0.32),
      ),
      child: Text(
        '✕ OUT',
        style: AppTextStyles.displayL.copyWith(
          fontSize: fontSize,
          color: AppColors.wrong,
          height: 1.0,
        ),
      ),
    ),
  );
}

/// What a toast is telling the user; sets its colour and glyph.
enum ToastKind {
  /// Something failed: a wrong code, no connection.
  error,

  /// It worked out, but not as asked: game already started, room full.
  warning,

  /// Just so you know.
  info,

  /// Done.
  success,
}

/// Widest a toast gets, so it stays a pill on a desktop screen.
const _toastMaxWidth = 480.0;

/// Shows [message] as a bottom toast (above the keyboard), replacing any.
void showToast(
  BuildContext context,
  String message, {
  ToastKind kind = ToastKind.error,
}) {
  final (bg, fg, glyph) = switch (kind) {
    ToastKind.error => (AppColors.maroonDeep, AppColors.maroonPale, '✕'),
    ToastKind.warning => (AppColors.goldDeep, AppColors.goldPale, '!'),
    ToastKind.info => (AppColors.info, AppColors.infoText, 'i'),
    ToastKind.success => (AppColors.green, AppColors.mintPale, '✓'),
  };
  final screen = MediaQuery.sizeOf(context).width;
  ScaffoldMessenger.of(context)
    ..hideCurrentSnackBar()
    ..showSnackBar(
      SnackBar(
        key: Key('toast.${kind.name}'),
        backgroundColor: bg,
        behavior: SnackBarBehavior.floating,
        width: screen > _toastMaxWidth + 32 ? _toastMaxWidth : null,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadii.md),
          side: BorderSide(color: fg.withValues(alpha: 0.25)),
        ),
        content: Semantics(
          liveRegion: true,
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                glyph,
                style: AppTextStyles.toast.copyWith(
                  color: fg,
                  fontSize: 15,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  message,
                  style: AppTextStyles.toast.copyWith(color: fg, fontSize: 15),
                ),
              ),
            ],
          ),
        ),
      ),
    );
}

/// The host's screen dropped: players wait, with the seconds until the game
/// ends unless the host comes back. [until] is server time.
class HostAwayCard extends StatefulWidget {
  final DateTime until;

  /// Server minus local time.
  final Duration clockOffset;

  /// The local time; replaceable in tests.
  final DateTime Function() clock;

  const HostAwayCard({
    super.key,
    required this.until,
    required this.clockOffset,
    this.clock = DateTime.now,
  });

  /// Whole seconds left, 0 once passed.
  static int secondsLeft(DateTime until, Duration offset, DateTime now) {
    final left = until.difference(now.toUtc().add(offset));
    return left.isNegative ? 0 : (left.inMilliseconds / 1000).ceil();
  }

  @override
  State<HostAwayCard> createState() => _HostAwayCardState();
}

class _HostAwayCardState extends State<HostAwayCard> {
  late final Timer _timer;

  @override
  void initState() {
    super.initState();
    _timer = Timer.periodic(
      const Duration(milliseconds: 250),
      (_) => setState(() {}),
    );
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final left = HostAwayCard.secondsLeft(
      widget.until,
      widget.clockOffset,
      widget.clock(),
    );
    return Container(
      key: const Key('hostAway'),
      margin: const EdgeInsets.symmetric(horizontal: 20),
      padding: const EdgeInsets.fromLTRB(20, 18, 20, 20),
      decoration: BoxDecoration(
        color: AppColors.surfaceHigh,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.gold.withValues(alpha: 0.5)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const PulsingDots(size: 8),
          const SizedBox(height: 12),
          Text(
            'THE HOST DISCONNECTED',
            textAlign: TextAlign.center,
            style: AppTextStyles.label.copyWith(
              color: AppColors.gold,
              letterSpacing: 1.5,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            left > 0
                ? 'Waiting for them to reconnect… $left s'
                : 'Ending the game…',
            key: const Key('hostAway.count'),
            textAlign: TextAlign.center,
            style: AppTextStyles.title.copyWith(fontSize: 22),
          ),
          const SizedBox(height: 8),
          Text(
            "If they don't come back, the game ends and the scores stand.",
            textAlign: TextAlign.center,
            style: AppTextStyles.bodySoft.copyWith(fontSize: 14),
          ),
        ],
      ),
    );
  }
}
