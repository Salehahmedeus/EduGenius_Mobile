import 'package:flutter/material.dart';

class AppColors {
  // Primary colors
  static const Color primary = Color(0xFFD32F2F);
  static const Color primaryLight = Color(0xFFFFEBEE);
  static const Color primaryMedium = Color(0xFFFFCDD2);

  // Neutral colors
  static const Color white = Colors.white;
  static const Color black = Colors.black;
  static const Color grey = Color(0xFF9E9E9E);
  static const Color lightGrey = Color(0xFFF5F5F5);

  // Semantic colors
  static const Color success = Color(0xFF4CAF50);
  static const Color error = Color(0xFFD32F2F);
  static const Color info = Color(0xFF2196F3);
  static const Color warning = Color(0xFFFFC107);

  // Background colors
  static const Color background = Colors.white;
  static const Color lightBackground = Color(0xFFF9FAFB);
  static const Color textFieldFill = Color(0xFFF5F5F5);

  // Dark Theme / Settings Redesign
  static const Color darkBackground = Color(0xFF131315); // Deep dark
  static const Color darkSurface = Color(0xFF1D1D21); // Group container
  static const Color darkItem = Color(0xFF2C2C2E); // Item tile
  static const Color darkTextPrimary = Colors.white;
  static const Color darkTextSecondary = Color(0xFFACACAE);
  static const Color darkBorder = Color(0xFF2C2C2E);

  // Helper method to get theme colors (optional but useful)
  static bool isDark(BuildContext context) =>
      Theme.of(context).brightness == Brightness.dark;
}
