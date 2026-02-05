part of 'login_bloc.dart';

enum LoginStatus {
  initial,
  loading,
  success,
  failure,
}

class LoginState extends Equatable {
  final LoginStatus status;
  final String email;
  final String password;
  final bool isEmailValid;
  final bool isPasswordValid;
  final String? message;
  final LoginData? userData;
  final String? token;
  final int? userId;

  const LoginState({
    required this.status,
    this.email = '',
    this.password = '',
    this.isEmailValid = false,
    this.isPasswordValid = false,
    this.message,
    this.userData,
    this.token,
    this.userId,
  });

  factory LoginState.initial() {
    return const LoginState(
      status: LoginStatus.initial,
      email: '',
      password: '',
      isEmailValid: false,
      isPasswordValid: false,
    );
  }

  bool get isFormValid => isEmailValid && isPasswordValid;

  LoginState copyWith({
    LoginStatus? status,
    String? email,
    String? password,
    bool? isEmailValid,
    bool? isPasswordValid,
    String? message,
    LoginData? userData,
    String? token,
    int? userId,
  }) {
    return LoginState(
      status: status ?? this.status,
      email: email ?? this.email,
      password: password ?? this.password,
      isEmailValid: isEmailValid ?? this.isEmailValid,
      isPasswordValid: isPasswordValid ?? this.isPasswordValid,
      message: message ?? this.message,
      userData: userData ?? this.userData,
      token: token ?? this.token,
      userId: userId ?? this.userId,
    );
  }

  @override
  List<Object?> get props => [
        status,
        email,
        password,
        isEmailValid,
        isPasswordValid,
        message,
        userData,
        token,
        userId,
      ];
}