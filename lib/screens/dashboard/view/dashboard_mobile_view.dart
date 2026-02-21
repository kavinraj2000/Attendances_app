import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hrm/core/constants/constants.dart';
import 'package:hrm/core/util/toast_util.dart';
import 'package:hrm/core/widgets/greeting_widget.dart' as GreetingData;
import 'package:hrm/screens/dashboard/bloc/dashboard_bloc.dart';
import 'package:intl/intl.dart';

class DashboardMobileView extends StatelessWidget {
  const DashboardMobileView({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocListener<DashboardBloc, DashboardState>(
      listenWhen: (previous, current) =>
          current.loadingStatus == DashboardLoadingStatus.success &&
          previous.checkInStatus != current.checkInStatus,
      listener: (context, state) {
        if (state.checkInStatus == CheckInStatus.checkedIn) {
          ToastUtil.checkIn(context: context);
        } else if (state.checkInStatus == CheckInStatus.checkedOut) {
          ToastUtil.checkOut(context: context);
        }
      },
      child: Scaffold(
        backgroundColor: Constants.color.white,
        body: SafeArea(
          child: BlocBuilder<DashboardBloc, DashboardState>(
            builder: (context, state) {
              return RefreshIndicator(
                color: Constants.color.lightblue,
                onRefresh: () async {
                  context.read<DashboardBloc>().add(RefreshDashboardData());
                },
                child: SingleChildScrollView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  padding: EdgeInsets.symmetric(horizontal: Constants.size.l),
                  child: Column(
                    children: [
                      SizedBox(height: Constants.size.l),
                      _GreetingCard(userName: state.userName),
                      SizedBox(height: Constants.size.l),
                      _DateTimeCard(state: state),
                      SizedBox(height: Constants.size.l),
                      _AttendanceSection(state: state),
                      SizedBox(height: Constants.size.l),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}

class _GreetingCard extends StatelessWidget {
  const _GreetingCard({required this.userName});

  final String userName;

  @override
  Widget build(BuildContext context) {
    final greetingData = GreetingData.getGreetingData();

    return Container(
      padding: EdgeInsets.all(Constants.size.l),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color.fromARGB(255, 3, 111, 200),
            Color.fromARGB(255, 60, 161, 243),
            Color.fromARGB(255, 143, 196, 240),
          ],
        ),
        borderRadius: BorderRadius.circular(Constants.size.radiusL),
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
                        const SizedBox(width: 12),
                      ],
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          userName.isNotEmpty ? userName : 'Guest',
                          style: const TextStyle(
                            fontSize: 34,
                            fontWeight: FontWeight.w700,
                            color: Colors.white,
                            letterSpacing: -0.5,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        Image.asset(greetingData.image, height: 60, width: 50),
                      ],
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
}

class _DateTimeCard extends StatelessWidget {
  const _DateTimeCard({required this.state});

  final DashboardState state;

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<void>(
      stream: Stream.periodic(const Duration(seconds: 1)),
      builder: (_, __) {
        final now = DateTime.now();
        return Container(
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [Colors.white, Color(0xFFF5F7FA)],
            ),
            borderRadius: BorderRadius.circular(Constants.size.l),
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
                        Constants.color.lightblue.withOpacity(0.08),
                        Constants.color.lightblue.withOpacity(0.0),
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
                        Constants.color.orange.withOpacity(0.08),
                        Constants.color.orange.withOpacity(0.0),
                      ],
                    ),
                  ),
                ),
              ),
              Column(
                children: [
                  Padding(
                    padding: EdgeInsets.all(Constants.size.l),
                    child: Row(
                      children: [
                        Expanded(child: _DateSection(now: now)),
                        Container(
                          width: 1,
                          height: 120,
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.topCenter,
                              end: Alignment.bottomCenter,
                              colors: [
                                Colors.transparent,
                                Constants.color.divider,
                                Colors.transparent,
                              ],
                            ),
                          ),
                        ),
                        Expanded(child: _TimeSection(now: now)),
                      ],
                    ),
                  ),
                  Container(
                    height: 1,
                    margin: EdgeInsets.symmetric(horizontal: Constants.size.l),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          Colors.transparent,
                          Constants.color.divider.withOpacity(0.5),
                          Colors.transparent,
                        ],
                      ),
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.all(Constants.size.l),
                    child: Row(
                      children: [
                        Expanded(
                          child: _AttendanceInfoChip(
                            label: 'Check In',
                            time: state.checkInTimeFormatted ?? '--:--',
                            color: const Color(0xFF10B981),
                          ),
                        ),
                        SizedBox(width: Constants.size.m),
                        Expanded(
                          child: _AttendanceInfoChip(
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
}

class _DateSection extends StatelessWidget {
  const _DateSection({required this.now});

  final DateTime now;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [Constants.color.orange, Constants.color.gold],
            ),

            borderRadius: BorderRadius.circular(8),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.calendar_today_rounded,
                size: 14,
                color: Constants.color.white,
              ),
              const SizedBox(width: 6),
              Text(
                DateFormat('EEEE').format(now).toUpperCase(),
                style: TextStyle(
                  fontSize: 11,
                  color: Constants.color.white,
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
            color: Constants.color.primary,
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
            color: Constants.color.secondary,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }
}

class _TimeSection extends StatelessWidget {
  const _TimeSection({required this.now});

  final DateTime now;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          DateFormat('HH:mm').format(now),
          style: TextStyle(
            fontSize: 56,
            color: Constants.color.primary,
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
            color: Constants.color.secondary,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }
}

class _AttendanceInfoChip extends StatelessWidget {
  const _AttendanceInfoChip({
    required this.label,
    required this.time,
    required this.color,
  });

  final String label;
  final String time;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(Constants.size.radiusM),
        border: Border.all(color: color.withOpacity(0.2), width: 1.5),
      ),
      child: Column(
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              color: Constants.color.secondary,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            time,
            style: TextStyle(
              fontSize: 18,
              color: Constants.color.primary,
              fontWeight: FontWeight.w700,
              letterSpacing: -0.5,
            ),
          ),
        ],
      ),
    );
  }
}

class _AttendanceSection extends StatelessWidget {
  const _AttendanceSection({required this.state});

  final DashboardState state;

  @override
  Widget build(BuildContext context) {
    final isCheckedIn = state.checkInStatus == CheckInStatus.checkedIn;

    return Container(
      padding: EdgeInsets.all(Constants.size.l),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: isCheckedIn
              ? [const Color(0xFFFFEBEE), const Color(0xFFFFF5F5)]
              : [const Color(0xFFF3F0FF), const Color(0xFFF8F7FF)],
        ),
        borderRadius: BorderRadius.circular(Constants.size.radiusL),
        boxShadow: [
          BoxShadow(
            color:
                (isCheckedIn
                        ? Constants.color.danger
                        : Constants.color.lightblue)
                    .withOpacity(0.15),
            blurRadius: 25,
            offset: const Offset(0, 8),
            spreadRadius: -5,
          ),
        ],
        border: Border.all(
          color: isCheckedIn
              ? Constants.color.danger.withOpacity(0.2)
              : Constants.color.lightblue.withOpacity(0.2),
          width: 2,
        ),
      ),
      child: Stack(
        children: [
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
                            ? Constants.color.danger
                            : Constants.color.lightblue)
                        .withOpacity(0.1),
                    Colors.transparent,
                  ],
                ),
              ),
            ),
          ),
          Column(
            children: [
              Text(
                isCheckedIn ? "You're Checked In" : 'Ready to Start Your Day?',
                style: TextStyle(
                  fontSize: Constants.size.l,
                  fontWeight: FontWeight.w700,
                  color: Constants.color.primary,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                isCheckedIn
                    ? "Tap to check out when you're done"
                    : 'Tap the button below to check in',
                style: TextStyle(
                  fontSize: Constants.size.s,
                  color: Constants.color.secondary,
                  fontWeight: FontWeight.w500,
                ),
              ),
              SizedBox(height: Constants.size.l),
              _CheckInButton(
                isCheckedIn: isCheckedIn,
                isLoading: state.isLoading,
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _CheckInButton extends StatelessWidget {
  const _CheckInButton({required this.isCheckedIn, required this.isLoading});

  final bool isCheckedIn;
  final bool isLoading;

  @override
  Widget build(BuildContext context) {
    final gradientColors = isCheckedIn
        ? [Constants.color.danger, Constants.color.white]
        : [Constants.color.lightblue, const Color(0xFF8B7FFF)];

    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0.0, end: 1.0),
      duration: const Duration(milliseconds: 2000),
      curve: Curves.easeInOut,
      key: ValueKey('${isCheckedIn}_${DateTime.now().second ~/ 2}'),
      builder: (context, pulse, _) {
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
                width: Constants.size.checkInButtonSize + 20,
                height: Constants.size.checkInButtonSize + 20,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: RadialGradient(
                    colors: [
                      gradientColors[0].withOpacity(0.0),
                      gradientColors[0].withOpacity(0.15 + pulse * 0.1),
                    ],
                  ),
                ),
              ),
              Container(
                width: Constants.size.checkInButtonSize,
                height: Constants.size.checkInButtonSize,
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
                      blurRadius: 30 + pulse * 10,
                      spreadRadius: pulse * 5,
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
                    : Center(
                        child: Text(
                          isCheckedIn ? 'CHECK OUT' : 'CHECK IN',
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w700,
                            fontSize: 16,
                            letterSpacing: 1.5,
                          ),
                        ),
                      ),
              ),
            ],
          ),
        );
      },
    );
  }
}
