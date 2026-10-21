import 'package:flutter/material.dart';

/// Quiz Night palette: blackboard green, chalk white, and the maroon and gold
/// of a school uniform. Values come from the Quiz Night design system.
abstract final class AppColors {
  // ---- Chalk (warm neutral): backgrounds, surfaces, text
  /// e0: the page.
  static const board = Color(0xFF0F1A15);

  /// Inside inputs and the deepest wells.
  static const boardDeep = Color(0xFF0B1A14);

  /// e1: cards and panels.
  static const surface = Color(0xFF16241D);

  /// e2: chips, rows, dialogs.
  static const surfaceHigh = Color(0xFF1E3028);

  /// e3: the highest raised surface.
  static const surfaceTop = Color(0xFF26392F);

  static const chalk = Color(0xFFF2F0E6);
  static const chalkSoft = Color(0xFFD6DBD3);
  static const muted = Color(0xFFAEB9B1);
  static const faint = Color(0xFF7F8C85);
  static const slate = Color(0xFF3A4A42);
  static const slateDim = Color(0xFF5C6B63);

  /// Hairlines and quiet borders: chalk at low opacity.
  static const line = Color(0x24F2F0E6);
  static const lineStrong = Color(0x80F2F0E6);

  // ---- Blackboard green (primary)
  static const green = Color(0xFF1A3A2C);
  static const greenLine = Color(0xFF5FA683);
  static const mint = Color(0xFF8DC6A7);
  static const mintPale = Color(0xFFC3E3D0);
  static const greenInk = Color(0xFF0B1A14);

  // ---- Gold (tertiary: prizes, primary actions, "you")
  static const gold = Color(0xFFE0B53A);
  static const goldLight = Color(0xFFF2CF6E);
  static const goldPressed = Color(0xFFC49A12);
  static const goldRim = Color(0xFFA37D00);
  static const goldShadow = Color(0xFF463400);
  static const goldDeep = Color(0xFF3A2D05);
  static const goldPale = Color(0xFFFBE7B0);

  /// Text on gold.
  static const goldInk = Color(0xFF1B1500);

  // ---- Maroon (secondary: uniform, danger, destructive)
  static const maroon = Color(0xFF9C2D44);
  static const maroonRim = Color(0xFF631A29);
  static const maroonDeep = Color(0xFF45111C);
  static const maroonDarkest = Color(0xFF2A0A10);
  static const maroonPale = Color(0xFFF4D3D8);

  // ---- Semantic
  static const correct = Color(0xFF2E9E68);
  static const wrong = Color(0xFFE5484D);

  /// Error text on dark surfaces (wrong is too dark for small text).
  static const errorText = Color(0xFFFF8A8E);
  static const warning = Color(0xFFF2994A);
  static const info = Color(0xFF12324A);
  static const infoText = Color(0xFFCFE6F7);
  static const white = Color(0xFFFFFFFF);
  static const qrBackground = white;

  /// The website header over scrolling content: the page at 94%.
  static const headerGlass = Color(0xF00F1A15);

  /// Soft shadow under raised mock-ups on the website.
  static const dropShadow = Color(0x66000000);

  /// Scrim behind dialogs and the reconnecting overlay.
  static const scrim = Color(0x8C0B1310);

  /// Initial badges: the nickname hashes to one of these board-safe tones.
  static const badgeTones = [
    Color(0xFF8DC6A7),
    Color(0xFFE5A3AF),
    Color(0xFFF2CF6E),
    Color(0xFF9CC3EE),
    Color(0xFFD6DBD3),
    Color(0xFFF0B07A),
    Color(0xFFC9B3E8),
    Color(0xFF7FD1C2),
  ];

  /// Text on any badge tone.
  static const badgeInk = board;

  // ---- Answer options: letter + shape + colour, never colour alone
  /// Option backgrounds A-D: blue, orange, raspberry, yellow. They separate by
  /// lightness as well as hue, so they stay apart under colour blindness.
  static const options = [
    Color(0xFF1E5BC6),
    Color(0xFFF08A24),
    Color(0xFFC2417A),
    Color(0xFFF4D23C),
  ];

  /// Text and shape colour on each option.
  static const optionInk = [
    white,
    Color(0xFF1B1000),
    white,
    Color(0xFF1B1500),
  ];

  /// The darker "pressed" shade of each option.
  static const optionPressed = [
    Color(0xFF174BA6),
    Color(0xFFD27412),
    Color(0xFFA6305F),
    Color(0xFFD9B820),
  ];

  // ---- Podium blocks
  static const podiumGold = gold;
  static const podiumSilver = chalkSoft;
  static const podiumBronze = maroon;
}
