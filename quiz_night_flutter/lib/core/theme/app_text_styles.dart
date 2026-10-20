import 'package:flutter/material.dart';

import 'app_colors.dart';

/// Font families bundled in assets/fonts (see tool/make_fonts.py).
abstract final class AppFonts {
  /// Display: Bricolage Grotesque, weight 800 only.
  static const display = 'Bricolage';

  /// Body: Figtree 400 / 700 / 800.
  static const body = 'Figtree';

  /// Per-glyph fallbacks: Nigerian letters the others lack (ẹ ọ ṣ ị ụ ṅ ɓ
  /// ɗ ƙ ƴ), then UI symbols (✓ ✕ ▲ ▼ ★ ⏱).
  static const fallback = ['NotoSansAfr', 'NotoSansSymbols'];
}

const _tabular = [FontFeature.tabularFigures()];

TextStyle _display(double size, double height, {double tracking = 0}) =>
    TextStyle(
      fontFamily: AppFonts.display,
      fontFamilyFallback: AppFonts.fallback,
      fontWeight: FontWeight.w800,
      fontSize: size,
      height: height,
      letterSpacing: tracking * size,
      fontFeatures: _tabular,
      color: AppColors.chalk,
    );

TextStyle _body(
  double size,
  double height,
  FontWeight weight, {
  double tracking = 0,
  Color color = AppColors.chalk,
}) => TextStyle(
  fontFamily: AppFonts.body,
  fontFamilyFallback: AppFonts.fallback,
  fontWeight: weight,
  fontSize: size,
  height: height,
  letterSpacing: tracking * size,
  color: color,
);

/// The phone type scale (design system "Typography", phone column).
///
/// Display roles (displayXl, displayL, headline) are set in capitals: pass
/// upper-cased text, e.g. via `DisplayText`.
abstract final class AppTextStyles {
  // ---- Design-system roles
  /// Room codes and the biggest moments. 56 / 1.0 / 800.
  static final displayXl = _display(56, 1.0, tracking: -0.01);

  /// "You survived". 40 / 1.05 / 800.
  static final displayL = _display(40, 1.05, tracking: -0.01);

  /// "Round 2 · Question 4". 28 / 1.15 / 800.
  static final headline = _display(28, 1.15);

  /// Question text. Figtree 20 / 1.25 / 700.
  static final title = _body(20, 1.25, FontWeight.w700);

  /// 16 / 1.45 / 400.
  static final body = _body(16, 1.45, FontWeight.w400);
  static final bodySoft = _body(
    16,
    1.45,
    FontWeight.w400,
    color: AppColors.chalkSoft,
  );

  /// Small capitals labels. 14 / 1.2 / 700 / +6%.
  static final label = _body(14, 1.2, FontWeight.w700, tracking: 0.06);

  /// 12 / 1.35.
  static final caption = _body(
    12,
    1.35,
    FontWeight.w400,
    tracking: 0.01,
    color: AppColors.muted,
  );

  /// Scores and timers, tabular. 32 / 1.0 / 800.
  static final numeric = _display(32, 1.0);

  // ---- Component styles built from the roles
  static final button = _body(17, 1.0, FontWeight.w800);
  static final buttonSecondary = _body(15, 1.0, FontWeight.w700);
  static final input = _body(18, 1.2, FontWeight.w400);
  static final codeInput = _display(34, 1.0, tracking: 0.3);
  static final error = _body(
    14,
    1.35,
    FontWeight.w700,
    color: AppColors.errorText,
  );
  static final eyebrow = _body(
    13,
    1.2,
    FontWeight.w800,
    tracking: 0.1,
    color: AppColors.mint,
  );
  static final optionLetter = _display(22, 1.0).copyWith(
    color: AppColors.white,
  );
  static final optionText = _body(17, 1.25, FontWeight.w700);
  static final chip = _body(15, 1.2, FontWeight.w700);
  static final badge = _display(15, 1.0);
  static final banner = _body(15, 1.35, FontWeight.w700);
  static final toast = _body(14, 1.2, FontWeight.w700);
}

/// The projector type scale (design system "Typography", 1080p column), for
/// host screens laid out on a 1920×1080 canvas. Body never goes below 36: on
/// a ~2.5 m projected image that is legible from 10 m.
abstract final class AppProjectorText {
  static final displayXl = _display(200, 0.95, tracking: 0.06);
  static final displayL = _display(120, 1.0, tracking: -0.01);
  static final headline = _display(72, 1.1);
  static final title = _body(56, 1.2, FontWeight.w700);
  static final body = _body(36, 1.35, FontWeight.w400);
  static final bodySoft = _body(
    36,
    1.35,
    FontWeight.w400,
    color: AppColors.chalkSoft,
  );
  static final label = _body(
    28,
    1.2,
    FontWeight.w700,
    tracking: 0.06,
    color: AppColors.muted,
  );
  static final caption = _body(
    24,
    1.3,
    FontWeight.w400,
    color: AppColors.muted,
  );
  static final numeric = _display(96, 1.0);
}
