import 'package:flutter/material.dart';

class AppTheme {
  const AppTheme._();

  static const cream = Color(0xFFF4E8D0);
  static const parchment = Color(0xFFE7D5B5);
  static const walnut = Color(0xFF6B4F36);
  static const darkBrown = Color(0xFF3B2A20);
  static const gold = Color(0xFFC59A4A);

  static ThemeData get light {
    final scheme = ColorScheme.fromSeed(
      seedColor: walnut,
      brightness: Brightness.light,
    ).copyWith(
      primary: walnut,
      secondary: gold,
      surface: cream,
      onSurface: darkBrown,
    );

    return ThemeData(
      useMaterial3: true,
      colorScheme: scheme,
      scaffoldBackgroundColor: cream,
      appBarTheme: const AppBarTheme(
        backgroundColor: darkBrown,
        foregroundColor: cream,
        elevation: 2,
        centerTitle: true,
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: Colors.white.withValues(alpha: 0.72),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: parchment),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: parchment),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: walnut, width: 2),
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: walnut,
          foregroundColor: cream,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: walnut,
          side: const BorderSide(color: walnut),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(foregroundColor: walnut),
      ),
      cardTheme: CardThemeData(
        color: Colors.white.withValues(alpha: 0.62),
        elevation: 2,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
      ),
    );
  }
}
