import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:hrm/app/route_name.dart';
import 'package:hrm/core/auth/bloc/auth_bloc.dart';
import 'package:hrm/core/auth/view/mobile/widgets/gradient_background.dart';
import 'package:hrm/core/auth/view/mobile/widgets/otp_card.dart';
import 'package:hrm/core/constants/constants.dart';
import 'package:hrm/core/util/toast_util.dart';

class OtpVerificationView extends StatelessWidget {
  const OtpVerificationView({
    super.key,
    required this.email,
  });

  final String email;

  @override
  Widget build(BuildContext context) {
    return BlocListener<AuthBloc, AuthState>(
      listenWhen: (p, c) => p.status != c.status || p.message != c.message,
      listener: (context, state) {
        if (state.status == AuthStatus.success) {
          context.goNamed(RouteName.dashboard);
          return;
        }

        if (state.message?.isNotEmpty ?? false) {
          ToastUtil.error(
            context: context,
            message: state.message!,
          );
        }
      },
      child: Scaffold(
        body: BlocBuilder<AuthBloc, AuthState>(
          builder: (context, state) {
            final isLoading = state.status == AuthStatus.loading;

            return GradientBackground(
              child: SafeArea(
                child: Stack(
                  children: [
                    Center(
                      child: SingleChildScrollView(
                        padding: EdgeInsets.all(Constants.size.l),
                        child: OtpCard(
                          email: email.isNotEmpty ? email : state.email,
                        ),
                      ),
                    ),
                    if (isLoading)
                      const Positioned.fill(
                        child: ColoredBox(
                          color: Colors.black26,
                          child: Center(
                            child: CircularProgressIndicator(),
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}