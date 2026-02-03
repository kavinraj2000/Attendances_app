part of 'dashboard_bloc.dart';

enum CheckInStatus { notCheckedIn, checkedIn, checkedOut }

enum DashboardLoadingStatus { initial, loading, success, failure }

class DashboardState extends Equatable {
  final CheckInStatus checkInStatus;
  final DashboardLoadingStatus loadingStatus;
  final DateTime? checkInTime;
  final DateTime? checkOutTime;
  final Duration elapsedTime;
  final CheckInModel? checkInModel;
  final CheckInModel? checkOutModel;
  final int? currentAttendanceId;
  final int currentEmployeeId;
  final String? errorMessage;
  final DateTime selectedDay;
  final DateTime focusedDay;
  final CalendarFormat calendarFormat;
  final Map<DateTime, int> attendanceData;

  const DashboardState({
    required this.checkInStatus,
    required this.loadingStatus,
    this.checkInTime,
    this.checkOutTime,
    required this.elapsedTime,
    this.checkInModel,
    this.checkOutModel,
    this.currentAttendanceId,
    required this.currentEmployeeId,
    this.errorMessage,
    required this.selectedDay,
    required this.focusedDay,
    required this.calendarFormat,
    required this.attendanceData,
  });

  factory DashboardState.initial() {
    final now = DateTime.now();
    return DashboardState(
      checkInStatus: CheckInStatus.notCheckedIn,
      loadingStatus: DashboardLoadingStatus.initial,
      elapsedTime: Duration.zero,
      selectedDay: now,
      focusedDay: now,
      calendarFormat: CalendarFormat.month,
      attendanceData: {},
      currentEmployeeId: 0,
    );
  }

  DashboardState copyWith({
    CheckInStatus? checkInStatus,
    DashboardLoadingStatus? loadingStatus,
    DateTime? checkInTime,
    DateTime? checkOutTime,
    Duration? elapsedTime,
    CheckInModel? checkInModel,
    CheckInModel? checkOutModel,
    int? currentAttendanceId,
    int? currentEmployeeId,
    String? errorMessage,
    DateTime? selectedDay,
    DateTime? focusedDay,
    CalendarFormat? calendarFormat,
    Map<DateTime, int>? attendanceData,
  }) {
    return DashboardState(
      checkInStatus: checkInStatus ?? this.checkInStatus,
      loadingStatus: loadingStatus ?? this.loadingStatus,
      checkInTime: checkInTime ?? this.checkInTime,
      checkOutTime: checkOutTime ?? this.checkOutTime,
      elapsedTime: elapsedTime ?? this.elapsedTime,
      checkInModel: checkInModel ?? this.checkInModel,
      checkOutModel: checkOutModel ?? this.checkOutModel,
      currentAttendanceId: currentAttendanceId ?? this.currentAttendanceId,
      currentEmployeeId: currentEmployeeId ?? this.currentEmployeeId,
      errorMessage: errorMessage,
      selectedDay: selectedDay ?? this.selectedDay,
      focusedDay: focusedDay ?? this.focusedDay,
      calendarFormat: calendarFormat ?? this.calendarFormat,
      attendanceData: attendanceData ?? this.attendanceData,
    );
  }

  @override
  List<Object?> get props => [
    checkInStatus,
    loadingStatus,
    checkInTime,
    checkOutTime,
    elapsedTime,
    checkInModel,
    checkOutModel,
    currentAttendanceId,
    currentEmployeeId,
    errorMessage,
    selectedDay,
    focusedDay,
    calendarFormat,
    attendanceData,
  ];
}
