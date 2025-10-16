import 'package:flutter/material.dart';

class AppThemes {
  // Modern Color Palette
  static const Color primaryColor = Color(0xFF00BCD4); // Cyan/Teal
  static const Color primaryDark = Color(0xFF0097A7);
  static const Color primaryLight = Color(0xFF4DD0E1);
  
  // Status Colors
  static const Color greenAccent = Color(0xFF4CAF50); // Success
  static const Color orangeAccent = Color(0xFFFF9800); // Warning
  static const Color redAccent = Color(0xFFF44336); // Error
  static const Color blueAccent = Color(0xFF2196F3); // Info
  static const Color purpleAccent = Color(0xFF9C27B0); // Premium
  
  // Background Colors
  static const Color lightBackground = Color(0xFFF8FAFC);
  static const Color lightCardBackground = Color(0xFFFFFFFF);
  static const Color lightSurfaceBackground = Color(0xFFF1F5F9);
  static const Color darkBackground = Color(0xFF0A0A0A);
  static const Color darkCardBackground = Color(0xFF1A1A1A);
  static const Color darkSurfaceBackground = Color(0xFF2D2D2D);
  
  // Text Colors
  static const Color lightPrimaryText = Color(0xFF1A1A1A);
  static const Color lightSecondaryText = Color(0xFF64748B);
  static const Color lightTertiaryText = Color(0xFF94A3B8);
  static const Color darkPrimaryText = Color(0xFFFFFFFF);
  static const Color darkSecondaryText = Color(0xFFE2E8F0);
  static const Color darkTertiaryText = Color(0xFF94A3B8);
  
  // Border Colors
  static const Color lightBorder = Color(0xFFE2E8F0);
  static const Color darkBorder = Color(0xFF334155);
  
  // Gradient Colors
  static const List<Color> primaryGradient = [primaryColor, primaryDark];
  static const List<Color> successGradient = [Color(0xFF10B981), Color(0xFF059669)];
  static const List<Color> warningGradient = [Color(0xFFF59E0B), Color(0xFFD97706)];
  static const List<Color> errorGradient = [Color(0xFFEF4444), Color(0xFFDC2626)];

  // Light theme
  static final lightTheme = ThemeData(
    useMaterial3: true,
    brightness: Brightness.light,
    primaryColor: primaryColor,
    scaffoldBackgroundColor: lightBackground,
    fontFamily: 'Inter', // Modern font
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
    cardTheme: CardThemeData(
      color: lightCardBackground,
      elevation: 0,
      shadowColor: Colors.black.withOpacity(0.05),
      shape: RoundedRectangleBorder(
        borderRadius: const BorderRadius.all(Radius.circular(16)),
        side: BorderSide(color: lightBorder.withOpacity(0.5)),
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
    fontFamily: 'Inter', // Modern font
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
    cardTheme: CardThemeData(
      color: darkCardBackground,
      elevation: 0,
      shadowColor: Colors.black.withOpacity(0.3),
      shape: RoundedRectangleBorder(
        borderRadius: const BorderRadius.all(Radius.circular(16)),
        side: BorderSide(color: darkBorder.withOpacity(0.3)),
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
      case 'success':
        return greenAccent;
      case 'hold':
      case 'new':
      case 'pending':
      case 'warning':
        return orangeAccent;
      case 'due':
      case 'error':
      case 'failed':
      case 'rejected':
        return redAccent;
      case 'info':
      case 'in progress':
        return blueAccent;
      case 'premium':
      case 'priority':
        return purpleAccent;
      default:
        return primaryColor;
    }
  }
  
  // Modern shadows
  static List<BoxShadow> getCardShadow(bool isDarkMode) {
    return [
      BoxShadow(
        color: isDarkMode 
            ? Colors.black.withOpacity(0.3)
            : Colors.grey.withOpacity(0.1),
        blurRadius: 10,
        offset: const Offset(0, 4),
      ),
    ];
  }
  
  static List<BoxShadow> getElevatedShadow(bool isDarkMode) {
    return [
      BoxShadow(
        color: isDarkMode 
            ? Colors.black.withOpacity(0.4)
            : Colors.grey.withOpacity(0.15),
        blurRadius: 20,
        offset: const Offset(0, 8),
      ),
    ];
  }
  
  // Modern gradients
  static LinearGradient getPrimaryGradient() {
    return const LinearGradient(
      colors: primaryGradient,
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
    );
  }
  
  static LinearGradient getSuccessGradient() {
    return const LinearGradient(
      colors: successGradient,
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
    );
  }
  
  static LinearGradient getWarningGradient() {
    return const LinearGradient(
      colors: warningGradient,
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
    );
  }
  
  static LinearGradient getErrorGradient() {
    return const LinearGradient(
      colors: errorGradient,
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
    );
  }
}