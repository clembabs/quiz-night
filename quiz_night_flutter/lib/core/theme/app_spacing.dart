import 'package:flutter/widgets.dart';

/// Spacing scale and layout constants.
abstract final class AppSpacing {
  static const xs = 4.0;
  static const sm = 8.0;
  static const md = 12.0;
  static const lg = 16.0;
  static const xl = 24.0;
  static const xxl = 32.0;
  static const xxxl = 40.0;

  static const screenPadding = EdgeInsets.all(xl);

  /// Max content width for phone-style screens.
  static const phoneMaxWidth = 420.0;

  /// Max content width for forms.
  static const formMaxWidth = 520.0;

  /// From this width the host screen uses the two-column projector layout.
  static const wideBreakpoint = 900.0;

  /// Minimum height of thumb-friendly buttons.
  static const buttonHeight = 56.0;

  /// Height of a player's answer button: big enough to hit without looking.
  static const answerButtonHeight = 76.0;
}

/// Corner radii.
abstract final class AppRadii {
  static const sm = 14.0;
  static const lg = 20.0;
  static const pill = 999.0;
}

/// Icon sizes.
abstract final class AppIconSizes {
  static const hero = 72.0;
  static const message = 56.0;
}
