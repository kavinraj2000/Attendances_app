import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hrm/core/auth/bloc/auth_bloc.dart';
import 'package:hrm/core/constants/constants.dart';

class OtpInputFields extends StatefulWidget {
  const OtpInputFields({super.key});

  @override
  State<OtpInputFields> createState() => _OtpInputFieldsState();
}

class _OtpInputFieldsState extends State<OtpInputFields> {
  final int otpLength = 4;

  late final List<TextEditingController> controllers = List.generate(
    otpLength,
    (_) => TextEditingController(),
  );

  late final List<FocusNode> focusNodes = List.generate(
    otpLength,
    (_) => FocusNode(),
  );

  @override
  void dispose() {
    for (final c in controllers) {
      c.dispose();
    }
    for (final f in focusNodes) {
      f.dispose();
    }
    super.dispose();
  }

  void _onChanged(int index, String value) {
    if (value.isNotEmpty && index < otpLength - 1) {
      focusNodes[index + 1].requestFocus();
    } else if (value.isEmpty && index > 0) {
      focusNodes[index - 1].requestFocus();
    }

    final otpChars = List.generate(
      otpLength,
      (i) => i == index ? value : controllers[i].text,
    );
    final otp = otpChars.join();

    context.read<AuthBloc>().add(OtpChanged(otp));

    if (otp.length == otpLength && !otp.contains('')) {
      FocusScope.of(context).unfocus();
      final email = context.read<AuthBloc>().state.email;
      context.read<AuthBloc>().add(
        OtpSubmitted(email: email, otp: int.parse(otp)),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final isLoading = context.select(
      (AuthBloc b) => b.state.status == AuthStatus.loading,
    );

    return LayoutBuilder(
      builder: (context, constraints) {
        // Compute field size: divide available width evenly with spacing
        final spacing = Constants.size.xs * 2 * otpLength;
        final fieldSize = ((constraints.maxWidth - spacing) / otpLength).clamp(
          40.0,
          72.0,
        );

        return Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(
            otpLength,
            (index) => Padding(
              padding: EdgeInsets.symmetric(horizontal: Constants.size.xs),
              child: SizedBox(
                width: fieldSize,
                height: fieldSize,
                child: TextFormField(
                  controller: controllers[index],
                  focusNode: focusNodes[index],
                  enabled: !isLoading,
                  textAlign: TextAlign.center,
                  keyboardType: TextInputType.number,
                  maxLength: 1,
                  style: TextStyle(
                    fontSize: fieldSize * 0.35,
                    fontWeight: FontWeight.bold,
                    color: Constants.color.white,
                  ),
                  inputFormatters: [
                    FilteringTextInputFormatter.digitsOnly,
                  ],
                  decoration: InputDecoration(
                    counterText: '',
                    filled: true,
                    fillColor: Constants.color.lightblue,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(
                        Constants.size.radiusM,
                      ),
                      borderSide: BorderSide.none,
                    ),
                    contentPadding: EdgeInsets.zero,
                  ),
                  onChanged: (v) => _onChanged(index, v),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}