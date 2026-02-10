import 'package:flutter/material.dart';
import 'package:hrm/core/widgets/attendance_widgets/week_row_widget.dart';
import 'package:hrm/screens/attendances/bloc/attendances_bloc.dart';


class CalendarGridWidget extends StatelessWidget {
  final AttendanceLogsState state;
  final int month;
  final int year;
  final bool isCurrentMonth;

  const CalendarGridWidget({
    super.key,
    required this.state,
    required this.month,
    required this.year,
    required this.isCurrentMonth,
  });

  @override
  Widget build(BuildContext context) {
    final daysInMonth = DateTime(year, month + 1, 0).day;
    final firstDayOfMonth = DateTime(year, month, 1).weekday;

    final startOffset = firstDayOfMonth % 7;
    final totalCells = startOffset + daysInMonth;
    final numberOfWeeks = (totalCells / 7).ceil();

    return Column(
      children: List.generate(numberOfWeeks, (weekIndex) {
        final isLastWeek = weekIndex == numberOfWeeks - 1;

        return WeekRowWidget(
          state: state,
          month: month,
          year: year,
          weekIndex: weekIndex,
          startOffset: startOffset,
          daysInMonth: daysInMonth,
          isCurrentMonth: isCurrentMonth,
          isLastWeek: isLastWeek,
        );
      }),
    );
  }
}