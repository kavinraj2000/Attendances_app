import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:hrm/screens/dashboard/bloc/dashboard_bloc.dart';
import 'package:hrm/core/widgets/card/swipe_card.dart';

class CheckInCard extends StatefulWidget {
  const CheckInCard({super.key});

  @override
  State<CheckInCard> createState() => _CheckInCardState();
}

class _CheckInCardState extends State<CheckInCard> {
  @override
  Widget build(BuildContext context) {
    return BlocBuilder<DashboardBloc, DashboardState>(
      builder: (context, state) {
        final isLoading = state.loadingStatus == DashboardLoadingStatus.loading;
        final isCheckedIn = state.checkInStatus == CheckInStatus.checkedIn;

        return Container(
          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(24),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.06),
                blurRadius: 20,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            children: [
              // Header Section
              _buildHeader(state, isCheckedIn),

              // Status Section
              if (isCheckedIn) _buildStatusSection(state),

              // Time Display
              if (state.checkInTime != null)
                _buildTimeSection(state, isCheckedIn),

              // Swipe Action Button
              Padding(
                padding: const EdgeInsets.all(20),
                child: SwipeActionButton(
                  isCheckedIn: isCheckedIn,
                  isLoading: isLoading,
                  onCheckIn: () => context.read<DashboardBloc>().add(CheckIn()),
                  onCheckOut: () =>
                      context.read<DashboardBloc>().add(CheckOut()),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildHeader(DashboardState state, bool isCheckedIn) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: isCheckedIn
              ? [
                  const Color(0xFF11998E),
                  const Color(0xFF38EF7D),
                ]
              : [
                  const Color(0xFF667EEA),
                  const Color(0xFF764BA2),
                ],
        ),
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(24),
          topRight: Radius.circular(24),
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              isCheckedIn ? Icons.task_alt_rounded : Icons.access_time_rounded,
              color: Colors.white,
              size: 28,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  isCheckedIn ? 'Checked In' : 'Ready to Start',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  DateFormat('EEEE, MMM dd, yyyy').format(DateTime.now()),
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.9),
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
          _buildStatusBadge(isCheckedIn),
        ],
      ),
    );
  }

  Widget _buildStatusBadge(bool isCheckedIn) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.25),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: Colors.white.withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 8,
            height: 8,
            decoration: BoxDecoration(
              color: isCheckedIn ? Colors.greenAccent : Colors.orangeAccent,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: (isCheckedIn ? Colors.greenAccent : Colors.orangeAccent)
                      .withOpacity(0.5),
                  blurRadius: 4,
                  spreadRadius: 1,
                ),
              ],
            ),
          ),
          const SizedBox(width: 6),
          Text(
            isCheckedIn ? 'Active' : 'Idle',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatusSection(DashboardState state) {
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFF8F9FA),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: const Color(0xFFE9ECEF),
          width: 1,
        ),
      ),
      child: Row(
        children: [
          const Icon(
            Icons.info_outline_rounded,
            color: Color(0xFF11998E),
            size: 20,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              'You are currently checked in. Don\'t forget to check out!',
              style: TextStyle(
                color: Colors.grey[700],
                fontSize: 13,
                height: 1.4,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTimeSection(DashboardState state, bool isCheckedIn) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      child: Row(
        children: [
          Expanded(
            child: _buildTimeCard(
              icon: Icons.login_rounded,
              label: 'Check In',
              time: state.checkInTime,
              color: const Color(0xFF11998E),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: _buildTimeCard(
              icon: Icons.logout_rounded,
              label: 'Check Out',
              time: state.checkOutTime,
              color: const Color(0xFFFF6B6B),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: _buildDurationCard(state),
          ),
        ],
      ),
    );
  }

  Widget _buildTimeCard({
    required IconData icon,
    required String label,
    required DateTime? time,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withOpacity(0.08),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: color.withOpacity(0.2),
          width: 1,
        ),
      ),
      child: Column(
        children: [
          Icon(
            icon,
            color: color,
            size: 20,
          ),
          const SizedBox(height: 8),
          Text(
            label,
            style: TextStyle(
              color: Colors.grey[600],
              fontSize: 11,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            time != null ? DateFormat('hh:mm a').format(time) : '--:--',
            style: TextStyle(
              color: color,
              fontSize: 13,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDurationCard(DashboardState state) {
    final duration = _workingTime(state);
    final formattedTime = _format(duration);

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(0xFF667EEA),
            Color(0xFF764BA2),
          ],
        ),
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF667EEA).withOpacity(0.3),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          const Icon(
            Icons.timer_rounded,
            color: Colors.white,
            size: 20,
          ),
          const SizedBox(height: 8),
          const Text(
            'Duration',
            style: TextStyle(
              color: Colors.white,
              fontSize: 11,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            formattedTime,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 13,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Duration _workingTime(DashboardState state) {
    if (state.checkInTime == null) return Duration.zero;
    return state.checkOutTime != null
        ? state.checkOutTime!.difference(state.checkInTime!)
        : DateTime.now().difference(state.checkInTime!);
  }

  String _format(Duration d) {
    final h = d.inHours;
    final m = d.inMinutes.remainder(60);
    return '${h.toString().padLeft(2, '0')}h ${m.toString().padLeft(2, '0')}m';
  }
}