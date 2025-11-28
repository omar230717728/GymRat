import 'package:flutter/material.dart';

/// Centralized colors for all themes
/// Each theme has its own class with descriptive fields.
/// This makes it easy to switch between them in ThemeData.

/// Base abstract class
abstract class AppColors {
  Color get primary;
  Color get secondary;
  Color get background;
  Color get surface;
  Color get textPrimary;
  Color get textSecondary;
  Color get error;
}

/// 🌿 Green Light Theme Colors
class AppColorsGreen extends AppColors {
  @override
  Color get primary =>Color(0xFF29E33C);


  @override
  Color get secondary =>Color(0xFF80F988);

  @override
  Color get background =>Color(0xFF000000);

  @override
  Color get surface => Color(0xFF282A2C);

  @override
  Color get textPrimary => Colors.white;

  @override
  Color get textSecondary => Color(0xFFC5C1C1);

  @override
  Color get error => Colors.red.shade400;
}

/// 🌿 Green Dark Theme Colors


/// ❤️ Red Light Theme Colors


/// ❤️ Red Dark Theme Colors
class AppColorsRed extends AppColors {
  @override
  Color get primary => Colors.red.shade400;

  @override
  Color get secondary => Colors.red.shade700;

  @override
  Color get background => Colors.black;

  @override
  Color get surface => Colors.grey.shade900;

  @override
  Color get textPrimary => Colors.white;

  @override
  Color get textSecondary => Colors.grey.shade400;

  @override
  Color get error => Colors.red.shade300;
}
