import 'package:flutter/widgets.dart';
import 'package:hrm/core/auth/view/mobile/otp_checkin_page.dart';

/// OTP Page Wrapper
/// 
/// This widget should NOT create a new AuthBloc.
/// It simply wraps the OTP verification view and passes the email.
/// The AuthBloc is already provided higher up in the widget tree.
class OtpPage extends StatelessWidget {
  final String email;
  const OtpPage({super.key, required this.email});

  @override
  Widget build(BuildContext context) {
    // 🔴 BUG FIX: Don't create a new BlocProvider here!
    // The AuthBloc is already provided at the app level.
    // Creating a new one loses all the state from the login screen.
    
    // Also, don't dispatch OtpSubmitted here - the user hasn't entered OTP yet!
    
    return OtpVerificationView(email: email);
  }
}