import 'package:flutter/material.dart';
import 'package:hrm/core/constants/constants.dart';
import 'package:lottie/lottie.dart';

class GradientBackground extends StatelessWidget {
  const GradientBackground({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration:  BoxDecoration(
        gradient: Constants.color.primaryGradient,
      ),
      child: Stack(
        children: [
          const Positioned.fill(
            child: Opacity(
              opacity: 0.08, // FIXED
              child: _BackgroundAnimation(),
            ),
          ),
          child,
        ],
      ),
    );
  }
}

class _BackgroundAnimation extends StatelessWidget {
  const _BackgroundAnimation();

  @override
  Widget build(BuildContext context) {
    return Lottie.asset(
      'assets/animations/bg.json',
      fit: BoxFit.cover,
      repeat: true,
    );
  }
}