part of 'login_bloc.dart';

enum LoginStatus {
  initial,
  loading,
  success,
  failure,
}

class LoginState extends Equatable {
  final LoginStatus status;
  final String? message;
  final String? token;
  final int? userId;
  final LoginData? userData;
  final String email;
  final String password;
  final bool isEmailValid;
  final bool isPasswordValid;

  const LoginState({
    required this.status,
    this.message,
    this.token,
    this.userId,
    this.userData,
    this.email = '',
    this.password = '',
    this.isEmailValid = false,
    this.isPasswordValid = false,
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

  LoginState copyWith({
    LoginStatus? status,
    String? message,
    String? token,
    int? userId,
    LoginData? userData,
    String? email,
    String? password,
    bool? isEmailValid,
    bool? isPasswordValid,
  }) {
    return LoginState(
      status: status ?? this.status,
      message: message ?? this.message,
      token: token ?? this.token,
      userId: userId ?? this.userId,
      userData: userData ?? this.userData,
      email: email ?? this.email,
      password: password ?? this.password,
      isEmailValid: isEmailValid ?? this.isEmailValid,
      isPasswordValid: isPasswordValid ?? this.isPasswordValid,
    );
  }

  // Convenience getters for accessing user data
  String? get username => userData?.username;
  String? get emailId => userData?.userDetails?.emailId;
  int? get employeeId => userData?.employeeId;
  int? get companyId => userData?.companyId;
  List<String>? get userRoles => userData?.userRole;
  String? get tokenType => userData?.tokenType;

  bool get isLoggedIn => status == LoginStatus.success && token != null;
  bool get isLoading => status == LoginStatus.loading;
  bool get isFailure => status == LoginStatus.failure;
  bool get canSubmit => isEmailValid && isPasswordValid;

  @override
  List<Object?> get props => [
        status,
        message,
        token,
        userId,
        userData,
        email,
        password,
        isEmailValid,
        isPasswordValid,
      ];

  @override
  String toString() {
    return '''LoginState {
      status: $status,
      message: $message,
      token: ${token?.substring(0, 20)}...,
      userId: $userId,
      username: $username,
      email: $email,
      isEmailValid: $isEmailValid,
      isPasswordValid: $isPasswordValid,
    }''';
  }
}