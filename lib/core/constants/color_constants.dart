import 'dart:ui';

import 'package:flutter/material.dart';

class COLORCONSTANTS {
  COLORCONSTANTS();


  final Map<String, Color> lightColors = {
    'primary': const Color(0xFF4361EE),
    'primaryDark': const Color(0xFF3A56D4),
    'primaryLight': const Color(0xFF4895EF),
    'secondary': const Color(0xFF7209B7),
    'accent': const Color(0xFF4CC9F0),
    'success': const Color(0xFF06D6A0),
    'warning': const Color(0xFFFFD166),
    'danger': const Color(0xFFEF476F),
    'dark': const Color(0xFF1A1A2E),
    'darkLight': const Color(0xFF2D3047),
    'light': const Color(0xFFF8F9FA),
    'gray': const Color(0xFF6C757D),
    'grayLight': const Color(0xFFE9ECEF),
    'white': const Color(0xFFFFFFFF),
    'cardBg': const Color(0xFFFFFFFF),
    'headerBg': const Color(0xFFFFFFFF),
  };

  final Map<String, Color> darkColors = {
    'primary': const Color(0xFF5A6FF0),
    'primaryDark': const Color(0xFF4361EE),
    'primaryLight': const Color(0xFF6A8AF9),
    'secondary': const Color(0xFF8A2BE2),
    'accent': const Color(0xFF5DD5FC),
    'success': const Color(0xFF10E8B5),
    'warning': const Color(0xFFFFDE7D),
    'danger': const Color(0xFFFF6B93),
    'dark': const Color(0xFFF1F3F9),
    'darkLight': const Color(0xFFD1D5E3),
    'light': const Color(0xFF121826),
    'gray': const Color(0xFF94A3B8),
    'grayLight': const Color(0xFF1E293B),
    'white': const Color(0xFF0F172A),
    'cardBg': const Color(0xFF1E293B),
    'headerBg': const Color(0xFF1E293B),
  };


  final presentColor = Color(0xFF4CAF50);
  final absentColor = Color(0xFFEF5350);
  final halfDayColor = Color(0xFFFF9800);
  final leaveColor = Color(0xFF42A5F5);
  final lateColor = Color(0xFFFFC107);
  final inprogressColor = Color(0xFF667EEA);
  final pendingColor = Color(0xFF6304F1);

  final todayColor = Color(0xFFFF0000);
  final selectedBorderColor = Color(0xFF667EEA);
  final inactiveDayColor = Color(0xFFBDBDBD);
  final weekendColor = Color(0xFFFF0000);

  final currentMonthBg = Color(0xFFF0F4FF); 
  final otherMonthBg = Colors.white;
  final cardBorderColor = Color(0xFFE0E0E0);
  final gridColor = Color(0xFFE8E8E8);

  final textPrimary = Color(0xFF000000);
  final textSecondary = Color(0xFF757575);
  final textTertiary = Color(0xFF9E9E9E);
  final textWeekend = Color(0xFFFF0000);
  final double spacingXs = 4.0;
  final double spacingS = 8.0;
  final double spacingM = 12.0;
  final double spacingL = 16.0;
  final double spacingXl = 20.0;
  final double spacingXxl = 24.0;
  final double dayCircleSize = 48.0;
  final double borderRadiusS = 4.0;
  final double borderRadiusM = 8.0;
  final double borderRadiusL = 12.0;


  Color getColor(String name, {bool isDark = false}) {
    final colors = isDark ? darkColors : lightColors;
    return colors[name] ?? lightColors['primary']!;
  }

  List<String> get colorKeys => lightColors.keys.toList();
}
