import 'dart:ui';

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

  Color getColor(String name, {bool isDark = false}) {
    final colors = isDark ? darkColors : lightColors;
    return colors[name] ?? lightColors['primary']!;
  }

  List<String> get colorKeys => lightColors.keys.toList();
}
