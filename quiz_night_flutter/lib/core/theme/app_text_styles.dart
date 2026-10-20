import 'package:flutter/material.dart';

import 'app_colors.dart';

/// Every text style in the app. Widgets pick from here instead of building
/// their own `TextStyle`s.
abstract final class AppTextStyles {
  static const title = TextStyle(
    fontSize: 44,
    fontWeight: FontWeight.w900,
    letterSpacing: -1,
    color: AppColors.text,
  );
  static const tagline = TextStyle(fontSize: 16, color: AppColors.muted);
  static const heading = TextStyle(
    fontSize: 28,
    fontWeight: FontWeight.w800,
    color: AppColors.text,
  );
  static const label = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.w700,
    color: AppColors.text,
  );
  static const body = TextStyle(fontSize: 16, color: AppColors.text);
  static const bodyMuted = TextStyle(fontSize: 18, color: AppColors.muted);
  static const caption = TextStyle(fontSize: 14, color: AppColors.muted);
  static const error = TextStyle(fontSize: 14, color: AppColors.danger);
  static const button = TextStyle(fontSize: 18, fontWeight: FontWeight.w700);
  static const input = TextStyle(fontSize: 20, color: AppColors.text);
  static const codeInput = TextStyle(
    fontSize: 32,
    fontWeight: FontWeight.w800,
    letterSpacing: 8,
    color: AppColors.text,
  );
  static const roomCode = TextStyle(
    fontSize: 72,
    fontWeight: FontWeight.w900,
    letterSpacing: 12,
    color: AppColors.gold,
  );
  static const stepperValue = TextStyle(
    fontSize: 20,
    fontWeight: FontWeight.w800,
    color: AppColors.text,
  );
  // ---- rounds
  static const questionHost = TextStyle(
    fontSize: 44,
    fontWeight: FontWeight.w800,
    height: 1.2,
    color: AppColors.text,
  );
  static const questionPlayer = TextStyle(
    fontSize: 22,
    fontWeight: FontWeight.w700,
    height: 1.25,
    color: AppColors.text,
  );
  static const roundLabel = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.w700,
    letterSpacing: 1.5,
    color: AppColors.gold,
  );
  static const optionLetter = TextStyle(
    fontSize: 22,
    fontWeight: FontWeight.w900,
    color: AppColors.onOption,
  );
  static const optionText = TextStyle(
    fontSize: 20,
    fontWeight: FontWeight.w700,
    color: AppColors.onOption,
  );
  static const optionTextLarge = TextStyle(
    fontSize: 28,
    fontWeight: FontWeight.w700,
    color: AppColors.onOption,
  );
  static const optionCount = TextStyle(
    fontSize: 22,
    fontWeight: FontWeight.w900,
    color: AppColors.onOption,
  );
  static const timer = TextStyle(
    fontSize: 28,
    fontWeight: FontWeight.w900,
    fontFeatures: [FontFeature.tabularFigures()],
    color: AppColors.text,
  );
  static const verdict = TextStyle(
    fontSize: 36,
    fontWeight: FontWeight.w900,
    color: AppColors.text,
  );
  static const points = TextStyle(
    fontSize: 48,
    fontWeight: FontWeight.w900,
    color: AppColors.gold,
  );
  static const rank = TextStyle(
    fontSize: 20,
    fontWeight: FontWeight.w700,
    color: AppColors.muted,
  );
  static const leaderName = TextStyle(
    fontSize: 20,
    fontWeight: FontWeight.w700,
    color: AppColors.text,
  );
  static const leaderScore = TextStyle(
    fontSize: 20,
    fontWeight: FontWeight.w900,
    fontFeatures: [FontFeature.tabularFigures()],
    color: AppColors.text,
  );
  static const leaderGain = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.w700,
    color: AppColors.success,
  );

  // ---- elimination
  static const revealIntro = TextStyle(
    fontSize: 48,
    fontWeight: FontWeight.w900,
    height: 1.1,
    color: AppColors.gold,
  );
  static const revealName = TextStyle(
    fontSize: 32,
    fontWeight: FontWeight.w900,
    color: AppColors.text,
  );
  static const bubbleTag = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w800,
    letterSpacing: 1,
    color: AppColors.gold,
  );
  static const banner = TextStyle(
    fontSize: 15,
    fontWeight: FontWeight.w700,
    color: AppColors.text,
  );

  // ---- buzzer final and podium
  static const buzzLabel = TextStyle(
    fontSize: 44,
    fontWeight: FontWeight.w900,
    letterSpacing: 2,
    color: AppColors.onOption,
  );
  static const finalistName = TextStyle(
    fontSize: 22,
    fontWeight: FontWeight.w800,
    color: AppColors.text,
  );
  static const finalScore = TextStyle(
    fontSize: 32,
    fontWeight: FontWeight.w900,
    fontFeatures: [FontFeature.tabularFigures()],
    color: AppColors.gold,
  );
  static const statusTag = TextStyle(
    fontSize: 13,
    fontWeight: FontWeight.w900,
    letterSpacing: 1.2,
    color: AppColors.background,
  );
  static const podiumPlace = TextStyle(
    fontSize: 40,
    fontWeight: FontWeight.w900,
    color: AppColors.background,
  );
  static const podiumName = TextStyle(
    fontSize: 22,
    fontWeight: FontWeight.w800,
    color: AppColors.text,
  );

  static const chip = TextStyle(fontSize: 16, fontWeight: FontWeight.w700);
  static const chipLarge = TextStyle(fontSize: 22, fontWeight: FontWeight.w700);
}
