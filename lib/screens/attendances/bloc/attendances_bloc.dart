import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hrm/core/model/attances_model.dart';
import 'package:hrm/screens/attendances/repo/attendances_repo.dart';
import 'package:logger/web.dart';

part 'attendances_event.dart';
part 'attendances_state.dart';

class AttendanceLogsBloc
    extends Bloc<AttendanceLogsEvent, AttendanceLogsState> {
  final AttendancesRepo repository;
  final log = Logger();

  AttendanceLogsBloc({required this.repository})
    : super(AttendanceLogsState.initial()) {
    on<LoadAttendanceLogs>(_onLoadAttendanceLogs);
    on<SelectDate>(_onSelectDate);
    on<ClearSelectedDate>(_onClearSelectedDate);
    on<RefreshSchedule>(_onRefreshSchedule);
  }

  Future<void> _onLoadAttendanceLogs(
    LoadAttendanceLogs event,
    Emitter<AttendanceLogsState> emit,
  ) async {
    emit(state.copyWith(status: AttendanceLogStatus.loading));

    try {
      final data = await repository.getAllAttendanceData();

      final filteredData = _filterByMonth(data, event.month, event.year);

      final summary = _calculateAttendanceSummary(filteredData);

      log.d('summary:_calculateAttendanceSummary:::$summary');

      emit(
        state.copyWith(
          status: AttendanceLogStatus.success,
          scheduleData: filteredData,
          attendanceSummary: summary,
          currentMonth: event.month,
          currentYear: event.year,
          currentDate: DateTime.now(),
          errorMessage: null,
          errorCode: null,
        ),
      );
    } catch (e) {
      _emitError(
        emit,
        'Failed to load attendance: ${e.toString()}',
        'LOAD_FAILED',
      );
    }
  }

  void _onSelectDate(SelectDate event, Emitter<AttendanceLogsState> emit) {
    emit(state.copyWith(selectedDate: event.date));
  }

  void _onClearSelectedDate(
    ClearSelectedDate event,
    Emitter<AttendanceLogsState> emit,
  ) {
    emit(state.copyWith(clearSelectedDate: true));
  }

  Future<void> _onRefreshSchedule(
    RefreshSchedule event,
    Emitter<AttendanceLogsState> emit,
  ) async {
    try {
      final data = await repository.getAllAttendanceData();
      final filteredData = _filterByMonth(
        data,
        state.currentMonth,
        state.currentYear,
      );

      emit(
        state.copyWith(
          scheduleData: filteredData,
          attendanceSummary: _calculateAttendanceSummary(filteredData),
        ),
      );
    } catch (e) {
      _emitError(emit, e.toString(), 'REFRESH_FAILED');
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
      } catch (_) {
        return false;
      }
    }).toList();
  }

  Map<String, int> _calculateAttendanceSummary(List<AttendanceModel> data) {
    int present = 0;
    int absent = 0;
    int halfDay = 0;
    int leave = 0;
    int pending = 0;

    for (final attendance in data) {
      switch (attendance.attendanceStatus) {
        case 'PRESENT':
          present++;
          break;
        case 'ABSENT':
          absent++;
          break;
        case 'LATE':
          halfDay++;
          break;
        case 'LEAVE':
          leave++;
          break;
        case 'INPROGRESS':
          pending++;
          break;
      }
    }

    return {
      'PRESENT': present,
      'ABSENT': absent,
      'LATE': halfDay,
      'LEAVE': leave,
      'INPROGRESS': pending,
    };
  }

  void _emitError(
    Emitter<AttendanceLogsState> emit,
    String message,
    String code,
  ) {
    emit(
      state.copyWith(
        status: AttendanceLogStatus.error,
        errorMessage: message,
        errorCode: code,
      ),
    );
  }
}
