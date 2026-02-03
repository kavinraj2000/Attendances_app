part of 'check_in_bloc.dart';

abstract class CheckInEvent extends Equatable {
  const CheckInEvent();

  @override
  List<Object?> get props => [];
}

// ─────────────────────────────────────────────
// CHECK-IN
// ─────────────────────────────────────────────

class PerformCheckIn extends CheckInEvent {
  final int employeeId;
  final String createdBy;
  final bool captureImage;
  final bool imageRequired;
  final bool startTimer;

  const PerformCheckIn({
    required this.employeeId,
    required this.createdBy,
    this.captureImage = true,
    this.imageRequired = false,
    this.startTimer = true,
  });

  @override
  List<Object?> get props => [
        employeeId,
        createdBy,
        captureImage,
        imageRequired,
        startTimer,
      ];
}

// ─────────────────────────────────────────────
// CHECK-OUT
// ─────────────────────────────────────────────

class PerformCheckOut extends CheckInEvent {
  final bool captureImage;
  final bool imageRequired;
  final String? updatedBy;

  const PerformCheckOut({
    this.captureImage = true,
    this.imageRequired = false,
    this.updatedBy,
  });

  @override
  List<Object?> get props => [captureImage, imageRequired, updatedBy];
}

// ─────────────────────────────────────────────
// TIMER
// ─────────────────────────────────────────────

class UpdateTimer extends CheckInEvent {
  const UpdateTimer();
}

class StopTimer extends CheckInEvent {
  const StopTimer();
}

// ─────────────────────────────────────────────
// RESET / LOAD
// ─────────────────────────────────────────────

class ResetCheckIn extends CheckInEvent {
  const ResetCheckIn();
}

class LoadExistingCheckIn extends CheckInEvent {
  final DateTime checkInTime;
  final int attendanceId;
  final int employeeId;
  final CheckInModel? checkInModel;
  final bool startTimer;

  const LoadExistingCheckIn({
    required this.checkInTime,
    required this.attendanceId,
    required this.employeeId,
    this.checkInModel,
    this.startTimer = true,
  });

  @override
  List<Object?> get props => [
        checkInTime,
        attendanceId,
        employeeId,
        checkInModel,
        startTimer,
      ];
}