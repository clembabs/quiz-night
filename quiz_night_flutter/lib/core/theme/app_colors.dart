import 'package:flutter/material.dart';

/// Quiz-show palette: deep navy stage, gold accents.
abstract final class AppColors {
  static const background = Color(0xFF14123A);
  static const surface = Color(0xFF221F55);
  static const surfaceHigh = Color(0xFF2E2A6B);
  static const gold = Color(0xFFFFC233);
  static const text = Color(0xFFF4F2FF);
  static const muted = Color(0xFFA9A4D6);
  static const danger = Color(0xFFFF5C7A);
  static const success = Color(0xFF3DDC97);
  static const qrBackground = Colors.white;
  static const onOption = Colors.white;

  /// Background of an eliminated name in the cut reveal.
  static const eliminated = Color(0xFF4A1F3D);

  // ---- buzzer final and podium
  static const buzzer = Color(0xFFE5484D);
  static const buzzerRim = Color(0xFF8E1F2B);
  static const silver = Color(0xFFC9CDD6);
  static const bronze = Color(0xFFD08A4E);

  /// Overlay that fades options that are not the answer after reveal.
  static const dimmed = Color(0x99000000);

  /// One colour per answer option (A-D).
  static const options = [
    Color(0xFFE5484D),
    Color(0xFF3E63DD),
    Color(0xFFF5A524),
    Color(0xFF30A46C),
  ];
}
