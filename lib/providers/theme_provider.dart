import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ThemeProvider with ChangeNotifier {
  static const String _themeKey = 'theme_mode';
  static const String _systemTheme = 'system';
  static const String _lightTheme = 'light';
  static const String _darkTheme = 'dark';

  String _currentThemeMode = _systemTheme;

  ThemeProvider() {
    _loadThemeMode();
  }

  String get currentThemeMode => _currentThemeMode;

  ThemeMode get themeMode {
    if (_currentThemeMode == _lightTheme) {
      return ThemeMode.light;
    } else if (_currentThemeMode == _darkTheme) {
      return ThemeMode.dark;
    } else {
      return ThemeMode.system;
    }
  }

  Future<void> _loadThemeMode() async {
    final prefs = await SharedPreferences.getInstance();
    _currentThemeMode = prefs.getString(_themeKey) ?? _systemTheme;
    notifyListeners();
  }

  Future<void> _saveThemeMode() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_themeKey, _currentThemeMode);
  }

  Future<void> setThemeMode(String themeMode) async {
    _currentThemeMode = themeMode;
    await _saveThemeMode();
    notifyListeners();
  }

  Future<void> toggleTheme() async {
    if (_currentThemeMode == _lightTheme) {
      await setThemeMode(_darkTheme);
    } else if (_currentThemeMode == _darkTheme) {
      await setThemeMode(_systemTheme);
    } else {
      await setThemeMode(_lightTheme);
    }
  }
}