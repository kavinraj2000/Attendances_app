import 'package:flutter/foundation.dart';
import 'package:hrm/core/enum/attendance_status.dart';
import 'package:hrm/core/model/attances_model.dart';
import 'package:hrm/screens/attendances/repo/attendances_repo.dart';
import 'package:logger/logger.dart';

// ─── Status Enum ─────────────────────────────────────────────────────────────

enum AttendanceLogStatus { initial, loading, success, error }

// ─── Provider ────────────────────────────────────────────────────────────────

class AttendanceLogProvider extends ChangeNotifier {
  final AttendancesRepo repo;
  final _log = Logger();

  AttendanceLogProvider({required this.repo}) {
    final now = DateTime.now();
    _currentMonth = now.month;
    _currentYear = now.year;
    _selectedDate = now;
    _currentDate = now;
  }

  // ── Private fields ────────────────────────────────────────────────────────

  AttendanceLogStatus _status = AttendanceLogStatus.initial;

  /// True only during a month navigation fetch — keeps the existing
  /// calendar visible while new data loads instead of showing a full spinner.
  bool _isChangingMonth = false;

  List<AttendanceModel> _scheduleData = [];
  Map<AttendanceStatus, int> _summary = {
    for (var s in AttendanceStatus.values) s: 0,
  };

  late int _currentMonth;
  late int _currentYear;
  DateTime? _currentDate;
  DateTime? _selectedDate;
  String? _errorMessage;
  String? _errorCode;

  // ── Public getters ────────────────────────────────────────────────────────

  AttendanceLogStatus get status => _status;

  /// True while a month-change fetch is in progress.
  /// Use this to show a subtle overlay/shimmer instead of a full-screen spinner.
  bool get isChangingMonth => _isChangingMonth;

  List<AttendanceModel> get scheduleData => _scheduleData;
  Map<AttendanceStatus, int> get summary => _summary;
  int get currentMonth => _currentMonth;
  int get currentYear => _currentYear;
  DateTime? get currentDate => _currentDate;
  DateTime? get selectedDate => _selectedDate;
  String? get errorMessage => _errorMessage;
  String? get errorCode => _errorCode;

  // ── Computed helpers ──────────────────────────────────────────────────────

  AttendanceModel? recordForDate(DateTime date) {
    for (final r in _scheduleData) {
      try {
        final d = DateTime.parse(r.attendanceDate.toString());
        if (d.year == date.year &&
            d.month == date.month &&
            d.day == date.day) {
          return r;
        }
      } catch (_) {}
    }
    return null;
  }

  // ── Actions ───────────────────────────────────────────────────────────────

  /// Initial load — shows the full-screen spinner.
  Future<void> loadAttendanceLogs({
    required int month,
    required int year,
  }) async {
    _setLoading();
    try {
      final data = await repo.getAllAttendanceData();
      final filtered = _filterByMonth(data, month, year);
      _setSuccess(filtered, month: month, year: year);
    } catch (e, st) {
      _log.e('Load error', error: e, stackTrace: st);
      _setError('Failed to load attendance', 'LOAD_FAILED');
    }
  }

  /// Month navigation — updates month/year immediately so the top bar and
  /// calendar header reflect the change instantly, then fetches silently with
  /// only [isChangingMonth] = true. No full-screen spinner.
  Future<void> changeMonth(DateTime newDate) async {
    // ✅ Immediately update month + year + selectedDate so the UI header
    //    snaps to the new month without waiting for the fetch
    _currentMonth = newDate.month;
    _currentYear = newDate.year;
    _selectedDate = newDate;
    _errorMessage = null;
    _errorCode = null;
    _isChangingMonth = true;
    notifyListeners(); // header updates, calendar shows overlay — no spinner

    try {
      final data = await repo.getAllAttendanceData();
      final filtered = _filterByMonth(data, newDate.month, newDate.year);
      _setSuccess(filtered, month: newDate.month, year: newDate.year);
    } catch (e, st) {
      _log.e('ChangeMonth error', error: e, stackTrace: st);
      _setError('Failed to load attendance', 'LOAD_FAILED');
    } finally {
      _isChangingMonth = false;
      notifyListeners();
    }
  }

  /// Silent background refresh — no loading spinner shown.
  Future<void> refreshSchedule() async {
    try {
      final data = await repo.getAllAttendanceData();
      final filtered = _filterByMonth(data, _currentMonth, _currentYear);
      _setSuccess(filtered, month: _currentMonth, year: _currentYear);
    } catch (e, st) {
      _log.e('Refresh error', error: e, stackTrace: st);
      _setError('Failed to refresh', 'REFRESH_FAILED');
    }
  }

  void selectDate(DateTime date) {
    _selectedDate = date;
    notifyListeners();
  }

  void clearSelectedDate() {
    _selectedDate = null;
    notifyListeners();
  }

  // ── Private helpers ───────────────────────────────────────────────────────

  void _setLoading() {
    _status = AttendanceLogStatus.loading;
    _isChangingMonth = false;
    _errorMessage = null;
    _errorCode = null;
    notifyListeners();
  }

  void _setSuccess(
    List<AttendanceModel> data, {
    required int month,
    required int year,
  }) {
    _status = AttendanceLogStatus.success;
    _scheduleData = data;
    _summary = _calculateSummary(data);
    _currentMonth = month;
    _currentYear = year;
    _currentDate = DateTime.now();
    _errorMessage = null;
    _errorCode = null;
    _isChangingMonth = false;
    notifyListeners();
  }

  void _setError(String message, String code) {
    _status = AttendanceLogStatus.error;
    _errorMessage = message;
    _errorCode = code;
    _isChangingMonth = false;
    notifyListeners();
  }

  List<AttendanceModel> _filterByMonth(
    List<AttendanceModel> data,
    int month,
    int year,
  ) {
    return data.where((a) {
      try {
        final d = DateTime.parse(a.attendanceDate.toString());
        return d.year == year && d.month == month;
      } catch (_) {
        return false;
      }
    }).toList();
  }

  Map<AttendanceStatus, int> _calculateSummary(List<AttendanceModel> data) {
    final summary = {for (var s in AttendanceStatus.values) s: 0};
    for (final a in data) {
      if (a.attendanceStatus != null) {
        summary.update(a.attendanceStatus!, (v) => v + 1);
      }
    }
    return summary;
  }
}