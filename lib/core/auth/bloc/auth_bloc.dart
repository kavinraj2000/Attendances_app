import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hrm/core/auth/repo/auth_repo.dart';
import 'package:hrm/core/repo/prefernces_repo.dart';
import 'package:logger/logger.dart';

part 'auth_event.dart';
part 'auth_state.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final AuthRepo _authRepo;
  final PreferencesRepository _prefs = PreferencesRepository();
  final log = Logger();

  AuthBloc(this._authRepo) : super(AuthState.initial()) {
    on<CheckAuthStatus>(_onCheckAuthStatus);
    on<EmailChanged>(_onEmailChanged);
    on<AuthSubmitted>(_onAuthSubmitted);
    on<OtpChanged>(_onOtpChanged);
    on<OtpSubmitted>(_onOtpSubmitted);
    on<LogoutRequested>(_onLogoutRequested);
  }

  // ---------------- CHECK AUTH ----------------
  Future<void> _onCheckAuthStatus(
    CheckAuthStatus event,
    Emitter<AuthState> emit,
  ) async {
    final isLoggedIn = await _prefs.isLoggedIn();

    if (isLoggedIn) {
      // User is already logged in, set status to success
      emit(state.copyWith(status: AuthStatus.success));
    } else {
      // User not logged in, keep initial state
      emit(AuthState.initial());
    }
  }

  void _onEmailChanged(EmailChanged event, Emitter<AuthState> emit) {
    emit(
      state.copyWith(
        email: event.email,
        isEmailValid: _isValidEmail(event.email),
        // Clear message when user starts typing
        message: '',
      ),
    );
  }

  Future<void> _onAuthSubmitted(
    AuthSubmitted event,
    Emitter<AuthState> emit,
  ) async {
    if (!_isValidEmail(event.email)) {
      emit(
        state.copyWith(
          status: AuthStatus.failure,
          message: 'Please enter a valid email',
        ),
      );
      return;
    }

    emit(state.copyWith(status: AuthStatus.loading));

    try {
      final res = await _authRepo.requestAuth(email: event.email);

      if (res.success == true) {
        emit(
          state.copyWith(
            status: AuthStatus.otpsend,
            email: event.email,
            message: 'OTP sent successfully to ${event.email}',
          ),
        );
      } else {
        emit(
          state.copyWith(
            status: AuthStatus.failure,
            message: res.message ?? 'Failed to send OTP',
          ),
        );
      }
    } catch (e) {
      emit(
        state.copyWith(
          status: AuthStatus.failure,
          message: 'Error: ${e.toString()}',
        ),
      );
    }
  }

  void _onOtpChanged(OtpChanged event, Emitter<AuthState> emit) {
    emit(state.copyWith(otp: event.otp));
  }

  Future<void> _onOtpSubmitted(
    OtpSubmitted event,
    Emitter<AuthState> emit,
  ) async {
    if (event.otp.toString().length != 4) {
      emit(
        state.copyWith(
          status: AuthStatus.failure,
          message: 'Please enter a 4-digit OTP',
        ),
      );
      return;
    }

    if (event.email.isEmpty || !_isValidEmail(event.email)) {
      emit(
        state.copyWith(
          status: AuthStatus.failure,
          message: 'Invalid email address',
        ),
      );
      return;
    }

    emit(state.copyWith(status: AuthStatus.loading));

    try {
      log.d('_onOtpSubmitted:${event.email}::::${event.otp}');
      final res = await _authRepo.verfifyOTP(
        email: event.email,
        otp: event.otp.toString(),
      );
      if (res.success == true) {
        await _prefs.setLoggedIn(true);

        emit(
          state.copyWith(
            status: AuthStatus.success,
            message: 'Login successful!',
          ),
        );
      } else {
        emit(
          state.copyWith(
            status: AuthStatus.failure,
            message: res.message ?? 'Invalid OTP. Please try again.',
          ),
        );
      }
    } catch (e) {
      log.e('OTP verification error: $e');
      emit(
        state.copyWith(
          status: AuthStatus.failure,
          message: 'Error: ${e.toString()}',
        ),
      );
    }
  }

  Future<void> _onLogoutRequested(
    LogoutRequested event,
    Emitter<AuthState> emit,
  ) async {
    await _prefs.logout();
    emit(AuthState.initial());
  }

  bool _isValidEmail(String email) {
    return RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w]{2,4}$').hasMatch(email);
  }
}
