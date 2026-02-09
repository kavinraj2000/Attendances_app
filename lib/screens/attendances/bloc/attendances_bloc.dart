import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hrm/core/model/attances_model.dart';
import 'package:hrm/screens/attendances/repo/attendances_repo.dart';

part 'attendances_event.dart';
part 'attendances_state.dart';

/// BLoC for managing attendance logs state and business logic
class AttendanceLogsBloc extends Bloc<AttendanceLogsEvent, AttendanceLogsState> {
  final AttendancesRepo repository;

  AttendanceLogsBloc({required this.repository})
      : super(AttendanceLogsState.initial()) {
    on<LoadAttendanceLogs>(_onLoadAttendanceLogs);
    on<SelectDate>(_onSelectDate);
    on<ClearSelectedDate>(_onClearSelectedDate);
    on<ChangeMonth>(_onChangeMonth);
    on<RefreshSchedule>(_onRefreshSchedule);
  }

  /// Handles loading attendance logs for a specific month/year
  Future<void> _onLoadAttendanceLogs(
    LoadAttendanceLogs event,
    Emitter<AttendanceLogsState> emit,
  ) async {
    emit(state.copyWith(status: AttendancesStatus.loading));

    try {
      final data = await repository.getAllAttendanceData();

      if (data.isEmpty) {
        emit(
          state.copyWith(
            status: AttendancesStatus.success,
            scheduleData: [],
            currentMonth: event.month,
            currentYear: event.year,
            currentDate: DateTime.now(),
          ),
        );
        return;
      }

      emit(
        state.copyWith(
          status: AttendancesStatus.success,
          scheduleData: _filterByMonth(data, event.month, event.year),
          currentMonth: event.month,
          currentYear: event.year,
          currentDate: DateTime.now(),
          errorMessage: null,
          errorCode: null,
        ),
      );
    } on NetworkException catch (e) {
      _emitError(emit, 'Network error: ${e.message}', 'NETWORK_ERROR');
    } on ServerException catch (e) {
      _emitError(emit, 'Server error: ${e.message}', 'SERVER_ERROR');
    } on AuthException catch (e) {
      _emitError(emit, 'Authentication error: ${e.message}', 'AUTH_ERROR');
    } catch (e) {
      _emitError(emit, 'An unexpected error occurred: ${e.toString()}', 'UNKNOWN_ERROR');
    }
  }

  void _onSelectDate(
    SelectDate event,
    Emitter<AttendanceLogsState> emit,
  ) {
    if (state.selectedDate != event.date) {
      emit(state.copyWith(selectedDate: event.date));
    }
  }

  void _onClearSelectedDate(
    ClearSelectedDate event,
    Emitter<AttendanceLogsState> emit,
  ) {
    emit(state.copyWith(clearSelectedDate: true));
  }

  Future<void> _onChangeMonth(
    ChangeMonth event,
    Emitter<AttendanceLogsState> emit,
  ) async {
    emit(state.copyWith(status: AttendancesStatus.loading));

    try {
      final data = await repository.getAllAttendanceData();

      if (data == null || data.isEmpty) {
        emit(
          state.copyWith(
            status: AttendancesStatus.success,
            scheduleData: [],
            currentMonth: event.month,
            currentYear: event.year,
            clearSelectedDate: true,
          ),
        );
        return;
      }

      emit(
        state.copyWith(
          status: AttendancesStatus.success,
          scheduleData: _filterByMonth(data, event.month, event.year),
          currentMonth: event.month,
          currentYear: event.year,
          clearSelectedDate: true,
        ),
      );
    } on NetworkException catch (e) {
      _emitError(emit, 'Network error: ${e.message}', 'NETWORK_ERROR');
    } on ServerException catch (e) {
      _emitError(emit, 'Server error: ${e.message}', 'SERVER_ERROR');
    } catch (e) {
      _emitError(emit, 'Failed to change month: ${e.toString()}', 'UNKNOWN_ERROR');
    }
  }

  Future<void> _onRefreshSchedule(
    RefreshSchedule event,
    Emitter<AttendanceLogsState> emit,
  ) async {
    try {
      final data = await repository.getAllAttendanceData();

      if (data == null || data.isEmpty) {
        emit(
          state.copyWith(
            scheduleData: [],
          ),
        );
        return;
      }

      emit(
        state.copyWith(
          scheduleData: _filterByMonth(
            data,
            state.currentMonth,
            state.currentYear,
          ),
        ),
      );
    } on NetworkException catch (e) {
      _emitError(emit, 'Network error: ${e.message}', 'NETWORK_ERROR');
    } on ServerException catch (e) {
      _emitError(emit, 'Server error: ${e.message}', 'SERVER_ERROR');
    } catch (e) {
      _emitError(emit, 'Failed to refresh: ${e.toString()}', 'UNKNOWN_ERROR');
    }
  }

  List<AttendanceModel> _filterByMonth(
    List<AttendanceModel> data,
    int month,
    int year,
  ) {
    return data.where((e) {
      try {
        final date = DateTime.parse(e.attendanceDate);
        return date.month == month && date.year == year;
      } catch (e) {
        return false;
      }
    }).toList();
  }

  /// Emits error state
  void _emitError(
    Emitter<AttendanceLogsState> emit,
    String message,
    String code,
  ) {
    emit(
      state.copyWith(
        status: AttendancesStatus.error,
        errorMessage: message,
        errorCode: code,
      ),
    );
  }
}

// Custom exceptions for better error handling
class NetworkException implements Exception {
  final String message;
  NetworkException(this.message);
}

class ServerException implements Exception {
  final String message;
  ServerException(this.message);
}

class AuthException implements Exception {
  final String message;
  AuthException(this.message);
}