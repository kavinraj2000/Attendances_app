import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hrm/core/constants/constants.dart';
import 'package:hrm/core/model/attances_model.dart';
import 'package:hrm/core/widgets/attances_popup_widget.dart';
import 'package:hrm/screens/attendances/bloc/attendances_bloc.dart';

class AttendanceLogsScreen extends StatefulWidget {
  const AttendanceLogsScreen({super.key});

  @override
  State<AttendanceLogsScreen> createState() => _AttendanceLogsScreenState();
}

class _AttendanceLogsScreenState extends State<AttendanceLogsScreen> {
  @override
  void initState() {
    super.initState();
    _loadCurrentMonthData();
  }

  void _loadCurrentMonthData() {
    final now = DateTime.now();
    context.read<AttendanceLogsBloc>().add(
          LoadAttendanceLogs(month: now.month, year: now.year),
        );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Constants.color.lightColors['white'],
      body: SafeArea(
        child: BlocConsumer<AttendanceLogsBloc, AttendanceLogsState>(
          listener: _handleStateChanges,
          builder: (context, state) {
            if (state.status == AttendancesStatus.loading) {
              return _buildLoadingWidget();
            } else if (state.status == AttendancesStatus.error) {
              return _buildErrorWidget(state);
            } else if (state.status == AttendancesStatus.success) {
              return _buildLoadedContent(state);
            }
            return _buildEmptyWidget();
          },
        ),
      ),
    );
  }

  void _handleStateChanges(BuildContext context, AttendanceLogsState state) {
    if (state.status == AttendancesStatus.error && state.isAuthError) {
      _showErrorSnackBar(context, 'Session expired. Please login again.');
    }
  }

  Widget _buildLoadingWidget() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(
            color: Constants.color.lightColors['primary'],
            strokeWidth: 3,
          ),
          const SizedBox(height: 16),
          Text(
            'Loading attendance data...',
            style: TextStyle(
              fontSize: 14,
              color: Constants.color.lightColors['primary'],
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorWidget(AttendanceLogsState state) {
    IconData errorIcon = Icons.error_outline;
    String errorTitle = 'Error';
    String errorMessage = state.errorMessage ?? 'An error occurred';

    if (state.isNetworkError) {
      errorIcon = Icons.wifi_off_rounded;
      errorTitle = 'Connection Error';
      errorMessage = 'Please check your internet connection and try again.';
    } else if (state.isServerError) {
      errorIcon = Icons.cloud_off_rounded;
      errorTitle = 'Server Error';
      errorMessage =
          'Our servers are currently experiencing issues. Please try again later.';
    } else if (state.isAuthError) {
      errorIcon = Icons.lock_outline_rounded;
      errorTitle = 'Authentication Required';
      errorMessage = 'Your session has expired. Please login again.';
    }

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: Constants.color.lightColors['primary']?.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                errorIcon,
                size: 64,
                color: Constants.color.lightColors['primary'],
              ),
            ),
            const SizedBox(height: 24),
            Text(
              errorTitle,
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: Constants.color.lightColors['primary'],
              ),
            ),
            const SizedBox(height: 12),
            Text(
              errorMessage,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 15,
                color: Colors.black54,
                height: 1.5,
              ),
            ),
            const SizedBox(height: 32),
            ElevatedButton.icon(
              onPressed: _loadCurrentMonthData,
              icon: const Icon(Icons.refresh_rounded, size: 20),
              label: const Text('Try Again'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Constants.color.lightColors['primary'],
                foregroundColor: Colors.white,
                padding:
                    const EdgeInsets.symmetric(horizontal: 32, vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                elevation: 2,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyWidget() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.calendar_today_rounded,
            size: 64,
            color: Colors.grey[400],
          ),
          const SizedBox(height: 16),
          Text(
            'No Data',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: Colors.grey[600],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLoadedContent(AttendanceLogsState state) {
    return RefreshIndicator(
      onRefresh: () async {
        context.read<AttendanceLogsBloc>().add(const RefreshSchedule());
        await Future.delayed(const Duration(milliseconds: 500));
      },
      color: Constants.color.lightColors['primary'],
      child: CustomScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        slivers: [
          SliverToBoxAdapter(child: _buildCalendarSection(state)),
          SliverToBoxAdapter(child: _buildLegendSection()),
          SliverToBoxAdapter(child: _buildStatisticsSection(state)),
          const SliverToBoxAdapter(child: SizedBox(height: 20)),
        ],
      ),
    );
  }

  Widget _buildCalendarSection(AttendanceLogsState state) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Constants.color.lightColors['primary']!,
            Constants.color.lightColors['secondary']!,
          ],
        ),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Constants.color.lightColors['primary']!.withOpacity(0.3),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          _buildMonthNavigation(state),
          const SizedBox(height: 20),
          _buildWeekDayHeaders(),
          const SizedBox(height: 12),
          _buildCalendarGrid(state),
        ],
      ),
    );
  }

  Widget _buildMonthNavigation(AttendanceLogsState state) {
    final months = [
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
      'December'
    ];

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        IconButton(
          icon: const Icon(Icons.chevron_left_rounded,
              color: Colors.white, size: 28),
          onPressed: () => _navigateMonth(state, -1),
        ),
        Column(
          children: [
            Text(
              months[state.currentMonth - 1],
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.white,
                letterSpacing: 0.5,
              ),
            ),
            Text(
              '${state.currentYear}',
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: Colors.white70,
              ),
            ),
          ],
        ),
        IconButton(
          icon: const Icon(Icons.chevron_right_rounded,
              color: Colors.white, size: 28),
          onPressed: () => _navigateMonth(state, 1),
        ),
      ],
    );
  }

  void _navigateMonth(AttendanceLogsState state, int delta) {
    int newMonth = state.currentMonth + delta;
    int newYear = state.currentYear;

    if (newMonth < 1) {
      newMonth = 12;
      newYear--;
    } else if (newMonth > 12) {
      newMonth = 1;
      newYear++;
    }

    context.read<AttendanceLogsBloc>().add(
          ChangeMonth(month: newMonth, year: newYear),
        );
  }

  Widget _buildWeekDayHeaders() {
    final weekDays = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: weekDays.map((day) {
        return Expanded(
          child: Center(
            child: Text(
              day,
              style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: Colors.white,
                letterSpacing: 0.5,
              ),
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildCalendarGrid(AttendanceLogsState state) {
    final daysInMonth =
        DateTime(state.currentYear, state.currentMonth + 1, 0).day;
    final firstDayOfMonth =
        DateTime(state.currentYear, state.currentMonth, 1).weekday;
    List<Widget> dayWidgets = [];

    // Add empty cells for days before month starts
    for (int i = 0; i < firstDayOfMonth - 1; i++) {
      dayWidgets.add(const SizedBox());
    }

    // Add current month days
    for (int day = 1; day <= daysInMonth; day++) {
      final date = DateTime(state.currentYear, state.currentMonth, day);
      final attendanceData = state.getAttendanceForDate(date);
      final isSelected = state.selectedDate != null &&
          state.selectedDate!.year == date.year &&
          state.selectedDate!.month == date.month &&
          state.selectedDate!.day == date.day;

      dayWidgets.add(_buildDayCell(date, attendanceData, isSelected));
    }

    return GridView.count(
      crossAxisCount: 7,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      mainAxisSpacing: 8,
      crossAxisSpacing: 8,
      children: dayWidgets,
    );
  }

  Widget _buildDayCell(
      DateTime date, AttendanceModel? attendanceData, bool isSelected) {
    final now = DateTime.now();
    final isToday =
        date.year == now.year && date.month == now.month && date.day == now.day;

    Color? backgroundColor;
    Color textColor = Colors.white70;

    if (attendanceData != null) {
      final status = _determineAttendanceStatus(attendanceData);
      backgroundColor = _getStatusColor(status);
      textColor = Colors.white;
    } else if (isToday) {
      backgroundColor = const Color(0xFFE8A87C);
      textColor = Colors.white;
    }

    return GestureDetector(
      onTap: () => _handleDayTap(date),
      child: Container(
        decoration: BoxDecoration(
          color: backgroundColor ?? Colors.transparent,
          shape: BoxShape.circle,
          border:
              isSelected ? Border.all(color: Colors.white, width: 2.5) : null,
        ),
        child: Center(
          child: Text(
            '${date.day}',
            style: TextStyle(
              fontSize: 14,
              fontWeight: (isSelected || isToday || attendanceData != null)
                  ? FontWeight.bold
                  : FontWeight.normal,
              color: textColor,
            ),
          ),
        ),
      ),
    );
  }

  void _handleDayTap(DateTime date) {
    showAttendancePopupFromBloc(context, date);
  }

  Widget _buildLegendSection() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Legend',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 14),
          Wrap(
            spacing: 20,
            runSpacing: 12,
            children: [
              _buildLegendItem('Present', const Color(0xFF43A047)),
              _buildLegendItem('Absent', const Color(0xFFE53935)),
              _buildLegendItem('Half Day', const Color(0xFFFFA726)),
              _buildLegendItem('Today', const Color(0xFFE8A87C)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildLegendItem(String label, Color color) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 18,
          height: 18,
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: color.withOpacity(0.3),
                blurRadius: 4,
                offset: const Offset(0, 2),
              ),
            ],
          ),
        ),
        const SizedBox(width: 8),
        Text(
          label,
          style: const TextStyle(
            fontSize: 14,
            color: Colors.black87,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  Widget _buildStatisticsSection(AttendanceLogsState state) {
    final stats = state.datesWithAttendance;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Monthly Summary',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _buildStatCard(
                  'Present',
                  stats['present'] ?? 0,
                  const Color(0xFF43A047),
                  Icons.check_circle_outline,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildStatCard(
                  'Absent',
                  stats['absent'] ?? 0,
                  const Color(0xFFE53935),
                  Icons.cancel_outlined,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _buildStatCard(
                  'Half Day',
                  stats['halfDay'] ?? 0,
                  const Color(0xFFFFA726),
                  Icons.access_time_rounded,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildStatCard(
                  'Leave',
                  stats['leave'] ?? 0,
                  const Color(0xFF42A5F5),
                  Icons.event_busy_rounded,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard(String label, int count, Color color, IconData icon) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.3), width: 1),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 28),
          const SizedBox(height: 8),
          Text(
            '$count',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 13,
              color: color.withOpacity(0.8),
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  AttendanceStatus _determineAttendanceStatus(AttendanceModel model) {
    final hasCheckIn = model.checkinTime != null &&
        model.checkinTime.toString().isNotEmpty &&
        model.checkinTime.toString() != 'null';

    final hasCheckOut = model.checkoutTime != null &&
        model.checkoutTime.toString().isNotEmpty &&
        model.checkoutTime.toString() != 'null';

    if (!hasCheckIn && !hasCheckOut) {
      return AttendanceStatus.absent;
    } else if (hasCheckIn && !hasCheckOut) {
      return AttendanceStatus.halfDay;
    } else if (hasCheckIn && hasCheckOut) {
      return AttendanceStatus.present;
    }

    return AttendanceStatus.absent;
  }

  Color _getStatusColor(AttendanceStatus status) {
    switch (status) {
      case AttendanceStatus.present:
        return const Color(0xFF43A047);
      case AttendanceStatus.absent:
        return const Color(0xFFE53935);
      case AttendanceStatus.halfDay:
        return const Color(0xFFFFA726);
      case AttendanceStatus.leave:
        return const Color(0xFF42A5F5);
    }
  }

  void _showErrorSnackBar(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.error_outline, color: Colors.white),
            const SizedBox(width: 12),
            Expanded(child: Text(message)),
          ],
        ),
        backgroundColor: const Color(0xFFE53935),
        duration: const Duration(seconds: 3),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }
}