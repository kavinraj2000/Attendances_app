import 'package:flutter/material.dart';

class COLORCONSTANTS {
  COLORCONSTANTS();

  final Color primary = Color(0xFF42A5F5);
  final Color secondary = Color(0xFF42A5F5);
  final Color success = Color(0xFF06D6A0);
  final Color warning = Color(0xFFFFD166);
  final Color danger = Color(0xFFEF476F);
  final Color white = Colors.white;
  final Color divider = Color(0xFFE0E0E0);
  final Color black = Color(0xFF000000);
  final Color grey = Color(0xFF757575);
  final Color green = Color(0xFF4CAF50);
  final Color red = Color(0xFFEF5350);
  final Color orange = Color(0xFFFF9800);
  final Color lightblue = Color(0xFF42A5F5);
  final Color gold = Color(0xFFFFC107);

  late final LinearGradient primaryGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [primary, secondary],
  );
}
