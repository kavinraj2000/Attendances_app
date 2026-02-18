import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:hrm/app/route_name.dart';
import 'package:hrm/core/util/toast_util.dart';
import 'package:lottie/lottie.dart';
import 'package:hrm/core/auth/bloc/auth_bloc.dart';

class AuthloginView extends StatelessWidget {
  const AuthloginView({super.key});

  @override
  Widget build(BuildContext context) {
    return const _AuthloginViewContent();
  }
}

class _AuthloginViewContent extends StatelessWidget {
  const _AuthloginViewContent();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: BlocConsumer<AuthBloc, AuthState>(
        listener: (context, state) {
    

          if (state.status == AuthStatus.otpsend && state.email.isNotEmpty) {
            ToastUtil.otpSent(context: context);

            context.goNamed(
              RouteName.otp,
              queryParameters: {'email': state.email},
            );
          }
        },
        builder: (context, state) {
          return Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [Color(0xFF667eea), Color(0xFF764ba2)],
              ),
            ),
            child: Stack(
              children: [
                Positioned.fill(
                  child: Opacity(
                    opacity: 0.2,
                    child: Lottie.asset(
                      'assets/lottie/background.json',
                      fit: BoxFit.cover,
                      repeat: true,
                      errorBuilder: (context, error, stackTrace) {
                        return Container(
                          decoration: BoxDecoration(
                            image: DecorationImage(
                              image: const AssetImage(
                                'assets/images/pattern.png',
                              ),
                              fit: BoxFit.cover,
                              opacity: 0.1,
                              onError: (error, stackTrace) {},
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ),
                SafeArea(
                  child: Center(
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.all(24),
                      child: _AuthForm(state: state),
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

class _AuthForm extends StatelessWidget {
  final AuthState state;

  const _AuthForm({required this.state});

  @override
  Widget build(BuildContext context) {
    final isLoading = state.status == AuthStatus.loading;

    return Container(
      constraints: const BoxConstraints(maxWidth: 400),
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
            blurRadius: 30,
            offset: const Offset(0, 15),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        mainAxisSize: MainAxisSize.min,
        children: [
          const _LogoWidget(),
          const SizedBox(height: 24),
          Text(
            'HRM System',
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.headlineMedium?.copyWith(
              fontWeight: FontWeight.bold,
              color: const Color(0xFF667eea),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Sign in to continue',
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.grey[600], fontSize: 16),
          ),
          const SizedBox(height: 40),
          _EmailField(
            isLoading: isLoading,
            isEmailValid: state.isEmailValid,
            currentEmail: state.email,
          ),
          const SizedBox(height: 32),
          _AuthButton(state: state),
        ],
      ),
    );
  }
}

class _LogoWidget extends StatelessWidget {
  const _LogoWidget();

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 100,
      child: Lottie.asset(
        'assets/lottie/123.json',
        fit: BoxFit.contain,
        repeat: true,
        errorBuilder: (context, error, stackTrace) {
          return Icon(
            Icons.business_center,
            size: 80,
            color: Theme.of(context).primaryColor,
          );
        },
      ),
    );
  }
}

class _EmailField extends StatefulWidget {
  final bool isLoading;
  final bool isEmailValid;
  final String currentEmail;

  const _EmailField({
    required this.isLoading,
    required this.isEmailValid,
    required this.currentEmail,
  });

  @override
  State<_EmailField> createState() => _EmailFieldState();
}

class _EmailFieldState extends State<_EmailField> {
  late final TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.currentEmail);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: _controller,
      enabled: !widget.isLoading,
      keyboardType: TextInputType.emailAddress,
      style: const TextStyle(fontSize: 16),
      decoration: InputDecoration(
        labelText: 'Email',
        prefixIcon: const Icon(Icons.email_outlined),
        filled: true,
        fillColor: Colors.grey[50],
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey[200]!),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFF667eea), width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Colors.red),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Colors.red, width: 2),
        ),
        errorText: _controller.text.isNotEmpty && !widget.isEmailValid
            ? 'Enter a valid email'
            : null,
      ),
      onChanged: (value) {
        context.read<AuthBloc>().add(EmailChanged(value));
      },
    );
  }
}

class _AuthButton extends StatelessWidget {
  final AuthState state;

  const _AuthButton({required this.state});

  @override
  Widget build(BuildContext context) {
    final isLoading = state.status == AuthStatus.loading;
    final isFormValid = state.isEmailValid && state.email.isNotEmpty;

    return Container(
      height: 56,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: isFormValid
              ? [const Color(0xFF667eea), const Color(0xFF764ba2)]
              : [Colors.grey[400]!, Colors.grey[500]!],
        ),
        borderRadius: BorderRadius.circular(12),
        boxShadow: isFormValid
            ? [
                BoxShadow(
                  color: const Color(0xFF667eea).withOpacity(0.4),
                  blurRadius: 15,
                  offset: const Offset(0, 8),
                ),
              ]
            : [],
      ),
      child: ElevatedButton(
        onPressed: isLoading || !isFormValid
            ? null
            : () {
                context.read<AuthBloc>().add(
                  AuthSubmitted(email: state.email.trim()),
                );
              },
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.transparent,
          shadowColor: Colors.transparent,
          disabledBackgroundColor: Colors.transparent,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        child: isLoading
            ? const SizedBox(
                height: 24,
                width: 24,
                child: CircularProgressIndicator(
                  strokeWidth: 2.5,
                  valueColor: AlwaysStoppedAnimation(Colors.white),
                ),
              )
            : const Text(
                'Send OTP',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
      ),
    );
  }
}
