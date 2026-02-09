import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hrm/core/constants/constants.dart';
import 'package:hrm/core/model/attances_model.dart';
import 'package:hrm/core/widgets/attances_popup_widget.dart';
import 'package:hrm/screens/attendances/bloc/attendances_bloc.dart';

/// Design constants for attendance calendar
class _AttendanceConstants {
  // Colors
  static const presentColor = Color(0xFF4CAF50);
  static const absentColor = Color(0xFFEF5350);
  static const halfDayColor = Color(0xFFFF9800);
  static const leaveColor = Color(0xFF42A5F5);
  static const todayColor = Color(0xFF667EEA);
  static const selectedBorderColor = Color(0xFF667EEA);
  static const inactiveDayColor = Color(0xFFBDBDBD);
  static const weekendColor = Color(0xFFE0E0E0);

  // Text colors
  static const textPrimary = Color(0xFF212121);
  static const textSecondary = Color(0xFF757575);
  static const textTertiary = Color(0xFF9E9E9E);

  // Spacing
  static const double spacingXs = 4.0;
  static const double spacingS = 8.0;
  static const double spacingM = 12.0;
  static const double spacingL = 16.0;
  static const double spacingXl = 20.0;
  static const double spacingXxl = 24.0;

  // Sizes
  static const double dayCircleSize = 40.0;
  static const double borderRadiusS = 8.0;
  static const double borderRadiusM = 12.0;
  static const double borderRadiusL = 16.0;
}

class AttendanceLogsScreen extends StatefulWidget {
  const AttendanceLogsScreen({super.key});

  @override
  State<AttendanceLogsScreen> createState() => _AttendanceLogsScreenState();
}

class _AttendanceLogsScreenState extends State<AttendanceLogsScreen> {
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _loadInitialData();
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _loadInitialData() {
    final now = DateTime.now();
    context.read<AttendanceLogsBloc>().add(
          LoadAttendanceLogs(month: now.month, year: now.year),
        );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      body: BlocConsumer<AttendanceLogsBloc, AttendanceLogsState>(
        listener: _handleStateChanges,
        builder: (context, state) {
          if (state.status == AttendancesStatus.loading) {
            return _buildLoadingWidget();
          } else if (state.status == AttendancesStatus.error) {
            return _buildErrorWidget(state);
          } else if (state.status == AttendancesStatus.success) {
            return _buildCalendarView(state);
          }
          return _buildEmptyWidget();
        },
      ),
    );
  }

  void _scrollToCurrentMonth() {
    _scrollController.animateTo(
      0,
      duration: const Duration(milliseconds: 500),
      curve: Curves.easeInOut,
    );
  }

  void _handleStateChanges(BuildContext context, AttendanceLogsState state) {
    if (state.status == AttendancesStatus.error && state.isAuthError) {
      _showErrorSnackBar(context, 'Session expired. Please login again.');
    }
  }

  /* ---------------- LOADING WIDGET ---------------- */

  Widget _buildLoadingWidget() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(
              _AttendanceConstants.todayColor,
            ),
            strokeWidth: 3,
          ),
          const SizedBox(height: _AttendanceConstants.spacingL),
          Text(
            'Loading attendance data...',
            style: TextStyle(
              fontSize: 14,
              color: _AttendanceConstants.textSecondary,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  /* ---------------- ERROR WIDGET ---------------- */

  Widget _buildErrorWidget(AttendanceLogsState state) {
    IconData errorIcon = Icons.error_outline_rounded;
    String errorTitle = 'Error';
    String errorMessage = state.errorMessage ?? 'An error occurred';

    if (state.isNetworkError) {
      errorIcon = Icons.wifi_off_rounded;
      errorTitle = 'Connection Error';
      errorMessage = 'Please check your internet connection and try again.';
    } else if (state.isServerError) {
      errorIcon = Icons.cloud_off_rounded;
      errorTitle = 'Server Error';
      errorMessage = 'Our servers are currently experiencing issues.';
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
                color: _AttendanceConstants.todayColor.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                errorIcon,
                size: 64,
                color: _AttendanceConstants.todayColor,
              ),
            ),
            const SizedBox(height: 24),
            Text(
              errorTitle,
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w600,
                color: _AttendanceConstants.textPrimary,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              errorMessage,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14,
                color: _AttendanceConstants.textSecondary,
                height: 1.5,
              ),
            ),
            const SizedBox(height: 32),
            ElevatedButton.icon(
              onPressed: _loadInitialData,
              icon: const Icon(Icons.refresh_rounded, size: 20),
              label: const Text('Try Again'),
              style: ElevatedButton.styleFrom(
                backgroundColor: _AttendanceConstants.todayColor,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(
                  horizontal: 32,
                  vertical: 14,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(
                    _AttendanceConstants.borderRadiusM,
                  ),
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
            color: _AttendanceConstants.inactiveDayColor,
          ),
          const SizedBox(height: 16),
          const Text(
            'No attendance data',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w500,
              color: _AttendanceConstants.textSecondary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCalendarView(AttendanceLogsState state) {
    final now = DateTime.now();
    final currentYear = now.year;

    return RefreshIndicator(
      color: _AttendanceConstants.todayColor,
      onRefresh: () async {
        context.read<AttendanceLogsBloc>().add(const RefreshSchedule());
        await Future.delayed(const Duration(milliseconds: 500));
      },
      child: CustomScrollView(
        controller: _scrollController,
        physics: const AlwaysScrollableScrollPhysics(),
        slivers: [
          // Summary and Legend at top
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(_AttendanceConstants.spacingL),
              child: Column(
                children: [
                  _buildMonthlySummaryCard(state),
                  const SizedBox(height: _AttendanceConstants.spacingL),
                  _buildLegendCard(),
                  const SizedBox(height: _AttendanceConstants.spacingL),
                ],
              ),
            ),
          ),

          SliverList(
            delegate: SliverChildBuilderDelegate(
              (context, index) {
                final monthNumber = index + 1; // 1-12
                return Padding(
                  padding: const EdgeInsets.only(
                    left: _AttendanceConstants.spacingL,
                    right: _AttendanceConstants.spacingL,
                    bottom: _AttendanceConstants.spacingL,
                  ),
                  child: _buildMonthCalendar(state, monthNumber, currentYear),
                );
              },
              childCount: 12, 
            ),
          ),

          // Bottom padding
          const SliverToBoxAdapter(
            child: SizedBox(height: _AttendanceConstants.spacingXxl),
          ),
        ],
      ),
    );
  }

  Widget _buildMonthlySummaryCard(AttendanceLogsState state) {
    final stats = state.datesWithAttendance;
    final now = DateTime.now();
    final monthName = _getMonthName(now.month);

    return Container(
      padding: const EdgeInsets.all(_AttendanceConstants.spacingXl),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF667EEA), Color(0xFF764BA2)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(_AttendanceConstants.borderRadiusL),
       
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
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
                    '${now.year}',
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
          ),
          const SizedBox(height: _AttendanceConstants.spacingXl),
          Row(
            children: [
              Expanded(
                child: _buildSummaryItem(
                  'Present',
                  '${stats['present'] ?? 0}',
                  Icons.check_circle,
                ),
              ),
              Expanded(
                child: _buildSummaryItem(
                  'Absent',
                  '${stats['absent'] ?? 0}',
                  Icons.cancel,
                ),
              ),
              Expanded(
                child: _buildSummaryItem(
                  'Half Day',
                  '${stats['halfDay'] ?? 0}',
                  Icons.access_time,
                ),
              ),
              Expanded(
                child: _buildSummaryItem(
                  'Leave',
                  '${stats['leave'] ?? 0}',
                  Icons.event_busy,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryItem(String label, String count, IconData icon) {
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

  Widget _buildLegendCard() {
    return Container(
      padding: const EdgeInsets.all(_AttendanceConstants.spacingL),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(_AttendanceConstants.borderRadiusM),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _buildLegendItem('Present', _AttendanceConstants.presentColor),
              _buildLegendItem('Absent', _AttendanceConstants.absentColor),
              _buildLegendItem('Half Day', _AttendanceConstants.halfDayColor),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _buildLegendItem('Late', const Color(0xFFFFC107)),
              _buildLegendItem('Inprogress', _AttendanceConstants.todayColor),
              _buildLegendItem('Pending', const Color(0xFF6304F1)),
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
          width: 12,
          height: 12,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        const SizedBox(width: 6),
        Text(
          label,
          style: const TextStyle(
            fontSize: 12,
            color: _AttendanceConstants.textSecondary,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  Widget _buildMonthCalendar(AttendanceLogsState state, int month, int year) {
    final now = DateTime.now();
    final monthName = _getMonthName(month);
    final isCurrentMonth = month == now.month && year == now.year;

    return Container(
      padding: const EdgeInsets.all(_AttendanceConstants.spacingXl),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(_AttendanceConstants.borderRadiusL),
        border: isCurrentMonth
            ? Border.all(
                color: _AttendanceConstants.todayColor.withOpacity(0.3),
                width: 2,
              )
            : null,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    monthName,
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w700,
                      color: _AttendanceConstants.textPrimary,
                    ),
                  ),
                  Text(
                    '$year',
                    style: TextStyle(
                      fontSize: 13,
                      color: _AttendanceConstants.textTertiary,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
              if (isCurrentMonth)
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: _AttendanceConstants.todayColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: const Text(
                    'Current',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: _AttendanceConstants.todayColor,
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: _AttendanceConstants.spacingXl),
          _buildWeekDayHeaders(),
          const SizedBox(height: _AttendanceConstants.spacingM),
          _buildCalendarGrid(state, month, year),
        ],
      ),
    );
  }

  Widget _buildWeekDayHeaders() {
    final weekDays = ['S', 'M', 'T', 'W', 'T', 'F', 'S'];
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: weekDays.map((day) {
        return Expanded(
          child: Center(
            child: Text(
              day,
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: _AttendanceConstants.textTertiary,
                letterSpacing: 0.5,
              ),
            ),
          ),
        );
      }).toList(),
    );
  }

  /* ---------------- CALENDAR GRID ---------------- */

  Widget _buildCalendarGrid(AttendanceLogsState state, int month, int year) {
    final daysInMonth = DateTime(year, month + 1, 0).day;
    final firstDayOfMonth = DateTime(year, month, 1).weekday;
    List<Widget> dayWidgets = [];

    int startOffset = firstDayOfMonth % 7;

    for (int i = 0; i < startOffset; i++) {
      dayWidgets.add(const SizedBox());
    }

    for (int day = 1; day <= daysInMonth; day++) {
      final date = DateTime(year, month, day);
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
      mainAxisSpacing: _AttendanceConstants.spacingS,
      crossAxisSpacing: _AttendanceConstants.spacingS,
      children: dayWidgets,
    );
  }

  /* ---------------- DAY CELL ---------------- */

  Widget _buildDayCell(
    DateTime date,
    AttendanceModel? attendanceData,
    bool isSelected,
  ) {
    final now = DateTime.now();
    final isToday =
        date.year == now.year && date.month == now.month && date.day == now.day;
    final isFutureDate = date.isAfter(now);
    final isWeekend =
        date.weekday == DateTime.saturday || date.weekday == DateTime.sunday;

    Color? backgroundColor;
    Color textColor = _AttendanceConstants.textPrimary;
    Color? borderColor;

    if (isFutureDate) {
      textColor = _AttendanceConstants.textTertiary;
    } else if (attendanceData != null) {
      final status = _determineAttendanceStatus(attendanceData);
      backgroundColor = _getStatusColor(status);
      textColor = Colors.white;
    } else if (isToday) {
      backgroundColor = _AttendanceConstants.todayColor;
      textColor = Colors.white;
    } else if (isWeekend && !isFutureDate) {
      backgroundColor = _AttendanceConstants.weekendColor.withOpacity(0.3);
      textColor = _AttendanceConstants.textSecondary;
    }

    if (isSelected) {
      borderColor = _AttendanceConstants.selectedBorderColor;
    }

    return GestureDetector(
      onTap: isFutureDate ? null : () => _handleDayTap(date),
      child: Container(
        decoration: BoxDecoration(
          color: backgroundColor,
          shape: BoxShape.circle,
          border: borderColor != null
              ? Border.all(color: borderColor, width: 2.5)
              : null,
          boxShadow: (isToday || attendanceData != null) && !isSelected
              ? [
                  BoxShadow(
                    color: (backgroundColor ?? Colors.transparent)
                        .withOpacity(0.3),
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  ),
                ]
              : null,
        ),
        child: Center(
          child: Text(
            '${date.day}',
            style: TextStyle(
              fontSize: 14,
              fontWeight: (isToday || attendanceData != null || isSelected)
                  ? FontWeight.w700
                  : FontWeight.w500,
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

  AttendanceStatus _determineAttendanceStatus(AttendanceModel model) {
    final hasCheckIn = model.checkinTime != null &&
        model.checkinTime!.toIso8601String().isNotEmpty &&
        model.checkinTime!.toIso8601String() != 'null';

    final hasCheckOut = model.checkoutTime != null &&
        model.checkoutTime!.toIso8601String().isNotEmpty &&
        model.checkoutTime!.toIso8601String() != 'null';

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
        return _AttendanceConstants.presentColor;
      case AttendanceStatus.absent:
        return _AttendanceConstants.absentColor;
      case AttendanceStatus.halfDay:
        return _AttendanceConstants.halfDayColor;
      case AttendanceStatus.leave:
        return _AttendanceConstants.leaveColor;
    }
  }

  String _getMonthName(int month) {
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
    return months[month - 1];
  }

  void _showErrorSnackBar(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.error_outline, color: Colors.white, size: 20),
            const SizedBox(width: 12),
            Expanded(
              child: Text(message, style: const TextStyle(fontSize: 14)),
            ),
          ],
        ),
        backgroundColor: _AttendanceConstants.absentColor,
        duration: const Duration(seconds: 3),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(
            _AttendanceConstants.borderRadiusM,
          ),
        ),
        margin: const EdgeInsets.all(_AttendanceConstants.spacingL),
      ),
    );
  }
}