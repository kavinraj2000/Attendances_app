part of 'attendances_bloc.dart';

/// Status enum for attendance logs
enum AttendancesStatus {
  initial,
  loading,
  success,
  error,
}

/// Base state for attendance logs
class AttendanceLogsState extends Equatable {
  final AttendancesStatus status;
  final List<AttendanceModel> scheduleData;
  final DateTime currentDate;
  final int currentMonth;
  final int currentYear;
  final DateTime? selectedDate;
  final String? errorMessage;
  final String? errorCode;

  const AttendanceLogsState({
    required this.status,
    required this.scheduleData,
    required this.currentDate,
    required this.currentMonth,
    required this.currentYear,
    this.selectedDate,
    this.errorMessage,
    this.errorCode,
  });

  /// Initial state factory
  factory AttendanceLogsState.initial() {
    final now = DateTime.now();
    return AttendanceLogsState(
      status: AttendancesStatus.initial,
      scheduleData: const [],
      currentDate: now,
      currentMonth: now.month,
      currentYear: now.year,
    );
  }

  @override
  List<Object?> get props => [
        status,
        scheduleData,
        currentDate,
        currentMonth,
        currentYear,
        selectedDate,
        errorMessage,
        errorCode,
      ];

  /// Copy with method for immutable state updates
  AttendanceLogsState copyWith({
    AttendancesStatus? status,
    List<AttendanceModel>? scheduleData,
    DateTime? currentDate,
    int? currentMonth,
    int? currentYear,
    DateTime? selectedDate,
    String? errorMessage,
    String? errorCode,
    bool clearSelectedDate = false,
  }) {
    return AttendanceLogsState(
      status: status ?? this.status,
      scheduleData: scheduleData ?? this.scheduleData,
      currentDate: currentDate ?? this.currentDate,
      currentMonth: currentMonth ?? this.currentMonth,
      currentYear: currentYear ?? this.currentYear,
      selectedDate: clearSelectedDate ? null : (selectedDate ?? this.selectedDate),
      errorMessage: errorMessage ?? this.errorMessage,
      errorCode: errorCode ?? this.errorCode,
    );
  }

  /// Get attendance data for a specific date
  AttendanceModel? getAttendanceForDate(DateTime date) {
    try {
      return scheduleData.firstWhere(
        (attendance) {
          final attendanceDate = DateTime.parse(attendance.attendanceDate);
          return attendanceDate.year == date.year &&
              attendanceDate.month == date.month &&
              attendanceDate.day == date.day;
        },
      );
    } catch (e) {
      return null;
    }
  }

  /// Check if a date has attendance data
  bool hasAttendanceForDate(DateTime date) {
    return getAttendanceForDate(date) != null;
  }

  /// Get all dates with attendance in current month
  Map<String, int> get datesWithAttendance {
    int present = 0;
    int absent = 0;
    int halfDay = 0;
    int leave = 0;

    for (var attendance in scheduleData) {
      try {
        final date = DateTime.parse(attendance.attendanceDate);
        if (date.month == currentMonth && date.year == currentYear) {
          final hasCheckIn = attendance.checkinTime != null &&
              attendance.checkinTime.toString().isNotEmpty &&
              attendance.checkinTime.toString() != 'null';

          final hasCheckOut = attendance.checkoutTime != null &&
              attendance.checkoutTime.toString().isNotEmpty &&
              attendance.checkoutTime.toString() != 'null';

          if (!hasCheckIn && !hasCheckOut) {
            absent++;
          } else if (hasCheckIn && !hasCheckOut) {
            halfDay++;
          } else if (hasCheckIn && hasCheckOut) {
            present++;
          }
        }
      } catch (e) {
        continue;
      }
    }

    return {
      'present': present,
      'absent': absent,
      'halfDay': halfDay,
      'leave': leave,
    };
  }

  /// Check if error is network related
  bool get isNetworkError {
    return errorCode == 'NETWORK_ERROR' ||
        (errorMessage?.toLowerCase().contains('network') ?? false) ||
        (errorMessage?.toLowerCase().contains('connection') ?? false);
  }

  /// Check if error is server related
  bool get isServerError {
    return errorCode == 'SERVER_ERROR' ||
        (errorMessage?.toLowerCase().contains('server') ?? false) ||
        (errorMessage?.toLowerCase().contains('500') ?? false);
  }

  /// Check if error is auth related
  bool get isAuthError {
    return errorCode == 'AUTH_ERROR' ||
        (errorMessage?.toLowerCase().contains('unauthorized') ?? false) ||
        (errorMessage?.toLowerCase().contains('401') ?? false);
  }
}