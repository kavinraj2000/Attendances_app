import 'package:flutter/material.dart';
import 'dart:math' as math;

import 'package:hrm/core/constants/constants.dart';

class DashedRingPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color =Constants.color.avatarAccent.withOpacity(0.4)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5;

    final center = Offset(size.width / 2, size.height / 2);
    const dashCount    = 24;
    const dashAngle    = (2 * math.pi) / dashCount;
    const gapFraction  = 0.45;

    for (int i = 0; i < dashCount; i++) {
      canvas.drawArc(
        Rect.fromCircle(center: center, radius: size.width / 2),
        i * dashAngle,
        dashAngle * (1 - gapFraction),
        false,
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(DashedRingPainter old) => false;
}