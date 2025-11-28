import 'package:flutter/material.dart';

/// Centralized Text Styles for the whole app
/// You can later link colors dynamically from AppColors.

class AppTextStyles {
  static TextStyle headline1(Color color) => TextStyle(
        fontSize: 24,
        fontWeight: FontWeight.bold,
        color: color,
      );

  static TextStyle body(Color color) => TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.normal,
        color: color,
      );

  static TextStyle caption(Color color) => TextStyle(
        fontSize: 14,
        fontWeight: FontWeight.w300,
        color: color,
      );

  static TextStyle taskDone(Color color) => TextStyle(
        fontSize: 16,
        decoration: TextDecoration.lineThrough,
        color: color.withOpacity(0.7),
      );
}
