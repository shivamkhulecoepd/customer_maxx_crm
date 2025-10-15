import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:customer_maxx_crm/utils/theme_utils.dart';

class ThemeProvider with ChangeNotifier, WidgetsBindingObserver {
  static const String _themeKey = 'theme_mode';
  static const String _systemTheme = 'system';
  static const String _lightTheme = 'light';
  static const String _darkTheme = 'dark';

  String _currentThemeMode = _systemTheme;

  ThemeProvider() {
    _loadThemeMode();
    // Listen to system theme changes
    WidgetsBinding.instance.addObserver(this);
  }

  String get currentThemeMode => _currentThemeMode;

  ThemeMode get themeMode {
    if (_currentThemeMode == _lightTheme) {
      return ThemeMode.light;
    } else if (_currentThemeMode == _darkTheme) {
      return ThemeMode.dark;
    } else {
      // For system theme, we need to check the platform brightness
      final platformBrightness = WidgetsBinding.instance.platformDispatcher.platformBrightness;
      return platformBrightness == Brightness.dark 
          ? ThemeMode.dark 
          : ThemeMode.light;
    }
  }

  bool get isDarkMode {
    if (_currentThemeMode == _lightTheme) {
      return false;
    } else if (_currentThemeMode == _darkTheme) {
      return true;
    } else {
      // For system theme, check the platform brightness
      return WidgetsBinding.instance.platformDispatcher.platformBrightness == Brightness.dark;
    }
  }

  Color getStatusColor(String status) {
    return AppThemes.getStatusColor(status);
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

  // WidgetsBindingObserver method to handle system theme changes
  @override
  void didChangePlatformBrightness() {
    // Notify listeners when system theme changes
    // This will only affect the UI if we're in system theme mode
    if (_currentThemeMode == _systemTheme) {
      notifyListeners();
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }
}