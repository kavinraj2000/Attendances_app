// dashboard_state.dart

part of 'dashboard_bloc.dart';

enum DashboardLoadingStatus { initial, loading, success, failure }

enum CheckInStatus { notCheckedIn, checkedIn }

class DashboardState extends Equatable {
  final DashboardLoadingStatus loadingStatus;
  final CheckInStatus checkInStatus;
  final DateTime? checkInTime;
  final DateTime? checkOutTime;
  final List<AttendanceModel> attendanceList;
  final String? errorMessage;
  final int todaySessionsCount;
  
  // Calendar states
  final DateTime focusedDay;
  final DateTime? selectedDay;
  final CalendarFormat calendarFormat;

  const DashboardState({
    required this.loadingStatus,
    required this.checkInStatus,
    this.checkInTime,
    this.checkOutTime,
    required this.attendanceList,
    this.errorMessage,
    required this.todaySessionsCount,
    required this.focusedDay,
    this.selectedDay,
    required this.calendarFormat,
  });

  factory DashboardState.initial() {
    return DashboardState(
      loadingStatus: DashboardLoadingStatus.initial,
      checkInStatus: CheckInStatus.notCheckedIn,
      checkInTime: null,
      checkOutTime: null,
      attendanceList: const [],
      errorMessage: null,
      todaySessionsCount: 0,
      focusedDay: DateTime.now(),
      selectedDay: DateTime.now(),
      calendarFormat: CalendarFormat.month,
    );
  }

  /// Computed property: Can user check in?
  bool get canCheckIn => 
      checkInStatus == CheckInStatus.notCheckedIn &&
      loadingStatus != DashboardLoadingStatus.loading;

  /// Computed property: Can user check out?
  bool get canCheckOut => 
      checkInStatus == CheckInStatus.checkedIn &&
      checkOutTime == null &&
      loadingStatus != DashboardLoadingStatus.loading;

  /// Computed property: Elapsed working time
  Duration get elapsedTime {
    if (checkInTime == null) return Duration.zero;
    
    final endTime = checkOutTime ?? DateTime.now();
    final elapsed = endTime.difference(checkInTime!);
    
    return elapsed.isNegative ? Duration.zero : elapsed;
  }

  DashboardState copyWith({
    DashboardLoadingStatus? loadingStatus,
    CheckInStatus? checkInStatus,
    DateTime? checkInTime,
    DateTime? checkOutTime,
    List<AttendanceModel>? attendanceList,
    String? errorMessage,
    int? todaySessionsCount,
    DateTime? focusedDay,
    DateTime? selectedDay,
    CalendarFormat? calendarFormat,
  }) {
    return DashboardState(
      loadingStatus: loadingStatus ?? this.loadingStatus,
      checkInStatus: checkInStatus ?? this.checkInStatus,
      checkInTime: checkInTime ?? this.checkInTime,
      checkOutTime: checkOutTime ?? this.checkOutTime,
      attendanceList: attendanceList ?? this.attendanceList,
      errorMessage: errorMessage,
      todaySessionsCount: todaySessionsCount ?? this.todaySessionsCount,
      focusedDay: focusedDay ?? this.focusedDay,
      selectedDay: selectedDay ?? this.selectedDay,
      calendarFormat: calendarFormat ?? this.calendarFormat,
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
        todaySessionsCount,
        focusedDay,
        selectedDay,
        calendarFormat,
      ];

  @override
  String toString() {
    return 'DashboardState('
        'status: $loadingStatus, '
        'checkIn: $checkInStatus, '
        'checkInTime: $checkInTime, '
        'checkOutTime: $checkOutTime, '
        'sessions: $todaySessionsCount'
        ')';
  }
}