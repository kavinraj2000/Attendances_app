import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:logger/web.dart';
import 'package:lottie/lottie.dart';
import 'package:hrm/app/route_name.dart';
import 'package:hrm/core/auth/bloc/auth_bloc.dart';

class OtpVerificationView extends StatelessWidget {
  final String email;

  const OtpVerificationView({super.key, required this.email});

  @override
  Widget build(BuildContext context) {
    return _OtpVerificationContent(email: email);
  }
}

class _OtpVerificationContent extends StatelessWidget {
  final String email;

  const _OtpVerificationContent({required this.email});

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
                SafeArea(
                  child: Center(
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.all(24),
                      child: _OtpForm(state: state, email: email),
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

class _OtpForm extends StatelessWidget {
  final AuthState state;
  final String email;

  const _OtpForm({required this.state, required this.email});

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
          const _OtpLogoWidget(),
          const SizedBox(height: 24),
          Text(
            'Enter OTP',
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.headlineMedium?.copyWith(
              fontWeight: FontWeight.bold,
              color: const Color(0xFF667eea),
            ),
          ),
          const SizedBox(height: 8),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Text(
              'We have sent you OTP to your e-mail address for verification',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.grey[600],
                fontSize: 14,
                height: 1.5,
              ),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            email,
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: Color(0xFF667eea),
              fontSize: 14,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 40),
          _OtpInputFields(isLoading: isLoading),
          const SizedBox(height: 32),
          _VerifyButton(state: state, email: email),
          const SizedBox(height: 20),
          _ResendOtpButton(isLoading: isLoading, email: email),
        ],
      ),
    );
  }
}

class _OtpLogoWidget extends StatelessWidget {
  const _OtpLogoWidget();

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 120,
      child: Stack(
        alignment: Alignment.center,
        children: [
          Container(
            width: 140,
            height: 140,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: const Color(0xFF667eea).withOpacity(0.1),
            ),
          ),
          Container(
            width: 100,
            height: 100,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: const LinearGradient(
                colors: [Color(0xFF667eea), Color(0xFF764ba2)],
              ),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF667eea).withOpacity(0.3),
                  blurRadius: 20,
                  offset: const Offset(0, 10),
                ),
              ],
            ),
            child: const Icon(
              Icons.mark_email_read_outlined,
              size: 50,
              color: Colors.white,
            ),
          ),
          Positioned(
            top: 10,
            right: 60,
            child: _NumberBadge(number: '1', color: Colors.red),
          ),
          Positioned(
            top: 30,
            right: 20,
            child: _NumberBadge(number: '2', color: Colors.green),
          ),
          Positioned(
            bottom: 20,
            left: 20,
            child: _NumberBadge(number: '3', color: Colors.blue),
          ),
        ],
      ),
    );
  }
}

class _NumberBadge extends StatelessWidget {
  final String number;
  final Color color;

  const _NumberBadge({required this.number, required this.color});

  @override
  Widget build(BuildContext context) {
    return Flexible(
      child: Container(
        width: 28,
        height: 28,
        decoration: BoxDecoration(
          color: color,
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: color.withOpacity(0.3),
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Center(
          child: Text(
            number,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 14,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ),
    );
  }
}

class _OtpInputFields extends StatefulWidget {
  final bool isLoading;

  const _OtpInputFields({required this.isLoading});

  @override
  State<_OtpInputFields> createState() => _OtpInputFieldsState();
}

class _OtpInputFieldsState extends State<_OtpInputFields> {
  final List<TextEditingController> _controllers = List.generate(
    4,
    (index) => TextEditingController(),
  );
  final List<FocusNode> _focusNodes = List.generate(4, (index) => FocusNode());

  @override
  void dispose() {
    for (var controller in _controllers) {
      controller.dispose();
    }
    for (var node in _focusNodes) {
      node.dispose();
    }
    super.dispose();
  }

  String get otpCode {
    return _controllers.map((c) => c.text).join();
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(4, (index) {
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 4),
          child: SizedBox(
            width: 60,
            height: 60,
            child: TextFormField(
              controller: _controllers[index],
              focusNode: _focusNodes[index],
              enabled: !widget.isLoading,
              textAlign: TextAlign.center,
              keyboardType: TextInputType.number,
              maxLength: 1,
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Color(0xFF667eea),
              ),
              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
              decoration: InputDecoration(
                counterText: '',
                filled: true,
                fillColor: Colors.grey[50],
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: Colors.grey[300]!),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(
                    color: Color(0xFF667eea),
                    width: 2,
                  ),
                ),
              ),
              onChanged: (value) {
                if (value.isNotEmpty && index < 3) {
                  _focusNodes[index + 1].requestFocus();
                } else if (value.isEmpty && index > 0) {
                  _focusNodes[index - 1].requestFocus();
                }

                context.read<AuthBloc>().add(OtpChanged(otpCode));
              },
            ),
          ),
        );
      }),
    );
  }
}

class _VerifyButton extends StatelessWidget {
  final AuthState state;
  final String email;

  const _VerifyButton({
    required this.state,
    required this.email,
  }); // Update constructor

  @override
  Widget build(BuildContext context) {
    final isLoading = state.status == AuthStatus.otpsend;

    return Container(
      child: ElevatedButton(
        onPressed: isLoading
            ? null
            : () {
                context.read<AuthBloc>().add(
                  OtpSubmitted(
                    email: email, 
                    otp: int.parse(state.otp),

                  ),
                );
                Logger().d('_VerifyButton:::$email::::${state.otp}');
              },
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.lightBlue,
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
                'Verify',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
              ),
      ),
    );
  }
}

class _ResendOtpButton extends StatefulWidget {
  final bool isLoading;
  final String email;

  const _ResendOtpButton({required this.isLoading, required this.email});

  @override
  State<_ResendOtpButton> createState() => _ResendOtpButtonState();
}

class _ResendOtpButtonState extends State<_ResendOtpButton> {
  int _remainingSeconds = 60;
  bool _canResend = false;

  @override
  void initState() {
    super.initState();
    _startTimer();
  }

  void _startTimer() {
    setState(() {
      _remainingSeconds = 60;
      _canResend = false;
    });

    Future.delayed(const Duration(seconds: 1), _tick);
  }

  void _tick() {
    if (_remainingSeconds > 0) {
      setState(() {
        _remainingSeconds--;
      });
      Future.delayed(const Duration(seconds: 1), _tick);
    } else {
      setState(() {
        _canResend = true;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          "Didn't receive code? ",
          style: TextStyle(color: Colors.grey[600], fontSize: 14),
        ),
        TextButton(
          onPressed: _canResend && !widget.isLoading
              ? () {
                  // context.read<AuthBloc>().add(ResendOtp(email: widget.email));
                  // _startTimer();
                }
              : null,
          child: Text(
            _canResend ? 'Resend' : 'Resend in ${_remainingSeconds}s',
            style: TextStyle(
              color: _canResend ? const Color(0xFF667eea) : Colors.grey[400],
              fontSize: 14,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ],
    );
  }
}
