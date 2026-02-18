import 'package:flutter/material.dart';
import 'package:hrm/core/constants/constants.dart';

class WeekdayHeadersWidget extends StatelessWidget {
  static const _weekDays = ['SUN', 'MON', 'TUE', 'WED', 'THU', 'FRI', 'SAT'];

  const WeekdayHeadersWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: _weekDays.asMap().entries.map((entry) {
        final index = entry.key;
        final day = entry.value;
        final isWeekend = index == 0 || index == 6;
        final isLast = index == _weekDays.length - 1;

        return Expanded(
          child: _WeekdayHeaderCell(
            day: day,
            isWeekend: isWeekend,
            showRightBorder: !isLast,
          ),
        );
      }).toList(),
    );
  }
}

class _WeekdayHeaderCell extends StatelessWidget {
  final String day;
  final bool isWeekend;
  final bool showRightBorder;

  const _WeekdayHeaderCell({
    required this.day,
    required this.isWeekend,
    required this.showRightBorder,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12),
      decoration: BoxDecoration(
        border: Border(
          right: showRightBorder
              ? BorderSide(color: Constants.color.gridColor, width: 1)
              : BorderSide.none,
        ),
      ),
      child: Center(
        child: Text(
          day,
          style: TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w700,
            color: isWeekend
                ? Constants.color.textWeekend
                : Constants.color.textPrimary,
            letterSpacing: 0.3,
          ),
        ),
      ),
    );
  }
}