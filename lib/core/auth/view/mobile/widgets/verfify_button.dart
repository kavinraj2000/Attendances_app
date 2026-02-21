import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hrm/core/auth/bloc/auth_bloc.dart';
import 'package:hrm/core/constants/constants.dart';

class VerifyButton extends StatelessWidget {
  const VerifyButton({super.key, required this.email});

  final String email;

  @override
  Widget build(BuildContext context) {
    final state = context.watch<AuthBloc>().state;

    final isLoading = state.status == AuthStatus.loading;
    final isComplete = state.otp.length == 4;

    final resolvedEmail =
        email.isNotEmpty ? email : state.email;

    return SizedBox(
      width: double.infinity,
      height: Constants.size.buttonHeight,
      child: ElevatedButton(
        onPressed: isLoading || !isComplete
            ? null
            : () {
                debugPrint(
                    'OtpSubmitted => email: $resolvedEmail | otp: ${state.otp}');

                context.read<AuthBloc>().add(
                      OtpSubmitted(
                        email: resolvedEmail,
                        otp: int.parse(state.otp),
                      ),
                    );
              },
        style: ElevatedButton.styleFrom(
          backgroundColor: Constants.color.primary,
          disabledBackgroundColor:
              Constants.color.primary.withOpacity(0.5),
          shape: RoundedRectangleBorder(
            borderRadius:
                BorderRadius.circular(Constants.size.radiusM),
          ),
        ),
        child: isLoading
            ? SizedBox(
                height: 20,
                width: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor:
                      AlwaysStoppedAnimation(Constants.color.white),
                ),
              )
            : Text(
                Constants.app.verify,
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Constants.color.white,
                ),
              ),
      ),
    );
  }
}