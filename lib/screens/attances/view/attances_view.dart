// import 'package:flutter/material.dart';
// import 'package:flutter_bloc/flutter_bloc.dart';
// import 'package:hrm/screens/check%20IN-OUT/bloc/check_in_bloc.dart';
// import 'package:hrm/screens/check%20IN-OUT/view/mobile/checkin_checkout_card.dart';
// import 'package:hrm/screens/dashboard/bloc/dashboard_bloc.dart';
// import 'package:hrm/screens/dashboard/repo/dashboard_repo.dart';

// class AttendanceScreen extends StatelessWidget {
//   final int employeeId;
//   final String employeeName;

//   const AttendanceScreen({
//     super.key,
//     required this.employeeId,
//     required this.employeeName,
//   });

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: const Text('Attendance'),
//         backgroundColor: Colors.blue,
//         foregroundColor: Colors.white,
//       ),
//       body: BlocProvider(
//         create: (context) => DashboardBloc(DashboardRepository()),
//         child: BlocListener<DashboardBloc, DashboardState>(
//           listener: (context, state) {
//             if (state.loadingStatus == CheckInStatus.checkedIn) {
//               // if (state.isCheckedIn && state.checkInTime != null) {
//               //   ScaffoldMessenger.of(context).showSnackBar(
//               //     const SnackBar(
//               //       content: Text('✅ Checked in successfully!'),
//               //       backgroundColor: Colors.green,
//               //       duration: Duration(seconds: 2),
//               //     ),
//               //   );
//               // } else if (!state.isCheckedIn && state.checkOutTime != null) {
//               //   ScaffoldMessenger.of(context).showSnackBar(
//               //     const SnackBar(
//               //       content: Text('✅ Checked out successfully!'),
//               //       backgroundColor: Colors.blue,
//               //       duration: Duration(seconds: 2),
//               //     ),
//               //   );
//               // }
//             }

//             // Show error message
//             if (state.loadingStatus == DashboardLoadingStatus.failure &&
//                 state.errorMessage != null) {
//               ScaffoldMessenger.of(context).showSnackBar(
//                 SnackBar(
//                   content: Text('❌ ${state.errorMessage}'),
//                   backgroundColor: Colors.red,
//                   duration: const Duration(seconds: 3),
//                 ),
//               );
//             }
//           },
//           child: SingleChildScrollView(
//             padding: const EdgeInsets.all(16),
//             child: Column(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 // Employee Info Card
//                 _EmployeeInfoCard(
//                   employeeName: employeeName,
//                   employeeId: employeeId,
//                 ),

//                 const SizedBox(height: 20),

//                 BlocBuilder<DashboardBloc, DashboardState>(
//                   builder: (context, state) {
//                     return CheckInCheckOutCard(
//                       state: state,
//                       employeeId: employeeId,
//                       createdBy: 'EMP_$employeeId',
//                     );
//                   },
//                 ),

//                 const SizedBox(height: 20),

//                 // Today's Summary Card
//                 BlocBuilder<CheckInBloc, CheckInState>(
//                   builder: (context, state) {
//                     return _TodaySummaryCard(state: state);
//                   },
//                 ),
//               ],
//             ),
//           ),
//         ),
//       ),
//     );
//   }
// }

// // ─────────────────────────────────────────────
// // Employee Info Card
// // ─────────────────────────────────────────────

// class _EmployeeInfoCard extends StatelessWidget {
//   final String employeeName;
//   final int employeeId;

//   const _EmployeeInfoCard({
//     required this.employeeName,
//     required this.employeeId,
//   });

//   @override
//   Widget build(BuildContext context) {
//     return Container(
//       padding: const EdgeInsets.all(16),
//       decoration: BoxDecoration(
//         gradient: LinearGradient(
//           colors: [Colors.blue.shade400, Colors.blue.shade600],
//           begin: Alignment.topLeft,
//           end: Alignment.bottomRight,
//         ),
//         borderRadius: BorderRadius.circular(12),
//         boxShadow: [
//           BoxShadow(
//             color: Colors.blue.withOpacity(0.3),
//             blurRadius: 8,
//             offset: const Offset(0, 4),
//           ),
//         ],
//       ),
//       child: Row(
//         children: [
//           CircleAvatar(
//             radius: 30,
//             backgroundColor: Colors.white,
//             child: Text(
//               employeeName.isNotEmpty ? employeeName[0].toUpperCase() : 'E',
//               style: TextStyle(
//                 fontSize: 24,
//                 fontWeight: FontWeight.bold,
//                 color: Colors.blue.shade600,
//               ),
//             ),
//           ),
//           const SizedBox(width: 16),
//           Expanded(
//             child: Column(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 Text(
//                   employeeName,
//                   style: const TextStyle(
//                     color: Colors.white,
//                     fontSize: 18,
//                     fontWeight: FontWeight.bold,
//                   ),
//                 ),
//                 const SizedBox(height: 4),
//                 Text(
//                   'ID: $employeeId',
//                   style: const TextStyle(
//                     color: Colors.white70,
//                     fontSize: 14,
//                   ),
//                 ),
//               ],
//             ),
//           ),
//           const Icon(
//             Icons.badge,
//             color: Colors.white,
//             size: 32,
//           ),
//         ],
//       ),
//     );
//   }
// }

// // ─────────────────────────────────────────────
// // Today's Summary Card
// // ─────────────────────────────────────────────

// class _TodaySummaryCard extends StatelessWidget {
//   final CheckInState state;

//   const _TodaySummaryCard({required this.state});

//   @override
//   Widget build(BuildContext context) {
//     return Container(
//       padding: const EdgeInsets.all(16),
//       decoration: BoxDecoration(
//         color: Colors.white,
//         borderRadius: BorderRadius.circular(12),
//         boxShadow: [
//           BoxShadow(
//             color: Colors.black.withOpacity(0.05),
//             blurRadius: 8,
//             offset: const Offset(0, 2),
//           ),
//         ],
//       ),
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           Row(
//             children: [
//               Icon(Icons.calendar_today, color: Colors.blue.shade600),
//               const SizedBox(width: 8),
//               const Text(
//                 'Today\'s Summary',
//                 style: TextStyle(
//                   fontSize: 16,
//                   fontWeight: FontWeight.bold,
//                 ),
//               ),
//             ],
//           ),
//           const Divider(height: 24),
//           _summaryRow(
//             'Status',
//             state.isCheckedIn
//                 ? 'Checked In ✅'
//                 : state.checkOutTime != null
//                     ? 'Checked Out'
//                     : 'Not Checked In',
//             state.isCheckedIn ? Colors.green : Colors.grey,
//           ),
//           if (state.checkInTime != null)
//             _summaryRow(
//               'Check-In Time',
//               _formatDateTime(state.checkInTime!),
//               Colors.black87,
//             ),
//           if (state.checkOutTime != null)
//             _summaryRow(
//               'Check-Out Time',
//               _formatDateTime(state.checkOutTime!),
//               Colors.black87,
//             ),
//           if (state.checkOutTime != null && state.checkInTime != null)
//             _summaryRow(
//               'Total Hours',
//               _calculateTotalHours(state.checkInTime!, state.checkOutTime!),
//               Colors.blue,
//             ),
//           if (state.latitude != null && state.longitude != null)
//             _summaryRow(
//               'Location',
//               '${state.latitude!.toStringAsFixed(6)}, ${state.longitude!.toStringAsFixed(6)}',
//               Colors.black54,
//               fontSize: 12,
//             ),
//         ],
//       ),
//     );
//   }

//   Widget _summaryRow(String label, String value, Color valueColor,
//       {double fontSize = 14}) {
//     return Padding(
//       padding: const EdgeInsets.symmetric(vertical: 6),
//       child: Row(
//         mainAxisAlignment: MainAxisAlignment.spaceBetween,
//         children: [
//           Text(
//             label,
//             style: const TextStyle(
//               color: Colors.black54,
//               fontSize: 14,
//             ),
//           ),
//           Flexible(
//             child: Text(
//               value,
//               style: TextStyle(
//                 color: valueColor,
//                 fontSize: fontSize,
//                 fontWeight: FontWeight.w600,
//               ),
//               textAlign: TextAlign.right,
//             ),
//           ),
//         ],
//       ),
//     );
//   }

//   String _formatDateTime(DateTime dateTime) {
//     final hour = dateTime.hour.toString().padLeft(2, '0');
//     final minute = dateTime.minute.toString().padLeft(2, '0');
//     return '$hour:$minute';
//   }

//   String _calculateTotalHours(DateTime checkIn, DateTime checkOut) {
//     final duration = checkOut.difference(checkIn);
//     final hours = duration.inHours;
//     final minutes = duration.inMinutes % 60;
//     return '${hours}h ${minutes}m';
//   }
// }



// class AttendanceScreenWithPersistence extends StatelessWidget {
//   final int employeeId;
//   final String employeeName;

//   const AttendanceScreenWithPersistence({
//     super.key,
//     required this.employeeId,
//     required this.employeeName,
//   });

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: const Text('Attendance'),
//         backgroundColor: Colors.blue,
//         foregroundColor: Colors.white,
//       ),
//       body: BlocProvider(
//         create: (context) {
//           final bloc = CheckInBloc(DashboardRepository());
          
      
//           return bloc;
//         },
//         child: BlocListener<CheckInBloc, CheckInState>(
//           listener: (context, state) {
      
//             if (state.loadingStatus == CheckInLoadingStatus.success) {
//               if (state.isCheckedIn) {
//                 ScaffoldMessenger.of(context).showSnackBar(
//                   const SnackBar(
//                     content: Text('✅ Checked in successfully!'),
//                     backgroundColor: Colors.green,
//                   ),
//                 );
//               } else if (state.checkOutTime != null) {
//                 ScaffoldMessenger.of(context).showSnackBar(
//                   const SnackBar(
//                     content: Text('✅ Checked out successfully!'),
//                     backgroundColor: Colors.blue,
//                   ),
//                 );
//               }
//             }
//           },
//           child: SingleChildScrollView(
//             padding: const EdgeInsets.all(16),
//             child: Column(
//               children: [
//                 _EmployeeInfoCard(
//                   employeeName: employeeName,
//                   employeeId: employeeId,
//                 ),
//                 const SizedBox(height: 20),
//                 BlocBuilder<CheckInBloc, CheckInState>(
//                   builder: (context, state) {
//                     return CheckInCheckOutCard(
//                       state: state,
//                       employeeId: employeeId,
//                       createdBy: 'EMP_$employeeId',
//                     );
//                   },
//                 ),
//                 const SizedBox(height: 20),
//                 BlocBuilder<CheckInBloc, CheckInState>(
//                   builder: (context, state) {
//                     return _TodaySummaryCard(state: state);
//                   },
//                 ),
//               ],
//             ),
//           ),
//         ),
//       ),
//     );
//   }
// }