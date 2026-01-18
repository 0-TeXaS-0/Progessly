import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ThemePreferences {
  static const String _themeColorKey = 'theme_color';
  static const String _darkModeKey = 'dark_mode';

  final SharedPreferences _prefs;

  ThemePreferences(this._prefs);

  // Available theme colors
  static const Map<String, Color> availableColors = {
    'Purple': Colors.purple,
    'Blue': Colors.blue,
    'Green': Colors.green,
    'Orange': Colors.orange,
    'Pink': Colors.pink,
    'Teal': Colors.teal,
    'Red': Colors.red,
    'Indigo': Colors.indigo,
  };

  // Get current theme color
  Color getThemeColor() {
    final colorName = _prefs.getString(_themeColorKey) ?? 'Purple';
    return availableColors[colorName] ?? Colors.purple;
  }

  // Get current theme color name
  String getThemeColorName() {
    return _prefs.getString(_themeColorKey) ?? 'Purple';
  }

  // Set theme color
  Future<void> setThemeColor(String colorName) async {
    await _prefs.setString(_themeColorKey, colorName);
  }

  // Get dark mode preference
  bool getDarkMode() {
    return _prefs.getBool(_darkModeKey) ?? true; // Default to dark mode
  }

  // Set dark mode preference
  Future<void> setDarkMode(bool isDark) async {
    await _prefs.setBool(_darkModeKey, isDark);
  }

  // Toggle dark mode
  Future<bool> toggleDarkMode() async {
    final currentMode = getDarkMode();
    await setDarkMode(!currentMode);
    return !currentMode;
  }
}
