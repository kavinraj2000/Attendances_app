import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hrm/core/services/image_capture_service.dart';
import 'package:hrm/screens/dashboard/bloc/dashboard_bloc.dart';
import 'package:intl/intl.dart';

class DashboardMobileView extends StatefulWidget {
  const DashboardMobileView({super.key});

  @override
  State<DashboardMobileView> createState() => _DashboardMobileViewState();
}

class _DashboardMobileViewState extends State<DashboardMobileView> {
  @override
  void initState() {
    super.initState();
    context.read<DashboardBloc>().add(InitializeDashboard());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: BlocBuilder<DashboardBloc, DashboardState>(
        builder: (context, state) {
          if (state.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          return RefreshIndicator(
            onRefresh: () async {
              context.read<DashboardBloc>().add(RefreshDashboardData());
              await Future.delayed(const Duration(milliseconds: 500));
            },
            child: SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              child: Column(
                children: [
                  const SizedBox(height: 40),
                  
                  // Current Time Display
                  _buildTimeDisplay(),
                  
                  const SizedBox(height: 60),
                  
                  // Check In/Out Button
                  _buildCheckInButton(state),
                  
                  const SizedBox(height: 20),
                  
                  _buildLocationText(state),
                  
                  const SizedBox(height: 60),
                  
                  // _buildTimeCards(state),
                  
                  const SizedBox(height: 40),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  

  Widget _buildTimeDisplay() {
    return StreamBuilder(
      stream: Stream.periodic(const Duration(seconds: 1)),
      builder: (context, snapshot) {
        final now = DateTime.now();
        return Column(
          children: [
            Text(
              DateFormat('HH:mm').format(now),
              style: const TextStyle(
                fontSize: 56,
                fontWeight: FontWeight.w300,
                color: Color(0xFF2C2C2C),
                letterSpacing: -2,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              DateFormat('EEEE, MMM dd').format(now),
              style: const TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w400,
                color: Color(0xFF9E9E9E),
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildCheckInButton(DashboardState state) {
    final isCheckedIn = state.checkInStatus == CheckInStatus.checkedIn;
    final isLoading = state.loadingStatus == DashboardLoadingStatus.loading;

    log.d('_buildCheckInButton:::$isLoading:::::::$isCheckedIn');

    return GestureDetector(
      onTap: isLoading
          ? null
          : () {
              if (isCheckedIn) {
                context.read<DashboardBloc>().add(CheckOut());
              } else {
                context.read<DashboardBloc>().add(CheckIn());
              }
            },
      child: Container(
        width: 180,
        height: 180,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: isCheckedIn
                ? [
                    const Color(0xFFFF6B6B),
                    const Color(0xFFEE5A6F),
                  ]
                : [
                    const Color(0xFF667EEA),
                    const Color(0xFF764BA2),
                  ],
          ),
          boxShadow: [
            BoxShadow(
              color: (isCheckedIn
                      ? const Color(0xFFFF6B6B)
                      : const Color(0xFF667EEA))
                  .withOpacity(0.4),
              blurRadius: 30,
              offset: const Offset(0, 15),
            ),
          ],
        ),
        child: isLoading
            ? const Center(
                child: CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                  strokeWidth: 3,
                ),
              )
            : Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    isCheckedIn ? Icons.logout : Icons.fingerprint,
                    size: 60,
                    color: Colors.white,
                  ),
                  const SizedBox(height: 12),
                  Text(
                    isCheckedIn ? 'Check  OUT' : 'Check IN',
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                      letterSpacing: 1.5,
                    ),
                  ),
                ],
              ),
      ),
    );
  }

  Widget _buildLocationText(DashboardState state) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(
          Icons.location_on_outlined,
          size: 16,
          color: Colors.grey[600],
        ),
        const SizedBox(width: 6),
        Text(
          'Location: Central Building Office',
          style: TextStyle(
            fontSize: 13,
            color: Colors.grey[600],
            fontWeight: FontWeight.w400,
          ),
        ),
      ],
    );
  }

  Widget _buildTimeCards(DashboardState state) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 40),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          _buildTimeCard(
            icon: Icons.login,
            label: 'Check In',
            time: state.checkInTime,
            iconColor: const Color(0xFF667EEA),
          ),
          _buildTimeCard(
            icon: Icons.access_time,
            label: 'Duration',
            time: state.checkInTime,
            isDuration: true,
            checkOutTime: state.checkOutTime,
            iconColor: const Color(0xFF4CAF50),
          ),
          _buildTimeCard(
            icon: Icons.logout,
            label: 'Check Out',
            time: state.checkOutTime,
            iconColor: const Color(0xFFFF6B6B),
          ),
        ],
      ),
    );
  }

  Widget _buildTimeCard({
    required IconData icon,
    required String label,
    required DateTime? time,
    bool isDuration = false,
    DateTime? checkOutTime,
    required Color iconColor,
  }) {
    String displayTime = '--:--';
    
    if (isDuration && time != null) {
      final endTime = checkOutTime ?? DateTime.now();
      final duration = endTime.difference(time);
      final hours = duration.inHours;
      final minutes = duration.inMinutes.remainder(60);
      displayTime = '${hours.toString().padLeft(2, '0')}:${minutes.toString().padLeft(2, '0')}';
    } else if (time != null) {
      displayTime = DateFormat('HH:mm').format(time);
    }

    return Column(
      children: [
        Container(
          width: 56,
          height: 56,
          decoration: BoxDecoration(
            color: iconColor.withOpacity(0.1),
            borderRadius: BorderRadius.circular(16),
          ),
          child: Icon(
            icon,
            color: iconColor,
            size: 28,
          ),
        ),
        const SizedBox(height: 12),
        Text(
          displayTime,
          style: const TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w600,
            color: Color(0xFF2C2C2C),
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: TextStyle(
            fontSize: 11,
            color: Colors.grey[600],
            fontWeight: FontWeight.w400,
          ),
        ),
      ],
    );
  }
}