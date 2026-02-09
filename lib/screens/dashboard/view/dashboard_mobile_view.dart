import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hrm/core/repo/prefernces_repo.dart';
import 'package:hrm/screens/dashboard/bloc/dashboard_bloc.dart';
import 'package:intl/intl.dart';

/// Design tokens and constants
class _DashboardConstants {
  // Colors
  static const primaryGradientStart = Color(0xFF667EEA);
  static const primaryGradientEnd = Color(0xFF764BA2);
  static const checkOutGradientStart = Color(0xFFFF6B6B);
  static const checkOutGradientEnd = Color(0xFFEE5A6F);
  static const textPrimary = Color(0xFF1A1A1A);
  static const textSecondary = Color(0xFF757575);
  static const textTertiary = Color(0xFF9E9E9E);
  static const surfaceWhite = Color(0xFFFAFAFA);
  static const dividerColor = Color(0xFFE0E0E0);

  // Spacing
  static const double spacingXs = 4.0;
  static const double spacingS = 8.0;
  static const double spacingM = 16.0;
  static const double spacingL = 24.0;
  static const double spacingXl = 32.0;
  static const double spacingXxl = 40.0;

  // Sizes
  static const double avatarRadius = 24.0;
  static const double checkInButtonSize = 200.0;
  static const double checkInButtonElevation = 20.0;
  static const double borderRadiusM = 12.0;
  static const double borderRadiusL = 16.0;

  // Typography
  static const double fontSizeXl = 64.0;
  static const double fontSizeL = 20.0;
  static const double fontSizeM = 16.0;
  static const double fontSizeS = 14.0;
  static const double fontSizeXs = 13.0;
}

class DashboardMobileView extends StatefulWidget {
  const DashboardMobileView({super.key});

  @override
  State<DashboardMobileView> createState() => _DashboardMobileViewState();
}

class _DashboardMobileViewState extends State<DashboardMobileView>
    with SingleTickerProviderStateMixin {
  String _userName = '';
  late AnimationController _pulseController;

  @override
  void initState() {
    super.initState();
    context.read<DashboardBloc>().add(InitializeDashboard());
    _loadUserName();
    _initializeAnimations();
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  void _initializeAnimations() {
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2000),
    )..repeat(reverse: true);
  }

  Future<void> _loadUserName() async {
    final pref = PreferencesRepository();
    final name = await pref.getUsername();
    if (mounted) {
      setState(() {
        _userName = name ?? '';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _DashboardConstants.surfaceWhite,
      body: SafeArea(
        child: BlocBuilder<DashboardBloc, DashboardState>(
          builder: (context, state) {
            if (state.isLoading) {
              return const Center(
                child: CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(
                    _DashboardConstants.primaryGradientStart,
                  ),
                ),
              );
            }

            return RefreshIndicator(
              color: _DashboardConstants.primaryGradientStart,
              onRefresh: () async {
                context.read<DashboardBloc>().add(RefreshDashboardData());
                await Future.delayed(const Duration(milliseconds: 500));
              },
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: _DashboardConstants.spacingL,
                  ),
                  child: Column(
                    children: [
                      const SizedBox(height: _DashboardConstants.spacingXl),
                      _buildUserHeader(),
                      const SizedBox(height: _DashboardConstants.spacingXxl),
                      _buildDateTimeCard(),
                      const SizedBox(height: _DashboardConstants.spacingXxl),
                      _buildAttendanceSection(state),
                      const SizedBox(height: _DashboardConstants.spacingXl),
                      const SizedBox(height: _DashboardConstants.spacingXxl),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  /* ---------------- USER HEADER ---------------- */

  Widget _buildUserHeader() {
    return Container(
      padding: const EdgeInsets.all(_DashboardConstants.spacingM),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(_DashboardConstants.borderRadiusL),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: const LinearGradient(
                colors: [
                  _DashboardConstants.primaryGradientStart,
                  _DashboardConstants.primaryGradientEnd,
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              boxShadow: [
                BoxShadow(
                  color: _DashboardConstants.primaryGradientStart.withOpacity(
                    0.3,
                  ),
                  blurRadius: 8,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: CircleAvatar(
              radius: _DashboardConstants.avatarRadius,
              backgroundColor: Colors.transparent,
              child: Text(
                _userName.isNotEmpty ? _userName[0].toUpperCase() : '?',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 22,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
          const SizedBox(width: _DashboardConstants.spacingM),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Welcome back,',
                  style: TextStyle(
                    fontSize: _DashboardConstants.fontSizeXs,
                    color: _DashboardConstants.textTertiary,
                    fontWeight: FontWeight.w400,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  _userName.isNotEmpty ? _userName : 'Guest',
                  style: const TextStyle(
                    fontSize: _DashboardConstants.fontSizeL,
                    fontWeight: FontWeight.w600,
                    color: _DashboardConstants.textPrimary,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          IconButton(
            icon: const Icon(Icons.notifications_outlined),
            color: _DashboardConstants.textSecondary,
            onPressed: () {
              // Navigate to notifications
            },
          ),
        ],
      ),
    );
  }

  /* ---------------- DATE & TIME CARD ---------------- */

  Widget _buildDateTimeCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(
        vertical: _DashboardConstants.spacingXl,
        horizontal: _DashboardConstants.spacingL,
      ),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [
            _DashboardConstants.primaryGradientStart,
            _DashboardConstants.primaryGradientEnd,
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(_DashboardConstants.borderRadiusL),
        boxShadow: [
          BoxShadow(
            color: _DashboardConstants.primaryGradientStart.withOpacity(0.25),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: StreamBuilder(
        stream: Stream.periodic(const Duration(seconds: 1)),
        builder: (context, snapshot) {
          final now = DateTime.now();
          return Column(
            children: [
              Text(
                DateFormat('HH:mm:ss').format(now),
                style: const TextStyle(
                  fontSize: _DashboardConstants.fontSizeXl,
                  fontWeight: FontWeight.w200,
                  color: Colors.white,
                  letterSpacing: -1,
                  height: 1.0,
                ),
              ),
              const SizedBox(height: _DashboardConstants.spacingS),
              Text(
                DateFormat('EEEE, MMMM dd, yyyy').format(now),
                style: TextStyle(
                  fontSize: _DashboardConstants.fontSizeM,
                  color: Colors.white.withOpacity(0.9),
                  fontWeight: FontWeight.w400,
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  /* ---------------- ATTENDANCE SECTION ---------------- */

  Widget _buildAttendanceSection(DashboardState state) {
    final isCheckedIn = state.checkInStatus == CheckInStatus.checkedIn;
    final isLoading = state.loadingStatus == DashboardLoadingStatus.loading;

    return Column(
      children: [
        Text(
          isCheckedIn ? 'You\'re checked in' : 'Ready to start?',
          style: const TextStyle(
            fontSize: _DashboardConstants.fontSizeL,
            fontWeight: FontWeight.w600,
            color: _DashboardConstants.textPrimary,
          ),
        ),
        const SizedBox(height: _DashboardConstants.spacingM),
        _buildCheckInButton(isCheckedIn, isLoading),
        const SizedBox(height: _DashboardConstants.spacingL),
        _buildLocationInfo(),
      ],
    );
  }

  Widget _buildCheckInButton(bool isCheckedIn, bool isLoading) {
    return AnimatedBuilder(
      animation: _pulseController,
      builder: (context, child) {
        return GestureDetector(
          onTap: isLoading
              ? null
              : () {
                  context.read<DashboardBloc>().add(
                    isCheckedIn ? CheckOut() : CheckIn(),
                  );
                },
          child: Container(
            width: _DashboardConstants.checkInButtonSize,
            height: _DashboardConstants.checkInButtonSize,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: LinearGradient(
                colors: isCheckedIn
                    ? [
                        _DashboardConstants.checkOutGradientStart,
                        _DashboardConstants.checkOutGradientEnd,
                      ]
                    : [
                        _DashboardConstants.primaryGradientStart,
                        _DashboardConstants.primaryGradientEnd,
                      ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              boxShadow: [
                BoxShadow(
                  color:
                      (isCheckedIn
                              ? _DashboardConstants.checkOutGradientStart
                              : _DashboardConstants.primaryGradientStart)
                          .withOpacity(0.4),
                  blurRadius: 25 + (_pulseController.value * 5),
                  offset: const Offset(
                    0,
                    _DashboardConstants.checkInButtonElevation,
                  ),
                  spreadRadius: _pulseController.value * 2,
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
                      Icon(
                        isCheckedIn
                            ? Icons.logout_rounded
                            : Icons.login_rounded,
                        size: 40,
                        color: Colors.white,
                      ),
                      const SizedBox(height: _DashboardConstants.spacingS),
                      Text(
                        isCheckedIn ? 'CHECK OUT' : 'CHECK IN',
                        style: const TextStyle(
                          fontSize: _DashboardConstants.fontSizeM,
                          fontWeight: FontWeight.w700,
                          color: Colors.white,
                          letterSpacing: 1.2,
                        ),
                      ),
                    ],
                  ),
          ),
        );
      },
    );
  }

  Widget _buildLocationInfo() {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: _DashboardConstants.spacingM,
        vertical: _DashboardConstants.spacingS,
      ),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(_DashboardConstants.borderRadiusM),
        border: Border.all(color: _DashboardConstants.dividerColor, width: 1),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.location_on,
            size: 18,
            color: _DashboardConstants.primaryGradientStart,
          ),
          const SizedBox(width: _DashboardConstants.spacingS),
          const Text(
            'Central Building Office',
            style: TextStyle(
              fontSize: _DashboardConstants.fontSizeS,
              color: _DashboardConstants.textSecondary,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}
