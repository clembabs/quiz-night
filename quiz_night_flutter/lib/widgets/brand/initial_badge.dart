import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';

/// Badge tone for [nickname] from its code points; same name, same colour.
Color badgeToneFor(String nickname) {
  final sum = nickname.runes.fold<int>(0, (a, r) => a + r);
  return AppColors.badgeTones[sum % AppColors.badgeTones.length];
}

/// The first user-perceived character, so Ọ̀, Ɗ and Ṣ stay whole.
String initialOf(String nickname) {
  final trimmed = nickname.trim();
  return trimmed.isEmpty ? '?' : trimmed.characters.first.toUpperCase();
}

/// A round initial badge in the nickname's tone.
class InitialBadge extends StatelessWidget {
  final String nickname;
  final double size;

  /// Eliminated players get a grey badge.
  final bool eliminated;

  const InitialBadge({
    super.key,
    required this.nickname,
    this.size = 32,
    this.eliminated = false,
  });

  @override
  Widget build(BuildContext context) => Container(
    width: size,
    height: size,
    alignment: Alignment.center,
    decoration: BoxDecoration(
      shape: BoxShape.circle,
      color: eliminated ? AppColors.slateDim : badgeToneFor(nickname),
    ),
    child: Text(
      initialOf(nickname),
      style: AppTextStyles.badge.copyWith(
        fontSize: size * 0.47,
        color: AppColors.badgeInk,
        height: 1.0,
      ),
    ),
  );
}
