import 'package:flutter/material.dart';
import 'package:hrm/core/constants/constants.dart';
import 'package:hrm/core/util/attendance_util.dart';
import 'package:hrm/screens/attendances/bloc/attendances_bloc.dart';
import 'package:logger/logger.dart';


class MonthlySummaryCard extends StatelessWidget {
  final AttendanceLogsState state;

  const MonthlySummaryCard({
    super.key,
    required this.state,
  });

  @override
  Widget build(BuildContext context) {
    final log=Logger();
    final stats = state.attendanceSummary;
    log.d('stats = state.attendanceSummary::::$stats');
    final now = DateTime.now();
    final monthName = AttendanceUtils.getMonthName(now.month);

    return Container(
      padding:  EdgeInsets.all(Constants.app.spacingXl),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF667EEA), Color.fromARGB(255, 117, 136, 242)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(Constants.app.borderRadiusL),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildHeader(monthName, now.year),
           SizedBox(height: Constants.app.spacingXl),
          _buildStatistics(stats),
        ],
      ),
    );
  }

  Widget _buildHeader(String monthName, int year) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              monthName,
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.w700,
                color: Colors.white,
              ),
            ),
            Text(
              '$year',
              style: TextStyle(
                fontSize: 14,
                color: Colors.white.withOpacity(0.8),
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.2),
            borderRadius: BorderRadius.circular(12),
          ),
          child: const Icon(
            Icons.calendar_month_rounded,
            color: Colors.white,
            size: 28,
          ),
        ),
      ],
    );
  }

  Widget _buildStatistics(Map<String, dynamic> stats) {
    Logger().d('_buildStatistics:::$stats');
    return Row(
      
      children: [
        Expanded(
          child: _SummaryStatItem(
            label: 'Present',
            count: '${stats['PRESENT'] ?? 0}',
            icon: Icons.check_circle,
          ),
        ),
        Expanded(
          child: _SummaryStatItem(
            label: 'Absent',
            count: '${stats['ABSENT'] ?? 0}',
            icon: Icons.cancel,
          ),
        ),
        Expanded(
          child: _SummaryStatItem(
            label: 'Late',
            count: '${stats['LATE'] ?? 0}',
            icon: Icons.access_time,
          ),
        ),
        Expanded(
          child: _SummaryStatItem(
            label: 'Pending',
            count: '${stats['INPROGRESS'] ?? 0}',
            icon: Icons.event_busy,
          ),
        ),
      ],
    );
  }
}

class _SummaryStatItem extends StatelessWidget {
  final String label;
  final String count;
  final IconData icon;

  const _SummaryStatItem({
    required this.label,
    required this.count,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Icon(icon, color: Colors.white, size: 24),
        const SizedBox(height: 6),
        Text(
          count,
          style: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w700,
            color: Colors.white,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          label,
          style: TextStyle(
            fontSize: 11,
            color: Colors.white.withOpacity(0.9),
            fontWeight: FontWeight.w500,
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }
}