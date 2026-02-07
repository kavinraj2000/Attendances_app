import 'dart:io';
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:geolocator/geolocator.dart';
import 'package:get/get_navigation/src/root/parse_route.dart';
import 'package:hrm/core/model/attances_model.dart';
import 'package:hrm/core/services/image_capture_service.dart';
import 'package:hrm/screens/dashboard/repo/dashboard_repo.dart';
import 'package:logger/logger.dart';

part 'dashboard_event.dart';
part 'dashboard_state.dart';

class DashboardBloc extends Bloc<DashboardEvent, DashboardState> {
  final DashboardRepository repo;
  final Logger log = Logger();

  DashboardBloc(this.repo) : super(DashboardState.initial()) {
    on<InitializeDashboard>(_onInitialize);
    on<CheckIn>(_onCheckIn);
    on<CheckOut>(_onCheckOut);
    on<SelectDate>(_onSelectDate);
    on<UpdateCalendarMonth>(_onUpdateCalendarMonth);
    on<LoadDashboardData>(_onLoadDashboardData);
    on<RefreshDashboardData>(_onRefreshDashboardData);
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
    final DateTime now = DateTime.now();

    final AttendanceModel? todayRecord =
        attendanceList.firstWhereOrNull((item) {
      if (item.checkinTime == null) return false;
      if (item.checkoutTime != null) return false;
      if (item.attendanceStatus == 'PENDING') return false;

      final diff = now.difference(item.checkinTime!);
      if (diff.isNegative) return false;

      return diff.inHours <= 24; 
    });

    final CheckInStatus checkInStatus =
        todayRecord != null
            ? CheckInStatus.checkedIn
            : CheckInStatus.notCheckedIn;

    emit(
      state.copyWith(
        attendanceList: attendanceList,
        checkInStatus: checkInStatus,
        checkInTime: todayRecord?.checkinTime,
        clearCheckOutTime: todayRecord == null,
        loadingStatus: DashboardLoadingStatus.success,
      ),
    );
  } catch (e, s) {
    log.e('Initialize failed $e', );
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

    emit(state.copyWith(
      loadingStatus: DashboardLoadingStatus.loading,
      clearError: true,
    ));

    try {
      final position = await Geolocator.getCurrentPosition();
      final File? image = await captureImage();
      final attendanceList = await repo.getAllAttendanceData();

      final AttendanceModel? activeAttendance = attendanceList
          .where((e) => e.checkoutTime == null&& e.attendanceDate==DateTime.now())
          .firstOrNull;
      await repo.checkIn(
        lat: position.latitude,
        lng: position.longitude,
        imageName: image?.path.split('/').last,
      );


      // final activeAttendance =
      //     attendanceList.where((e) => e.checkoutTime == null && e.attendanceDate==DateTime.now()).first;
// log.d('_onCheckIn:activeAttendance::$activeAttendance');
      emit(
        state.copyWith(
          attendanceList: attendanceList,
          checkInStatus: CheckInStatus.checkedIn,
          // checkInTime: activeAttendance.checkinTime,
          clearCheckOutTime: true,
          loadingStatus: DashboardLoadingStatus.success,
        ),
      );
    } catch (e, s) {
      log.e('Check-in failed $e');
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

    if (state.checkInStatus != CheckInStatus.checkedIn|| state.checkInTime == null)
    {
       emit(state.copyWith(
      loadingStatus: DashboardLoadingStatus.failure,
      errorMessage: 'Already checked out or no active check-in',
    ));
    
     return;
  }

    emit(state.copyWith(
      loadingStatus: DashboardLoadingStatus.loading,
      clearError: true,
    ));

    try {
      final position = await Geolocator.getCurrentPosition();
      final File? image = await captureImage();

log.d('_onCheckOut::position::$position::::image::::${image?.absolute}:::$event');
      await repo.checkOut(
        lat: position.latitude,
        lng: position.longitude,
        image: image,
      );
      final attendanceList = await repo.getAllAttendanceData();
log.d('attendanceList::$attendanceList');
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
      log.e('Check-out failed $e');
      emit(
        state.copyWith(
          loadingStatus: DashboardLoadingStatus.failure,
          errorMessage: 'Check-out failed',
        ),
      );
    }
  }

  // Calendar event handlers
  void _onSelectDate(
    SelectDate event,
    Emitter<DashboardState> emit,
  ) {
    emit(state.copyWith(selectedDate: event.date));
  }

  void _onUpdateCalendarMonth(
    UpdateCalendarMonth event,
    Emitter<DashboardState> emit,
  ) {
    emit(state.copyWith(focusedMonth: event.month));
  }

  Future<void> _onLoadDashboardData(
    LoadDashboardData event,
    Emitter<DashboardState> emit,
  ) async {
    // This is the same as InitializeDashboard
    add(InitializeDashboard());
  }

  Future<void> _onRefreshDashboardData(
    RefreshDashboardData event,
    Emitter<DashboardState> emit,
  ) async {
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
          clearCheckOutTime: activeAttendance == null,
        ),
      );
    } catch (e) {
      log.e('Refresh failed $e');
      // Don't emit error on refresh, just keep existing state
    }
  }
}