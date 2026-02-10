import 'package:flutter/material.dart';
import 'package:hrm/core/constants/constants.dart';
import 'package:hrm/core/model/attances_model.dart';
import 'package:hrm/core/util/attendance_util.dart';
import 'package:hrm/core/widgets/attances_popup_widget.dart';

class DayCellWidget extends StatelessWidget {
  final DateTime date;
  final AttendanceModel? attendanceData;
  final bool isSelected;

  const DayCellWidget({
    super.key,
    required this.date,
    this.attendanceData,
    this.isSelected = false,
  });

  @override
  Widget build(BuildContext context) {
    final cellStyle = _getCellStyle();

    return GestureDetector(
      onTap: cellStyle.isFutureDate ? null : () => _handleDayTap(context),
      child: Container(
        margin: const EdgeInsets.all(4),
        decoration: BoxDecoration(
          color: cellStyle.backgroundColor,
          borderRadius: BorderRadius.circular(Constants.color.borderRadiusS),
          border: isSelected
              ? Border.all(
                  color: Constants.color.selectedBorderColor,
                  width: 2,
                )
              : null,
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              '${date.day}',
              style: TextStyle(
                fontSize: 16,
                fontWeight: cellStyle.hasAttendance || cellStyle.isToday
                    ? FontWeight.w700
                    : FontWeight.w600,
                color: cellStyle.textColor,
              ),
            ),
            if (cellStyle.hasAttendance) ...[
              const SizedBox(height: 3),
              _buildStatusIndicator(),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildStatusIndicator() {
    return Container(
      width: 6,
      height: 6,
      decoration: BoxDecoration(
        color: AttendanceUtils.getStatusColor(attendanceData?.attendanceStatus),
        shape: BoxShape.circle,
      ),
    );
  }

  void _handleDayTap(BuildContext context) {
    showAttendancePopupFromBloc(context, date);
  }

  _DayCellStyle _getCellStyle() {
    final now = DateTime.now();
    final isToday = date.year == now.year &&
        date.month == now.month &&
        date.day == now.day;
    final isFutureDate = date.isAfter(now);
    final isWeekend =
        date.weekday == DateTime.saturday || date.weekday == DateTime.sunday;
    final hasAttendance = attendanceData != null;

    Color? backgroundColor;
    Color textColor = Constants.color.textPrimary;

    if (isFutureDate) {
      textColor = Constants.color.textTertiary;
    } else if (hasAttendance) {
      backgroundColor = Colors.transparent;
      textColor = isWeekend
          ? Constants.color.textWeekend
          : Constants.color.textPrimary;
    } else if (isToday) {
      backgroundColor = Constants.color.todayColor;
      textColor = Colors.white;
    } else if (isWeekend) {
      textColor = Constants.color.textWeekend;
    }

    return _DayCellStyle(
      backgroundColor: backgroundColor,
      textColor: textColor,
      isToday: isToday,
      isFutureDate: isFutureDate,
      isWeekend: isWeekend,
      hasAttendance: hasAttendance,
    );
  }
}

class _DayCellStyle {
  final Color? backgroundColor;
  final Color textColor;
  final bool isToday;
  final bool isFutureDate;
  final bool isWeekend;
  final bool hasAttendance;

  const _DayCellStyle({
    this.backgroundColor,
    required this.textColor,
    required this.isToday,
    required this.isFutureDate,
    required this.isWeekend,
    required this.hasAttendance,
  });
}