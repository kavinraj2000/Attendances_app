import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hrm/core/constants/constants.dart';
import 'package:hrm/core/helper/attendances_helper.dart';
import 'package:hrm/core/model/attances_model.dart';
import 'package:hrm/screens/dashboard/bloc/dashboard_bloc.dart';
import 'package:table_calendar/table_calendar.dart';

class DashboardMobileView extends StatelessWidget {
  const DashboardMobileView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Constants.color.lightColors['primary'],
      body: BlocConsumer<DashboardBloc, DashboardState>(
        listener: _handleStateChanges,
        builder: (context, state) {
          if (state.loadingStatus == DashboardLoadingStatus.loading &&
              state.attendanceList.isEmpty) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }

          return _buildBody(context, state);
        },
      ),
    );
  }


  void _handleStateChanges(BuildContext context, DashboardState state) {
    if (state.loadingStatus == DashboardLoadingStatus.failure &&
        state.errorMessage != null) {
      _showErrorSnackbar(context, state.errorMessage!);
      return;
    }

    if (state.loadingStatus == DashboardLoadingStatus.success) {
      _handleSuccessStates(context, state);
    }
  }

  void _handleSuccessStates(BuildContext context, DashboardState state) {
    if (state.checkInStatus == CheckInStatus.checkedIn &&
        state.checkOutTime == null &&
        state.checkInTime != null) {
      _showSuccessSnackbar(
        context,
        'Checked in successfully at ${_formatTime(state.checkInTime!)}',
      );
    }

    if (state.checkOutTime != null &&
        state.checkInStatus == CheckInStatus.notCheckedIn) {
      _showInfoSnackbar(
        context,
        'Checked out successfully at ${_formatTime(state.checkOutTime!)}',
      );
    }
  }


  Widget _buildBody(BuildContext context, DashboardState state) {
    return Column(
      children: [
        _buildHeader(context, state),
        Expanded(
          child: Container(
            decoration: const BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.vertical(
                top: Radius.circular(30),
              ),
            ),
            child: RefreshIndicator(
              onRefresh: () async {
                context.read<DashboardBloc>().add(RefreshDashboard());
                await Future.delayed(const Duration(seconds: 1));
              },
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.all(20),
                child: Column(
                  children: [
                    _CheckInCard(state: state),
                    const SizedBox(height: 24),
                    _AttendanceCalendarCard(
                      attendanceMap: AttendanceHelper.buildAttendanceMap(
                        state.attendanceList,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }


  Widget _buildHeader(BuildContext context, DashboardState state) {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 60, 20, 30),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Attendance',
            style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            _getGreeting(),
            style: TextStyle(
              fontSize: 16,
              color: Colors.white.withOpacity(0.9),
            ),
          ),
        ],
      ),
    );
  }


  String _getGreeting() {
    final hour = DateTime.now().hour;
    if (hour < 12) return 'Good Morning!';
    if (hour < 17) return 'Good Afternoon!';
    return 'Good Evening!';
  }

  String _formatTime(DateTime time) {
    return '${time.hour.toString().padLeft(2, '0')}:'
        '${time.minute.toString().padLeft(2, '0')}';
  }


  void _showSuccessSnackbar(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.check_circle, color: Colors.white),
            const SizedBox(width: 12),
            Expanded(child: Text(message)),
          ],
        ),
        backgroundColor: Colors.green,
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 3),
      ),
    );
  }

  void _showInfoSnackbar(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.info, color: Colors.white),
            const SizedBox(width: 12),
            Expanded(child: Text(message)),
          ],
        ),
        backgroundColor: Colors.blue,
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 3),
      ),
    );
  }

  void _showErrorSnackbar(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.error, color: Colors.white),
            const SizedBox(width: 12),
            Expanded(child: Text(message)),
          ],
        ),
        backgroundColor: Colors.red,
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 4),
        action: SnackBarAction(
          label: 'Dismiss',
          textColor: Colors.white,
          onPressed: () {},
        ),
      ),
    );
  }
}


class _CheckInCard extends StatelessWidget {
  final DashboardState state;

  const _CheckInCard({required this.state});

  @override
  Widget build(BuildContext context) {
    final isLoading = state.loadingStatus == DashboardLoadingStatus.loading;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          // Time Cards Row
          Row(
            children: [
              Expanded(
                child: _TimeCard(
                  icon: Icons.login,
                  label: 'Check In',
                  time: _formatTime(state.checkInTime),
                  color: Colors.green,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _TimeCard(
                  icon: Icons.logout,
                  label: 'Check Out',
                  time: _formatTime(state.checkOutTime),
                  color: Colors.red,
                ),
              ),
            ],
          ),

          if (state.elapsedTime.inSeconds > 0) ...[
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 12,
              ),
              decoration: BoxDecoration(
                color: Colors.blue.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(
                    Icons.access_time,
                    color: Colors.blue,
                    size: 20,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'Working Time: ${_formatDuration(state.elapsedTime)}',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Colors.blue,
                    ),
                  ),
                ],
              ),
            ),
          ],

          const SizedBox(height: 20),

          if (state.checkInStatus == CheckInStatus.notCheckedIn)
            _CheckInButton(
              isLoading: isLoading,
              canCheckIn: state.canCheckIn,
              onPressed: () {
                context.read<DashboardBloc>().add(CheckIn());
              },
            )
          else
            _CheckOutButton(
              isLoading: isLoading,
              canCheckOut: state.canCheckOut,
              onPressed: () {
                context.read<DashboardBloc>().add(CheckOut());
              },
            ),
        ],
      ),
    );
  }

  String _formatTime(DateTime? time) {
    if (time == null) return '--:--';
    return '${time.hour.toString().padLeft(2, '0')}:'
        '${time.minute.toString().padLeft(2, '0')}';
  }

  String _formatDuration(Duration duration) {
    final hours = duration.inHours;
    final minutes = duration.inMinutes.remainder(60);
    return '${hours}h ${minutes}m';
  }
}



class _TimeCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final String time;
  final Color color;

  const _TimeCard({
    required this.icon,
    required this.label,
    required this.time,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: color.withOpacity(0.2),
          width: 1.5,
        ),
        color: color.withOpacity(0.05),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 28),
          const SizedBox(height: 8),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey[600],
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            time,
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}



class _CheckInButton extends StatelessWidget {
  final bool isLoading;
  final bool canCheckIn;
  final VoidCallback onPressed;

  const _CheckInButton({
    required this.isLoading,
    required this.canCheckIn,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 56,
      child: ElevatedButton.icon(
        onPressed: (canCheckIn && !isLoading) ? onPressed : null,
        icon: isLoading
            ? const SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                ),
              )
            : const Icon(Icons.login, size: 24),
        label: Text(
          isLoading ? 'Processing...' : 'Check In',
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.green,
          foregroundColor: Colors.white,
          disabledBackgroundColor: Colors.grey[300],
          disabledForegroundColor: Colors.grey[500],
          elevation: isLoading ? 0 : 2,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),
    );
  }
}



class _CheckOutButton extends StatelessWidget {
  final bool isLoading;
  final bool canCheckOut;
  final VoidCallback onPressed;

  const _CheckOutButton({
    required this.isLoading,
    required this.canCheckOut,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 56,
      child: ElevatedButton.icon(
        onPressed: (canCheckOut && !isLoading) ? onPressed : null,
        icon: isLoading
            ? const SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                ),
              )
            : const Icon(Icons.logout, size: 24),
        label: Text(
          isLoading ? 'Processing...' : 'Check Out',
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.red,
          foregroundColor: Colors.white,
          disabledBackgroundColor: Colors.grey[300],
          disabledForegroundColor: Colors.grey[500],
          elevation: isLoading ? 0 : 2,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),
    );
  }
}



class _AttendanceCalendarCard extends StatelessWidget {
  final Map<DateTime, AttendanceModel> attendanceMap;

  const _AttendanceCalendarCard({required this.attendanceMap});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<DashboardBloc, DashboardState>(
      builder: (context, state) {
        return Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            color: Colors.white,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Attendance Calendar',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),
              TableCalendar(
                firstDay: DateTime(2020),
                lastDay: DateTime(2030),
                focusedDay: state.focusedDay,
                calendarFormat: state.calendarFormat,
                selectedDayPredicate: (day) => isSameDay(state.selectedDay, day),
                onDaySelected: (selectedDay, focusedDay) {
                  context.read<DashboardBloc>().add(
                        SelectDay(selectedDay, focusedDay),
                      );

                  final normalizedDay = AttendanceHelper.midnight(selectedDay);
                  final attendance = attendanceMap[normalizedDay];

                  if (attendance != null) {
                    _showAttendanceDetails(context, attendance);
                  }
                },
                onFormatChanged: (format) {
                  context.read<DashboardBloc>().add(
                        ChangeCalendarFormat(format),
                      );
                },
                onPageChanged: (focusedDay) {
                  context.read<DashboardBloc>().add(
                        ChangePage(focusedDay),
                      );
                },
                calendarStyle: CalendarStyle(
                  todayDecoration: BoxDecoration(
                    color: Colors.blue.withOpacity(0.5),
                    shape: BoxShape.circle,
                  ),
                  selectedDecoration: const BoxDecoration(
                    color: Colors.blue,
                    shape: BoxShape.circle,
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  void _showAttendanceDetails(BuildContext context, AttendanceModel attendance) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Attendance Details'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Date: ${attendance.attendanceDate}'),
            if (attendance.checkinTime != null)
              Text('Check-in: ${attendance.checkinTime}'),
            if (attendance.checkoutTime != null)
              Text('Check-out: ${attendance.checkoutTime}'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }
}