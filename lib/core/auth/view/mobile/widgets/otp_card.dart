import 'package:flutter/material.dart';
import 'package:hrm/core/auth/view/mobile/widgets/otp_input_field.dart';
import 'package:hrm/core/auth/view/mobile/widgets/otp_logo.dart';
import 'package:hrm/core/auth/view/mobile/widgets/otp_title.dart';
import 'package:hrm/core/auth/view/mobile/widgets/verfify_button.dart';
import 'package:hrm/core/constants/constants.dart';

class OtpCard extends StatelessWidget {
  const OtpCard({required this.email});

  final String email;

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints:  BoxConstraints(
        maxWidth: Constants.size.maxCardWidth,
      ),
      padding:  EdgeInsets.all(Constants.size.xl),
      decoration: BoxDecoration(
        color: Constants.color.white,
        borderRadius:
            BorderRadius.circular(Constants.size.radiusCard),
        boxShadow: [
          BoxShadow(
            color: Constants.color.grey,
            blurRadius: 25,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
           OtpLogo(),
           SizedBox(height: Constants.size.l),
          OtpTitle(email: email),
           SizedBox(height: Constants.size.xl),
           OtpInputFields(),
           SizedBox(height: Constants.size.l),
          VerifyButton(email: email),
           SizedBox(height: Constants.size.m),
        ],
      ),
    );
  }
}