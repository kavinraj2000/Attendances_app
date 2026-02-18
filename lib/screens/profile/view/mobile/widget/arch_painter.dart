import 'package:flutter/material.dart';
import 'package:hrm/core/constants/constants.dart';

class ArchPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color =Constants.color.archBlue;
    final path = Path()
      ..moveTo(0, 0)
      ..lineTo(0, size.height * 0.72)
      ..quadraticBezierTo(
        size.width * 0.5, size.height * 1.05,
        size.width,       size.height * 0.72,
      )
      ..lineTo(size.width, 0)
      ..close();
    canvas.drawPath(path, paint);

    final strokePaint = Paint()
      ..color = Colors.white.withOpacity(0.5)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5;
    final strokePath = Path()
      ..moveTo(0, size.height * 0.72)
      ..quadraticBezierTo(
        size.width * 0.5, size.height * 1.05,
        size.width,       size.height * 0.72,
      );
    canvas.drawPath(strokePath, strokePaint);
  }

  @override
  bool shouldRepaint(ArchPainter old) => false;
}