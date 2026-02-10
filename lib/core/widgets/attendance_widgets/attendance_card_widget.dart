import 'package:flutter/material.dart';
import 'package:hrm/core/constants/constants.dart';

class AttendanceLegendCard extends StatelessWidget {
  const AttendanceLegendCard({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(Constants.color.spacingL),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(Constants.color.borderRadiusM),
        border: Border.all(color: Constants.color.cardBorderColor),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _LegendItem(
                label: 'Present',
                color: Constants.color.presentColor,
              ),
              _LegendItem(label: 'Absent', color: Constants.color.absentColor),
              _LegendItem(label: 'Late', color: Constants.color.lateColor),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _LegendItem(
                label: 'Inprogress',
                color: Constants.color.inprogressColor,
              ),
              _LegendItem(
                label: 'Pending',
                color: Constants.color.pendingColor,
              ),
              const SizedBox(width: 80),
            ],
          ),
        ],
      ),
    );
  }
}

class _LegendItem extends StatelessWidget {
  final String label;
  final Color color;

  const _LegendItem({required this.label, required this.color});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 10,
          height: 10,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        const SizedBox(width: 6),
        Text(
          label,
          style: TextStyle(
            fontSize: 11,
            color: Constants.color.textSecondary,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }
}
