part of 'attendances_bloc.dart';

/// Base class for all attendance logs events
abstract class AttendanceLogsEvent extends Equatable {
  const AttendanceLogsEvent();

  @override
  List<Object?> get props => [];
}

/// Event to load attendance logs for a specific month and year
class LoadAttendanceLogs extends AttendanceLogsEvent {
  final int month;
  final int year;

  const LoadAttendanceLogs({
    required this.month,
    required this.year,
  });

  @override
  List<Object?> get props => [month, year];
}

/// Event to select a specific date in the calendar
class SelectDate extends AttendanceLogsEvent {
  final DateTime date;

  const SelectDate(this.date);

  @override
  List<Object?> get props => [date];
}

/// Event to change the displayed month
class ChangeMonth extends AttendanceLogsEvent {
  final int month;
  final int year;

  const ChangeMonth({
    required this.month,
    required this.year,
  });

  @override
  List<Object?> get props => [month, year];
}

/// Event to refresh the current schedule
class RefreshSchedule extends AttendanceLogsEvent {
  const RefreshSchedule();
}

/// Event to clear selected date
class ClearSelectedDate extends AttendanceLogsEvent {
  const ClearSelectedDate();
}