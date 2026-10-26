import 'package:flutter/material.dart';

import 'app_colors.dart';
import 'app_motion.dart';
import 'app_spacing.dart';
import 'app_text_styles.dart';

/// The app's [ThemeData] from design tokens; dark for projector and phones.
abstract final class AppTheme {
  static ThemeData dark() {
    final buttonShape = RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(AppRadii.md),
    );

    final scheme =
        ColorScheme.fromSeed(
          seedColor: AppColors.green,
          brightness: Brightness.dark,
        ).copyWith(
          primary: AppColors.gold,
          onPrimary: AppColors.goldInk,
          secondary: AppColors.maroon,
          onSecondary: AppColors.white,
          tertiary: AppColors.mint,
          surface: AppColors.surface,
          onSurface: AppColors.chalk,
          onSurfaceVariant: AppColors.muted,
          surfaceContainerHighest: AppColors.surfaceHigh,
          outline: AppColors.lineStrong,
          outlineVariant: AppColors.line,
          error: AppColors.wrong,
          onError: AppColors.white,
        );

    final base = ThemeData(
      colorScheme: scheme,
      fontFamily: AppFonts.body,
      fontFamilyFallback: AppFonts.fallback,
    );

    return base.copyWith(
      scaffoldBackgroundColor: AppColors.board,
      textTheme: base.textTheme.apply(
        bodyColor: AppColors.chalk,
        displayColor: AppColors.chalk,
        fontFamily: AppFonts.body,
        fontFamilyFallback: AppFonts.fallback,
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: AppColors.board,
        foregroundColor: AppColors.chalk,
        elevation: 0,
        scrolledUnderElevation: 0,
        titleTextStyle: AppTextStyles.label,
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: ButtonStyle(
          minimumSize: const WidgetStatePropertyAll(
            Size(64, AppSpacing.primaryButtonHeight),
          ),
          shape: WidgetStatePropertyAll(buttonShape),
          textStyle: WidgetStatePropertyAll(AppTextStyles.button),
          animationDuration: AppDurations.instant,
          backgroundColor: WidgetStateProperty.resolveWith((s) {
            if (s.contains(WidgetState.disabled)) {
              return AppColors.chalk.withValues(alpha: AppOpacity.disabled);
            }
            if (s.contains(WidgetState.pressed)) return AppColors.goldPressed;
            if (s.contains(WidgetState.hovered)) return AppColors.goldLight;
            return AppColors.gold;
          }),
          foregroundColor: WidgetStateProperty.resolveWith(
            (s) => s.contains(WidgetState.disabled)
                ? AppColors.board
                : AppColors.goldInk,
          ),
          overlayColor: const WidgetStatePropertyAll(Colors.transparent),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          minimumSize: const Size(64, AppSpacing.secondaryButtonHeight),
          foregroundColor: AppColors.chalk,
          side: const BorderSide(
            color: AppColors.lineStrong,
            width: AppBorders.thin,
          ),
          textStyle: AppTextStyles.buttonSecondary,
          shape: buttonShape,
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: AppColors.chalk,
          textStyle: AppTextStyles.buttonSecondary,
          minimumSize: const Size(48, AppSpacing.secondaryButtonHeight),
          shape: buttonShape,
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.boardDeep,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.s4,
          vertical: AppSpacing.s4,
        ),
        hintStyle: AppTextStyles.input.copyWith(color: AppColors.faint),
        labelStyle: AppTextStyles.label.copyWith(color: AppColors.chalkSoft),
        floatingLabelBehavior: FloatingLabelBehavior.never,
        counterStyle: AppTextStyles.caption,
        border: _inputBorder(AppColors.line, AppBorders.thin),
        enabledBorder: _inputBorder(AppColors.line, AppBorders.thin),
        focusedBorder: _inputBorder(AppColors.gold, AppBorders.focus),
        errorBorder: _inputBorder(AppColors.wrong, AppBorders.thin),
        focusedErrorBorder: _inputBorder(AppColors.wrong, AppBorders.focus),
        errorStyle: AppTextStyles.error,
      ),
      dialogTheme: DialogThemeData(
        backgroundColor: AppColors.surfaceHigh,
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadii.xl),
        ),
        titleTextStyle: AppTextStyles.headline,
        contentTextStyle: AppTextStyles.bodySoft,
      ),
      // Toasts: a chalk pill, per the design system.
      snackBarTheme: SnackBarThemeData(
        behavior: SnackBarBehavior.floating,
        backgroundColor: AppColors.chalk,
        contentTextStyle: AppTextStyles.toast.copyWith(color: AppColors.board),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadii.full),
        ),
        elevation: 4,
      ),
      progressIndicatorTheme: const ProgressIndicatorThemeData(
        color: AppColors.gold,
        linearTrackColor: AppColors.line,
        circularTrackColor: AppColors.line,
      ),
      dividerTheme: const DividerThemeData(
        color: AppColors.line,
        thickness: AppBorders.hairline,
      ),
      iconTheme: const IconThemeData(color: AppColors.chalk),
    );
  }

  static OutlineInputBorder _inputBorder(Color color, double width) =>
      OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppRadii.md),
        borderSide: BorderSide(color: color, width: width),
      );
}
