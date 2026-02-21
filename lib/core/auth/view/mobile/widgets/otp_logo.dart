import 'package:flutter/material.dart';
import 'package:hrm/core/constants/constants.dart';


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
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Constants.color.primary.withOpacity(0.1),
            ),
          ),
          Container(
            width: 100,
            height: 100,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: Constants.color.primaryGradient,
              boxShadow: [
                BoxShadow(
                  color: Constants.color.primary.withOpacity(0.3),
                  blurRadius: 20,
                  offset: const Offset(0, 10),
                ),
              ],
            ),
            child:  Icon(
              Icons.mark_email_read_outlined,
              size: 48,
              color: Constants.color.white,
            ),
          ),
        ],
      ),
    );
  }
}