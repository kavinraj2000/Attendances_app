part of 'dashboard_bloc.dart';

enum CheckInStatus { checkedIn, checkedOut, notCheckedIn }

enum DashboardLoadingStatus { initial, loading,loaded, success, failure }

class DashboardState extends Equatable {
  final List<AttendanceModel> attendanceList;
  final CheckInStatus checkInStatus;
  final DateTime? checkInTime;
  final DateTime? checkOutTime;
  final DateTime selectedDate;
  final DateTime focusedMonth;
  final DashboardLoadingStatus loadingStatus;
  final String? errorMessage;
  final bool isLoading; 

  const DashboardState({
    required this.attendanceList,
    required this.checkInStatus,
    this.checkInTime,
    this.checkOutTime,
    required this.selectedDate,
    required this.focusedMonth,
    required this.loadingStatus,
    this.errorMessage,
    this.isLoading = false,
  });

  factory DashboardState.initial() {
    final now = DateTime.now();
    return DashboardState(
      attendanceList: const [],
      checkInStatus: CheckInStatus.notCheckedIn,
      checkInTime: null,
      checkOutTime: null,
      selectedDate: now,
      focusedMonth: now,
      loadingStatus: DashboardLoadingStatus.initial,
      errorMessage: null,
      isLoading: false,
    );
  }

  // Helper getters for formatting
  String? get checkInTimeFormatted {
    if (checkInTime == null) return null;
    return DateFormat('hh:mm a').format(checkInTime!);
  }

  String? get checkOutTimeFormatted {
    if (checkOutTime == null) return null;
    return DateFormat('hh:mm a').format(checkOutTime!);
  }

  String get totalWorkingHours {
    if (checkInTime == null) return '00h 00m hrs';
    
    final endTime = checkOutTime ?? DateTime.now();
    final duration = endTime.difference(checkInTime!);
    
    final hours = duration.inHours;
    final minutes = duration.inMinutes.remainder(60);
    
    return '${hours.toString().padLeft(2, '0')}h ${minutes.toString().padLeft(2, '0')}m hrs';
  }

  String get extraWorkingHours {
    if (checkInTime == null) return '-- hrs';
    
    final endTime = checkOutTime ?? DateTime.now();
    final duration = endTime.difference(checkInTime!);
    
    // Assuming 8 hours is standard working time
    const standardHours = 8;
    final totalHours = duration.inHours;
    
    if (totalHours <= standardHours) return '-- hrs';
    
    final extraHours = totalHours - standardHours;
    return '$extraHours hrs';
  }

  DashboardState copyWith({
    List<AttendanceModel>? attendanceList,
    CheckInStatus? checkInStatus,
    DateTime? checkInTime,
    DateTime? checkOutTime,
    DateTime? selectedDate,
    DateTime? focusedMonth,
    DashboardLoadingStatus? loadingStatus,
    String? errorMessage,
    bool? isLoading,
    bool clearCheckInTime = false,
    bool clearCheckOutTime = false,
    bool clearError = false,
  }) {
    return DashboardState(
      attendanceList: attendanceList ?? this.attendanceList,
      checkInStatus: checkInStatus ?? this.checkInStatus,
      checkInTime: clearCheckInTime ? null : (checkInTime ?? this.checkInTime),
      checkOutTime: clearCheckOutTime ? null : (checkOutTime ?? this.checkOutTime),
      selectedDate: selectedDate ?? this.selectedDate,
      focusedMonth: focusedMonth ?? this.focusedMonth,
      loadingStatus: loadingStatus ?? this.loadingStatus,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
      isLoading: isLoading ?? this.isLoading,
    );
  }

  @override
  List<Object?> get props => [
        attendanceList,
        checkInStatus,
        checkInTime,
        checkOutTime,
        selectedDate,
        focusedMonth,
        loadingStatus,
        errorMessage,
        isLoading,
      ];
}