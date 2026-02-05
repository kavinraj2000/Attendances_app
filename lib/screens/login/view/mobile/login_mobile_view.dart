import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:hrm/app/route_name.dart';
import 'package:hrm/screens/login/bloc/login_bloc.dart';

class LoginMobileView extends StatelessWidget {
  const LoginMobileView({super.key});

  @override
  Widget build(BuildContext context) {
    return const _LoginMobileViewContent();
  }
}

class _LoginMobileViewContent extends StatelessWidget {
  const _LoginMobileViewContent();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: BlocConsumer<LoginBloc, LoginState>(
        listener: (context, state) {
          if (state.message != null && state.message!.isNotEmpty) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message!),
                backgroundColor: state.status == LoginStatus.failure
                    ? Colors.red
                    : Colors.green,
              ),
            );
          }

          if (state.status == LoginStatus.success ) {
            context.goNamed(RouteName.dashboard);
          }
        },
        builder: (context, state) {
          return SafeArea(
            child: Center(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(24),
                child: _LoginForm(state: state),
              ),
            ),
          );
        },
      ),
    );
  }
}

class _LoginForm extends StatelessWidget {
  final LoginState state;

  const _LoginForm({required this.state});

  @override
  Widget build(BuildContext context) {
    final isLoading = state.status == LoginStatus.loading;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Icon(
          Icons.business_center,
          size: 80,
          color: Theme.of(context).primaryColor,
        ),
        const SizedBox(height: 16),

        Text(
          'HRM System',
          textAlign: TextAlign.center,
          style: Theme.of(
            context,
          ).textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.bold),
        ),

        const SizedBox(height: 8),
        Text(
          'Sign in to continue',
          textAlign: TextAlign.center,
          style: TextStyle(color: Colors.grey[600]),
        ),

        const SizedBox(height: 48),

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

        const SizedBox(height: 24),

        _LoginButton(state: state),

        const SizedBox(height: 16),

        // _ForgotPasswordButton(isLoading: isLoading),
      ],
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
      decoration: InputDecoration(
        labelText: 'Email',
        prefixIcon: const Icon(Icons.email),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        errorText: _controller.text.isNotEmpty && !widget.isEmailValid
            ? 'Enter valid email'
            : null,
      ),
      onChanged: (value) {
        context.read<LoginBloc>().add(EmailChanged(value));
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
      decoration: InputDecoration(
        labelText: 'Password',
        prefixIcon: const Icon(Icons.lock),
        suffixIcon: IconButton(
          icon: Icon(
            _obscurePassword ? Icons.visibility : Icons.visibility_off,
          ),
          onPressed: () {
            setState(() {
              _obscurePassword = !_obscurePassword;
            });
          },
        ),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        errorText: _controller.text.isNotEmpty && !widget.isPasswordValid
            ? 'Minimum 6 characters'
            : null,
      ),
      onChanged: (value) {
        context.read<LoginBloc>().add(PasswordChanged(value));
      },
    );
  }
}

class _LoginButton extends StatelessWidget {
  final LoginState state;

  const _LoginButton({required this.state});

  @override
  Widget build(BuildContext context) {
    final isLoading = state.status == LoginStatus.loading;
    final isFormValid = state.isEmailValid && state.isPasswordValid;

    return ElevatedButton(
      onPressed: isLoading || !isFormValid
          ? null
          : () {
              context.read<LoginBloc>().add(
                LoginSubmitted(
                  email: state.email.trim(),
                  password: state.password,
                ),
              );
            },
      style: ElevatedButton.styleFrom(
        padding: const EdgeInsets.symmetric(vertical: 16),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
      child: isLoading
          ? const SizedBox(
              height: 20,
              width: 20,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                valueColor: AlwaysStoppedAnimation(Colors.white),
              ),
            )
          : const Text('Login', style: TextStyle(fontSize: 16)),
    );
  }
}

// class _ForgotPasswordButton extends StatelessWidget {
//   final bool isLoading;

//   const _ForgotPasswordButton({required this.isLoading});

//   @override
//   Widget build(BuildContext context) {
//     return TextButton(
//       onPressed: isLoading
//           ? null
//           : () {
//               // TODO: Implement forgot password functionality
//               ScaffoldMessenger.of(context).showSnackBar(
//                 const SnackBar(
//                   content: Text('Forgot password feature coming soon'),
//                 ),
//               );
//             },
//       child: const Text('Forgot Password?'),
//     );
//   }
// }
