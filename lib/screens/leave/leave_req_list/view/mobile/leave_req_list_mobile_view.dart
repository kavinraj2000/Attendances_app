import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:hrm/app/route_name.dart';
import 'package:hrm/core/model/leave_list_model.dart';
import 'package:hrm/core/util/toast_util.dart';
import 'package:hrm/screens/leave/leave_req_list/bloc/leave_req_list_bloc.dart';
import 'package:intl/intl.dart';

class LeaveRequestsListPage extends StatefulWidget {
  const LeaveRequestsListPage({super.key});

  @override
  State<LeaveRequestsListPage> createState() => _LeaveRequestsListPageState();
}

class _LeaveRequestsListPageState extends State<LeaveRequestsListPage> {
  List<Color> getLeaveTypeColor(String type) {
    switch (type) {
      case 'CASUAL':
        return [
          const Color(0xFF8B5CF6),
          const Color.fromARGB(255, 173, 145, 237),
        ];
      case 'SICK':
        return [
          const Color(0xFF3B82F6),
          const Color.fromARGB(255, 90, 123, 176),
        ];
      case 'ANNUAL':
        return [
          const Color.fromARGB(255, 144, 99, 241),
          const Color.fromARGB(255, 172, 141, 239),
        ];
      case 'MATERNITY':
        return [
          const Color.fromARGB(255, 238, 207, 3),
          const Color.fromARGB(255, 240, 220, 83),
        ];
      case 'WFH':
        return [
          const Color.fromARGB(255, 3, 238, 93),
          const Color.fromARGB(255, 117, 251, 168),
        ];
      case 'PATERNITY':
        return [Colors.orange, Colors.orangeAccent];
      case 'BEREAVEMENT':
        return [Colors.blueGrey, Colors.grey];
      default:
        return [Colors.blueAccent, Colors.purple];
    }
  }

  Color getLeaveTypeGradient(String leaveType) {
    return getLeaveTypeColor(leaveType).first;
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
    context.pushNamed(RouteName.leavereq, extra: request.toJson());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: BlocBuilder<LeaveReqListBloc, LeaveReqListState>(
          builder: (context, state) {
            if (state.status == LeaveReqListStatus.loading) {
              return const Center(child: CircularProgressIndicator());
            }

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
                        state.message,
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
                        context.read<LeaveReqListBloc>().add(
                          InitialLeaverequestListevent(),
                        );
                      },
                      icon: const Icon(Icons.refresh),
                      label: const Text('Retry'),
                    ),
                  ],
                ),
              );
            }

            final leaveRequests = state.leaveList;

            if (leaveRequests.isEmpty) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.event_busy, size: 64, color: Colors.grey[400]),
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
                            ],
                          ),
                          IconButton(
                            icon: const Icon(Icons.refresh),
                            onPressed: () {
                              context.read<LeaveReqListBloc>().add(
                                InitialLeaverequestListevent(),
                              );
                            },
                            tooltip: 'Refresh',
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),

                      Row(
                        children: [
                          Expanded(
                            child: _buildStatCard(
                              'Total',
                              leaveRequests.length.toString(),
                              Icons.calendar_today,
                              [
                                const Color.fromARGB(255, 181, 2, 41),
                                const Color.fromARGB(255, 238, 124, 149),
                              ],
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: _buildStatCard(
                              'Approved',
                              getApprovedCount(leaveRequests).toString(),
                              Icons.check_circle,
                              [
                                const Color.fromARGB(255, 1, 211, 134),
                                const Color.fromARGB(255, 107, 231, 206),
                              ],
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: _buildStatCard(
                              'Pending',
                              getPendingCount(leaveRequests).toString(),
                              Icons.access_time,
                              [
                                const Color.fromARGB(255, 248, 236, 0),
                                const Color.fromARGB(255, 215, 210, 102),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                Expanded(
                  child: RefreshIndicator(
                    onRefresh: () async {
                      context.read<LeaveReqListBloc>().add(
                        InitialLeaverequestListevent(),
                      );
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
    );
  }

  Widget _buildStatCard(
    String label,
    String value,
    IconData icon,
    List<Color> color,
  ) {
    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        gradient: LinearGradient(colors: color),
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
                    style: const TextStyle(fontSize: 12, color: Colors.white70),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    value,
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
              Icon(icon, color: Colors.white, size: 28),
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
                gradient: LinearGradient(
                  colors: getLeaveTypeColor(request.leaveType),
                ),
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(16),
                  bottomLeft: Radius.circular(16),
                ),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    request.totalDays == 1 ? 'day' : 'days',
                    style: const TextStyle(
                      color: Colors.white70,
                      fontSize: 11,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${request.totalDays.toInt()} ',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'leave',
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
                            color: getStatusColor(
                              request.status,
                            ).withOpacity(0.1),
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(
                              color: getStatusColor(
                                request.status,
                              ).withOpacity(0.3),
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

                    Row(
                      children: [
                        Icon(
                          Icons.calendar_today,
                          size: 14,
                          color: getLeaveTypeGradient(request.leaveType),
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
                      ],
                    ),

                    if (request.modifiedBy != null) ...[
                      const SizedBox(height: 12),
                      Container(
                        padding: const EdgeInsets.only(top: 12),
                        decoration: const BoxDecoration(
                          border: Border(
                            top: BorderSide(color: Color(0xFFE5E7EB), width: 1),
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
