import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hrm/core/constants/constants.dart';
import 'package:hrm/core/repo/prefernces_repo.dart';
import 'package:hrm/core/util/toast_util.dart';
import 'package:hrm/core/widgets/greeting_widget.dart' as GreetingData;
import 'package:hrm/screens/dashboard/bloc/dashboard_bloc.dart';
import 'package:intl/intl.dart';



class DashboardMobileView extends StatefulWidget {
  const DashboardMobileView({super.key});

  @override
  State<DashboardMobileView> createState() => _DashboardMobileViewState();
}

class _DashboardMobileViewState extends State<DashboardMobileView>
    with SingleTickerProviderStateMixin {
  String _userName = '';
  late AnimationController _pulseController;
  CheckInStatus? _previousCheckInStatus;

  @override
  void initState() {
    super.initState();
    context.read<DashboardBloc>().add(InitializeDashboard());
    _loadUserName();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2000),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  Future<void> _loadUserName() async {
    final pref = PreferencesRepository();
    final name = await pref.getUsername();
    if (mounted) {
      setState(() => _userName = name ?? '');
    }
  }

void _handleCheckInStatusChange(BuildContext context, DashboardState state) {
  if (state.loadingStatus == DashboardLoadingStatus.success &&
      _previousCheckInStatus != state.checkInStatus) {
    final newStatus = state.checkInStatus; 
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      if (newStatus == CheckInStatus.checkedIn) {
        ToastUtil.checkIn(context: context);
      } else if (newStatus == CheckInStatus.checkedOut) {
        ToastUtil.checkOut(context: context);
      }
    });
  }
  _previousCheckInStatus = state.checkInStatus;
}
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Constants.color.surfaceWhite,
      body: SafeArea(
        child: BlocBuilder<DashboardBloc, DashboardState>(
          builder: (context, state) {
            _handleCheckInStatusChange(context, state);
            return RefreshIndicator(
              color: Constants.color.leaveColor,
              onRefresh: () async {
                context.read<DashboardBloc>().add(RefreshDashboardData());
              },
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding:  EdgeInsets.symmetric(
                  horizontal: Constants.app.spacingL,
                ),
                child: Column(
                  children: [
                     SizedBox(height: Constants.app.spacingL),
                    _buildGreetingCard(),
                     SizedBox(height: Constants.app.spacingL),
                    _buildDateTimeCard(state),
                     SizedBox(height: Constants.app.spacingL),
                    _buildAttendanceSection(state),
                     SizedBox(height: Constants.app.spacingXxl),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildGreetingCard() {
    final greetingData = GreetingData.getGreetingData();

    return Container(
      padding:  EdgeInsets.all(Constants.app.spacingL),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            const Color.fromARGB(255, 3, 111, 200),
            const Color.fromARGB(255, 60, 161, 243),
            const Color.fromARGB(255, 143, 196, 240),
          ],
        ),
        borderRadius: BorderRadius.circular(Constants.app.borderRadiusXl),
       
      ),
      child: Stack(
        children: [
          Positioned(
            right: -20,
            top: -20,
            child: Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withOpacity(0.1),
              ),
            ),
          ),
          Positioned(
            left: -10,
            bottom: -30,
            child: Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withOpacity(0.08),
              ),
            ),
          ),
          Row(
            children: [
              
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(
                          greetingData.text,
                          style: TextStyle(
                            fontSize: 15,
                            color: Colors.white.withOpacity(0.95),
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const SizedBox(width: 6),
                        Image.asset(greetingData.image, height: 20, width: 20),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      _userName.isNotEmpty ? _userName : 'Guest',
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                        letterSpacing: -0.5,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
           
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildDateTimeCard(DashboardState state) {
    return StreamBuilder(
      stream: Stream.periodic(const Duration(seconds: 1)),
      builder: (_, __) {
        final now = DateTime.now();
        return Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [Colors.white, const Color(0xFFF5F7FA)],
            ),
            borderRadius: BorderRadius.circular(
              Constants.app.borderRadiusXl,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.08),
                blurRadius: 25,
                offset: const Offset(0, 8),
                spreadRadius: -5,
              ),
            ],
            border: Border.all(color: Colors.white, width: 2),
          ),
          child: Stack(
            children: [
              Positioned(
                right: -40,
                top: -40,
                child: Container(
                  width: 140,
                  height: 140,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: RadialGradient(
                      colors: [
                        Constants.color.accentTeal.withOpacity(0.08),
                        Constants.color.accentTeal.withOpacity(0.0),
                      ],
                    ),
                  ),
                ),
              ),
              Positioned(
                left: -30,
                bottom: -30,
                child: Container(
                  width: 100,
                  height: 100,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: RadialGradient(
                      colors: [
                        Constants.color.accentOrange.withOpacity(0.08),
                        Constants.color.accentOrange.withOpacity(0.0),
                      ],
                    ),
                  ),
                ),
              ),
              Column(
                children: [
                  Padding(
                    padding:  EdgeInsets.all(Constants.app.spacingL),
                    child: Row(
                      children: [
                        Expanded(child: _buildDateSection(now)),
                        Container(
                          width: 1,
                          height: 120,
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.topCenter,
                              end: Alignment.bottomCenter,
                              colors: [
                                Colors.transparent,
                                Constants.color.dividerColor,
                                Colors.transparent,
                              ],
                            ),
                          ),
                        ),
                        Expanded(child: _buildTimeSection(now)),
                      ],
                    ),
                  ),

                  Container(
                    height: 1,
                    margin:  EdgeInsets.symmetric(
                      horizontal: Constants.app.spacingL,
                    ),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          Colors.transparent,
                          Constants.color.dividerColor.withOpacity(0.5),
                          Colors.transparent,
                        ],
                      ),
                    ),
                  ),

                  Padding(
                    padding:  EdgeInsets.all(Constants.app.spacingL),
                    child: Row(
                      children: [
                        Expanded(
                          child: _buildAttendanceInfo(
                            label: 'Check In',
                            time: state.checkInTimeFormatted ?? '--:--',
                            color: const Color(0xFF10B981),
                          ),
                        ),
                         SizedBox(width: Constants.app.spacingM),
                        Expanded(
                          child: _buildAttendanceInfo(
                            label: 'Check Out',
                            time: state.checkOutTimeFormatted ?? '--:--',
                            color: const Color(0xFFEF4444),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildDateSection(DateTime now) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                Constants.color.accentPurple.withOpacity(0.15),
                Constants.color.accentPurple.withOpacity(0.08),
              ],
            ),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.calendar_today_rounded,
                size: 14,
                color: Constants.color.accentPurple,
              ),
              const SizedBox(width: 6),
              Text(
                DateFormat('EEEE').format(now).toUpperCase(),
                style: TextStyle(
                  fontSize: 11,
                  color: Constants.color.accentPurple,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 1.2,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),
        Text(
          DateFormat('dd').format(now),
          style: TextStyle(
            fontSize: 56,
            color: Constants.color.textPrimary,
            fontWeight: FontWeight.w800,
            height: 1,
            letterSpacing: -2,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          DateFormat('MMM yyyy').format(now),
          style: TextStyle(
            fontSize: 16,
            color: Constants.color.textSecondary,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }

  Widget _buildTimeSection(DateTime now) {
    return Column(
      children: [
        Text(
          DateFormat('HH:mm').format(now),
          style: TextStyle(
            fontSize: 56,
            color: Constants.color.textPrimary,
            fontWeight: FontWeight.w800,
            height: 1,
            letterSpacing: -2,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          '${DateFormat('ss').format(now)} sec',
          style: TextStyle(
            fontSize: 16,
            color: Constants.color.textSecondary,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }

  Widget _buildAttendanceInfo({
    required String label,
    required String time,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(Constants.app.borderRadiusM),
        border: Border.all(color: color.withOpacity(0.2), width: 1.5),
      ),
      child: Column(
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              color: Constants.color.textSecondary,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            time,
            style: TextStyle(
              fontSize: 18,
              color: Constants.color.textPrimary,
              fontWeight: FontWeight.w700,
              letterSpacing: -0.5,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAttendanceSection(DashboardState state) {
    final isCheckedIn = state.checkInStatus == CheckInStatus.checkedIn;
    return Container(
      padding:  EdgeInsets.all(Constants.app.spacingXl),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            isCheckedIn ? const Color(0xFFFFEBEE) : const Color(0xFFF3F0FF),
            isCheckedIn ? const Color(0xFFFFF5F5) : const Color(0xFFF8F7FF),
          ],
        ),
        borderRadius: BorderRadius.circular(Constants.app.borderRadiusXl),
        boxShadow: [
          BoxShadow(
            color:
                (isCheckedIn
                        ? Constants.color.checkOutGradientStart
                        : Constants.color.accentPurple)
                    .withOpacity(0.15),
            blurRadius: 25,
            offset: const Offset(0, 8),
            spreadRadius: -5,
          ),
        ],
        border: Border.all(
          color: isCheckedIn
              ? Constants.color.checkOutGradientStart.withOpacity(0.2)
              : Constants.color.accentPurple.withOpacity(0.2),
          width: 2,
        ),
      ),
      child: Stack(
        children: [
          // Background decoration
          Positioned(
            right: -50,
            bottom: -50,
            child: Container(
              width: 150,
              height: 150,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    (isCheckedIn
                            ? Constants.color.checkOutGradientStart
                            : Constants.color.accentPurple)
                        .withOpacity(0.1),
                    Colors.transparent,
                  ],
                ),
              ),
            ),
          ),
          // Content
          Column(
            children: [
              Text(
                isCheckedIn ? 'You\'re Checked In' : 'Ready to Start Your Day?',
                style: TextStyle(
                  fontSize: Constants.app.fontSizeL,
                  fontWeight: FontWeight.w700,
                  color: Constants.color.textPrimary,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                isCheckedIn
                    ? 'Tap to check out when you\'re done'
                    : 'Tap the button below to check in',
                style: TextStyle(
                  fontSize: Constants.app.fontSizeS,
                  color: Constants.color.textSecondary,
                  fontWeight: FontWeight.w500,
                ),
              ),
               SizedBox(height: Constants.app.spacingXl),
              _buildCheckInButton(isCheckedIn, state.isLoading),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildCheckInButton(bool isCheckedIn, bool isLoading) {
    return AnimatedBuilder(
      animation: _pulseController,
      builder: (_, __) {
        final gradientColors = isCheckedIn
            ? [
                Constants.color.checkOutGradientStart,
                Constants.color.checkOutGradientEnd,
              ]
            : [Constants.color.accentPurple, const Color(0xFF8B7FFF)];

        return GestureDetector(
          onTap: isLoading
              ? null
              : () => context.read<DashboardBloc>().add(
                  isCheckedIn ? CheckOut() : CheckIn(),
                ),
          child: Stack(
            alignment: Alignment.center,
            children: [
              Container(
                width: Constants.app.checkInButtonSize + 20,
                height: Constants.app.checkInButtonSize + 20,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: RadialGradient(
                    colors: [
                      gradientColors[0].withOpacity(0.0),
                      gradientColors[0].withOpacity(
                        0.15 + _pulseController.value * 0.1,
                      ),
                    ],
                  ),
                ),
              ),
              // Main Button
              Container(
                width: Constants.app.checkInButtonSize,
                height: Constants.app.checkInButtonSize,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: gradientColors,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: gradientColors[0].withOpacity(0.5),
                      blurRadius: 30 + _pulseController.value * 10,
                      spreadRadius: _pulseController.value * 5,
                      offset: const Offset(0, 10),
                    ),
                  ],
                ),
                child: isLoading
                    ? const Center(
                        child: CircularProgressIndicator(
                          color: Colors.white,
                          strokeWidth: 3,
                        ),
                      )
                    : Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            isCheckedIn ? 'CHECK OUT' : 'CHECK IN',
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.w700,
                              fontSize: 16,
                              letterSpacing: 1.5,
                            ),
                          ),
                        ],
                      ),
              ),
            ],
          ),
        );
      },
    );
  }
}
