part of 'dashboard_bloc.dart';

enum DashboardLoadingStatus { initial, loading, success, failure }
enum CheckInStatus { checkedIn, notCheckedIn }

class DashboardState extends Equatable {
  final DashboardLoadingStatus loadingStatus;
  final CheckInStatus checkInStatus;
  final DateTime? checkInTime;
  final DateTime? checkOutTime;
  final List<AttendanceModel> attendanceList;
  final String? errorMessage;
  final DateTime selectedDate;
  final DateTime focusedMonth;
  final Map<DateTime, List<String>> events; 

   DashboardState({
    required this.loadingStatus,
    required this.checkInStatus,
    this.checkInTime,
    this.checkOutTime,
    this.attendanceList = const [],
    this.errorMessage,
    DateTime? selectedDate,
    DateTime? focusedMonth,
    this.events = const {},
  })  : selectedDate = selectedDate ?? DateTime(2024, 1, 1),
        focusedMonth = focusedMonth ?? DateTime(2024, 1, 1);

  factory DashboardState.initial() {
    final now = DateTime.now();
    return DashboardState(
      loadingStatus: DashboardLoadingStatus.initial,
      checkInStatus: CheckInStatus.notCheckedIn,
      selectedDate: now,
      focusedMonth: DateTime(now.year, now.month, 1),
    );
  }

  List<AttendanceModel> getEventsForDate(DateTime date) {
    return attendanceList.where((attendance) {
      if (attendance.checkinTime == null) return false;
      final attendanceDate = attendance.checkinTime!;
      return attendanceDate.year == date.year &&
          attendanceDate.month == date.month &&
          attendanceDate.day == date.day;
    }).toList();
  }

  double get totalHoursWorked {
    double total = 0;
    for (var attendance in attendanceList) {
      if (attendance.checkinTime != null && attendance.checkoutTime != null) {
        final duration = attendance.checkoutTime!.difference(attendance.checkinTime!);
        total += duration.inMinutes / 60;
      }
    }
    return total;
  }

  double get todayHoursWorked {
    final today = DateTime.now();
    final todayAttendance = attendanceList.where((attendance) {
      if (attendance.checkinTime == null) return false;
      final date = attendance.checkinTime!;
      return date.year == today.year &&
          date.month == today.month &&
          date.day == today.day;
    }).toList();

    if (todayAttendance.isEmpty) return 0;

    final attendance = todayAttendance.first;
    if (attendance.checkinTime == null) return 0;

    final endTime = attendance.checkoutTime ?? DateTime.now();
    final duration = endTime.difference(attendance.checkinTime!);
    return duration.inMinutes / 60;
  }

  double get weekAttendanceRate {
    final now = DateTime.now();
    final startOfWeek = now.subtract(Duration(days: now.weekday - 1));
    
    int workDays = 0;
    int attendedDays = 0;

    for (int i = 0; i < 7; i++) {
      final day = startOfWeek.add(Duration(days: i));
      if (day.weekday != DateTime.saturday && day.weekday != DateTime.sunday) {
        workDays++;
        final hasAttendance = attendanceList.any((attendance) {
          if (attendance.checkinTime == null) return false;
          final date = attendance.checkinTime!;
          return date.year == day.year &&
              date.month == day.month &&
              date.day == day.day;
        });
        if (hasAttendance) attendedDays++;
      }
    }

    return workDays > 0 ? attendedDays / workDays : 0;
  }

  bool get isLoading => loadingStatus == DashboardLoadingStatus.loading;

  DashboardState copyWith({
    DashboardLoadingStatus? loadingStatus,
    CheckInStatus? checkInStatus,
    DateTime? checkInTime,
    DateTime? checkOutTime,
    List<AttendanceModel>? attendanceList,
    String? errorMessage,
    DateTime? selectedDate,
    DateTime? focusedMonth,
    Map<DateTime, List<String>>? events,
    bool clearError = false,
    bool clearCheckInTime = false,
    bool clearCheckOutTime = false,
  }) {
    return DashboardState(
      loadingStatus: loadingStatus ?? this.loadingStatus,
      checkInStatus: checkInStatus ?? this.checkInStatus,
      checkInTime: clearCheckInTime ? null : (checkInTime ?? this.checkInTime),
      checkOutTime: clearCheckOutTime ? null : (checkOutTime ?? this.checkOutTime),
      attendanceList: attendanceList ?? this.attendanceList,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
      selectedDate: selectedDate ?? this.selectedDate,
      focusedMonth: focusedMonth ?? this.focusedMonth,
      events: events ?? this.events,
    );
  }

  @override
  List<Object?> get props => [
        loadingStatus,
        checkInStatus,
        checkInTime,
        checkOutTime,
        attendanceList,
        errorMessage,
        selectedDate,
        focusedMonth,
        events,
      ];
}