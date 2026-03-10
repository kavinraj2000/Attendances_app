import 'package:flutter/material.dart';

class Util extends StatelessWidget {
  final Widget? child;

  const Util({
    super.key,
    this.child,
  });

  @override
  Widget build(BuildContext context) {
    final mediaQuery = MediaQuery.of(context);

    return MediaQuery(
      data: mediaQuery.copyWith(
        textScaler: TextScaler.linear(
          mediaQuery.textScaler.scale(1.0).clamp(0.9, 1.2),
        ),
      ),
      child: child ?? const SizedBox.shrink(),
    );
  }
}