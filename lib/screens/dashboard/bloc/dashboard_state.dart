part of 'dashboard_bloc.dart';

enum DashboardLoadingStatus { initial, loading, success, failure }

enum CheckInStatus { checkedIn, notCheckedIn }

class DashboardState extends Equatable {
  final DashboardLoadingStatus loadingStatus;
  final CheckInStatus checkInStatus;
  final DateTime? checkInTime;
  final DateTime? checkOutTime;
  final String? errorMessage;
  final List<AttendanceModel>? attendanceList;

  const DashboardState({
    required this.loadingStatus,
    required this.checkInStatus,
    this.checkInTime,
    this.checkOutTime,
    this.errorMessage,
    this.attendanceList,
  });

  factory DashboardState.initial() {
    return const DashboardState(
      loadingStatus: DashboardLoadingStatus.initial,
      checkInStatus: CheckInStatus.notCheckedIn,
      checkInTime: null,
      checkOutTime: null,
      errorMessage: null,
      attendanceList: [],
    );
  }

  bool get canCheckIn => checkInStatus == CheckInStatus.notCheckedIn;
  bool get canCheckOut => checkInStatus == CheckInStatus.checkedIn;

  DashboardState copyWith({
    DashboardLoadingStatus? loadingStatus,
    CheckInStatus? checkInStatus,
    DateTime? checkInTime,
    bool clearCheckInTime = false,
    DateTime? checkOutTime,
    bool clearCheckOutTime = false,
    String? errorMessage,
    bool clearError = false,
    List<AttendanceModel>? attendanceList,
  }) {
    return DashboardState(
      loadingStatus: loadingStatus ?? this.loadingStatus,
      checkInStatus: checkInStatus ?? this.checkInStatus,
      checkInTime: clearCheckInTime ? null : (checkInTime ?? this.checkInTime),
      checkOutTime: clearCheckOutTime
          ? null
          : (checkOutTime ?? this.checkOutTime),
      errorMessage: clearError ? null : errorMessage,
      attendanceList: attendanceList ?? this.attendanceList,
    );
  }

  @override
  List<Object?> get props => [
    loadingStatus,
    checkInStatus,
    checkInTime,
    checkOutTime,
    errorMessage,
  ];
}
