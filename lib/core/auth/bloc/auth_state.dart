part of 'auth_bloc.dart';


enum AuthStatus {
  initial,
  loading,
  success,
  failure,
}

class AuthState extends Equatable {
  final AuthStatus status;
  final String email;
  final String password;
  final bool isEmailValid;
  final bool isPasswordValid;
  final String? message;
  final LoginData? userData;
  final String? token;
  final int? userId;

  const AuthState({
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

  factory AuthState.initial() {
    return const AuthState(
      status: AuthStatus.initial,
      email: '',
      password: '',
      isEmailValid: false,
      isPasswordValid: false,
    );
  }

  bool get isFormValid => isEmailValid && isPasswordValid;

  AuthState copyWith({
    AuthStatus? status,
    String? email,
    String? password,
    bool? isEmailValid,
    bool? isPasswordValid,
    String? message,
    LoginData? userData,
    String? token,
    int? userId,
  }) {
    return AuthState(
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