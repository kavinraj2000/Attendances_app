import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hrm/core/auth/bloc/auth_bloc.dart';
import 'package:hrm/core/auth/repo/auth_repo.dart';
import 'package:hrm/core/auth/view/mobile/otp_checkin_page.dart';
import 'package:hrm/core/repo/prefernces_repo.dart';

class OtpPage extends StatelessWidget {
  final String email;
  const OtpPage({super.key, required this.email});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) =>
          AuthBloc(AuthRepo(context.read<PreferencesRepository>()))
            ..add(OtpSubmitted( email: email)),
      child: OtpVerificationView(email: email),
    );
  }
}
