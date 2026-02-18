import 'package:flutter/material.dart';
import 'package:hrm/core/constants/constants.dart';
import 'package:hrm/core/model/attances_model.dart';
import 'package:hrm/screens/attendances/view/mobile/attendance_widgets/day_cell_widget.dart';
import 'package:hrm/screens/attendances/bloc/attendances_bloc.dart';

class WeekRowWidget extends StatelessWidget {
  final AttendanceLogsState state;
  final int month;
  final int year;
  final int weekIndex;
  final int startOffset;
  final int daysInMonth;
  final bool isCurrentMonth;
  final bool isLastWeek;

  const WeekRowWidget({
    super.key,
    required this.state,
    required this.month,
    required this.year,
    required this.weekIndex,
    required this.startOffset,
    required this.daysInMonth,
    required this.isCurrentMonth,
    required this.isLastWeek,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        border: Border(
          bottom: !isLastWeek
              ? BorderSide(color: Constants.color.gridColor, width: 1)
              : BorderSide.none,
        ),
      ),
      child: Row(
        children: List.generate(7, (dayIndex) {
          final cellIndex = weekIndex * 7 + dayIndex;
          final dayNumber = cellIndex - startOffset + 1;
          final isLast = dayIndex == 6;

          if (cellIndex < startOffset || dayNumber > daysInMonth) {
            return _buildEmptyCell(isCurrentMonth, isLast);
          }

          final date = DateTime(year, month, dayNumber);
          final attendance = _getAttendanceForDate(date);
          final isSelected = _isDateSelected(date);

          return Expanded(
            child: Container(
              height: 60,
              decoration: BoxDecoration(
                border: Border(
                  right: !isLast
                      ? BorderSide(
                          color: Constants.color.gridColor, width: 1)
                      : BorderSide.none,
                ),
              ),
              child: DayCellWidget(
                date: date,
                attendanceData: attendance,
                isSelected: isSelected,
              ),
            ),
          );
        }),
      ),
    );
  }

  Widget _buildEmptyCell(bool isCurrentMonth, bool isLast) {
    return Expanded(
      child: Container(
        height: 60,
        decoration: BoxDecoration(
          color: isCurrentMonth
              ? Constants.color.currentMonthBg.withOpacity(0.5)
              : Colors.transparent,
          border: Border(
            right: !isLast
                ? BorderSide(color: Constants.color.gridColor, width: 1)
                : BorderSide.none,
          ),
        ),
      ),
    );
  }

  AttendanceModel? _getAttendanceForDate(DateTime date) {
    for (final item in state.scheduleData) {
      try {
        final attendanceDate =
            DateTime.parse(item.attendanceDate);
        if (attendanceDate.year == date.year &&
            attendanceDate.month == date.month &&
            attendanceDate.day == date.day) {
          return item;
        }
      } catch (_) {}
    }
    return null;
  }

  bool _isDateSelected(DateTime date) {
    if (state.selectedDate == null) return false;
    return state.selectedDate!.year == date.year &&
        state.selectedDate!.month == date.month &&
        state.selectedDate!.day == date.day;
  }
}
