import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hrm/core/model/login_model.dart';
import 'package:hrm/core/repo/prefernces_repo.dart';
import 'package:hrm/screens/login/repo/login_repo.dart';

part 'login_event.dart';
part 'login_state.dart';

class LoginBloc extends Bloc<LoginEvent, LoginState> {
  final LoginRepo _loginRepo;
  final PreferencesRepository _prefsRepo;

  LoginBloc({
    LoginRepo? loginRepo,
    PreferencesRepository? prefsRepo,
  })  : _loginRepo = loginRepo ?? LoginRepo(),
        _prefsRepo = prefsRepo ?? PreferencesRepository(),
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

    try {
      // Call the login repository
      final loginModel = await _loginRepo.requestLogin(
        email: event.email,
        password: event.password,
      );

      // Check if login was successful
      if (loginModel.success == true && loginModel.data != null) {
        emit(state.copyWith(
          status: LoginStatus.success,
          message: loginModel.message ?? 'Login successful',
          userData: loginModel.data,
          token: loginModel.token,
          userId: loginModel.userId,
        ));
      } else {
        emit(state.copyWith(
          status: LoginStatus.failure,
          message: loginModel.message ?? 'Login failed',
        ));
      }
    } catch (e) {
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

      if (isLoggedIn) {
        // Get token from storage
        final token = await _loginRepo.getToken();
        final userId = await _loginRepo.getUserId();
        
        final userData = await _loginRepo.getUserData();

        if (token != null && userData != null) {
          emit(state.copyWith(
            status: LoginStatus.success,
            message: 'Already logged in',
            token: token,
            userId: userId != null ? int.tryParse(userId) : null,
            userData: userData,
          ));
        } else {
          emit(LoginState.initial());
        }
      } else {
        emit(LoginState.initial());
      }
    } catch (e) {
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
      
      emit(LoginState.initial());
    } catch (e) {
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
        emit(state.copyWith(
          userData: userData,
          message: 'User data refreshed',
        ));
      }
    } catch (e) {
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