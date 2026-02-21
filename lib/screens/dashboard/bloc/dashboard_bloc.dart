import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:geolocator/geolocator.dart';
import 'package:hrm/core/model/attances_model.dart';
import 'package:hrm/core/repo/prefernces_repo.dart';
import 'package:hrm/core/services/image_capture_service.dart';
import 'package:hrm/core/services/permission_handler.dart';
import 'package:hrm/screens/dashboard/repo/dashboard_repo.dart';
import 'package:intl/intl.dart';
import 'package:logger/logger.dart';

part 'dashboard_event.dart';
part 'dashboard_state.dart';

class DashboardBloc extends Bloc<DashboardEvent, DashboardState> {
  final DashboardRepository repo;
  final PreferencesRepository _prefs;
  final Logger log = Logger();

  DashboardBloc(this.repo, {PreferencesRepository? prefs})
    : _prefs = prefs ?? PreferencesRepository(),
      super(DashboardState.initial()) {
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
      final results = await Future.wait([
        repo.getAllAttendanceData(),
        _prefs.getUsername(),
      ]);

      final attendanceList = results[0] as List<AttendanceModel>;
      final userName = (results[1] as String?) ?? '';

      final now = DateTime.now();
      final todayRecord = _findActiveCheckin(attendanceList, now);
      final checkInStatus = todayRecord != null
          ? CheckInStatus.checkedIn
          : CheckInStatus.notCheckedIn;

      log.d(
        'Initialize: ${attendanceList.length} records | '
        'Status: $checkInStatus | User: $userName',
      );

      emit(
        state.copyWith(
          loadingStatus: DashboardLoadingStatus.loaded,
          attendanceList: attendanceList,
          userName: userName,
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
      final imageFile = await ImageService().captureImage();
      if (imageFile == null) throw Exception('Image capture cancelled');

      final filename = await repo.uploadImage(file: imageFile, value: 1);
      log.d('repo.uploadImage:::$imageFile');

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

      final position = await Geolocator.getCurrentPosition();
      final imageFile = await ImageService().captureImage();
      if (imageFile == null) throw Exception('Image capture cancelled');

      await repo.uploadImage(file: imageFile, value: 0);
      final imageName = imageFile.path.split('/').last;

      log.d('repo.uploadImage:::$imageFile');

      await repo.checkOut(
        lat: position.latitude,
        lng: position.longitude,
        image: imageName,
      );

      final attendanceList = await repo.getAllAttendanceData();
      final now = DateTime.now();
      final todayRecord = _findTodayRecord(attendanceList, now);

      log.i('Check-out successful | Record found: ${todayRecord != null}');

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

      if (e.toString().contains('Already checked out') ||
          e.toString().contains('no active check-in')) {
        emit(
          state.copyWith(
            loadingStatus: DashboardLoadingStatus.failure,
            checkInStatus: CheckInStatus.checkedOut,
            clearCheckInTime: true,
            clearCheckOutTime: true,
            errorMessage: 'Already checked out or no active check-in found',
            isLoading: false,
          ),
        );
        return;
      }

      final errorMessage = e.toString().contains('permission')
          ? 'Permission denied. Please grant required permissions.'
          : e.toString().contains('network') ||
                e.toString().contains('connection')
          ? 'Network error. Please check your connection.'
          : 'Check-out failed. Please try again.';

      emit(
        state.copyWith(
          loadingStatus: DashboardLoadingStatus.failure,
          errorMessage: errorMessage,
          isLoading: false,
        ),
      );
    }
  }

  void _onSelectDate(SelectDate event, Emitter<DashboardState> emit) =>
      emit(state.copyWith(selectedDate: event.date));

  void _onUpdateCalendarMonth(
    UpdateCalendarMonth event,
    Emitter<DashboardState> emit,
  ) => emit(state.copyWith(focusedMonth: event.month));

  Future<void> _onLoadDashboardData(
    LoadDashboardData event,
    Emitter<DashboardState> emit,
  ) async => add(InitializeDashboard());

  Future<void> _onRefreshDashboardData(
    RefreshDashboardData event,
    Emitter<DashboardState> emit,
  ) async {
    try {
      final attendanceList = await repo.getAllAttendanceData();
      final now = DateTime.now();
      final activeRecord = _findActiveCheckin(attendanceList, now);

      log.d(
        'Refresh: ${attendanceList.length} records | '
        'Active: ${activeRecord != null}',
      );

      emit(
        state.copyWith(
          attendanceList: attendanceList,
          checkInStatus: activeRecord != null
              ? CheckInStatus.checkedIn
              : CheckInStatus.notCheckedIn,
          checkInTime: activeRecord?.checkinTime,
          checkOutTime: activeRecord == null
              ? (attendanceList.isNotEmpty
                    ? attendanceList.first.checkoutTime
                    : null)
              : null,
          clearCheckOutTime: activeRecord != null,
        ),
      );
    } catch (e, s) {
      log.e('Refresh failed: $e\n$s');
      emit(
        state.copyWith(
          loadingStatus: DashboardLoadingStatus.failure,
          errorMessage: 'Failed to refresh data',
        ),
      );
    }
  }

  AttendanceModel? _findActiveCheckin(
    List<AttendanceModel> list,
    DateTime now,
  ) {
    return list.cast<AttendanceModel?>().firstWhere((item) {
      if (item == null || item.checkinTime == null) return false;
      if (item.checkoutTime != null) return false;
      if (item.attendanceStatus == 'PENDING') return false;
      return _isSameDay(item.checkinTime!, now);
    }, orElse: () => null);
  }

  AttendanceModel? _findTodayRecord(List<AttendanceModel> list, DateTime now) {
    return list.cast<AttendanceModel?>().firstWhere((item) {
      if (item == null || item.checkinTime == null) return false;
      return _isSameDay(item.checkinTime!, now);
    }, orElse: () => null);
  }

  bool _isSameDay(DateTime a, DateTime b) =>
      a.year == b.year && a.month == b.month && a.day == b.day;
}
