part of 'check_in_bloc.dart';

enum CheckInLoadingStatus {
  initial,
  loading,
  success,
  failure,
}

class CheckInState extends Equatable {
  final bool isCheckedIn;
  final DateTime? checkInTime;
  final DateTime? checkOutTime;
  final Duration elapsedTime;
  final CheckInModel? checkInModel;
  final CheckInModel? checkOutModel;
  final int? attendanceId;
  final int? employeeId;
  final double? latitude;
  final double? longitude;
  final CheckInLoadingStatus loadingStatus;
  final String? errorMessage;

  const CheckInState({
    required this.isCheckedIn,
    this.checkInTime,
    this.checkOutTime,
    required this.elapsedTime,
    this.checkInModel,
    this.checkOutModel,
    this.attendanceId,
    this.employeeId,
    this.latitude,
    this.longitude,
    required this.loadingStatus,
    this.errorMessage,
  });

  factory CheckInState.initial() {
    return const CheckInState(
      isCheckedIn: false,
      elapsedTime: Duration.zero,
      loadingStatus: CheckInLoadingStatus.initial,
    );
  }

  CheckInState copyWith({
    bool? isCheckedIn,
    DateTime? checkInTime,
    DateTime? checkOutTime,
    Duration? elapsedTime,
    CheckInModel? checkInModel,
    CheckInModel? checkOutModel,
    int? attendanceId,
    int? employeeId,
    double? latitude,
    double? longitude,
    CheckInLoadingStatus? loadingStatus,
    String? errorMessage,
  }) {
    return CheckInState(
      isCheckedIn: isCheckedIn ?? this.isCheckedIn,
      checkInTime: checkInTime ?? this.checkInTime,
      checkOutTime: checkOutTime ?? this.checkOutTime,
      elapsedTime: elapsedTime ?? this.elapsedTime,
      checkInModel: checkInModel ?? this.checkInModel,
      checkOutModel: checkOutModel ?? this.checkOutModel,
      attendanceId: attendanceId ?? this.attendanceId,
      employeeId: employeeId ?? this.employeeId,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      loadingStatus: loadingStatus ?? this.loadingStatus,
      errorMessage: errorMessage,
    );
  }

  @override
  List<Object?> get props => [
        isCheckedIn,
        checkInTime,
        checkOutTime,
        elapsedTime,
        checkInModel,
        checkOutModel,
        attendanceId,
        employeeId,
        latitude,
        longitude,
        loadingStatus,
        errorMessage,
      ];
}