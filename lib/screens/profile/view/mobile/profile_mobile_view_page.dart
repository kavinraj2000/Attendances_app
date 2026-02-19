// import 'package:flutter/material.dart';
// import 'package:flutter_bloc/flutter_bloc.dart';
// import 'package:hrm/screens/profile/bloc/profile_bloc.dart';



// class ProfileMobileView extends StatelessWidget {
//   const ProfileMobileView({super.key});

//   @override
//   Widget build(BuildContext context) {
//     return BlocConsumer<ProfileBloc, ProfileState>(
//       listener: (context, state) {
//         if (state is ProfileLoggedOut) {
//           Navigator.of(context).pushNamedAndRemoveUntil('/login', (_) => false);
//         } else if (state is ProfileError) {
//           ScaffoldMessenger.of(context).showSnackBar(
//             SnackBar(
//               content: Text(state.message),
//               backgroundColor: Colors.red,
//             ),
//           );
//         }
//       },
//       builder: (context, state) {
//         final theme = Theme.of(context);
//         final colorScheme = theme.colorScheme;

//         if (state is ProfileLoading || state is ProfileInitial) {
//           return const Scaffold(
//             body: Center(child: CircularProgressIndicator()),
//           );
//         }

//         if (state is ProfileLoaded) {
//           return Scaffold(
//             backgroundColor: colorScheme.surface,
//             body: RefreshIndicator(
//               onRefresh: () async =>
//                   context.read<ProfileBloc>().add(ProfileLoadRequested()),
//               child: CustomScrollView(
//                 slivers: [
//                   SliverAppBar(
//                     expandedHeight: 220,
//                     pinned: true,
//                     backgroundColor: colorScheme.primary,
//                     flexibleSpace: FlexibleSpaceBar(
//                       background: _ProfileHeader(
//                         username: state.username,
//                         emailId: state.emailId,
//                         colorScheme: colorScheme,
//                       ),
//                     ),
                    
//                   ),
//                   // SliverToBoxAdapter(
//                   //   child: Padding(
//                   //     padding: const EdgeInsets.all(16),
//                   //     child: _ProfileBody(state: state),
//                   //   ),
//                   // ),
//                 ],
//               ),
//             ),
//           );
//         }

//         // ProfileError state — show error + retry
//         return Scaffold(
//           body: Center(
//             child: Column(
//               mainAxisSize: MainAxisSize.min,
//               children: [
//                 const Icon(Icons.error_outline, size: 48, color: Colors.red),
//                 const SizedBox(height: 12),
//                 Text(
//                   state is ProfileError ? state.message : 'Something went wrong',
//                   textAlign: TextAlign.center,
//                 ),
//                 const SizedBox(height: 16),
//                 ElevatedButton(
//                   onPressed: () =>
//                       context.read<ProfileBloc>().add(ProfileLoadRequested()),
//                   child: const Text('Retry'),
//                 ),
//               ],
//             ),
//           ),
//         );
//       },
//     );
//   }
// }

// // ── Header ────────────────────────────────────────────────────────────────────

// class _ProfileHeader extends StatelessWidget {
//   final String? username;
//   final String? emailId;
//   final ColorScheme colorScheme;

//   const _ProfileHeader({
//     required this.username,
//     required this.emailId,
//     required this.colorScheme,
//   });

//   String _getInitials(String? name) {
//     if (name == null || name.isEmpty) return '?';
//     final parts = name.trim().split(' ');
//     if (parts.length == 1) return parts[0][0].toUpperCase();
//     return (parts[0][0] + parts[1][0]).toUpperCase();
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Container(
//       decoration: BoxDecoration(
//         gradient: LinearGradient(
//           begin: Alignment.topLeft,
//           end: Alignment.bottomRight,
//           colors: [
//             colorScheme.primary,
//             colorScheme.primary.withOpacity(0.75),
//           ],
//         ),
//       ),
//       child: Column(
//         mainAxisAlignment: MainAxisAlignment.center,
//         children: [
//           const SizedBox(height: 40),
//           Container(
//             width: 88,
//             height: 88,
//             decoration: BoxDecoration(
//               shape: BoxShape.circle,
//               color: Colors.white.withOpacity(0.2),
//               border: Border.all(color: Colors.white, width: 2.5),
//             ),
//             child: Center(
//               child: Text(
//                 _getInitials(username),
//                 style: const TextStyle(
//                   color: Colors.white,
//                   fontSize: 32,
//                   fontWeight: FontWeight.bold,
//                 ),
//               ),
//             ),
//           ),
//           const SizedBox(height: 10),
//           Text(
//             username ?? 'User',
//             style: const TextStyle(
//               color: Colors.white,
//               fontSize: 20,
//               fontWeight: FontWeight.bold,
//             ),
//           ),
//           const SizedBox(height: 4),
//           Text(
//             emailId ?? '',
//             style: TextStyle(
//               color: Colors.white.withOpacity(0.85),
//               fontSize: 13,
//             ),
//           ),
//           const SizedBox(height: 8),
//         ],
//       ),
//     );
//   }
// }





//   @override
//   Widget build(BuildContext context) {
//     return SizedBox(
//       width: double.infinity,
//       child: ElevatedButton.icon(
//         onPressed: () {},
//         style: ElevatedButton.styleFrom(
//           backgroundColor: Colors.red.shade600,
//           foregroundColor: Colors.white,
//           padding: const EdgeInsets.symmetric(vertical: 14),
//           shape: RoundedRectangleBorder(
//             borderRadius: BorderRadius.circular(12),
//           ),
//         ),
//         icon: const Icon(Icons.logout),
//         label: const Text(
//           'Logout',
//           style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
//         ),
//       ),
//     );
//   }


// // ── Auth Badge ────────────────────────────────────────────────────────────────

// class _AuthBadge extends StatelessWidget {
//   final String authStatus;
//   const _AuthBadge({required this.authStatus});

//   @override
//   Widget build(BuildContext context) {
//     final isSuccess = authStatus == 'Success';
//     return Center(
//       child: Container(
//         padding:
//             const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
//         decoration: BoxDecoration(
//           color: isSuccess
//               ? Colors.green.withOpacity(0.12)
//               : Colors.orange.withOpacity(0.12),
//           borderRadius: BorderRadius.circular(20),
//           border: Border.all(
//             color: isSuccess ? Colors.green : Colors.orange,
//           ),
//         ),
//         child: Row(
//           mainAxisSize: MainAxisSize.min,
//           children: [
//             Icon(
//               isSuccess
//                   ? Icons.verified_outlined
//                   : Icons.warning_amber_outlined,
//               size: 16,
//               color: isSuccess ? Colors.green : Colors.orange,
//             ),
//             const SizedBox(width: 6),
//             Text(
//               'Auth Status: $authStatus',
//               style: TextStyle(
//                 fontWeight: FontWeight.w600,
//                 color: isSuccess
//                     ? Colors.green.shade700
//                     : Colors.orange.shade700,
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }

// // ── Section Card ──────────────────────────────────────────────────────────────

// class _SectionCard extends StatelessWidget {
//   final String title;
//   final IconData icon;
//   final List<Widget> children;

//   const _SectionCard({
//     required this.title,
//     required this.icon,
//     required this.children,
//   });

//   @override
//   Widget build(BuildContext context) {
//     final primary = Theme.of(context).colorScheme.primary;
//     return Card(
//       elevation: 0,
//       shape: RoundedRectangleBorder(
//         borderRadius: BorderRadius.circular(14),
//         side: BorderSide(color: Colors.grey.shade200),
//       ),
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           Padding(
//             padding: const EdgeInsets.symmetric(
//                 horizontal: 16, vertical: 12),
//             child: Row(
//               children: [
//                 Icon(icon, size: 18, color: primary),
//                 const SizedBox(width: 8),
//                 Text(
//                   title,
//                   style: TextStyle(
//                     fontWeight: FontWeight.w700,
//                     fontSize: 14,
//                     color: primary,
//                   ),
//                 ),
//               ],
//             ),
//           ),
//           const Divider(height: 1),
//           ...children,
//         ],
//       ),
//     );
//   }
// }

// // ── Info Row ──────────────────────────────────────────────────────────────────

// class _InfoRow extends StatelessWidget {
//   final IconData icon;
//   final String label;
//   final String value;
//   final Color? valueColor;

//   const _InfoRow({
//     required this.icon,
//     required this.label,
//     required this.value,
//     this.valueColor,
//   });

//   @override
//   Widget build(BuildContext context) {
//     return Padding(
//       padding:
//           const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
//       child: Row(
//         children: [
//           Icon(icon, size: 18, color: Colors.grey.shade500),
//           const SizedBox(width: 12),
//           Expanded(
//             child: Text(
//               label,
//               style: TextStyle(fontSize: 13, color: Colors.grey.shade600),
//             ),
//           ),
//           Text(
//             value,
//             style: TextStyle(
//               fontSize: 14,
//               fontWeight: FontWeight.w600,
//               color: valueColor ?? Colors.black87,
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }

// // ── Role Chip ─────────────────────────────────────────────────────────────────

// class _RoleChip extends StatelessWidget {
//   final String role;
//   const _RoleChip({required this.role});

//   @override
//   Widget build(BuildContext context) {
//     final primary = Theme.of(context).colorScheme.primary;
//     return Chip(
//       label: Text(
//         role.trim(),
//         style: TextStyle(
//           fontSize: 12,
//           color: primary,
//           fontWeight: FontWeight.w600,
//         ),
//       ),
//       backgroundColor: primary.withOpacity(0.1),
//       side: BorderSide(color: primary.withOpacity(0.3)),
//       padding: const EdgeInsets.symmetric(horizontal: 4),
//     );
//   }
// }