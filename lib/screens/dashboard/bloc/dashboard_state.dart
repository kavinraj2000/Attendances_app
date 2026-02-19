part of 'dashboard_bloc.dart';

enum DashboardLoadingStatus { initial, loading, loaded, success, failure }

enum CheckInStatus { notCheckedIn, checkedIn, checkedOut }

class DashboardState extends Equatable {
  const DashboardState({
    required this.loadingStatus,
    required this.isLoading,
    required this.checkInStatus,
    required this.userName,
    required this.attendanceList,
    this.checkInTime,
    this.checkOutTime,
    this.selectedDate,
    this.focusedMonth,
    this.errorMessage,
  });

  final DashboardLoadingStatus loadingStatus;
  final bool isLoading;
  final CheckInStatus checkInStatus;
  final String userName;
  final List<AttendanceModel> attendanceList;
  final DateTime? checkInTime;
  final DateTime? checkOutTime;
  final DateTime? selectedDate;
  final DateTime? focusedMonth;
  final String? errorMessage;

  factory DashboardState.initial() => const DashboardState(
        loadingStatus: DashboardLoadingStatus.initial,
        isLoading: false,
        checkInStatus: CheckInStatus.notCheckedIn,
        userName: '',
        attendanceList: [],
      );

  // Formatted helpers consumed directly by the UI
  String? get checkInTimeFormatted =>
      checkInTime != null ? DateFormat('hh:mm a').format(checkInTime!) : null;

  String? get checkOutTimeFormatted =>
      checkOutTime != null ? DateFormat('hh:mm a').format(checkOutTime!) : null;

  DashboardState copyWith({
    DashboardLoadingStatus? loadingStatus,
    bool? isLoading,
    CheckInStatus? checkInStatus,
    String? userName,
    List<AttendanceModel>? attendanceList,
    DateTime? checkInTime,
    DateTime? checkOutTime,
    DateTime? selectedDate,
    DateTime? focusedMonth,
    String? errorMessage,
    // Explicit clear flags — needed because copyWith can't distinguish
    // "pass null to clear" vs "don't change the field"
    bool clearCheckInTime = false,
    bool clearCheckOutTime = false,
    bool clearError = false,
  }) {
    return DashboardState(
      loadingStatus: loadingStatus ?? this.loadingStatus,
      isLoading: isLoading ?? this.isLoading,
      checkInStatus: checkInStatus ?? this.checkInStatus,
      userName: userName ?? this.userName,
      attendanceList: attendanceList ?? this.attendanceList,
      checkInTime: clearCheckInTime ? null : (checkInTime ?? this.checkInTime),
      checkOutTime:
          clearCheckOutTime ? null : (checkOutTime ?? this.checkOutTime),
      selectedDate: selectedDate ?? this.selectedDate,
      focusedMonth: focusedMonth ?? this.focusedMonth,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
    );
  }

  @override
  List<Object?> get props => [
        loadingStatus,
        isLoading,
        checkInStatus,
        userName,
        attendanceList,
        checkInTime,
        checkOutTime,
        selectedDate,
        focusedMonth,
        errorMessage,
      ];
}