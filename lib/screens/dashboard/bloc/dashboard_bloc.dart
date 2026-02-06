import 'dart:io';
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:geolocator/geolocator.dart';
import 'package:hrm/core/model/attances_model.dart';
import 'package:hrm/core/services/image_capture_service.dart';
import 'package:hrm/screens/dashboard/repo/dashboard_repo.dart';
import 'package:logger/logger.dart';
import 'package:table_calendar/table_calendar.dart';

part 'dashboard_event.dart';
part 'dashboard_state.dart';

class DashboardBloc extends Bloc<DashboardEvent, DashboardState> {
  final DashboardRepository repo;
  final Logger log = Logger();

  DashboardBloc(this.repo) : super(DashboardState.initial()) {
    on<InitializeDashboard>(_onInitialize);
    on<CheckIn>(_onCheckIn);
    on<CheckOut>(_onCheckOut);
  }


  Future<void> _onInitialize(
    InitializeDashboard event,
    Emitter<DashboardState> emit,
  ) async {
    emit(state.copyWith(
      loadingStatus: DashboardLoadingStatus.loading,
      clearError: true,
    ));

    try {
      final attendanceList = await repo.getAllAttendanceData();

      final AttendanceModel? activeAttendance = attendanceList
          .where((e) => e.checkoutTime == null)
          .cast<AttendanceModel?>()
          .firstOrNull;

      emit(
        state.copyWith(
          attendanceList: attendanceList,
          checkInStatus: activeAttendance != null
              ? CheckInStatus.checkedIn
              : CheckInStatus.notCheckedIn,
          checkInTime: activeAttendance?.checkinTime,
          checkOutTime: null, 
          loadingStatus: DashboardLoadingStatus.success,
        ),
      );
    } catch (e, s) {
      log.e('Initialize failed $e',);
      emit(
        state.copyWith(
          loadingStatus: DashboardLoadingStatus.failure,
          errorMessage: 'Failed to load dashboard',
        ),
      );
    }
  }


  Future<void> _onCheckIn(
    CheckIn event,
    Emitter<DashboardState> emit,
  ) async {
    if (state.checkInStatus == CheckInStatus.checkedIn) return;

    emit(state.copyWith(
      loadingStatus: DashboardLoadingStatus.loading,
      clearError: true,
    ));

    try {
      final position = await Geolocator.getCurrentPosition();
      final File? image = await captureImage();

      await repo.checkIn(
        lat: position.latitude,
        lng: position.longitude,
        imageName: image?.path.split('/').last,
      );

      final attendanceList = await repo.getAllAttendanceData();

      final activeAttendance = attendanceList
          .where((e) => e.checkoutTime == null)
          .first;

      emit(
        state.copyWith(
          attendanceList: attendanceList,
          checkInStatus: CheckInStatus.checkedIn,
          checkInTime: activeAttendance.checkinTime,
          clearCheckOutTime: true,
          loadingStatus: DashboardLoadingStatus.success,
        ),
      );
    } catch (e, s) {
      log.e('Check-in failed $e', );
      emit(
        state.copyWith(
          loadingStatus: DashboardLoadingStatus.failure,
          errorMessage: 'Check-in failed',
        ),
      );
    }
  }


  Future<void> _onCheckOut(
    CheckOut event,
    Emitter<DashboardState> emit,
  ) async {
    if (state.checkInStatus != CheckInStatus.checkedIn) return;

    emit(state.copyWith(
      loadingStatus: DashboardLoadingStatus.loading,
      clearError: true,
    ));

    try {
      final position = await Geolocator.getCurrentPosition();
      final File? image = await captureImage();

      await repo.checkOut(
        lat: position.latitude,
        lng: position.longitude,
        image: image,
      );

      final attendanceList = await repo.getAllAttendanceData();

      emit(
        state.copyWith(
          attendanceList: attendanceList,
          checkInStatus: CheckInStatus.notCheckedIn,
          clearCheckInTime: true,
          clearCheckOutTime: true,
          loadingStatus: DashboardLoadingStatus.success,
        ),
      );
    } catch (e, s) {
      log.e('Check-out failed $e',);
      emit(
        state.copyWith(
          loadingStatus: DashboardLoadingStatus.failure,
          errorMessage: 'Check-out failed',
        ),
      );
    }
  }
}
