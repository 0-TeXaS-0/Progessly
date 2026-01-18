import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../data/preferences/theme_preferences.dart';

class ThemeProvider with ChangeNotifier {
  ThemePreferences? _themePrefs;
  Color _themeColor = Colors.purple;
  bool _isDarkMode = true;

  Color get themeColor => _themeColor;
  bool get isDarkMode => _isDarkMode;
  String get themeColorName => _themePrefs?.getThemeColorName() ?? 'Purple';

  Future<void> loadPreferences() async {
    final prefs = await SharedPreferences.getInstance();
    _themePrefs = ThemePreferences(prefs);

    _themeColor = _themePrefs!.getThemeColor();
    _isDarkMode = _themePrefs!.getDarkMode();
    notifyListeners();
  }

  Future<void> setThemeColor(String colorName) async {
    if (_themePrefs == null) return;

    await _themePrefs!.setThemeColor(colorName);
    _themeColor = ThemePreferences.availableColors[colorName] ?? Colors.purple;
    notifyListeners();
  }

  Future<void> toggleDarkMode() async {
    if (_themePrefs == null) return;

    _isDarkMode = await _themePrefs!.toggleDarkMode();
    notifyListeners();
  }

  ThemeData getTheme() {
    return ThemeData(
      useMaterial3: true,
      brightness: _isDarkMode ? Brightness.dark : Brightness.light,
      colorScheme: ColorScheme.fromSeed(
        seedColor: _themeColor,
        brightness: _isDarkMode ? Brightness.dark : Brightness.light,
      ),
    );
  }
}
