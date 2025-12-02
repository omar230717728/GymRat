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

/// 🌿 Green Theme Colors
class AppColorsGreen extends AppColors {
  @override
  Color get primary => const Color(0xFF29E33C);
  @override
  Color get secondary => const Color(0xFF80F988);
  @override
  Color get background => const Color(0xFF000000);
  @override
  Color get surface => const Color(0xFF282A2C);
  @override
  Color get textPrimary => Colors.white;
  @override
  Color get textSecondary => const Color(0xFFC5C1C1);
  @override
  Color get error => Colors.red.shade400;
}

/// ❤️ Red Theme Colors
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

/// 💙 Blue Theme Colors
class AppColorsBlue extends AppColors {
  @override
  Color get primary => Colors.blueAccent;
  @override
  Color get secondary => Colors.blue.shade700;
  @override
  Color get background => const Color(0xFF050A19);
  @override
  Color get surface => const Color(0xFF101828);
  @override
  Color get textPrimary => Colors.white;
  @override
  Color get textSecondary => Colors.blueGrey.shade200;
  @override
  Color get error => Colors.redAccent;
}

/// 💜 Purple Theme Colors
class AppColorsPurple extends AppColors {
  @override
  Color get primary => Colors.purpleAccent;
  @override
  Color get secondary => Colors.deepPurple;
  @override
  Color get background => const Color(0xFF0F0518);
  @override
  Color get surface => const Color(0xFF1D1028);
  @override
  Color get textPrimary => Colors.white;
  @override
  Color get textSecondary => Colors.purple.shade100;
  @override
  Color get error => Colors.redAccent;
}

/// 🧡 Orange Theme Colors
class AppColorsOrange extends AppColors {
  @override
  Color get primary => Colors.orangeAccent;
  @override
  Color get secondary => Colors.deepOrange;
  @override
  Color get background => Colors.black;
  @override
  Color get surface => const Color(0xFF1F1F1F);
  @override
  Color get textPrimary => Colors.white;
  @override
  Color get textSecondary => Colors.grey.shade400;
  @override
  Color get error => Colors.redAccent;
}

/// 🌃 Dark Neon Theme Colors
class AppColorsDarkNeon extends AppColors {
  @override
  Color get primary => const Color(0xFF00FFEA); // Cyan Neon
  @override
  Color get secondary => const Color(0xFFFF00FF); // Magenta Neon
  @override
  Color get background => const Color(0xFF050505);
  @override
  Color get surface => const Color(0xFF121212);
  @override
  Color get textPrimary => Colors.white;
  @override
  Color get textSecondary => Colors.grey.shade300;
  @override
  Color get error => const Color(0xFFFF3333);
}
