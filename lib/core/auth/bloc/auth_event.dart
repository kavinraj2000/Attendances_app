part of 'auth_bloc.dart';

abstract class AuthEvent extends Equatable {
  const AuthEvent();

  @override
  List<Object?> get props => [];
}

class EmailChanged extends AuthEvent {
  final String email;

  const EmailChanged(this.email);

  @override
  List<Object?> get props => [email];
}

class PasswordChanged extends AuthEvent {
  final String password;

  const PasswordChanged(this.password);

  @override
  List<Object?> get props => [password];
}

class AuthSubmitted extends AuthEvent {
  final String email;

  const AuthSubmitted({required this.email});

  @override
  List<Object?> get props => [email];
}

class CheckAuthStatus extends AuthEvent {
  const CheckAuthStatus();
}

class LogoutRequested extends AuthEvent {
  const LogoutRequested();
}

class RefreshUserData extends AuthEvent {
  const RefreshUserData();
}

class OtpChanged extends AuthEvent {
  final String otp;

  const OtpChanged(this.otp);

  @override
  List<Object?> get props => [otp];
}

class OtpSubmitted extends AuthEvent {
  final String email;
  final int? otp;

  const OtpSubmitted({this.otp, required this.email});

  @override
  List<Object?> get props => [otp];
}

class ResendOtp extends AuthEvent {
  final String email;

  const ResendOtp({required this.email});

  @override
  List<Object?> get props => [email];
}
