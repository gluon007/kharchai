import 'package:flutter/material.dart';

class AppTheme {
  static const Color primaryColor = Color(0xFF5E35B1);
  static const Color accentColor = Color(0xFF03DAC5);
  static const Color errorColor = Color(0xFFB00020);
  
  // Light theme
  static final ThemeData lightTheme = ThemeData(
    primaryColor: primaryColor,
    scaffoldBackgroundColor: Colors.white,
    appBarTheme: AppBarTheme(
      color: primaryColor,
      elevation: 0,
      iconTheme: const IconThemeData(color: Colors.white),
      titleTextStyle: const TextStyle(
        color: Colors.white,
        fontSize: 20,
        fontWeight: FontWeight.bold,
      ),
    ),
    colorScheme: ColorScheme.light(
      primary: primaryColor,
      secondary: accentColor,
      error: errorColor,
    ),
    buttonTheme: ButtonThemeData(
      buttonColor: primaryColor,
      textTheme: ButtonTextTheme.primary,
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        foregroundColor: Colors.white,
        backgroundColor: primaryColor,
        elevation: 2,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
      ),
    ),
    inputDecorationTheme: InputDecorationTheme(
      fillColor: Colors.grey[100],
      filled: true,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: BorderSide.none,
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: BorderSide(color: primaryColor),
      ),
    ),
    textTheme: const TextTheme(
      displayLarge: TextStyle(color: Colors.black87, fontWeight: FontWeight.bold),
      displayMedium: TextStyle(color: Colors.black87, fontWeight: FontWeight.bold),
      displaySmall: TextStyle(color: Colors.black87, fontWeight: FontWeight.bold),
      headlineMedium: TextStyle(color: Colors.black87, fontWeight: FontWeight.w600),
      headlineSmall: TextStyle(color: Colors.black87, fontWeight: FontWeight.w600),
      titleLarge: TextStyle(color: Colors.black87, fontWeight: FontWeight.w600),
      bodyLarge: TextStyle(color: Colors.black87),
      bodyMedium: TextStyle(color: Colors.black87),
    ),
  );

  // Dark theme
  static final ThemeData darkTheme = ThemeData(
    primaryColor: primaryColor,
    scaffoldBackgroundColor: const Color(0xFF121212),
    appBarTheme: const AppBarTheme(
      color: Color(0xFF1F1F1F),
      elevation: 0,
      iconTheme: IconThemeData(color: Colors.white),
      titleTextStyle: TextStyle(
        color: Colors.white,
        fontSize: 20,
        fontWeight: FontWeight.bold,
      ),
    ),
    colorScheme: ColorScheme.dark(
      primary: primaryColor,
      secondary: accentColor,
      error: errorColor,
      surface: const Color(0xFF1F1F1F),
    ),
    cardColor: const Color(0xFF1F1F1F),
    dividerColor: Colors.white12,
    buttonTheme: ButtonThemeData(
      buttonColor: primaryColor,
      textTheme: ButtonTextTheme.primary,
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        foregroundColor: Colors.white,
        backgroundColor: primaryColor,
        elevation: 2,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
      ),
    ),
    inputDecorationTheme: InputDecorationTheme(
      fillColor: const Color(0xFF2A2A2A),
      filled: true,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: BorderSide.none,
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: BorderSide(color: primaryColor),
      ),
      hintStyle: const TextStyle(color: Colors.white70),
    ),
    textTheme: const TextTheme(
      displayLarge: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
      displayMedium: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
      displaySmall: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
      headlineMedium: TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
      headlineSmall: TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
      titleLarge: TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
      bodyLarge: TextStyle(color: Colors.white),
      bodyMedium: TextStyle(color: Colors.white),
    ),
  );
} 