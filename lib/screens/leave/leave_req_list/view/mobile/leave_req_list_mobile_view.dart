import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hrm/core/model/leave_list_model.dart';
import 'package:hrm/screens/leave/leave_req_list/bloc/leave_req_list_bloc.dart';
import 'package:intl/intl.dart';

class LeaveRequestsListPage extends StatefulWidget {
  const LeaveRequestsListPage({Key? key}) : super(key: key);

  @override
  State<LeaveRequestsListPage> createState() => _LeaveRequestsListPageState();
}

class _LeaveRequestsListPageState extends State<LeaveRequestsListPage> {
  @override
  void initState() {
    super.initState();
    // Trigger the initial event to fetch leave requests
    context.read<LeaveReqListBloc>().add(InitialLeaverequestListevent());
  }

  Color getLeaveTypeColor(String type) {
    switch (type) {
      case 'CASUAL':
        return const Color(0xFF8B5CF6);
      case 'SICK':
        return const Color(0xFF3B82F6);
      case 'ANNUAL':
        return const Color(0xFF6366F1);
      default:
        return Colors.grey;
    }
  }

  Color getStatusColor(String status) {
    switch (status) {
      case 'APPROVED':
        return Colors.green;
      case 'PENDING':
        return Colors.orange;
      case 'REJECTED':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  IconData getStatusIcon(String status) {
    switch (status) {
      case 'APPROVED':
        return Icons.check_circle;
      case 'PENDING':
        return Icons.access_time;
      case 'REJECTED':
        return Icons.cancel;
      default:
        return Icons.info;
    }
  }

  String formatDate(DateTime date) {
    return DateFormat('MMM dd, yyyy').format(date);
  }

  int getApprovedCount(List<LeaveRequestListModel> requests) =>
      requests.where((r) => r.status == 'APPROVED').length;
  
  int getPendingCount(List<LeaveRequestListModel> requests) =>
      requests.where((r) => r.status == 'PENDING').length;

  void _onEditLeaveRequest(LeaveRequestListModel request) {
    // TODO: Navigate to edit page or show edit dialog
    // Example navigation:
    // Navigator.pushNamed(
    //   context,
    //   '/edit-leave-request',
    //   arguments: request,
    // );
    
    // For now, show a snackbar
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Edit leave request #${request.id}'),
        action: SnackBarAction(
          label: 'OK',
          onPressed: () {},
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Color(0xFFF3E8FF),
              Color(0xFFDEEDFF),
            ],
          ),
        ),
        child: SafeArea(
          child: BlocBuilder<LeaveReqListBloc, LeaveReqListState>(
            builder: (context, state) {
              // Show loading indicator
              if (state.status == LeaveReqListStatus.loading) {
                return const Center(
                  child: CircularProgressIndicator(),
                );
              }

              // Show error message
              if (state.status == LeaveReqListStatus.failure) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(
                        Icons.error_outline,
                        size: 64,
                        color: Colors.red,
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'Error loading leave requests',
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 32),
                        child: Text(
                          state.message ?? 'Unknown error',
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            fontSize: 14,
                            color: Color(0xFF6B7280),
                          ),
                        ),
                      ),
                      const SizedBox(height: 24),
                      ElevatedButton.icon(
                        onPressed: () {
                          context
                              .read<LeaveReqListBloc>()
                              .add(InitialLeaverequestListevent());
                        },
                        icon: const Icon(Icons.refresh),
                        label: const Text('Retry'),
                      ),
                    ],
                  ),
                );
              }

              // Show leave requests list
              final leaveRequests = state.leaveList;

              if (leaveRequests.isEmpty) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.event_busy,
                        size: 64,
                        color: Colors.grey[400],
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'No leave requests found',
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

              return Column(
                children: [
                  // Header
                  Padding(
                    padding: const EdgeInsets.all(20.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Leave Requests',
                                  style: TextStyle(
                                    fontSize: 28,
                                    fontWeight: FontWeight.bold,
                                    color: Color(0xFF1F2937),
                                  ),
                                ),
                                SizedBox(height: 4),
                                Text(
                                  'Manage and track employee leave applications',
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: Color(0xFF6B7280),
                                  ),
                                ),
                              ],
                            ),
                            IconButton(
                              icon: const Icon(Icons.refresh),
                              onPressed: () {
                                context
                                    .read<LeaveReqListBloc>()
                                    .add(InitialLeaverequestListevent());
                              },
                              tooltip: 'Refresh',
                            ),
                          ],
                        ),
                        const SizedBox(height: 20),

                        // Stats Cards
                        Row(
                          children: [
                            Expanded(
                              child: _buildStatCard(
                                'Total',
                                leaveRequests.length.toString(),
                                Icons.calendar_today,
                                const Color(0xFF8B5CF6),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: _buildStatCard(
                                'Approved',
                                getApprovedCount(leaveRequests).toString(),
                                Icons.check_circle,
                                Colors.green,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: _buildStatCard(
                                'Pending',
                                getPendingCount(leaveRequests).toString(),
                                Icons.access_time,
                                Colors.orange,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),

                  // Leave Requests List
                  Expanded(
                    child: RefreshIndicator(
                      onRefresh: () async {
                        context
                            .read<LeaveReqListBloc>()
                            .add(InitialLeaverequestListevent());
                      },
                      child: ListView.builder(
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        itemCount: leaveRequests.length,
                        itemBuilder: (context, index) {
                          return _buildLeaveRequestCard(leaveRequests[index]);
                        },
                      ),
                    ),
                  ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _buildStatCard(
      String label, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
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
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: const TextStyle(
                      fontSize: 12,
                      color: Color(0xFF6B7280),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    value,
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF1F2937),
                    ),
                  ),
                ],
              ),
              Icon(icon, color: color, size: 28),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildLeaveRequestCard(LeaveRequestListModel request) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
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
      child: IntrinsicHeight(
        child: Row(
          children: [
            Container(
              width: 80,
              decoration: BoxDecoration(
                color: getLeaveTypeColor(request.leaveType),
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(16),
                  bottomLeft: Radius.circular(16),
                ),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text(
                    'ID',
                    style: TextStyle(
                      color: Colors.white70,
                      fontSize: 11,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    request.id.toString(),
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    request.leaveType,
                    style: const TextStyle(
                      color: Colors.white70,
                      fontSize: 10,
                      fontWeight: FontWeight.w500,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),

            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                '${request.leaveType} Leave',
                                style: const TextStyle(
                                  fontSize: 15,
                                  fontWeight: FontWeight.w600,
                                  color: Color(0xFF1F2937),
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                request.reason,
                                style: const TextStyle(
                                  fontSize: 13,
                                  color: Color(0xFF6B7280),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 8),
                        if (request.status == 'PENDING')
                          IconButton(
                            icon: const Icon(Icons.edit),
                            iconSize: 20,
                            color: const Color(0xFF8B5CF6),
                            onPressed: () {
                              _onEditLeaveRequest(request);
                            },
                            tooltip: 'Edit',
                            padding: EdgeInsets.zero,
                            constraints: const BoxConstraints(),
                          ),
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            color:
                                getStatusColor(request.status).withOpacity(0.1),
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(
                              color: getStatusColor(request.status)
                                  .withOpacity(0.3),
                            ),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                getStatusIcon(request.status),
                                size: 14,
                                color: getStatusColor(request.status),
                              ),
                              const SizedBox(width: 4),
                              Text(
                                request.status,
                                style: TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w600,
                                  color: getStatusColor(request.status),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 12),

                    // Date and duration info
                    Row(
                      children: [
                        Icon(
                          Icons.calendar_today,
                          size: 14,
                          color: getLeaveTypeColor(request.leaveType),
                        ),
                        const SizedBox(width: 6),
                        Expanded(
                          child: Text(
                            '${formatDate(request.startDate)} - ${formatDate(request.endDate)}',
                            style: const TextStyle(
                              fontSize: 12,
                              color: Color(0xFF6B7280),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Icon(
                          Icons.access_time,
                          size: 14,
                          color: getLeaveTypeColor(request.leaveType),
                        ),
                        const SizedBox(width: 6),
                        Text(
                          '${request.totalDays.toInt()} ${request.totalDays == 1 ? 'day' : 'days'}',
                          style: const TextStyle(
                            fontSize: 12,
                            color: Color(0xFF6B7280),
                          ),
                        ),
                      ],
                    ),

                    if (request.modifiedBy != null) ...[
                      const SizedBox(height: 12),
                      Container(
                        padding: const EdgeInsets.only(top: 12),
                        decoration: const BoxDecoration(
                          border: Border(
                            top: BorderSide(
                              color: Color(0xFFE5E7EB),
                              width: 1,
                            ),
                          ),
                        ),
                        child: Text(
                          'Last modified by ${request.modifiedBy} on ${formatDate(request.modified)}',
                          style: const TextStyle(
                            fontSize: 11,
                            color: Color(0xFF9CA3AF),
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}