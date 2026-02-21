part of 'attendances_bloc.dart';

enum AttendanceLogStatus { initial, loading, success, error }

class AttendanceLogsState extends Equatable {
  final AttendanceLogStatus status;
  final List<AttendanceModel> scheduleData;
  final Map<String, int> attendanceSummary;
  final DateTime? selectedDate;
  final int currentMonth;
  final int currentYear;
  final DateTime currentDate;
  final String? errorMessage;
  final String? errorCode;
  final bool clearSelectedDate;

  const AttendanceLogsState({
    required this.status,
    required this.scheduleData,
    required this.attendanceSummary,
    required this.currentMonth,
    required this.currentYear,
    required this.currentDate,
    this.selectedDate,
    this.errorMessage,
    this.errorCode,
    this.clearSelectedDate = false,
  });

  factory AttendanceLogsState.initial() {
    final now = DateTime.now();
    return AttendanceLogsState(
      status: AttendanceLogStatus.initial,
      scheduleData: const [],
      attendanceSummary: const {},
      currentMonth: now.month,
      currentYear: now.year,
      currentDate: now,
    );
  }

  AttendanceLogsState copyWith({
    AttendanceLogStatus? status,
    List<AttendanceModel>? scheduleData,
    Map<String, int>? attendanceSummary,
    DateTime? selectedDate,
    int? currentMonth,
    int? currentYear,
    DateTime? currentDate,
    String? errorMessage,
    String? errorCode,
    bool? clearSelectedDate,
  }) {
    return AttendanceLogsState(
      status: status ?? this.status,
      scheduleData: scheduleData ?? this.scheduleData,
      attendanceSummary: attendanceSummary ?? this.attendanceSummary,
      selectedDate: selectedDate ?? this.selectedDate,
      currentMonth: currentMonth ?? this.currentMonth,
      currentYear: currentYear ?? this.currentYear,
      currentDate: currentDate ?? this.currentDate,
      errorMessage: errorMessage,
      errorCode: errorCode,
      clearSelectedDate: clearSelectedDate ?? false,
    );
  }

  @override
  List<Object?> get props => [
    status,
    scheduleData,
    attendanceSummary,
    selectedDate,
    currentMonth,
    currentYear,
    currentDate,
    errorMessage,
    errorCode,
    clearSelectedDate,
  ];
}
