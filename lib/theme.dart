import 'package:flutter/material.dart';

/// Warm & gentle theme for kids — soft colours, rounded shapes, large text.
class AppTheme {
  static const Color primary = Color(0xFF5B8C5A);      // Soft green
  static const Color secondary = Color(0xFFE8A87C);    // Warm peach
  static const Color accent = Color(0xFF41B3A3);       // Teal
  static const Color background = Color(0xFFFFF8F0);   // Warm cream
  static const Color surface = Colors.white;
  static const Color textDark = Color(0xFF3D3D3D);
  static const Color textLight = Color(0xFF7A7A7A);
  static const Color correct = Color(0xFF5B8C5A);
  static const Color incorrect = Color(0xFFE07A5F);
  static const Color starGold = Color(0xFFFFD166);

  static ThemeData get theme => ThemeData(
    useMaterial3: true,
    colorScheme: ColorScheme.fromSeed(
      seedColor: primary,
      surface: background,
    ),
    scaffoldBackgroundColor: background,
    fontFamily: 'Nunito',
    textTheme: const TextTheme(
      headlineLarge: TextStyle(
        fontSize: 36,
        fontWeight: FontWeight.w800,
        color: textDark,
      ),
      headlineMedium: TextStyle(
        fontSize: 28,
        fontWeight: FontWeight.w700,
        color: textDark,
      ),
      titleLarge: TextStyle(
        fontSize: 22,
        fontWeight: FontWeight.w600,
        color: textDark,
      ),
      bodyLarge: TextStyle(
        fontSize: 20,
        fontWeight: FontWeight.w400,
        color: textDark,
      ),
      bodyMedium: TextStyle(
        fontSize: 16,
        color: textLight,
      ),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: primary,
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        textStyle: const TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.w600,
        ),
      ),
    ),
    cardTheme: CardThemeData(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      color: surface,
    ),
  );
}
