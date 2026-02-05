import 'package:hrm/core/model/attances_model.dart';

class AttendanceHelper {
  // ───────────────────────── DATE HELPERS ─────────────────────────

  static DateTime midnight(DateTime date) =>
      DateTime(date.year, date.month, date.day);

  // ───────────────────────── MAP BUILDER ─────────────────────────

  /// Builds calendar map: Date -> AttendanceModel
  static Map<DateTime, AttendanceModel> buildAttendanceMap(
    List<AttendanceModel> attendanceList,
  ) {
    final map = <DateTime, AttendanceModel>{};

    for (final attendance in attendanceList) {
      final rawDate = attendance.attendanceDate;
      if (rawDate == null) continue;

      try {
        final parsedDate = DateTime.parse(rawDate);
        map[midnight(parsedDate)] = attendance;
      } catch (_) {
        // Skip invalid date formats safely
      }
    }

    return map;
  }

  // ───────────────────────── POPUP DATA BUILDER ─────────────────────────

  /// Builds structured data for attendance popup
  static Map<String, dynamic> buildSchedule(AttendanceModel attendance) {
    return {
      'date': attendance.attendanceDate,
      'checkInTime': attendance.checkinTime,
      'checkOutTime': attendance.checkoutTime,
      'workingHours': attendance.attendanceDate,
      'status': attendance.attendanceDate,
      'location': attendance.checkoutLatitude,
    };
  }

  // ───────────────────────── STATUS CODE ─────────────────────────

  static int? getStatusCode(String? status) {
    if (status == null) return null;

    switch (status.toUpperCase()) {
      case 'PRESENT':
        return 1;
      case 'ABSENT':
        return 2;
      case 'HALF_DAY':
      case 'HALFDAY':
        return 3;
      case 'LEAVE':
        return 4;
      case 'HOLIDAY':
        return 5;
      default:
        return null;
    }
  }
}
