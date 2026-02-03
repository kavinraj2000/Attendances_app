import 'package:flutter/material.dart';

class Util extends StatelessWidget {
   final Widget? child;

  const Util({super.key, this.child});

  @override
  Widget build(BuildContext context) {
    return MediaQuery(
      data: MediaQuery.of(context).copyWith(textScaleFactor: 1.0),
      child: Center(
        child: AspectRatio(
          aspectRatio: 390 / 844,
          child: Container(
            color: Colors.black,
            child: FittedBox(
              fit: BoxFit.contain,
              child: SizedBox(
                width: 390,
                height: 844,
                child: Column(
                  children: [
                    Expanded(child: child ?? const SizedBox.shrink()),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
