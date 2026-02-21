import 'package:flutter/material.dart';
import 'package:hrm/core/constants/constants.dart';


class OtpTitle extends StatelessWidget {
  const OtpTitle({
    super.key,
    required this.email,
  });

  final String email;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          Constants.app.enterOtp,
          textAlign: TextAlign.center,
          style: Theme.of(context)
              .textTheme
              .headlineMedium
              ?.copyWith(
                fontWeight: FontWeight.bold,
                color: Constants.color.primary,
              ),
        ),
         SizedBox(height: Constants.size.s),
        Padding(
          padding:  EdgeInsets.symmetric(
            horizontal: Constants.size.m,
          ),
          child: Text(
            Constants.app.otpSentMessage,
            textAlign: TextAlign.center,
            style: Theme.of(context)
                .textTheme
                .bodyMedium
                ?.copyWith(
                  color: Constants.color.secondary,
                  height: 1.5,
                ),
          ),
        ),
         SizedBox(height: Constants.size.s),
        Text(
          email,
          textAlign: TextAlign.center,
          style: Theme.of(context)
              .textTheme
              .bodyMedium
              ?.copyWith(
                fontWeight: FontWeight.w600,
                color: Constants.color.primary,
              ),
        ),
      ],
    );
  }
}