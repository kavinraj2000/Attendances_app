import 'dart:io';

import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:geolocator/geolocator.dart';
import 'package:hrm/core/model/attances_model.dart';
import 'package:hrm/core/services/image_capture_service.dart';
import 'package:hrm/screens/dashboard/repo/dashboard_repo.dart';
import 'package:logger/logger.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:intl/intl.dart';

part 'dashboard_event.dart';
part 'dashboard_state.dart';

class DashboardBloc extends Bloc<DashboardEvent, DashboardState> {
  final DashboardRepository repo;
  final Logger log = Logger();

  bool _isProcessing = false;

  DashboardBloc(this.repo) : super(DashboardState.initial()) {
    on<InitializeDashboard>(_onInitialize);
    on<CheckIn>(_onCheckIn);
    on<CheckOut>(_onCheckOut);
    // on<RefreshDashboard>(_onRefresh);
    on<SelectDay>(_onSelectDay);
    on<ChangeCalendarFormat>(_onChangeCalendarFormat);
    on<ChangePage>(_onChangePage);
  }

  Future<void> _onInitialize(
    InitializeDashboard event,
    Emitter<DashboardState> emit,
  ) async {
    emit(state.copyWith(loadingStatus: DashboardLoadingStatus.loading));

    try {
      final attendance = await repo.getAllAttendanceData();
      final todayAttendance = await _getTodayAttendance();

      emit(
        state.copyWith(
          attendanceList: attendance,
          checkInStatus: _determineCheckInStatus(todayAttendance),
          checkInTime: todayAttendance?.checkinTime,
          checkOutTime: todayAttendance?.checkoutTime,
          todaySessionsCount: _countTodaySessions(attendance),
          loadingStatus: DashboardLoadingStatus.success,
          errorMessage: null,
        ),
      );
    } catch (e, stackTrace) {
      log.e('Failed to initialize dashboard', error: e, stackTrace: stackTrace);
      emit(
        state.copyWith(
          loadingStatus: DashboardLoadingStatus.failure,
          errorMessage: 'Failed to load dashboard data',
        ),
      );
    }
  }

  Future<void> _onCheckIn(CheckIn event, Emitter<DashboardState> emit) async {
    if (_isProcessing) {
      log.w('Check-in already in progress');
      return;
    }

    if (!state.canCheckIn) {
      log.w('Cannot check in - already checked in');
      emit(
        state.copyWith(
          loadingStatus: DashboardLoadingStatus.failure,
          errorMessage: 'You are already checked in',
        ),
      );
      return;
    }

    _isProcessing = true;

    try {
      emit(state.copyWith(loadingStatus: DashboardLoadingStatus.loading));

      final position = await _getLocation(emit);
      if (position == null) {
        _isProcessing = false;
        return;
      }

      final File? image = await _captureImageSafely();

      String? imageName;
      if (image != null) {
        imageName = image.path.split('/').last;
      }

      final attendance = await repo.checkIn(
        lat: position.latitude,
        lng: position.longitude,
        imageName: imageName,
      );

      emit(
        state.copyWith(
          checkInStatus: CheckInStatus.checkedIn,
          checkInTime: attendance.checkinTime,
          checkOutTime: null,
          todaySessionsCount: state.todaySessionsCount + 1,
          loadingStatus: DashboardLoadingStatus.success,
          errorMessage: null,
        ),
      );

    
      
      log.i('Check-in successful at ${attendance.checkinTime}');
    } catch (e, stackTrace) {
      log.e('Check-in failed', error: e, stackTrace: stackTrace);
      emit(
        state.copyWith(
          loadingStatus: DashboardLoadingStatus.failure,
          errorMessage: _getUserFriendlyErrorMessage(e),
        ),
      );
    } finally {
      _isProcessing = false;
    }
  }

  Future<void> _onCheckOut(CheckOut event, Emitter<DashboardState> emit) async {
    if (_isProcessing) {
      log.w('Check-out already in progress');
      return;
    }

    if (!state.canCheckOut) {
      log.w('Cannot check out - not checked in');
      emit(
        state.copyWith(
          loadingStatus: DashboardLoadingStatus.failure,
          errorMessage: 'You need to check in first',
        ),
      );
      return;
    }

    _isProcessing = true;

    try {
      emit(state.copyWith(loadingStatus: DashboardLoadingStatus.loading));

      final position = await _getLocation(emit);
      if (position == null) {
        _isProcessing = false;
        return;
      }

      final File? image = await _captureImageSafely();

      await repo.checkOut(
        lat: position.latitude,
        lng: position.longitude,
        image: image,
      );

      final checkOutTime = DateTime.now();

      emit(
        state.copyWith(
          checkInStatus: CheckInStatus.notCheckedIn,
          checkOutTime: checkOutTime,
          loadingStatus: DashboardLoadingStatus.success,
          errorMessage: null,
        ),
      );

      add(RefreshDashboard());
      
      log.i('Check-out successful at $checkOutTime');
    } catch (e, stackTrace) {
      log.e('Check-out failed', error: e, stackTrace: stackTrace);
      emit(
        state.copyWith(
          loadingStatus: DashboardLoadingStatus.failure,
          errorMessage: _getUserFriendlyErrorMessage(e),
        ),
      );
    // } finally {
    //   _isProcessing = false;
    }
  }

  // Future<void> _onRefresh(
  //   RefreshDashboard event,
  //   Emitter<DashboardState> emit,
  // ) async {
  //   try {
  //     final attendance = await repo.getAllAttendanceData();
  //     final todayAttendance = await _getTodayAttendance();

  //     emit(
  //       state.copyWith(
  //         attendanceList: attendance,
  //         todaySessionsCount: _countTodaySessions(attendance),
  //         checkInTime: todayAttendance?.checkinTime,
  //         checkOutTime: todayAttendance?.checkoutTime,
  //         checkInStatus: _determineCheckInStatus(todayAttendance),
  //       ),
  //     );
  //   } catch (e, stackTrace) {
  //     log.e('Refresh failed', error: e, stackTrace: stackTrace);
  //   }
  // }

  void _onSelectDay(SelectDay e, Emitter<DashboardState> emit) {
    emit(state.copyWith(
      selectedDay: e.selectedDay,
      focusedDay: e.focusedDay,
    ));
  }

  void _onChangeCalendarFormat(
    ChangeCalendarFormat e,
    Emitter<DashboardState> emit,
  ) {
    emit(state.copyWith(calendarFormat: e.format));
  }

  void _onChangePage(ChangePage e, Emitter<DashboardState> emit) {
    emit(state.copyWith(focusedDay: e.focusedDay));
  }


  Future<Position?> _getLocation(Emitter<DashboardState> emit) async {
    try {
      var permission = await Geolocator.checkPermission();
      
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
      }

      if (permission == LocationPermission.denied ||
          permission == LocationPermission.deniedForever) {
        emit(
          state.copyWith(
            loadingStatus: DashboardLoadingStatus.failure,
            errorMessage: 'Location permission is required for attendance',
          ),
        );
        return null;
      }

      final position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
        timeLimit: const Duration(seconds: 10),
      );

      return position;
    } catch (e) {
      log.e('Failed to get location', error: e);
      emit(
        state.copyWith(
          loadingStatus: DashboardLoadingStatus.failure,
          errorMessage: 'Failed to get your location',
        ),
      );
      return null;
    }
  }

  Future<File?> _captureImageSafely() async {
    try {
      final image = await captureImage();
      return image;
    } catch (e) {
      log.e('Failed to capture image', error: e);
      return null;
    }
  }

  Future<AttendanceModel?> _getTodayAttendance() async {
    try {
      return await repo.getAttendanceDataByDate(date: DateTime.now());
    } catch (e) {
      log.e('Failed to get today\'s attendance', error: e);
      return null;
    }
  }

  CheckInStatus _determineCheckInStatus(AttendanceModel? todayAttendance) {
    if (todayAttendance == null) {
      return CheckInStatus.notCheckedIn;
    }

    if (todayAttendance.checkinTime != null && 
        todayAttendance.checkoutTime == null) {
      return CheckInStatus.checkedIn;
    }

    if (todayAttendance.checkoutTime != null) {
      return CheckInStatus.notCheckedIn;
    }

    return CheckInStatus.notCheckedIn;
  }

  int _countTodaySessions(List<AttendanceModel> attendance) {
    final today = DateFormat('yyyy-MM-dd').format(DateTime.now());
    return attendance.where((e) => e.attendanceDate == today).length;
  }

  String _getUserFriendlyErrorMessage(dynamic error) {
    final errorString = error.toString().toLowerCase();

    if (errorString.contains('network') || errorString.contains('socket')) {
      return 'Network error. Please check your connection';
    }
    
    if (errorString.contains('timeout')) {
      return 'Request timed out. Please try again';
    }
    
    if (errorString.contains('permission')) {
      return 'Permission denied. Please grant required permissions';
    }
    
    if (errorString.contains('user not logged in')) {
      return 'Session expired. Please login again';
    }

    if (error is Exception) {
      final message = error.toString().replaceFirst('Exception: ', '');
      if (message.isNotEmpty && message.length < 100) {
        return message;
      }
    }

    return 'An error occurred. Please try again';
  }
}