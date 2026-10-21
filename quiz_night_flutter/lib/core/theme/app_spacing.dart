import 'package:flutter/widgets.dart';

/// Spacing on a 4 px base (design system "Spacing").
abstract final class AppSpacing {
  static const s1 = 4.0;
  static const s2 = 8.0;
  static const s3 = 12.0;
  static const s4 = 16.0;
  static const s5 = 20.0;
  static const s6 = 24.0;
  static const s8 = 32.0;
  static const s12 = 48.0;
  static const s16 = 64.0;

  /// Side gutter on phones.
  static const gutter = s5;
  static const screenPadding = EdgeInsets.all(s5);

  /// Phone content column on tablets and desktop browsers.
  static const playerColumn = 480.0;

  /// Max width for forms.
  static const formMaxWidth = 520.0;

  // ---- Touch targets
  static const primaryButtonHeight = 56.0;
  static const secondaryButtonHeight = 48.0;
  static const answerButtonMin = 72.0;

  /// Diameter of the buzzer on a 360 phone (about 78% of the column).
  static const buzzerSize = 260.0;
}

/// Corner radii (design system "Radius").
abstract final class AppRadii {
  static const xs = 4.0;
  static const sm = 8.0;

  /// Buttons and inputs.
  static const md = 12.0;

  /// Answer buttons.
  static const lg = 14.0;

  /// Dialogs and big panels.
  static const xl = 20.0;
  static const full = 999.0;
}

/// Border widths (design system "Border").
abstract final class AppBorders {
  static const hairline = 1.0;
  static const thin = 2.0;

  /// Focus, selected, "you".
  static const focus = 3.0;
}

/// Window-width classes (design system "Breakpoints").
abstract final class AppBreakpoints {
  /// Below this: phones. Player and spectator, single column.
  static const medium = 600.0;

  /// From this: host / projector layout.
  static const expanded = 1024.0;
}

/// Icon sizes.
abstract final class AppIconSizes {
  static const hero = 72.0;
  static const message = 56.0;
}

/// Opacity levels (design system "Opacity").
abstract final class AppOpacity {
  static const disabled = 0.38;
  static const dimmed = 0.45;
  static const pressed = 0.12;
  static const hover = 0.08;
}

/// Website layout (landing page).
abstract final class AppWebLayout {
  /// Widest the content column gets.
  static const maxWidth = 1160.0;

  /// From this width the header shows its links; below it, a Menu button.
  static const wideNav = 900.0;

  static const headerHeight = 68.0;

  /// Side gutter: 16 to 32, like CSS `clamp(16px, 4vw, 32px)`.
  static double gutter(double width) => (width * 0.04).clamp(16, 32);

  /// Space above the hero: 40 to 96.
  static double heroTop(double width) => (width * 0.08).clamp(40, 96);

  /// Gap between the hero's two columns: 32 to 64.
  static double heroGap(double width) => (width * 0.05).clamp(32, 64);

  /// Card corner radius.
  static const card = 20.0;
}
