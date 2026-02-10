import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hrm/core/constants/constants.dart';
import 'package:hrm/core/widgets/attendance_widgets/attendance_card_widget.dart';
import 'package:hrm/core/widgets/attendance_widgets/month_calander_widget.dart';
import 'package:hrm/core/widgets/attendance_widgets/month_summary_card_widget.dart';
import 'package:hrm/screens/attendances/bloc/attendances_bloc.dart';


class AttendanceLogsScreen extends StatefulWidget {
  const AttendanceLogsScreen({super.key});

  @override
  State<AttendanceLogsScreen> createState() => _AttendanceLogsScreenState();
}

class _AttendanceLogsScreenState extends State<AttendanceLogsScreen> {
  final ScrollController _scrollController = ScrollController();

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 255, 255, 255),
      body: BlocConsumer<AttendanceLogsBloc, AttendanceLogsState>(
        listener: _handleStateChanges,
        builder: (context, state) {
          return switch (state.status) {
            AttendanceLogStatus.loading => _buildLoadingWidget(),
            AttendanceLogStatus.success => _buildCalendarView(state),
            _ => _buildEmptyWidget(),
          };
        },
      ),
    );
  }

  void _handleStateChanges(BuildContext context, AttendanceLogsState state) {
    if (state.status == AttendanceLogStatus.error && state.isAuthError) {
      _showErrorSnackBar(context, 'Session expired. Please login again.');
    }
  }

  Widget _buildLoadingWidget() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
           CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(
              Constants.color.inprogressColor,
            ),
            strokeWidth: 3,
          ),
           SizedBox(height: Constants.color.spacingL),
          Text(
            'Loading attendance data...',
            style: TextStyle(
              fontSize: 14,
              color: Constants.color.textSecondary,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
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
            color: Constants.color.inactiveDayColor,
          ),
          const SizedBox(height: 16),
           Text(
            'No attendance data',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w500,
              color: Constants.color.textSecondary,
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
      color: Constants.color.inprogressColor,
      onRefresh: () async {
        context.read<AttendanceLogsBloc>().add(const RefreshSchedule());
        await Future.delayed(const Duration(milliseconds: 500));
      },
      child: CustomScrollView(
        controller: _scrollController,
        physics: const AlwaysScrollableScrollPhysics(),
        slivers: [
          // Header Section
          SliverToBoxAdapter(
            child: Padding(
              padding:  EdgeInsets.all(Constants.color.spacingL),
              child: Column(
                children: [
                  MonthlySummaryCard(state: state),
                   SizedBox(height: Constants.color.spacingL),
                  const AttendanceLegendCard(),
                   SizedBox(height: Constants.color.spacingL),
                ],
              ),
            ),
          ),

          // Calendar Grid for all 12 months
          SliverList(
            delegate: SliverChildBuilderDelegate(
              (context, index) {
                final monthNumber = index + 1;
                return Padding(
                  padding:  EdgeInsets.only(
                    left: Constants.color.spacingL,
                    right: Constants.color.spacingL,
                    bottom: Constants.color.spacingL,
                  ),
                  child: MonthCalendarWidget(
                    state: state,
                    month: monthNumber,
                    year: currentYear,
                  ),
                );
              },
              childCount: 12,
            ),
          ),

           SliverToBoxAdapter(
            child: SizedBox(height: Constants.color.spacingXxl),
          ),
        ],
      ),
    );
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
        backgroundColor: Constants.color.absentColor,
        duration: const Duration(seconds: 3),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(Constants.color.borderRadiusM),
        ),
        margin:  EdgeInsets.all(Constants.color.spacingL),
      ),
    );
  }
}