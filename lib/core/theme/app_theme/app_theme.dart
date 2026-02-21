import 'package:flutter/material.dart';
import 'package:hrm/core/theme/app_theme/app_theme_colors.dart';

class AppTheme {
  AppTheme._();

  static const AppThemeColors _lightColors = AppThemeColors(
    primary: Color(0xFF667EEA),
    secondary: Color(0xFF764BA2),
    background: Color(0xFFF8F9FC),
    cardBg: Colors.white,
    textPrimary: Color(0xFF1C1C1C),
    textSecondary: Color(0xFF6C757D),
    border: Color(0xFFE0E0E0),
    danger: Color(0xFFEF476F),
    white: Colors.white,
    headerBg: Colors.white,
  );

  static const AppThemeColors _darkColors = AppThemeColors(
    primary: Color(0xFF667EEA),
    secondary: Color(0xFF764BA2),
    background: Color(0xFF121212),
    cardBg: Color(0xFF1E1E1E),
    textPrimary: Colors.white,
    textSecondary: Color(0xFFB0B0B0),
    border: Color(0xFF2C2C2C),
    danger: Color(0xFFEF476F),
    white: Colors.white,
    headerBg: Color(0xFF1A1A1A),
  );

  static ThemeData get lightTheme {
    final c = _lightColors;

    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      scaffoldBackgroundColor: c.background,
      primaryColor: c.primary,
      cardColor: c.cardBg,

      colorScheme: ColorScheme.light(
        primary: c.primary,
        secondary: c.secondary,
        error: c.danger,
        onPrimary: Colors.white,
        onSurface: c.textPrimary,
      ),

      appBarTheme: AppBarTheme(
        backgroundColor: c.headerBg,
        foregroundColor: c.textPrimary,
        elevation: 0,
      ),

      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: c.cardBg,
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: c.border),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: c.primary, width: 2),
        ),
      ),

      textTheme: TextTheme(
        bodyLarge: TextStyle(color: c.textPrimary),
        bodyMedium: TextStyle(color: c.textSecondary),
      ),
    );
  }

  static ThemeData get darktheme {
    final c = _darkColors;

    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      scaffoldBackgroundColor: c.background,
      primaryColor: c.primary,
      cardColor: c.cardBg,

      colorScheme: ColorScheme.light(
        primary: c.primary,
        secondary: c.secondary,
        error: c.danger,
        onPrimary: Colors.white,
        onSurface: c.textPrimary,
      ),

      appBarTheme: AppBarTheme(
        backgroundColor: c.headerBg,
        foregroundColor: c.textPrimary,
        elevation: 0,
      ),

      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: c.cardBg,
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: c.border),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: c.primary, width: 2),
        ),
      ),

      textTheme: TextTheme(
        bodyLarge: TextStyle(color: c.textPrimary),
        bodyMedium: TextStyle(color: c.textSecondary),
      ),
    );
  }
}
