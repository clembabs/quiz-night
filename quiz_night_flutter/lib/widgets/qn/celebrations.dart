import 'dart:math';

import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_motion.dart';
import '../../core/theme/app_text_styles.dart';
import '../brand/initial_badge.dart';

/// A one-shot burst of 16 shapes flying out from the centre (survived).
class ShapeBurst extends StatefulWidget {
  const ShapeBurst({super.key});

  @override
  State<ShapeBurst> createState() => _ShapeBurstState();
}

class _ShapeBurstState extends State<ShapeBurst>
    with SingleTickerProviderStateMixin {
  late final _c = AnimationController(
    vsync: this,
    duration: AppDurations.dramatic,
  )..forward();

  static const _colors = [
    AppColors.gold,
    AppColors.chalk,
    AppColors.maroon,
    AppColors.mint,
  ];

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (MediaQuery.disableAnimationsOf(context)) return const SizedBox.shrink();
    return IgnorePointer(
      child: AnimatedBuilder(
        animation: _c,
        builder: (context, _) {
          final t = AppCurves.decelerate.transform(_c.value);
          final fade = (1 - (_c.value - 0.66).clamp(0.0, 1.0) * 3).clamp(
            0.0,
            1.0,
          );
          return Stack(
            clipBehavior: Clip.none,
            children: [
              for (var i = 0; i < 16; i++)
                Builder(
                  builder: (context) {
                    final a = i / 16 * 2 * pi + 0.2;
                    final r = (110 + (i % 3) * 40) * t;
                    final size = 10.0 + (i % 4) * 4;
                    return Transform.translate(
                      offset: Offset(
                        cos(a) * r - size / 2,
                        sin(a) * r - size / 2,
                      ),
                      child: Transform.rotate(
                        angle: i * 40 * pi / 180 * t,
                        child: Opacity(
                          opacity: fade,
                          child: Container(
                            width: size,
                            height: size,
                            decoration: BoxDecoration(
                              color: _colors[i % 4],
                              shape: i % 4 == 0 || i % 4 == 3
                                  ? BoxShape.circle
                                  : BoxShape.rectangle,
                              borderRadius: i % 4 == 1
                                  ? BorderRadius.circular(2)
                                  : null,
                            ),
                          ),
                        ),
                      ),
                    );
                  },
                ),
            ],
          );
        },
      ),
    );
  }
}

/// One podium block that rises from the floor after [delay].
class PodiumBlock extends StatefulWidget {
  final int place;
  final String nickname;
  final String score;
  final double height;
  final Duration delay;

  /// Projector (true) or phone sizing.
  final bool large;

  const PodiumBlock({
    super.key,
    required this.place,
    required this.nickname,
    required this.score,
    required this.height,
    this.delay = Duration.zero,
    this.large = true,
  });

  @override
  State<PodiumBlock> createState() => _PodiumBlockState();
}

class _PodiumBlockState extends State<PodiumBlock>
    with SingleTickerProviderStateMixin {
  late final _c = AnimationController(
    vsync: this,
    duration: AppDurations.dramatic,
  );

  @override
  void initState() {
    super.initState();
    Future.delayed(widget.delay, () {
      if (mounted) _c.forward();
    });
  }

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final (bg, fg) = switch (widget.place) {
      1 => (AppColors.podiumGold, AppColors.goldInk),
      2 => (AppColors.podiumSilver, AppColors.board),
      _ => (AppColors.podiumBronze, AppColors.white),
    };
    final k = widget.large ? 1.0 : 0.3;
    final reduced = MediaQuery.disableAnimationsOf(context);
    return AnimatedBuilder(
      animation: _c,
      builder: (context, _) {
        final rise = reduced
            ? 1.0
            : const Cubic(0.34, 1.3, 0.64, 1).transform(_c.value);
        final nameIn = reduced ? 1.0 : ((_c.value - 0.6) / 0.4).clamp(0.0, 1.0);
        return Column(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            Opacity(
              opacity: nameIn,
              child: Column(
                children: [
                  InitialBadge(nickname: widget.nickname, size: 120 * k),
                  SizedBox(height: 12 * k),
                  Text(
                    widget.nickname,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: AppTextStyles.headline.copyWith(fontSize: 52 * k),
                  ),
                ],
              ),
            ),
            SizedBox(height: 20 * k),
            Align(
              alignment: Alignment.bottomCenter,
              heightFactor: 1,
              child: Transform(
                alignment: Alignment.bottomCenter,
                transform: Matrix4.diagonal3Values(
                  1,
                  rise.clamp(0.001, 1.2),
                  1,
                ),
                child: Container(
                  height: widget.height,
                  width: double.infinity,
                  padding: EdgeInsets.only(top: 28 * k),
                  decoration: BoxDecoration(
                    color: bg,
                    borderRadius: BorderRadius.vertical(
                      top: Radius.circular(24 * k),
                    ),
                  ),
                  child: FittedBox(
                    fit: BoxFit.scaleDown,
                    alignment: Alignment.topCenter,
                    child: Column(
                      children: [
                        Text(
                          '${widget.place}',
                          style: AppTextStyles.numeric.copyWith(
                            fontSize: 140 * k,
                            color: fg,
                          ),
                        ),
                        Text(
                          widget.score,
                          style: AppTextStyles.numeric.copyWith(
                            fontSize: 40 * k,
                            color: fg,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}
