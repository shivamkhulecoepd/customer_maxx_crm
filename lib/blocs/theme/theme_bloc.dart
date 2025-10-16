import 'package:bloc/bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/material.dart';
import 'theme_event.dart';
import 'theme_state.dart';

class ThemeBloc extends Bloc<ThemeEvent, ThemeState> with WidgetsBindingObserver {
  static const String _themeKey = 'theme_mode';
  static const String _systemTheme = 'system';
  static const String _lightTheme = 'light';
  static const String _darkTheme = 'dark';

  ThemeBloc() : super(ThemeState.initial()) {
    on<LoadTheme>(_onLoadTheme);
    on<ThemeChanged>(_onThemeChanged);
    on<ToggleTheme>(_onToggleTheme);
    
    // Listen to system theme changes
    WidgetsBinding.instance.addObserver(this);
  }

  Future<void> _onLoadTheme(LoadTheme event, Emitter<ThemeState> emit) async {
    final prefs = await SharedPreferences.getInstance();
    final savedThemeMode = prefs.getString(_themeKey) ?? _systemTheme;
    
    final themeMode = _getThemeMode(savedThemeMode);
    final isDarkMode = _isDarkMode(savedThemeMode);
    
    emit(state.copyWith(
      currentThemeMode: savedThemeMode,
      themeMode: themeMode,
      isDarkMode: isDarkMode,
    ));
  }

  Future<void> _onThemeChanged(
    ThemeChanged event,
    Emitter<ThemeState> emit,
  ) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_themeKey, event.themeMode);
    
    final themeMode = _getThemeMode(event.themeMode);
    final isDarkMode = _isDarkMode(event.themeMode);
    
    emit(state.copyWith(
      currentThemeMode: event.themeMode,
      themeMode: themeMode,
      isDarkMode: isDarkMode,
    ));
  }

  Future<void> _onToggleTheme(
    ToggleTheme event,
    Emitter<ThemeState> emit,
  ) async {
    String newThemeMode;
    
    if (state.currentThemeMode == _lightTheme) {
      newThemeMode = _darkTheme;
    } else if (state.currentThemeMode == _darkTheme) {
      newThemeMode = _systemTheme;
    } else {
      newThemeMode = _lightTheme;
    }
    
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_themeKey, newThemeMode);
    
    final themeMode = _getThemeMode(newThemeMode);
    final isDarkMode = _isDarkMode(newThemeMode);
    
    emit(state.copyWith(
      currentThemeMode: newThemeMode,
      themeMode: themeMode,
      isDarkMode: isDarkMode,
    ));
  }

  ThemeMode _getThemeMode(String themeMode) {
    if (themeMode == _lightTheme) {
      return ThemeMode.light;
    } else if (themeMode == _darkTheme) {
      return ThemeMode.dark;
    } else {
      // For system theme, we need to check the platform brightness
      final platformBrightness = WidgetsBinding.instance.platformDispatcher.platformBrightness;
      return platformBrightness == Brightness.dark 
          ? ThemeMode.dark 
          : ThemeMode.light;
    }
  }

  bool _isDarkMode(String themeMode) {
    if (themeMode == _lightTheme) {
      return false;
    } else if (themeMode == _darkTheme) {
      return true;
    } else {
      // For system theme, check the platform brightness
      return WidgetsBinding.instance.platformDispatcher.platformBrightness == Brightness.dark;
    }
  }

  // WidgetsBindingObserver method to handle system theme changes
  @override
  void didChangePlatformBrightness() {
    // Notify when system theme changes
    // This will only affect the UI if we're in system theme mode
    if (state.currentThemeMode == _systemTheme) {
      final platformBrightness = WidgetsBinding.instance.platformDispatcher.platformBrightness;
      final isDarkMode = platformBrightness == Brightness.dark;
      
      add(ThemeChanged(state.currentThemeMode));
    }
  }

  @override
  Future<void> close() {
    WidgetsBinding.instance.removeObserver(this);
    return super.close();
  }
}