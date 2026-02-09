import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:lottie/lottie.dart';
import 'package:hrm/app/route_name.dart';
import 'package:hrm/core/auth/bloc/auth_bloc.dart';

/// Alternative version with simpler Lottie integration
/// This version uses a fallback icon if Lottie file is not available
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
          if (state.message != null && state.message!.isNotEmpty) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message!),
                backgroundColor: state.status == AuthStatus.failure
                    ? Colors.red
                    : Colors.green,
              ),
            );
          }

          if (state.status == AuthStatus.success) {
            context.goNamed(RouteName.dashboard);
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

                // Main Content
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
          _LogoWidget(),

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

          const SizedBox(height: 16),

          _PasswordField(
            isLoading: isLoading,
            isPasswordValid: state.isPasswordValid,
            currentPassword: state.password,
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
            ? 'Enter valid email'
            : null,
      ),
      onChanged: (value) {
        context.read<AuthBloc>().add(EmailChanged(value));
      },
    );
  }
}

class _PasswordField extends StatefulWidget {
  final bool isLoading;
  final bool isPasswordValid;
  final String currentPassword;

  const _PasswordField({
    required this.isLoading,
    required this.isPasswordValid,
    required this.currentPassword,
  });

  @override
  State<_PasswordField> createState() => _PasswordFieldState();
}

class _PasswordFieldState extends State<_PasswordField> {
  late final TextEditingController _controller;
  bool _obscurePassword = true;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.currentPassword);
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
      obscureText: _obscurePassword,
      style: const TextStyle(fontSize: 16),
      decoration: InputDecoration(
        labelText: 'Password',
        prefixIcon: const Icon(Icons.lock_outline),
        filled: true,
        fillColor: Colors.grey[50],
        suffixIcon: IconButton(
          icon: Icon(
            _obscurePassword
                ? Icons.visibility_off_outlined
                : Icons.visibility_outlined,
          ),
          onPressed: () {
            setState(() {
              _obscurePassword = !_obscurePassword;
            });
          },
        ),
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
        errorText: _controller.text.isNotEmpty && !widget.isPasswordValid
            ? 'Minimum 6 characters'
            : null,
      ),
      onChanged: (value) {
        context.read<AuthBloc>().add(PasswordChanged(value));
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
    final isFormValid = state.isEmailValid && state.isPasswordValid;

    return Container(
      height: 56,
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF667eea), Color(0xFF764ba2)],
        ),
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF667eea).withOpacity(0.4),
            blurRadius: 15,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: ElevatedButton(
        onPressed: isLoading || !isFormValid
            ? null
            : () {
                context.read<AuthBloc>().add(
                  AuthSubmitted(
                    email: state.email.trim(),
                    password: state.password,
                  ),
                );
              },
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.transparent,
          shadowColor: Colors.transparent,
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
                'Login',
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
