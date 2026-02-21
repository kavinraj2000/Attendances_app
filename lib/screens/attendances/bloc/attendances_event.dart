part of 'attendances_bloc.dart';

abstract class AttendanceLogsEvent extends Equatable {
  const AttendanceLogsEvent();

  @override
  List<Object?> get props => [];
}

class LoadAttendanceLogs extends AttendanceLogsEvent {
  final int month;
  final int year;

  const LoadAttendanceLogs({required this.month, required this.year});

  @override
  List<Object?> get props => [month, year];
}

class SelectDate extends AttendanceLogsEvent {
  final DateTime date;

  const SelectDate(this.date);

  @override
  List<Object?> get props => [date];
}

class ChangeMonth extends AttendanceLogsEvent {
  final int month;
  final int year;

  const ChangeMonth({required this.month, required this.year});

  @override
  List<Object?> get props => [month, year];
}

class RefreshSchedule extends AttendanceLogsEvent {
  const RefreshSchedule();
}

class ClearSelectedDate extends AttendanceLogsEvent {
  const ClearSelectedDate();
}
