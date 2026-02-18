import 'dart:io';
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:geolocator/geolocator.dart';
import 'package:hrm/core/model/attances_model.dart';
import 'package:hrm/core/services/image_capture_service.dart';
import 'package:hrm/core/services/permission_handler.dart';
import 'package:hrm/screens/dashboard/repo/dashboard_repo.dart';
import 'package:intl/intl.dart';
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
    emit(
      state.copyWith(
        loadingStatus: DashboardLoadingStatus.loading,
        isLoading: true,
        clearError: true,
      ),
    );

    try {
      final attendanceList = await repo.getAllAttendanceData();
      final DateTime now = DateTime.now();

      bool isSameDay(DateTime a, DateTime b) {
        return a.year == b.year && a.month == b.month && a.day == b.day;
      }

      final AttendanceModel? todayRecord = attendanceList
          .cast<AttendanceModel?>()
          .firstWhere((item) {
            if (item == null || item.checkinTime == null) return false;
            if (item.checkoutTime != null) return false;
            if (item.attendanceStatus == 'PENDING') return false;
            return isSameDay(item.checkinTime!, now);
          }, orElse: () => null);

      final CheckInStatus checkInStatus = todayRecord != null
          ? CheckInStatus.checkedIn
          : CheckInStatus.notCheckedIn;

      log.d(
        'Initialize: Found ${attendanceList.length} records, '
        'Status: $checkInStatus',
      );

      emit(
        state.copyWith(
          loadingStatus: DashboardLoadingStatus.loaded,
          attendanceList: attendanceList,
          checkInStatus: checkInStatus,
          checkInTime: todayRecord?.checkinTime,
          clearCheckOutTime: todayRecord == null,
          isLoading: false,
        ),
      );
    } catch (e, s) {
      log.e('Initialize failed: $e\n$s');

      emit(
        state.copyWith(
          loadingStatus: DashboardLoadingStatus.failure,
          errorMessage: 'Failed to load dashboard',
          isLoading: false,
        ),
      );
    }
  }

  Future<void> _onCheckIn(CheckIn event, Emitter<DashboardState> emit) async {
    emit(
      state.copyWith(
        loadingStatus: DashboardLoadingStatus.loading,
        isLoading: true,
        clearError: true,
      ),
    );

    try {
      final granted = await requestRequiredPermissions();
      if (!granted) {
        emit(
          state.copyWith(
            loadingStatus: DashboardLoadingStatus.failure,
            errorMessage: 'Required permissions not granted',
            isLoading: false,
          ),
        );
        return;
      }

      final position = await Geolocator.getCurrentPosition();
      final imageService = ImageService();
      final File? imageFile = await imageService.captureImage();

      if (imageFile == null) throw Exception("Image capture cancelled");

      int checkStatus = 1;

      if (state.checkInTime != null) {
        final checkInTime = DateTime.parse(state.checkInTime.toString());
        final now = DateTime.now();

        final isSameDay =
            checkInTime.year == now.year &&
            checkInTime.month == now.month &&
            checkInTime.day == now.day;

        if (state.checkInTime == null || isSameDay) {
          checkStatus = 0;
        }
      }

      log.d('checkin::::checkStatus:::$checkStatus');

      log.d("Uploading image...");
      final String filename = await repo.uploadImage(file: imageFile, value: 1);

      log.d("Calling check-in API...");
      await repo.checkIn(
        lat: position.latitude,
        lng: position.longitude,
        imageName: filename,
      );

      final attendanceList = await repo.getAllAttendanceData();

      emit(
        state.copyWith(
          loadingStatus: DashboardLoadingStatus.success,
          attendanceList: attendanceList,
          checkInStatus: CheckInStatus.checkedIn,
          checkInTime: DateTime.now(),
          clearCheckOutTime: true,
          isLoading: false,
        ),
      );
    } catch (e, s) {
      log.e('Check-in failed: $e\n$s');
      emit(
        state.copyWith(
          loadingStatus: DashboardLoadingStatus.failure,
          errorMessage: e.toString(),
          isLoading: false,
        ),
      );
    }
  }

  Future<void> _onCheckOut(CheckOut event, Emitter<DashboardState> emit) async {
    if (state.checkInStatus != CheckInStatus.checkedIn) {
      log.w('Checkout attempted but no active check-in');
      emit(
        state.copyWith(
          loadingStatus: DashboardLoadingStatus.failure,
          errorMessage: 'No active check-in found',
          isLoading: false,
        ),
      );
      return;
    }

    emit(
      state.copyWith(
        loadingStatus: DashboardLoadingStatus.loading,
        isLoading: true,
        clearError: true,
      ),
    );

    try {
      final granted = await requestRequiredPermissions();
      if (!granted) {
        emit(
          state.copyWith(
            loadingStatus: DashboardLoadingStatus.failure,
            errorMessage: 'Required permissions not granted',
            isLoading: false,
          ),
        );
        return;
      }

      log.d('Getting location and capturing image for checkout...');
      final position = await Geolocator.getCurrentPosition();
      final imageService = ImageService();
      final File? imageFile = await imageService.captureImage();

      if (imageFile == null) {
        throw Exception("Image capture cancelled");
      }
      log.d('Check-out at: ${position.latitude}, ${position.longitude}');
      await repo.uploadImage(file: imageFile, value: 0);
      log.d('repo.storeImages:::$imageFile');
      final imageName = imageFile.path.split('/').last;

      await repo.checkOut(
        lat: position.latitude,
        lng: position.longitude,
        image: imageName,
      );

      log.i('Check-out successful, refreshing attendance list...');

      final attendanceList = await repo.getAllAttendanceData();
      final DateTime now = DateTime.now();

      final AttendanceModel? todayRecord = attendanceList
          .cast<AttendanceModel?>()
          .firstWhere((item) {
            if (item == null || item.checkinTime == null) return false;

            final checkinDate = DateTime(
              item.checkinTime!.year,
              item.checkinTime!.month,
              item.checkinTime!.day,
            );
            final today = DateTime(now.year, now.month, now.day);

            return checkinDate.isAtSameMomentAs(today);
          }, orElse: () => null);

      log.d('Checked out record found: ${todayRecord != null}');

      emit(
        state.copyWith(
          loadingStatus: DashboardLoadingStatus.success,
          attendanceList: attendanceList,
          checkInStatus: CheckInStatus.checkedOut,
          checkInTime: todayRecord?.checkinTime,
          checkOutTime: todayRecord?.checkoutTime ?? now,
          isLoading: false,
        ),
      );
    } catch (e, s) {
      log.e('Check-out failed: $e\n$s');

      String errorMessage = 'Check-out failed. Please try again.';
      if (e.toString().contains('Already checked out') ||
          e.toString().contains('no active check-in')) {
        errorMessage = 'Already checked out or no active check-in found';
        emit(
          state.copyWith(
            loadingStatus: DashboardLoadingStatus.failure,
            checkInStatus: CheckInStatus.checkedOut,
            clearCheckInTime: true,
            clearCheckOutTime: true,
            errorMessage: errorMessage,
            isLoading: false,
          ),
        );
        return;
      } else if (e.toString().contains('permission')) {
        errorMessage = 'Permission denied. Please grant required permissions.';
      } else if (e.toString().contains('network') ||
          e.toString().contains('connection')) {
        errorMessage = 'Network error. Please check your connection.';
      }

      emit(
        state.copyWith(
          loadingStatus: DashboardLoadingStatus.failure,
          errorMessage: errorMessage,
          isLoading: false,
        ),
      );
    }
  }

  void _onSelectDate(SelectDate event, Emitter<DashboardState> emit) {
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
    add(InitializeDashboard());
  }

  Future<void> _onRefreshDashboardData(
    RefreshDashboardData event,
    Emitter<DashboardState> emit,
  ) async {
    try {
      final attendanceList = await repo.getAllAttendanceData();
      final DateTime now = DateTime.now();

      final AttendanceModel? activeAttendance = attendanceList
          .cast<AttendanceModel?>()
          .firstWhere((item) {
            if (item == null || item.checkinTime == null) return false;
            if (item.checkoutTime != null) return false;

            final checkinDate = DateTime(
              item.checkinTime!.year,
              item.checkinTime!.month,
              item.checkinTime!.day,
            );
            final today = DateTime(now.year, now.month, now.day);

            return checkinDate.isAtSameMomentAs(today);
          }, orElse: () => null);

      log.d(
        'Refresh: Found ${attendanceList.length} records, '
        'Active: ${activeAttendance != null}',
      );

      emit(
        state.copyWith(
          attendanceList: attendanceList,
          checkInStatus: activeAttendance != null
              ? CheckInStatus.checkedIn
              : CheckInStatus.notCheckedIn,
          checkInTime: activeAttendance?.checkinTime,
          checkOutTime: activeAttendance == null
              ? (attendanceList.isNotEmpty
                    ? attendanceList.first.checkoutTime
                    : null)
              : null,
          clearCheckOutTime: activeAttendance != null,
        ),
      );
    } catch (e, s) {
      log.e('Refresh failed: $e\n$s');
      // Optionally emit error state if needed
      emit(
        state.copyWith(
          loadingStatus: DashboardLoadingStatus.failure,
          errorMessage: 'Failed to refresh data',
        ),
      );
    }
  }
}
