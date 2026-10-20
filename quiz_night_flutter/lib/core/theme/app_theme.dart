import 'package:flutter/material.dart';

import 'app_colors.dart';
import 'app_spacing.dart';
import 'app_text_styles.dart';

/// Builds the app's [ThemeData] from the colour, text and spacing tokens.
abstract final class AppTheme {
  static ThemeData dark() {
    final shape = RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(AppRadii.sm),
    );
    const minSize = Size(64, AppSpacing.buttonHeight);

    final scheme =
        ColorScheme.fromSeed(
          seedColor: AppColors.gold,
          brightness: Brightness.dark,
        ).copyWith(
          primary: AppColors.gold,
          onPrimary: AppColors.background,
          surface: AppColors.surface,
          onSurface: AppColors.text,
          error: AppColors.danger,
        );

    return ThemeData(
      colorScheme: scheme,
      scaffoldBackgroundColor: AppColors.background,
      appBarTheme: const AppBarTheme(backgroundColor: AppColors.background),
      textTheme: Typography.whiteMountainView.apply(
        bodyColor: AppColors.text,
        displayColor: AppColors.text,
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          minimumSize: minSize,
          textStyle: AppTextStyles.button,
          shape: shape,
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          minimumSize: minSize,
          foregroundColor: AppColors.text,
          side: const BorderSide(color: AppColors.muted),
          textStyle: AppTextStyles.button,
          shape: shape,
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.surface,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppRadii.sm),
          borderSide: BorderSide.none,
        ),
        labelStyle: const TextStyle(color: AppColors.muted),
      ),
    );
  }
}
