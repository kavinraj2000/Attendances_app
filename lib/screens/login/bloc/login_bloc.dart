import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hrm/core/model/login_model.dart';
import 'package:hrm/screens/login/repo/login_repo.dart';
import 'package:logger/logger.dart';

part 'login_event.dart';
part 'login_state.dart';

class LoginBloc extends Bloc<LoginEvent, LoginState> {
  final LoginRepo _loginRepo;
  final log = Logger();

  LoginBloc({
    LoginRepo? loginRepo,
  })  : _loginRepo = loginRepo ?? LoginRepo(),
        super(LoginState.initial()) {
    on<EmailChanged>(_onEmailChanged);
    on<PasswordChanged>(_onPasswordChanged);
    on<LoginSubmitted>(_onLoginSubmitted);
    on<CheckLoginStatus>(_onCheckLoginStatus);
    on<LogoutRequested>(_onLogoutRequested);
    on<RefreshUserData>(_onRefreshUserData);
  }

  void _onEmailChanged(EmailChanged event, Emitter<LoginState> emit) {
    // Email validation
    final isValid = _isValidEmail(event.email);
    emit(state.copyWith(
      email: event.email,
      isEmailValid: isValid,
    ));
  }

  void _onPasswordChanged(PasswordChanged event, Emitter<LoginState> emit) {
    // Password validation
    final isValid = event.password.length >= 6;
    emit(state.copyWith(
      password: event.password,
      isPasswordValid: isValid,
    ));
  }

  Future<void> _onLoginSubmitted(
    LoginSubmitted event,
    Emitter<LoginState> emit,
  ) async {
    emit(state.copyWith(
      status: LoginStatus.loading,
      message: 'Logging in...',
    ));

      log.d('_onLoginSubmitted::$event');
    try {
      final loginModel = await _loginRepo.requestLogin(
        email: event.email,
        password: event.password,
      );
      
      log.d('loginModel:${loginModel.toJson()}');

      if (loginModel.success == true) {
        emit(state.copyWith(
          status: LoginStatus.success,
          message: loginModel.message ?? 'Login successful',
          userData: loginModel.data,
          token: loginModel.token,
          userId: loginModel.userId,
        ));
        log.d('loginModel.success:::${loginModel.status}:::::::${loginModel.data}');
      } else {
        emit(state.copyWith(
          status: LoginStatus.failure,
          message: loginModel.message ?? 'Login failed',
        ));
      }
    } catch (e) {
      log.e('Login error: $e');
      emit(state.copyWith(
        status: LoginStatus.failure,
        message: e.toString().replaceAll('Exception: ', ''),
      ));
    }
  }

  Future<void> _onCheckLoginStatus(
    CheckLoginStatus event,
    Emitter<LoginState> emit,
  ) async {
    emit(state.copyWith(
      status: LoginStatus.loading,
      message: 'Checking login status...',
    ));

    try {
      // Check if user is logged in
      final isLoggedIn = await _loginRepo.isLoggedIn();
      log.d('isLoggedIn: $isLoggedIn');

      if (isLoggedIn) {
        final token = await _loginRepo.getToken();
        final userId = await _loginRepo.getUserId();
        final userData = await _loginRepo.getUserData();

        log.d('Token: $token');
        log.d('UserId: $userId');
        log.d('UserData: ${userData?.toJson()}');

        if (token != null && userData != null) {
          emit(state.copyWith(
            status: LoginStatus.success,
            message: 'Already logged in',
            token: token,
            userId: userId != null ? int.tryParse(userId) : null,
            userData: userData,
          ));
        } else {
          log.w('Token or userData is null, resetting to initial state');
          emit(LoginState.initial());
        }
      } else {
        log.d('User not logged in, showing login screen');
        emit(LoginState.initial());
      }
    } catch (e) {
      log.e('Error checking login status: $e');
      emit(LoginState.initial());
    }
  }

  Future<void> _onLogoutRequested(
    LogoutRequested event,
    Emitter<LoginState> emit,
  ) async {
    emit(state.copyWith(
      status: LoginStatus.loading,
      message: 'Logging out...',
    ));

    try {
      await _loginRepo.logout();
      log.d('Logout successful');
      
      emit(LoginState.initial());
    } catch (e) {
      log.e('Logout error: $e');
      emit(state.copyWith(
        status: LoginStatus.failure,
        message: 'Logout failed: ${e.toString()}',
      ));
    }
  }

  Future<void> _onRefreshUserData(
    RefreshUserData event,
    Emitter<LoginState> emit,
  ) async {
    try {
      final userData = await _loginRepo.getUserData();
      
      if (userData != null) {
        log.d('User data refreshed: ${userData.toJson()}');
        emit(state.copyWith(
          userData: userData,
          message: 'User data refreshed',
        ));
      } else {
        log.w('No user data found to refresh');
      }
    } catch (e) {
      log.e('Failed to refresh user data: $e');
      emit(state.copyWith(
        message: 'Failed to refresh user data',
      ));
    }
  }

  bool _isValidEmail(String email) {
    final emailRegex = RegExp(
      r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$',
    );
    return emailRegex.hasMatch(email);
  }
}