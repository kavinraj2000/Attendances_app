import 'package:flutter/widgets.dart';
import 'package:hrm/core/auth/view/mobile/widgets/otp_verfication_page.dart';

class OtpPage extends StatelessWidget {
  final String email;
  const OtpPage({super.key, required this.email});

  @override
  Widget build(BuildContext context) {
    return OtpVerificationView(email: email);
  }
}
