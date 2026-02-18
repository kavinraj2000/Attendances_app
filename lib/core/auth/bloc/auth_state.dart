part of 'auth_bloc.dart';

enum AuthStatus {
  initial,
  loading,
  otpsend,
  otpverified,
  success,
  failure,
  loaded,
}

class AuthState extends Equatable {
  final AuthStatus status;
  final String email;
  final String otp;
  final bool isEmailValid;
  final String? message;

  const AuthState({
    required this.status,
    required this.email,
    required this.otp,
    required this.isEmailValid,
    this.message,
  });

  factory AuthState.initial() {
    return const AuthState(
      status: AuthStatus.initial,
      email: '',
      otp: '',
      isEmailValid: false,
    );
  }

  AuthState copyWith({
    AuthStatus? status,
    String? email,
    String? otp,
    bool? isEmailValid,
    String? message,
  }) {
    return AuthState(
      status: status ?? this.status,
      email: email ?? this.email,
      otp: otp ?? this.otp,
      isEmailValid: isEmailValid ?? this.isEmailValid,
      message: message,
    );
  }

  @override
  List<Object?> get props => [status, email, otp, isEmailValid, message];
}
