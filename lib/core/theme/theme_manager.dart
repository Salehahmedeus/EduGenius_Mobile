import 'package:flutter/material.dart';

class ThemeManager extends ValueNotifier<ThemeMode> {
  ThemeManager() : super(ThemeMode.system);

  bool get isDarkMode => value == ThemeMode.dark;

  void toggleTheme() {
    value = value == ThemeMode.light ? ThemeMode.dark : ThemeMode.light;
  }

  void setTheme(ThemeMode mode) {
    value = mode;
  }
}

// Global instance for simple access
final themeManager = ThemeManager();
