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

  /// One colour per answer option (A-D), used from Milestone 4.
  static const options = [
    Color(0xFFE5484D),
    Color(0xFF3E63DD),
    Color(0xFFF5A524),
    Color(0xFF30A46C),
  ];
}
