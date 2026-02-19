import 'package:flutter/material.dart';
import 'package:hrm/core/constants/color_constants.dart';
import 'package:hrm/core/constants/constants.dart';

class AppTheme {
  static Map<String, Color> get lightColors => Constants.color.lightColors;
  static Map<String, Color> get darkcolors => Constants.color.darkColors;


  static const Map<String, List<BoxShadow>> shadows = {
    'sm': [
      BoxShadow(
        color: Color(0x1A1C1C33),
        offset: Offset(0, 2),
        blurRadius: 4,
        spreadRadius: 0,
      ),
    ],
    'md': [
      BoxShadow(
        color: Color(0x1A1C1C33),
        offset: Offset(0, 4),
        blurRadius: 8,
        spreadRadius: -1,
      ),
      BoxShadow(
        color: Color(0x1A1C1C33),
        offset: Offset(0, 2),
        blurRadius: 4,
        spreadRadius: -1,
      ),
    ],
    'lg': [
      BoxShadow(
        color: Color(0x1A1C1C33),
        offset: Offset(0, 10),
        blurRadius: 20,
        spreadRadius: -3,
      ),
      BoxShadow(
        color: Color(0x1A1C1C33),
        offset: Offset(0, 4),
        blurRadius: 6,
        spreadRadius: -2,
      ),
    ],
    'xl': [
      BoxShadow(
        color: Color(0x1A1C1C33),
        offset: Offset(0, 20),
        blurRadius: 25,
        spreadRadius: -5,
      ),
      BoxShadow(
        color: Color(0x1A1C1C33),
        offset: Offset(0, 10),
        blurRadius: 10,
        spreadRadius: -5,
      ),
    ],
  };

  static const Map<String, List<BoxShadow>> darkShadows = {
    'sm': [
      BoxShadow(
        color: Color(0x4D000000),
        offset: Offset(0, 2),
        blurRadius: 4,
        spreadRadius: 0,
      ),
    ],
    'md': [
      BoxShadow(
        color: Color(0x4D000000),
        offset: Offset(0, 4),
        blurRadius: 8,
        spreadRadius: -1,
      ),
      BoxShadow(
        color: Color(0x4D000000),
        offset: Offset(0, 2),
        blurRadius: 4,
        spreadRadius: -1,
      ),
    ],
    'lg': [
      BoxShadow(
        color: Color(0x4D000000),
        offset: Offset(0, 10),
        blurRadius: 20,
        spreadRadius: -3,
      ),
      BoxShadow(
        color: Color(0x4D000000),
        offset: Offset(0, 4),
        blurRadius: 6,
        spreadRadius: -2,
      ),
    ],
    'xl': [
      BoxShadow(
        color: Color(0x4D000000),
        offset: Offset(0, 20),
        blurRadius: 25,
        spreadRadius: -5,
      ),
      BoxShadow(
        color: Color(0x4D000000),
        offset: Offset(0, 10),
        blurRadius: 10,
        spreadRadius: -5,
      ),
    ],
  };

  static const Map<String, double> radius = {
    'sm': 8.0,
    'md': 12.0,
    'lg': 16.0,
    'xl': 20.0,
    'full': 50.0,
  };

  static const Map<String, double> dimensions = {
    'sidebarWidth': 260.0,
    'sidebarWidthCollapsed': 70.0,
    'headerHeight': 80.0,
  };

  // Animation Duration
  static const Duration transitionDuration = Duration(milliseconds: 300);
  static const Curve transitionCurve = Curves.easeInOut;

  static final Map<String, LinearGradient> gradients = {
    'sidebar': const LinearGradient(
      begin: Alignment.topCenter,
      end: Alignment.bottomCenter,
      colors: [Color(0xFF1A1A2E), Color(0xFF16213E)],
    ),
    'sidebarDark': const LinearGradient(
      begin: Alignment.topCenter,
      end: Alignment.bottomCenter,
      colors: [Color(0xFF0F172A), Color(0xFF0C1425)],
    ),
  };

  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      primaryColor: lightColors['primary'],
      scaffoldBackgroundColor: lightColors['light'],
      cardColor: lightColors['cardBg'],
      
      colorScheme: ColorScheme.light(
        primary: lightColors['primary']!,
        secondary: lightColors['secondary']!,
        surface: Colors.white,
        error: lightColors['danger']!,
        onPrimary: Colors.white,
        onSecondary: Colors.white,
        onSurface: lightColors['dark']!,
        onError: Colors.white,
      ),

      appBarTheme: AppBarTheme(
        backgroundColor: Colors.white,
        foregroundColor: lightColors['dark'],
        elevation: 0,
        centerTitle: false,
        titleTextStyle: TextStyle(
          color: lightColors['dark'],
          fontSize: 20,
          fontWeight: FontWeight.w600,
        ),
      ),

      // cardTheme: CardTheme(
      //   color: lightColors['cardBg'],
      //   elevation: 0,
      //   shape: RoundedRectangleBorder(
      //     borderRadius: BorderRadius.circular(radius['md']!),
      //   ),
      //   shadowColor: const Color(0x1A1C1C33),
      // ),

      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: lightColors['primary'],
          foregroundColor: Colors.white,
          elevation: 0,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(radius['md']!),
          ),
        ),
      ),

      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: lightColors['light'],
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(radius['md']!),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(radius['md']!),
          borderSide: BorderSide(color: lightColors['grayLight']!),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(radius['md']!),
          borderSide: BorderSide(color: lightColors['primary']!, width: 2),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      ),

      textTheme: TextTheme(
        displayLarge: TextStyle(
          fontSize: 32,
          fontWeight: FontWeight.bold,
          color: lightColors['dark'],
        ),
        displayMedium: TextStyle(
          fontSize: 28,
          fontWeight: FontWeight.bold,
          color: lightColors['dark'],
        ),
        displaySmall: TextStyle(
          fontSize: 24,
          fontWeight: FontWeight.w600,
          color: lightColors['dark'],
        ),
        headlineMedium: TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.w600,
          color: lightColors['dark'],
        ),
        bodyLarge: TextStyle(
          fontSize: 16,
          color: lightColors['dark'],
        ),
        bodyMedium: TextStyle(
          fontSize: 14,
          color: lightColors['gray'],
        ),
      ),

      iconTheme: IconThemeData(
        color: lightColors['dark'],
        size: 24,
      ),
    );
  }

  static ThemeData get darkTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      primaryColor:Constants.color.darkColors['primary'],
      scaffoldBackgroundColor: Constants.color.darkColors['light'],
      cardColor: Constants.color.darkColors['cardBg'],
      
      colorScheme: ColorScheme.dark(
        primary: Constants.color.darkColors['primary']!,
        secondary: Constants.color.darkColors['secondary']!,
        surface: Constants.color.darkColors['white']!,
        error: Constants.color.darkColors['danger']!,
        onPrimary: Constants.color.darkColors['white']!,
        onSecondary: Constants.color.darkColors['white']!,
        onSurface: Constants.color.darkColors['dark']!,
        onError: Constants.color.darkColors['white']!,
      ),

      appBarTheme: AppBarTheme(
        backgroundColor: Constants.color.darkColors['headerBg'],
        foregroundColor: Constants.color.darkColors['dark'],
        elevation: 0,
        centerTitle: false,
        titleTextStyle: TextStyle(
          color: Constants.color.darkColors['dark'],
          fontSize: 20,
          fontWeight: FontWeight.w600,
        ),
      ),

  

      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: Constants.color.darkColors['primary'],
          foregroundColor: Constants.color.darkColors['white'],
          elevation: 0,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(radius['md']!),
          ),
        ),
      ),

      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: Constants.color.darkColors['grayLight'],
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(radius['md']!),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(radius['md']!),
          borderSide: BorderSide(color: Constants.color.darkColors['grayLight']!),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(radius['md']!),
          borderSide: BorderSide(color: Constants.color.darkColors['primary']!, width: 2),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      ),

      textTheme: TextTheme(
        displayLarge: TextStyle(
          fontSize: 32,
          fontWeight: FontWeight.bold,
          color: Constants.color.darkColors['dark'],
        ),
        displayMedium: TextStyle(
          fontSize: 28,
          fontWeight: FontWeight.bold,
          color: Constants.color.darkColors['dark'],
        ),
        displaySmall: TextStyle(
          fontSize: 24,
          fontWeight: FontWeight.w600,
          color: Constants.color.darkColors['dark'],
        ),
        headlineMedium: TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.w600,
          color: Constants.color.darkColors['dark'],
        ),
        bodyLarge: TextStyle(
          fontSize: 16,
          color: Constants.color.darkColors['dark'],
        ),
        bodyMedium: TextStyle(
          fontSize: 14,
          color: Constants.color.darkColors['gray'],
        ),
      ),

      iconTheme: IconThemeData(
        color: Constants.color.darkColors['dark'],
        size: 24,
      ),
    );
  }

  // Helper method to get color by name
  static Color getColor(String name, {bool isDark = false}) {
    final colors = isDark ? Constants.color.darkColors : lightColors;
    return colors[name] ?? lightColors['primary']!;
  }

  // Helper method to get shadow by name
  static List<BoxShadow> getShadow(String name, {bool isDark = false}) {
    final shadowMap = isDark ? darkShadows : shadows;
    return shadowMap[name] ?? shadows['md']!;
  }

  // Helper method to get radius by name
  static double getRadius(String name) {
    return radius[name] ?? radius['md']!;
  }

  // Helper method to get dimension by name
  static double getDimension(String name) {
    return dimensions[name] ?? 0.0;
  }
}