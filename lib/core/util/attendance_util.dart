import 'package:flutter/material.dart';
import 'package:hrm/core/constants/constants.dart';

class AttendanceUtils {
  AttendanceUtils._(); 

  static String getMonthName(int month) {
    const months = [
      'January',
      'February',
      'March',
      'April',
      'May',
      'June',
      'July',
      'August',
      'September',
      'October',
      'November',
      'December',
    ];

    if (month < 1 || month > 12) {
      throw ArgumentError('Month must be between 1 and 12');
    }

    return months[month - 1];
  }

  static String getMonthNameShort(int month) {
    return getMonthName(month).substring(0, 3);
  }

  static Color getStatusColor(String? status) {
    if (status == null) return Constants.color.inactiveDayColor;

    switch (status.toUpperCase()) {
      case 'PRESENT':
        return Constants.color.presentColor;
      case 'ABSENT':
        return Constants.color.absentColor;
      case 'LATE':
        return Constants.color.lateColor;
      case 'PENDING':
        return Constants.color.pendingColor;
      case 'INPROGRESS':
        return Constants.color.inprogressColor;
      case 'LEAVE':
        return Constants.color.leaveColor;
      case 'HALFDAY':
        return Constants.color.halfDayColor;
      default:
        return Constants.color.inactiveDayColor;
    }
  }

  static String getStatusLabel(String? status) {
    if (status == null) return 'Unknown';

    switch (status.toUpperCase()) {
      case 'PRESENT':
        return 'Present';
      case 'ABSENT':
        return 'Absent';
      case 'LATE':
        return 'Late';
      case 'PENDING':
        return 'Pending';
      case 'INPROGRESS':
        return 'In Progress';
      case 'LEAVE':
        return 'On Leave';
      case 'HALFDAY':
        return 'Half Day';
      default:
        return status;
    }
  }

  static bool isWeekend(DateTime date) {
    return date.weekday == DateTime.saturday || date.weekday == DateTime.sunday;
  }

  static bool isToday(DateTime date) {
    final now = DateTime.now();
    return date.year == now.year &&
        date.month == now.month &&
        date.day == now.day;
  }

  static bool isFutureDate(DateTime date) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final checkDate = DateTime(date.year, date.month, date.day);
    return checkDate.isAfter(today);
  }

  static bool isSameDay(DateTime date1, DateTime date2) {
    return date1.year == date2.year &&
        date1.month == date2.month &&
        date1.day == date2.day;
  }

  static int getDaysInMonth(int year, int month) {
    return DateTime(year, month + 1, 0).day;
  }

  static int getFirstDayOfMonth(int year, int month) {
    return DateTime(year, month, 1).weekday % 7;
  }

  static Map<String, int> calculateStatistics(
    List<DateTime> dates,
    Map<DateTime, String> attendanceMap,
  ) {
    final stats = {
      'present': 0,
      'absent': 0,
      'late': 0,
      'pending': 0,
      'leave': 0,
      'halfday': 0,
      'inprogress': 0,
    };

    for (final date in dates) {
      final status = attendanceMap[date]?.toUpperCase();
      if (status == null) continue;

      switch (status) {
        case 'PRESENT':
          stats['present'] = (stats['present'] ?? 0) + 1;
          break;
        case 'ABSENT':
          stats['absent'] = (stats['absent'] ?? 0) + 1;
          break;
        case 'LATE':
          stats['late'] = (stats['late'] ?? 0) + 1;
          break;
        case 'PENDING':
          stats['pending'] = (stats['pending'] ?? 0) + 1;
          break;
        case 'LEAVE':
          stats['leave'] = (stats['leave'] ?? 0) + 1;
          break;
        case 'HALFDAY':
          stats['halfday'] = (stats['halfday'] ?? 0) + 1;
          break;
        case 'INPROGRESS':
          stats['inprogress'] = (stats['inprogress'] ?? 0) + 1;
          break;
      }
    }

    return stats;
  }

  static String formatDate(DateTime date) {
    return '${getMonthName(date.month)} ${date.day}, ${date.year}';
  }

  static String formatDateShort(DateTime date) {
    return '${getMonthNameShort(date.month)} ${date.day}';
  }
}
