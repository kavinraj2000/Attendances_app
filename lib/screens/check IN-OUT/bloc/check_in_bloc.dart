import 'dart:async';
import 'dart:io';

import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:geolocator/geolocator.dart';
import 'package:hrm/core/model/check_in_model.dart';
import 'package:hrm/screens/dashboard/repo/dashboard_repo.dart';
import 'package:logger/logger.dart';

part 'check_in_event.dart';
part 'check_in_state.dart';

class CheckInBloc extends Bloc<CheckInEvent, CheckInState> {
  final DashboardRepository repo;
  Timer? _timer;
  final Logger log = Logger();

  CheckInBloc(this.repo) : super(CheckInState.initial()) {
    on<PerformCheckIn>(_onPerformCheckIn);
    on<PerformCheckOut>(_onPerformCheckOut);
    on<UpdateTimer>(_onUpdateTimer);
    on<ResetCheckIn>(_onResetCheckIn);
    on<StopTimer>(_onStopTimer);
    on<LoadExistingCheckIn>(_onLoadExistingCheckIn);
  }

  Future<void> _onPerformCheckIn(
    PerformCheckIn event,
    Emitter<CheckInState> emit,
  ) async {
    if (state.isCheckedIn) {
      emit(state.copyWith(errorMessage: 'Already checked in'));
      return;
    }

    emit(
      state.copyWith(
        loadingStatus: CheckInLoadingStatus.loading,
        errorMessage: null,
      ),
    );

    try {
      // 1️⃣ Capture image if required
      File? imageFile;
      if (event.captureImage) {
        imageFile = await repo.captureImage();
        if (imageFile == null && event.imageRequired) {
          emit(
            state.copyWith(
              loadingStatus: CheckInLoadingStatus.failure,
              errorMessage: 'Image capture is required',
            ),
          );
          return;
        }
      }

      // 2️⃣ Get GPS location
      final position = await _getLocation(emit);
      if (position == null) return;

      log.d('CheckIn::position=${position.latitude},${position.longitude}');

      // 3️⃣ Call check-in API
      final model = await repo.addCheckin(
        // employeeId: event.employeeId,
        latitude: position.latitude,
        longitude: position.longitude,
        imageFile: imageFile,
        // createdBy: event.createdBy,
      );

      log.d(
        'CheckIn Success: employeeId=${model.employeeId}, attendanceId=${model.attendanceId}',
      );

      // 4️⃣ Update state
      emit(
        state.copyWith(
          isCheckedIn: true,
          checkInTime: model.checkinTime ?? DateTime.now(),
          elapsedTime: Duration.zero,
          checkInModel: model,
          attendanceId: model.attendanceId,
          employeeId: model.employeeId,
          latitude: position.latitude,
          longitude: position.longitude,
          loadingStatus: CheckInLoadingStatus.success,
          errorMessage: null,
        ),
      );

      // 5️⃣ Start timer if requested
      if (event.startTimer) {
        _startTimer();
      }

      log.i('✅ Check-in successful');
    } catch (e) {
      log.e('❌ Check-in failed: $e');
      emit(
        state.copyWith(
          loadingStatus: CheckInLoadingStatus.failure,
          errorMessage: 'Check-in failed: ${e.toString()}',
        ),
      );
    }
  }

  // ─────────────────────────────────────────────
  // CHECK-OUT
  // ─────────────────────────────────────────────

  Future<void> _onPerformCheckOut(
    PerformCheckOut event,
    Emitter<CheckInState> emit,
  ) async {
    if (!state.isCheckedIn) {
      emit(state.copyWith(errorMessage: 'Not checked in yet'));
      return;
    }

    if (state.attendanceId == null || state.employeeId == null) {
      emit(state.copyWith(errorMessage: 'Missing attendance information'));
      return;
    }

    emit(
      state.copyWith(
        loadingStatus: CheckInLoadingStatus.loading,
        errorMessage: null,
      ),
    );

    try {
      // 1️⃣ Capture image if required
      File? imageFile;
      if (event.captureImage) {
        imageFile = await repo.captureImage();
        if (imageFile == null && event.imageRequired) {
          emit(
            state.copyWith(
              loadingStatus: CheckInLoadingStatus.failure,
              errorMessage: 'Image capture is required',
            ),
          );
          return;
        }
      }

      // 2️⃣ Get GPS location
      final position = await _getLocation(emit);
      if (position == null) return;

      log.d('CheckOut::position=${position.latitude},${position.longitude}');

      final model = await repo.addCheckin(
        // employeeId: state.employeeId!,
        latitude: position.latitude,
        longitude: position.longitude,
        imageFile: imageFile,
      );

      log.d('CheckOut Success: attendanceId=${model.attendanceId}');

      // 4️⃣ Stop timer
      _stopTimer();

      // 5️⃣ Update state
      emit(
        state.copyWith(
          isCheckedIn: false,
          checkOutTime: model.checkoutTime ?? DateTime.now(),
          checkOutModel: model,
          loadingStatus: CheckInLoadingStatus.success,
          errorMessage: null,
        ),
      );

      log.i('✅ Check-out successful');
    } catch (e) {
      log.e('❌ Check-out failed: $e');
      emit(
        state.copyWith(
          loadingStatus: CheckInLoadingStatus.failure,
          errorMessage: 'Check-out failed: ${e.toString()}',
        ),
      );
    }
  }

  // ─────────────────────────────────────────────
  // TIMER
  // ─────────────────────────────────────────────

  void _onUpdateTimer(UpdateTimer event, Emitter<CheckInState> emit) {
    if (state.isCheckedIn && state.checkInTime != null) {
      final elapsed = DateTime.now().difference(state.checkInTime!);
      emit(state.copyWith(elapsedTime: elapsed));
    }
  }

  void _startTimer() {
    _timer?.cancel();
    _timer = Timer.periodic(
      const Duration(seconds: 1),
      (_) => add(const UpdateTimer()),
    );
    log.d('⏱️  Timer started');
  }

  void _stopTimer() {
    _timer?.cancel();
    _timer = null;
    log.d('⏱️  Timer stopped');
  }

  void _onStopTimer(StopTimer event, Emitter<CheckInState> emit) {
    _stopTimer();
  }

  // ─────────────────────────────────────────────
  // RESET / LOAD
  // ─────────────────────────────────────────────

  void _onResetCheckIn(ResetCheckIn event, Emitter<CheckInState> emit) {
    _stopTimer();
    emit(CheckInState.initial());
    log.i('🔄 Check-in reset');
  }

  void _onLoadExistingCheckIn(
    LoadExistingCheckIn event,
    Emitter<CheckInState> emit,
  ) {
    final elapsed = DateTime.now().difference(event.checkInTime);

    emit(
      state.copyWith(
        isCheckedIn: true,
        checkInTime: event.checkInTime,
        elapsedTime: elapsed,
        attendanceId: event.attendanceId,
        employeeId: event.employeeId,
        checkInModel: event.checkInModel,
      ),
    );

    if (event.startTimer) {
      _startTimer();
    }

    log.i('📥 Existing check-in loaded');
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

      if (permission == LocationPermission.deniedForever ||
          permission == LocationPermission.denied) {
        emit(
          state.copyWith(
            loadingStatus: CheckInLoadingStatus.failure,
            errorMessage: 'Location permission denied',
          ),
        );
        return null;
      }

      return await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );
    } catch (e) {
      log.e('📍 Location error: $e');
      emit(
        state.copyWith(
          loadingStatus: CheckInLoadingStatus.failure,
          errorMessage: 'Unable to fetch location: ${e.toString()}',
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
