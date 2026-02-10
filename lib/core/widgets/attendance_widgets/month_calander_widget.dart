import 'package:flutter/material.dart';
import 'package:hrm/core/constants/constants.dart';
import 'package:hrm/core/util/attendance_util.dart';
import 'package:hrm/core/widgets/attendance_widgets/calander_grid_widget.dart';
import 'package:hrm/core/widgets/attendance_widgets/week_header_widget.dart';
import 'package:hrm/screens/attendances/bloc/attendances_bloc.dart';

class MonthCalendarWidget extends StatelessWidget {
  final AttendanceLogsState state;
  final int month;
  final int year;

  const MonthCalendarWidget({
    super.key,
    required this.state,
    required this.month,
    required this.year,
  });

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    final monthName = AttendanceUtils.getMonthName(month);
    final isCurrentMonth = month == now.month && year == now.year;

    return Container(
      decoration: BoxDecoration(
        color: isCurrentMonth
            ? Constants.color.currentMonthBg
            : Constants.color.otherMonthBg,
        borderRadius: BorderRadius.circular(Constants.color.borderRadiusM),
        border: Border.all(
          color: isCurrentMonth
              ? Constants.color.inprogressColor.withOpacity(0.5)
              : Constants.color.cardBorderColor,
          width: isCurrentMonth ? 2 : 1.5,
        ),
        boxShadow: isCurrentMonth
            ? [
                BoxShadow(
                  color: Constants.color.inprogressColor.withOpacity(0.1),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                ),
              ]
            : null,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildHeader(monthName, year, isCurrentMonth),
          _buildWeekdayHeadersSection(isCurrentMonth),
          CalendarGridWidget(
            state: state,
            month: month,
            year: year,
            isCurrentMonth: isCurrentMonth,
          ),
        ],
      ),
    );
  }

  Widget _buildHeader(String monthName, int year, bool isCurrentMonth) {
    return Container(
      padding: EdgeInsets.all(Constants.color.spacingL),
      decoration: BoxDecoration(
        color: isCurrentMonth
            ? Constants.color.inprogressColor.withOpacity(0.08)
            : Colors.transparent,
        borderRadius:  BorderRadius.only(
          topLeft: Radius.circular(Constants.color.borderRadiusM),
          topRight: Radius.circular(Constants.color.borderRadiusM),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            '$monthName $year',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: isCurrentMonth
                  ? Constants.color.inprogressColor
                  : Constants.color.textPrimary,
              letterSpacing: 0.5,
            ),
          ),
          if (isCurrentMonth) _buildCurrentMonthBadge(),
        ],
      ),
    );
  }

  Widget _buildCurrentMonthBadge() {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 12,
        vertical: 5,
      ),
      decoration: BoxDecoration(
        color: Constants.color.inprogressColor,
        borderRadius: BorderRadius.circular(12),
        // boxShadow: [
        //   BoxShadow(
        //     color: Constants.color.inprogressColor.withOpacity(0.3),
        //     blurRadius: 4,
        //     offset: const Offset(0, 2),
        //   ),
        // ],
      ),
      child: const Text(
        'Current',
        style: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w700,
          color: Colors.white,
        ),
      ),
    );
  }

  Widget _buildWeekdayHeadersSection(bool isCurrentMonth) {
    return Container(
      decoration: BoxDecoration(
        color: isCurrentMonth
            ? Colors.white.withOpacity(0.7)
            : Colors.transparent,
        border: Border(
          top: BorderSide(color: Constants.color.gridColor, width: 1),
          bottom: BorderSide(color: Constants.color.gridColor, width: 1),
        ),
      ),
      child: const WeekdayHeadersWidget(),
    );
  }
}