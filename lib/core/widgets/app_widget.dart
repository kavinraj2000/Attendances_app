import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:hrm/app/route_name.dart';
import 'package:hrm/core/constants/constants.dart';

class CustomAppBar extends StatefulWidget implements PreferredSizeWidget {
  final String userName;
  final String greeting;
  final VoidCallback? onMenuPressed;
  final VoidCallback? onNotificationPressed;
  final bool showLocation;
  final VoidCallback? onProfilePressed;
  final VoidCallback? onSettingsPressed;
  final VoidCallback? onLogoutPressed;

  const CustomAppBar({
    super.key,
    required this.userName,
    this.greeting = '',
    this.onMenuPressed,
    this.onNotificationPressed,
    this.showLocation = true,
    this.onProfilePressed,
    this.onSettingsPressed,
    this.onLogoutPressed,
  });

  @override
  Size get preferredSize => const Size.fromHeight(80);

  @override
  State<CustomAppBar> createState() => _CustomAppBarState();
}

class _CustomAppBarState extends State<CustomAppBar> {
  @override
  Widget build(BuildContext context) {
    final primary = Constants.color.lightColors['primary']!;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [primary, Constants.color.lightColors['secondary']!],
        ),
      ),
      child: SafeArea(
        bottom: false,
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'HRM',
                  style: Constants.app.headerwhite.copyWith(fontSize: 30),
                ),

                Row(
                  children: [
                    IconButton(
                      icon: const Icon(
                        Icons.notifications_none,
                        color: Colors.white,
                      ),
                      onPressed: widget.onNotificationPressed,
                    ),

                    /// PROFILE MENU
                    PopupMenuButton<String>(
                      offset: const Offset(0, 50),
                      color: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: CircleAvatar(
                        radius: 18,
                        backgroundColor: Constants.color.lightColors['gray']!,
                        child: Text(
                          widget.userName.isNotEmpty
                              ? widget.userName[0].toUpperCase()
                              : '',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 15,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      itemBuilder: (context) => [
                        PopupMenuItem<String>(
                          value: 'profile',
                          child: Row(
                            children: [
                              Icon(
                                Icons.person_outline,
                                color: Constants.color.lightColors['primary'],
                              ),
                              const SizedBox(width: 12),
                              const Text('Profile'),
                            ],
                          ),
                        ),
                        PopupMenuItem<String>(
                          value: 'leave',
                          child: Row(
                            children: [
                              IconButton(
                                onPressed: () {
                                  context.goNamed(RouteName.leave);
                                },
                                icon: Icon(Icons.date_range),
                                color: Constants.color.lightColors['primary'],
                              ),
                              const SizedBox(width: 12),
                              const Text('Leave Request'),
                            ],
                          ),
                        ),
                        const PopupMenuDivider(),
                        PopupMenuItem<String>(
                          value: 'logout',
                          child: Row(
                            children: [
                              Icon(Icons.logout, color: Colors.red[400]),
                              const SizedBox(width: 12),
                              Text(
                                'Logout',
                                style: TextStyle(color: Colors.red[400]),
                              ),
                            ],
                          ),
                        ),
                      ],
                      onSelected: (value) {
                        switch (value) {
                          case 'profile':
                            widget.onProfilePressed?.call();
                            break;
                          case 'leave':
                            widget.onSettingsPressed?.call();
                            break;
                          case 'logout':
                            widget.onLogoutPressed?.call();
                            break;
                        }
                      },
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
