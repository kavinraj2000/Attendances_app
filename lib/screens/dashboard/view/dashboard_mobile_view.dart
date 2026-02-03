import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hrm/core/constants/constants.dart';
import 'package:hrm/core/model/check_in_model.dart';
import 'package:hrm/core/widgets/attances_popup_widget.dart';
import 'package:hrm/screens/dashboard/bloc/dashboard_bloc.dart';
import 'package:table_calendar/table_calendar.dart';

class DashboardMobileView extends StatefulWidget {
  const DashboardMobileView({super.key});

  @override
  State<DashboardMobileView> createState() => _DashboardMobileViewState();
}

class _DashboardMobileViewState extends State<DashboardMobileView> {
  CalendarFormat _calendarFormat = CalendarFormat.month;
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;

  /// status codes
  /// 1 = present, 2 = absent, 3 = halfDay, 4 = leave, 5 = holiday
  final Map<DateTime, int> _attendanceData = {
    DateTime(2026, 1, 20): 1,
    DateTime(2026, 1, 21): 1,
    DateTime(2026, 1, 22): 3,
    DateTime(2026, 1, 23): 4,
    DateTime(2026, 1, 24): 5,
    DateTime(2026, 1, 25): 2,
  };

  DateTime _midnight(DateTime d) => DateTime(d.year, d.month, d.day);

  /// 🔥 BUILD SHIFT TIMELINE (9 HOURS)
  List<ScheduleItem> _buildShiftSchedule(DateTime checkInTime) {
    final checkOutTime = checkInTime.add(const Duration(hours: 9));
    final now = DateTime.now();

    return [
      ScheduleItem(
        title: 'Check In',
        time: checkInTime,
        isActive: now.isAfter(checkInTime) && now.isBefore(checkOutTime),
        categoryIcon: Icons.login,
      ),
      ScheduleItem(
        title: 'Check Out',
        time: checkOutTime,
        isActive: now.isAfter(checkOutTime),
        categoryIcon: Icons.logout,
      ),
    ];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Constants.color.lightColors['primary'],
      body: BlocConsumer<DashboardBloc, DashboardState>(
        listener: (context, state) {
          if (state.loadingStatus == DashboardLoadingStatus.failure &&
              state.errorMessage != null) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.errorMessage!),
                backgroundColor: Colors.red,
              ),
            );
          }

          if (state.loadingStatus == DashboardLoadingStatus.success) {
            if (state.checkInStatus == CheckInStatus.checkedIn) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Checked in successfully'),
                  backgroundColor: Colors.green,
                ),
              );
            }

            if (state.checkInStatus == CheckInStatus.checkedOut) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Checked out successfully'),
                  backgroundColor: Colors.blue,
                ),
              );
            }
          }
        },
        builder: (context, state) {
          if (state.loadingStatus == DashboardLoadingStatus.loading) {
            return const Center(child: CircularProgressIndicator());
          }

          return Column(
            children: [
              Expanded(
                child: Container(
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
                  ),
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      children: [
                        _buildCheckInCard(context, state),
                        const SizedBox(height: 24),
                        _buildAttendanceCalendar(context, state),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  // ═══════════ CHECK-IN CARD ═══════════

  Widget _buildCheckInCard(BuildContext context, DashboardState state) {
    final elapsed = state.elapsedTime;
    final hours = elapsed.inHours.toString().padLeft(2, '0');
    final minutes = (elapsed.inMinutes % 60).toString().padLeft(2, '0');
    final seconds = (elapsed.inSeconds % 60).toString().padLeft(2, '0');

    final isCheckedIn = state.checkInStatus == CheckInStatus.checkedIn;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
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
          const Text('Working Time',
              style: TextStyle(fontSize: 14, color: Colors.black54)),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _timeBox(hours),
              _colon(),
              _timeBox(minutes),
              _colon(),
              _timeBox(seconds),
            ],
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: isCheckedIn
                      ? null
                      : () => context.read<DashboardBloc>().add(const CheckIn()),
                  icon: const Icon(Icons.login),
                  label: const Text('Check In'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: isCheckedIn
                      ? () =>
                          context.read<DashboardBloc>().add(const CheckOut())
                      : null,
                  icon: const Icon(Icons.logout),
                  label: const Text('Check Out'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _timeBox(String value) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.grey[100],
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        value,
        style: const TextStyle(fontSize: 32, fontWeight: FontWeight.bold),
      ),
    );
  }

  Widget _colon() {
    return const Padding(
      padding: EdgeInsets.symmetric(horizontal: 8),
      child: Text(':',
          style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold)),
    );
  }

  // ═══════════ ATTENDANCE CALENDAR ═══════════

  Widget _buildAttendanceCalendar(BuildContext context, DashboardState state) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10),
        ],
      ),
      child: Column(
        children: [
          const Text(
            'Attendance Calendar',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          TableCalendar(
            firstDay: DateTime(2020),
            lastDay: DateTime(2030),
            focusedDay: _focusedDay,
            calendarFormat: _calendarFormat,
            selectedDayPredicate: (day) => isSameDay(_selectedDay, day),
            onDaySelected: (selectedDay, focusedDay) {
              setState(() {
                _selectedDay = selectedDay;
                _focusedDay = focusedDay;
              });

              /// ✅ USE REAL CHECK-IN TIME
              final checkInTime =
                  state.checkInTime ?? DateTime.now();

              final items = _buildShiftSchedule(checkInTime);

              showSchedulePopup(context, items);
            },
            onFormatChanged: (format) =>
                setState(() => _calendarFormat = format),
            calendarBuilders: CalendarBuilders(
              defaultBuilder: (context, day, _) => _calendarCell(day),
              selectedBuilder: (context, day, _) =>
                  _calendarCell(day, selected: true),
              todayBuilder: (context, day, _) =>
                  _calendarCell(day, today: true),
            ),
          ),
        ],
      ),
    );
  }

  // ═══════════ CALENDAR CELL ═══════════

  Widget _calendarCell(DateTime day,
      {bool selected = false, bool today = false}) {
    final status = _attendanceData[_midnight(day)];
    Color border = Colors.transparent;
    Color bg = Colors.grey[100]!;

    if (selected) {
      bg = Colors.blue;
    } else if (today) {
      bg = Colors.blue.withOpacity(0.3);
    } else if (status == 1) {
      border = Colors.green;
    } else if (status == 2) {
      border = Colors.red;
    } else if (status == 3) {
      border = Colors.amber;
    } else if (status == 4) {
      border = Colors.purple;
    } else if (status == 5) {
      border = Colors.blue;
    }

    return Container(
      margin: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: bg,
        border: Border.all(color: border, width: status != null ? 2 : 0),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Center(
        child: Text(
          '${day.day}',
          style:
              TextStyle(color: selected ? Colors.white : Colors.black),
        ),
      ),
    );
  }
}
