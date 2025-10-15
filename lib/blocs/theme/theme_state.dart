import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';

class ThemeState extends Equatable {
  final String currentThemeMode;
  final ThemeMode? themeMode;
  final bool isDarkMode;

  const ThemeState({
    required this.currentThemeMode,
    this.themeMode,
    required this.isDarkMode,
  });

  factory ThemeState.initial() {
    final platformBrightness = WidgetsBinding.instance.platformDispatcher.platformBrightness;
    return ThemeState(
      currentThemeMode: 'system',
      themeMode: platformBrightness == Brightness.dark 
          ? ThemeMode.dark 
          : ThemeMode.light,
      isDarkMode: platformBrightness == Brightness.dark,
    );
  }

  ThemeState copyWith({
    String? currentThemeMode,
    ThemeMode? themeMode,
    bool? isDarkMode,
  }) {
    return ThemeState(
      currentThemeMode: currentThemeMode ?? this.currentThemeMode,
      themeMode: themeMode ?? this.themeMode,
      isDarkMode: isDarkMode ?? this.isDarkMode,
    );
  }

  @override
  List<Object?> get props => [currentThemeMode, themeMode, isDarkMode];
}