import 'package:flutter/material.dart';

class OtpLogo extends StatelessWidget {
  const OtpLogo({super.key});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 120,
      child: Stack(
        alignment: Alignment.center,
        children: [
          Container(
            width: 140,
            height: 140,
            decoration: BoxDecoration(shape: BoxShape.circle),
            child: Image.asset('assets/images/logo.png', fit: BoxFit.contain),
          ),
        ],
      ),
    );
  }
}
