import 'dart:async';
import 'dart:io';

import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:geolocator/geolocator.dart';
import 'package:hrm/core/model/check_in_model.dart';
import 'package:hrm/screens/dashboard/repo/dashboard_repo.dart';
import 'package:hrm/screens/login/repo/login_repo.dart';
import 'package:logger/logger.dart';
import 'package:table_calendar/table_calendar.dart';

part 'dashboard_event.dart';
part 'dashboard_state.dart';

class DashboardBloc extends Bloc<DashboardEvent, DashboardState> {
  final DashboardRepository repo;
  Timer? _timer;
  final Logger log = Logger();

  DashboardBloc(this.repo) : super(DashboardState.initial()) {
    on<InitializeDashboard>(_onInitializeDashboard);
    on<CheckIn>(_onCheckIn);
    on<CheckOut>(_onCheckOut);
    on<UpdateTimer>(_onUpdateTimer);
    on<SelectDay>(_onSelectDay);
    on<ChangeCalendarFormat>(_onChangeCalendarFormat);
    on<ChangePage>(_onChangePage);
  }

  // ─────────────────────────────────────────────
  // INITIALIZE
  // ─────────────────────────────────────────────
  Future<void> _onInitializeDashboard(
    InitializeDashboard event,
    Emitter<DashboardState> emit,
  ) async {
    emit(
      state.copyWith(
        currentEmployeeId: event.employeeId,
        loadingStatus: DashboardLoadingStatus.success,
      ),
    );
  }

  // ─────────────────────────────────────────────
  // CHECK-IN
  // ─────────────────────────────────────────────
  Future<void> _onCheckIn(CheckIn event, Emitter<DashboardState> emit) async {
    if (state.currentEmployeeId == null) {
      emit(
        state.copyWith(
          loadingStatus: DashboardLoadingStatus.failure,
          errorMessage: 'Employee ID missing',
        ),
      );
      return;
    }

    emit(
      state.copyWith(
        loadingStatus: DashboardLoadingStatus.loading,
        errorMessage: null,
      ),
    );

    try {
      // 1️⃣ Get location
      final position = await _getLocation(emit);
      if (position == null) return;

      // 2️⃣ OPTIONAL image (safe)
      File? imageFile;
      try {
        imageFile = await repo.captureImage();
      } catch (e) {
        log.w('Image capture failed, continuing without image: $e');
        imageFile = null;
      }

      // 3️⃣ Call API (employeeId from STATE ✅)
      final CheckInModel model = await repo.addCheckin(
        // employeeId: state.currentEmployeeId!,
        latitude: position.latitude,
        longitude: position.longitude,
        imageFile: imageFile,
      );

      emit(
        state.copyWith(
          checkInStatus: CheckInStatus.checkedIn,
          checkInTime: model.checkinTime ?? DateTime.now(),
          elapsedTime: Duration.zero,
          checkInModel: model,
          currentAttendanceId: model.attendanceId,
          loadingStatus: DashboardLoadingStatus.success,
        ),
      );

      _startTimer();
      log.i('Check-in success');
    } catch (e) {
      log.e('Check-in error: $e');
      emit(
        state.copyWith(
          loadingStatus: DashboardLoadingStatus.failure,
          errorMessage: 'Check-in failed: ${e.toString()}',
        ),
      );
    }
  }

  // ─────────────────────────────────────────────
  // CHECK-OUT
  // ─────────────────────────────────────────────
  Future<void> _onCheckOut(CheckOut event, Emitter<DashboardState> emit) async {
    // ✅ FIX: Only check for employeeId, not attendanceId
    // since attendanceId might not be returned by the API

    // ✅ FIX: Check if user is actually checked in
    if (state.checkInStatus != CheckInStatus.checkedIn) {
      emit(
        state.copyWith(
          loadingStatus: DashboardLoadingStatus.failure,
          errorMessage: 'Please check in first',
        ),
      );
      return;
    }

    emit(
      state.copyWith(
        loadingStatus: DashboardLoadingStatus.loading,
        errorMessage: null,
      ),
    );

    try {
      // 1️⃣ Get location
      final position = await _getLocation(emit);
      if (position == null) return;

      // 2️⃣ OPTIONAL image (safe)
      File? imageFile;
      try {
        imageFile = await repo.captureImage();
      } catch (e) {
        log.w('Image capture failed, continuing without image: $e');
        imageFile = null;
      }
      final LoginRepo _loginRepo = LoginRepo();

      final userData = await _loginRepo.getUserData();
      final id = await _loginRepo.getEmployeeId();
      final model = await repo.addCheckout(
        // employeeId: id!,
        latitude: position.latitude,
        longitude: position.longitude,
        imageFile: imageFile,
        // updatedBy: userData?.username,
      );

      // 4️⃣ Stop timer
      _stopTimer();

      // 5️⃣ Update state
      emit(
        state.copyWith(
          checkInStatus: CheckInStatus.checkedOut,
          checkOutTime: model.checkoutTime ?? DateTime.now(),
          checkOutModel: model,
          loadingStatus: DashboardLoadingStatus.success,
        ),
      );

      log.i('Check-out success');
    } catch (e) {
      log.e('Check-out error: $e');
      emit(
        state.copyWith(
          loadingStatus: DashboardLoadingStatus.failure,
          errorMessage: 'Check-out failed: ${e.toString()}',
        ),
      );
    }
  }

  // ─────────────────────────────────────────────
  // TIMER
  // ─────────────────────────────────────────────
  void _onUpdateTimer(UpdateTimer event, Emitter<DashboardState> emit) {
    emit(
      state.copyWith(
        elapsedTime: state.elapsedTime + const Duration(seconds: 1),
      ),
    );
  }

  void _startTimer() {
    _timer?.cancel();
    _timer = Timer.periodic(
      const Duration(seconds: 1),
      (_) => add(const UpdateTimer()),
    );
  }

  void _stopTimer() {
    _timer?.cancel();
    _timer = null;
  }

  // ─────────────────────────────────────────────
  // CALENDAR
  // ─────────────────────────────────────────────
  void _onSelectDay(SelectDay event, Emitter<DashboardState> emit) {
    emit(
      state.copyWith(
        selectedDay: event.selectedDay,
        focusedDay: event.focusedDay,
      ),
    );
  }

  void _onChangeCalendarFormat(
    ChangeCalendarFormat event,
    Emitter<DashboardState> emit,
  ) {}

  void _onChangePage(ChangePage event, Emitter<DashboardState> emit) {
    emit(state.copyWith(focusedDay: event.focusedDay));
  }

  // ─────────────────────────────────────────────
  // LOCATION
  // ─────────────────────────────────────────────
  Future<Position?> _getLocation(Emitter emit) async {
    try {
      LocationPermission permission = await Geolocator.checkPermission();

      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
      }

      if (permission == LocationPermission.denied ||
          permission == LocationPermission.deniedForever) {
        emit(
          state.copyWith(
            loadingStatus: DashboardLoadingStatus.failure,
            errorMessage: 'Location permission denied',
          ),
        );
        return null;
      }

      return await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );
    } catch (e) {
      log.e('Location error: $e');
      emit(
        state.copyWith(
          loadingStatus: DashboardLoadingStatus.failure,
          errorMessage: 'Unable to fetch location',
        ),
      );
      return null;
    }
  }

  @override
  Future<void> close() {
    _stopTimer();
    return super.close();
  }
}
