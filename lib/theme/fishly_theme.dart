import 'package:flutter/material.dart';

class FishlyTheme {
  static const Color navy = Color(0xFF1E3651);
  static const Color text = Color(0xFF1F2937);
  static const Color muted = Color(0xFF6B7280);
  static const Color sky = Color(0xFF42A5E8);
  static const Color skyDeep = Color(0xFF2387C9);
  static const Color gold = Color(0xFFF6B325);
  static const String roundedFontFamily = 'Arial Rounded MT Bold';

  static ThemeData get themeData {
    const colorScheme = ColorScheme.light(
      primary: skyDeep,
      secondary: gold,
      surface: Colors.white,
    );

    return ThemeData(
      colorScheme: colorScheme,
      scaffoldBackgroundColor: const Color(0xFFF8FDFF),
      useMaterial3: true,
      fontFamily: roundedFontFamily,
      textTheme: const TextTheme(
        headlineLarge: TextStyle(
          fontSize: 34,
          fontWeight: FontWeight.w800,
          color: text,
          height: 1.05,
        ),
        headlineMedium: TextStyle(
          fontSize: 28,
          fontWeight: FontWeight.w800,
          color: text,
        ),
        titleMedium: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w800,
          color: text,
        ),
        bodyLarge: TextStyle(
          fontSize: 15,
          fontWeight: FontWeight.w500,
          color: text,
        ),
        bodyMedium: TextStyle(
          fontSize: 13,
          fontWeight: FontWeight.w500,
          color: muted,
        ),
        labelLarge: TextStyle(
          fontSize: 13,
          fontWeight: FontWeight.w700,
          color: text,
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: Colors.white.withValues(alpha: 0.82),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(22),
          borderSide: BorderSide(color: navy.withValues(alpha: 0.08)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(22),
          borderSide: BorderSide(color: navy.withValues(alpha: 0.08)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(22),
          borderSide: const BorderSide(color: skyDeep, width: 1.2),
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 16,
        ),
      ),
    );
  }
}
