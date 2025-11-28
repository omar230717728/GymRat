import 'package:flutter/material.dart';
import '../shared/app_colors.dart';
import '../shared/app_text_styles.dart';

/// Enum for available themes
enum AppTheme {
  green,
  red,
}

/// ThemeManager: returns ThemeData for each theme
class ThemeManager {
  static ThemeData getTheme(AppTheme theme) {
    switch (theme) {
      case AppTheme.green:
        return _buildTheme(AppColorsGreen());
      case AppTheme.red:
        return _buildTheme(AppColorsRed());  
    }
  }

  /// Build ThemeData dynamically from AppColors
  static ThemeData _buildTheme(AppColors colors) {
    final base = ThemeData();

    return base.copyWith(
      scaffoldBackgroundColor: colors.background,

      appBarTheme: AppBarTheme(
        
        titleTextStyle: AppTextStyles.headline1(colors.textPrimary),
        iconTheme: IconThemeData(color: colors.textPrimary),
        elevation: 2,
      ),

      textTheme: TextTheme(
        bodyLarge: AppTextStyles.body(colors.textPrimary),
        bodyMedium: AppTextStyles.caption(colors.textSecondary),
      ),

      floatingActionButtonTheme: FloatingActionButtonThemeData(
        backgroundColor: colors.primary,
        foregroundColor: colors.textPrimary,
      ),

      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: colors.primary,
          foregroundColor: colors.textPrimary,
          textStyle: AppTextStyles.body(colors.textPrimary),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),

      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: colors.primary,
          side: BorderSide(color: colors.primary, width: 1.5),
          textStyle: AppTextStyles.body(colors.primary),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),

      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: colors.surface,
        contentPadding: const EdgeInsets.symmetric(
          vertical: 12,
          horizontal: 16,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: colors.secondary, width: 1.5),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: colors.primary, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: colors.error, width: 1.5),
        ),
        hintStyle: AppTextStyles.caption(colors.textSecondary),
        labelStyle: AppTextStyles.body(colors.textPrimary),
      ),

      iconTheme: IconThemeData(color: colors.primary),
      colorScheme: ColorScheme(
        brightness: colors.background == Colors.black
            ? Brightness.dark
            : Brightness.light,
        primary: colors.primary,
        onPrimary: colors.textPrimary,
        secondary: colors.secondary,
        onSecondary: colors.textPrimary,
        error: colors.error,
        onError: colors.textPrimary,
        background: colors.background,
        onBackground: colors.textPrimary,
        surface: colors.surface,
        onSurface: colors.textPrimary,
      ),
    );
  }
}
