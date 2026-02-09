import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hrm/core/auth/repo/auth_repo.dart';
import 'package:hrm/core/model/login_model.dart';
import 'package:hrm/core/repo/prefernces_repo.dart';
import 'package:logger/logger.dart';

part 'auth_event.dart';
part 'auth_state.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final AuthRepo _authRepo;
  final log = Logger();
  final pref = PreferencesRepository();

  AuthBloc(this._authRepo) : super(AuthState.initial()) {
    on<EmailChanged>(_onEmailChanged);
    on<PasswordChanged>(_onPasswordChanged);
    on<AuthSubmitted>(_onAuthSubmitted);
    on<CheckAuthStatus>(_onCheckAuthStatus);
    on<LogoutRequested>(_onLogoutRequested);
    on<RefreshUserData>(_onRefreshUserData);
  }

  void _onEmailChanged(EmailChanged event, Emitter<AuthState> emit) {
    final isValid = _isValidEmail(event.email);
    emit(state.copyWith(email: event.email, isEmailValid: isValid));
  }

  void _onPasswordChanged(PasswordChanged event, Emitter<AuthState> emit) {
    final isValid = event.password.length >= 6;
    emit(state.copyWith(password: event.password, isPasswordValid: isValid));
  }

  Future<void> _onAuthSubmitted(
    AuthSubmitted event,
    Emitter<AuthState> emit,
  ) async {
    emit(state.copyWith(status: AuthStatus.loading, message: 'Logging in...'));

    log.d('_onAuthSubmitted::$event');
    try {
      final AuthModel = await _authRepo.requestAuth(
        email: event.email,
        password: event.password,
      );

      log.d('AuthModel:${AuthModel.toJson()}');

      if (AuthModel.success == true) {
        emit(
          state.copyWith(
            status: AuthStatus.success,
            message: AuthModel.message ?? 'Auth successful',
            userData: AuthModel.data,
            token: AuthModel.token,
            userId: AuthModel.userId,
          ),
        );
        log.d(
          'AuthModel.success:::${AuthModel.status}:::::::${AuthModel.data}',
        );
      } else {
        emit(
          state.copyWith(
            status: AuthStatus.failure,
            message: AuthModel.message ?? 'Auth failed',
          ),
        );
      }
    } catch (e) {
      log.e('Auth error: $e');
      emit(
        state.copyWith(
          status: AuthStatus.failure,
          message: e.toString().replaceAll('Exception: ', ''),
        ),
      );
    }
  }

  Future<void> _onCheckAuthStatus(
    CheckAuthStatus event,
    Emitter<AuthState> emit,
  ) async {
    emit(
      state.copyWith(
        status: AuthStatus.loading,
        message: 'Checking Auth status...',
      ),
    );

    try {
      final isLoggedIn = await pref.isLoggedIn();
      log.d('isLoggedIn: $isLoggedIn');

      if (isLoggedIn) {
        final token = await pref.getToken();
        final userId = await pref.getUserId();
        final userData = await pref.getUserData();

        log.d('Token: $token');
        log.d('UserId: $userId');
        log.d('UserData: ${userData?.toJson()}');

        if (token != null && userData != null) {
          emit(
            state.copyWith(
              status: AuthStatus.success,
              message: 'Already logged in',
              token: token,
              userId: userId != null ? int.tryParse(userId) : null,
              userData: userData,
            ),
          );
        } else {
          log.w('Token or userData is null, resetting to initial state');
          emit(AuthState.initial());
        }
      } else {
        log.d('User not logged in, showing Auth screen');
        emit(AuthState.initial());
      }
    } catch (e) {
      log.e('Error checking Auth status: $e');
      emit(AuthState.initial());
    }
  }

  Future<void> _onLogoutRequested(
    LogoutRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(
      state.copyWith(status: AuthStatus.loading, message: 'Logging out...'),
    );

    try {
      await pref.logout();
      log.d('Logout successful');

      emit(AuthState.initial());
    } catch (e) {
      log.e('Logout error: $e');
      emit(
        state.copyWith(
          status: AuthStatus.failure,
          message: 'Logout failed: ${e.toString()}',
        ),
      );
    }
  }

  Future<void> _onRefreshUserData(
    RefreshUserData event,
    Emitter<AuthState> emit,
  ) async {
    try {
      final userData = await pref.getUserData();

      if (userData != null) {
        log.d('User data refreshed: ${userData.toJson()}');
        emit(
          state.copyWith(userData: userData, message: 'User data refreshed'),
        );
      } else {
        log.w('No user data found to refresh');
      }
    } catch (e) {
      log.e('Failed to refresh user data: $e');
      emit(state.copyWith(message: 'Failed to refresh user data'));
    }
  }

  bool _isValidEmail(String email) {
    final emailRegex = RegExp(
      r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$',
    );
    return emailRegex.hasMatch(email);
  }
}
