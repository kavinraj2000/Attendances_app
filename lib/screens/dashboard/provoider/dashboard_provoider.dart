import 'package:flutter/foundation.dart';
import 'package:geolocator/geolocator.dart';
import 'package:hrm/core/model/attances_model.dart';
import 'package:hrm/core/repo/prefernces_repo.dart';
import 'package:hrm/core/services/image_capture_service.dart';
import 'package:hrm/core/services/permission_handler.dart';
import 'package:hrm/screens/dashboard/repo/dashboard_repo.dart';
import 'package:intl/intl.dart';
import 'package:logger/logger.dart';

enum CheckInStatus { checkedIn, checkedOut, notCheckedIn }

enum DashboardLoadingStatus { initial, loading, loaded, success, failure }

class DashboardProvider extends ChangeNotifier {
  final DashboardRepository repo;
  final PreferencesRepository _prefs;
  final Logger log = Logger();

  // --- State fields ---
  DashboardLoadingStatus loadingStatus = DashboardLoadingStatus.initial;
  bool isLoading = false;
  String? errorMessage;

  List<AttendanceModel> attendanceList = [];
  String userName = '';
  CheckInStatus checkInStatus = CheckInStatus.notCheckedIn;

  DateTime? checkInTime;
  DateTime? checkOutTime;
  DateTime selectedDate = DateTime.now();
  DateTime focusedMonth = DateTime.now();

  // --- Derived getters ---
  String? get checkInTimeFormatted =>
      checkInTime != null ? DateFormat('HH:mm').format(checkInTime!) : null;

  String? get checkOutTimeFormatted =>
      checkOutTime != null ? DateFormat('HH:mm').format(checkOutTime!) : null;

  DashboardProvider(this.repo, {PreferencesRepository? prefs})
      : _prefs = prefs ?? PreferencesRepository();

  // ─── Initialize ───────────────────────────────────────────────────────────

  Future<void> initialize() async {
    loadingStatus = DashboardLoadingStatus.loading;
    isLoading = true;
    errorMessage = null;
    notifyListeners();

    try {
      final results = await Future.wait([
        repo.getAllAttendanceData(),
        _prefs.getUsername(),
      ]);

      final fetchedList = results[0] as List<AttendanceModel>;
      final fetchedName = (results[1] as String?) ?? '';

      final now = DateTime.now();
      final todayRecord = _findActiveCheckin(fetchedList, now);

      attendanceList = fetchedList;
      userName = fetchedName;
      checkInStatus = todayRecord != null
          ? CheckInStatus.checkedIn
          : CheckInStatus.notCheckedIn;
      checkInTime = todayRecord?.checkinTime;
      if (todayRecord == null) checkOutTime = null;

      loadingStatus = DashboardLoadingStatus.loaded;
      isLoading = false;

      log.d(
        'Initialize: ${attendanceList.length} records | '
        'Status: $checkInStatus | User: $userName',
      );
    } catch (e, s) {
      log.e('Initialize failed: $e\n$s');
      loadingStatus = DashboardLoadingStatus.failure;
      errorMessage = 'Failed to load dashboard';
      isLoading = false;
    }

    notifyListeners();
  }

  // ─── Check In ─────────────────────────────────────────────────────────────

  Future<void> checkIn() async {
    loadingStatus = DashboardLoadingStatus.loading;
    isLoading = true;
    errorMessage = null;
    notifyListeners();

    try {
      final granted = await requestRequiredPermissions();
      if (!granted) {
        _emitFailure('Required permissions not granted');
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

      final fetchedList = await repo.getAllAttendanceData();

      attendanceList = fetchedList;
      checkInStatus = CheckInStatus.checkedIn;
      checkInTime = DateTime.now();
      checkOutTime = null;
      loadingStatus = DashboardLoadingStatus.success;
      isLoading = false;
    } catch (e, s) {
      log.e('Check-in failed: $e\n$s');
      _emitFailure(e.toString());
      return;
    }

    notifyListeners();
  }

  // ─── Check Out ────────────────────────────────────────────────────────────

  Future<void> checkOut() async {
    if (checkInStatus != CheckInStatus.checkedIn) {
      log.w('Checkout attempted but no active check-in');
      _emitFailure('No active check-in found');
      return;
    }

    loadingStatus = DashboardLoadingStatus.loading;
    isLoading = true;
    errorMessage = null;
    notifyListeners();

    try {
      final granted = await requestRequiredPermissions();
      if (!granted) {
        _emitFailure('Required permissions not granted');
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

      final fetchedList = await repo.getAllAttendanceData();
      final now = DateTime.now();
      final todayRecord = _findTodayRecord(fetchedList, now);

      log.i('Check-out successful | Record found: ${todayRecord != null}');

      attendanceList = fetchedList;
      checkInStatus = CheckInStatus.checkedOut;
      checkInTime = todayRecord?.checkinTime;
      checkOutTime = todayRecord?.checkoutTime ?? now;
      loadingStatus = DashboardLoadingStatus.success;
      isLoading = false;
    } catch (e, s) {
      log.e('Check-out failed: $e\n$s');

      if (e.toString().contains('Already checked out') ||
          e.toString().contains('no active check-in')) {
        checkInStatus = CheckInStatus.checkedOut;
        checkInTime = null;
        checkOutTime = null;
        _emitFailure('Already checked out or no active check-in found');
        return;
      }

      final msg = e.toString().contains('permission')
          ? 'Permission denied. Please grant required permissions.'
          : e.toString().contains('network') ||
                e.toString().contains('connection')
          ? 'Network error. Please check your connection.'
          : 'Check-out failed. Please try again.';

      _emitFailure(msg);
      return;
    }

    notifyListeners();
  }

  // ─── Other actions ────────────────────────────────────────────────────────

  void selectDate(DateTime date) {
    selectedDate = date;
    notifyListeners();
  }

  void updateCalendarMonth(DateTime month) {
    focusedMonth = month;
    notifyListeners();
  }

  Future<void> refresh() async {
    try {
      final fetchedList = await repo.getAllAttendanceData();
      final now = DateTime.now();
      final activeRecord = _findActiveCheckin(fetchedList, now);

      log.d(
        'Refresh: ${fetchedList.length} records | '
        'Active: ${activeRecord != null}',
      );

      attendanceList = fetchedList;
      checkInStatus = activeRecord != null
          ? CheckInStatus.checkedIn
          : CheckInStatus.notCheckedIn;
      checkInTime = activeRecord?.checkinTime;
      checkOutTime = activeRecord == null
          ? (fetchedList.isNotEmpty ? fetchedList.first.checkoutTime : null)
          : null;
    } catch (e, s) {
      log.e('Refresh failed: $e\n$s');
      loadingStatus = DashboardLoadingStatus.failure;
      errorMessage = 'Failed to refresh data';
    }

    notifyListeners();
  }

  // ─── Helpers ──────────────────────────────────────────────────────────────

  void _emitFailure(String message) {
    loadingStatus = DashboardLoadingStatus.failure;
    errorMessage = message;
    isLoading = false;
    notifyListeners();
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