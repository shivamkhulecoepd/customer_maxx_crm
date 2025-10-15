import 'package:flutter/material.dart';

class AppThemes {
  // Color Palette from specification
  static const Color primaryColor = Color(0xFF00BCD4); // Cyan/Teal
  static const Color greenAccent = Color(0xFF4CAF50); // Green for positive statuses
  static const Color orangeAccent = Color(0xFFFF9800); // Orange for warnings/holds
  static const Color redAccent = Color(0xFFF44336); // Red for errors/dues
  static const Color blueAccent = Color(0xFF2196F3); // Blue for info
  static const Color lightBackground = Color(0xFFFFFFFF); // White background
  static const Color lightCardBackground = Color(0xFFF5F5F5); // Light gray for cards
  static const Color darkBackground = Color(0xFF121212); // Dark gray/black background
  static const Color darkCardBackground = Color(0xFF1E1E1E); // Slightly lighter gray for cards
  static const Color lightPrimaryText = Color(0xFF000000); // Black for primary text
  static const Color lightSecondaryText = Color(0xFF757575); // Gray for secondary text
  static const Color darkPrimaryText = Color(0xFFFFFFFF); // White for primary text
  static const Color darkSecondaryText = Color(0xFFBDBDBD); // Light gray for secondary text
  static const Color lightBorder = Color(0xFFE0E0E0); // Subtle gray for borders in light mode
  static const Color darkBorder = Color(0xFF424242); // Subtle gray for borders in dark mode

  // Light theme
  static final lightTheme = ThemeData(
    useMaterial3: true,
    brightness: Brightness.light,
    primaryColor: primaryColor,
    scaffoldBackgroundColor: lightBackground,
    fontFamily: 'Roboto', // Sans-serif font
    appBarTheme: AppBarTheme(
      backgroundColor: primaryColor,
      foregroundColor: lightBackground,
      elevation: 2,
      titleTextStyle: const TextStyle(
        color: lightBackground,
        fontSize: 20,
        fontWeight: FontWeight.bold,
      ),
      iconTheme: const IconThemeData(color: lightBackground),
    ),
    colorScheme: ColorScheme.fromSeed(
      seedColor: primaryColor,
      brightness: Brightness.light,
    ).copyWith(
      primary: primaryColor,
      secondary: primaryColor,
      surface: lightBackground,
      onSurface: lightPrimaryText,
      onPrimary: lightBackground,
      onSecondary: lightBackground,
      error: redAccent,
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: primaryColor,
        foregroundColor: lightBackground,
        textStyle: const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.bold,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(24), // Rounded buttons
        ),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        elevation: 2,
        minimumSize: const Size.fromHeight(48), // 48px height
      ),
    ),
    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(
        foregroundColor: primaryColor,
        textStyle: const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.bold,
        ),
      ),
    ),
    inputDecorationTheme: InputDecorationTheme(
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8), // 8px border radius
        borderSide: const BorderSide(color: lightBorder),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: const BorderSide(color: lightBorder),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: const BorderSide(color: primaryColor, width: 2),
      ),
      labelStyle: const TextStyle(color: lightSecondaryText),
      filled: true,
      fillColor: lightCardBackground,
    ),
    cardTheme: const CardThemeData(
      color: Color(0xFFF5F5F5),
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.all(Radius.circular(12)), // 12px rounded corners
        side: BorderSide(color: Color(0xFFE0E0E0)),
      ),
    ),
    drawerTheme: const DrawerThemeData(
      backgroundColor: lightBackground,
    ),
    textTheme: const TextTheme(
      headlineLarge: TextStyle(
        fontSize: 20,
        fontWeight: FontWeight.bold,
        color: lightPrimaryText,
      ),
      headlineMedium: TextStyle(
        fontSize: 18,
        fontWeight: FontWeight.bold,
        color: lightPrimaryText,
      ),
      headlineSmall: TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.bold,
        color: lightPrimaryText,
      ),
      bodyLarge: TextStyle(
        fontSize: 14,
        color: lightPrimaryText,
      ),
      bodyMedium: TextStyle(
        fontSize: 14,
        color: lightSecondaryText,
      ),
      bodySmall: TextStyle(
        fontSize: 12,
        color: lightSecondaryText,
      ),
      labelLarge: TextStyle(
        fontSize: 12,
        color: lightPrimaryText,
      ),
      labelMedium: TextStyle(
        fontSize: 10,
        color: lightSecondaryText,
      ),
    ),
    dividerTheme: const DividerThemeData(
      color: lightBorder,
      thickness: 1,
    ),
    iconTheme: const IconThemeData(
      color: lightPrimaryText,
      size: 24,
    ),
    floatingActionButtonTheme: FloatingActionButtonThemeData(
      backgroundColor: primaryColor,
      foregroundColor: lightBackground,
      elevation: 6,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(28),
      ),
    ),
  );

  // Dark theme
  static final darkTheme = ThemeData(
    useMaterial3: true,
    brightness: Brightness.dark,
    primaryColor: primaryColor,
    scaffoldBackgroundColor: darkBackground,
    fontFamily: 'Roboto', // Sans-serif font
    appBarTheme: AppBarTheme(
      backgroundColor: primaryColor,
      foregroundColor: darkBackground,
      elevation: 2,
      titleTextStyle: const TextStyle(
        color: darkBackground,
        fontSize: 20,
        fontWeight: FontWeight.bold,
      ),
      iconTheme: const IconThemeData(color: darkBackground),
    ),
    colorScheme: ColorScheme.fromSeed(
      seedColor: primaryColor,
      brightness: Brightness.dark,
    ).copyWith(
      primary: primaryColor,
      secondary: primaryColor,
      surface: darkBackground,
      onSurface: darkPrimaryText,
      onPrimary: darkBackground,
      onSecondary: darkBackground,
      error: redAccent,
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: primaryColor,
        foregroundColor: darkBackground,
        textStyle: const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.bold,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(24), // Rounded buttons
        ),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        elevation: 2,
        minimumSize: const Size.fromHeight(48), // 48px height
      ),
    ),
    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(
        foregroundColor: primaryColor,
        textStyle: const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.bold,
        ),
      ),
    ),
    inputDecorationTheme: InputDecorationTheme(
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8), // 8px border radius
        borderSide: const BorderSide(color: darkBorder),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: const BorderSide(color: darkBorder),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: const BorderSide(color: primaryColor, width: 2),
      ),
      labelStyle: const TextStyle(color: darkSecondaryText),
      filled: true,
      fillColor: darkCardBackground,
    ),
    cardTheme: const CardThemeData(
      color: Color(0xFF1E1E1E),
      elevation: 4, // Deeper shadows in dark mode
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.all(Radius.circular(12)), // 12px rounded corners
        side: BorderSide(color: Color(0xFF424242)),
      ),
    ),
    drawerTheme: const DrawerThemeData(
      backgroundColor: darkBackground,
    ),
    textTheme: const TextTheme(
      headlineLarge: TextStyle(
        fontSize: 20,
        fontWeight: FontWeight.bold,
        color: darkPrimaryText,
      ),
      headlineMedium: TextStyle(
        fontSize: 18,
        fontWeight: FontWeight.bold,
        color: darkPrimaryText,
      ),
      headlineSmall: TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.bold,
        color: darkPrimaryText,
      ),
      bodyLarge: TextStyle(
        fontSize: 14,
        color: darkPrimaryText,
      ),
      bodyMedium: TextStyle(
        fontSize: 14,
        color: darkSecondaryText,
      ),
      bodySmall: TextStyle(
        fontSize: 12,
        color: darkSecondaryText,
      ),
      labelLarge: TextStyle(
        fontSize: 12,
        color: darkPrimaryText,
      ),
      labelMedium: TextStyle(
        fontSize: 10,
        color: darkSecondaryText,
      ),
    ),
    dividerTheme: const DividerThemeData(
      color: darkBorder,
      thickness: 1,
    ),
    iconTheme: const IconThemeData(
      color: darkPrimaryText,
      size: 24,
    ),
    floatingActionButtonTheme: FloatingActionButtonThemeData(
      backgroundColor: primaryColor,
      foregroundColor: darkBackground,
      elevation: 6,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(28),
      ),
    ),
  );

  // Status badge colors
  static Color getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'completed':
      case 'client replied':
      case 'accepted':
        return greenAccent;
      case 'hold':
      case 'new':
        return orangeAccent;
      case 'due':
      case 'error':
        return redAccent;
      default:
        return primaryColor;
    }
  }
}