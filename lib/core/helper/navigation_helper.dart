import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:go_router/go_router.dart';
import 'package:hrm/app/route_name.dart';
import 'package:hrm/core/constants/route_constants.dart';
import 'package:hrm/core/repo/prefernces_repo.dart';
import 'package:hrm/core/widgets/app_widget/app_widget.dart';
import 'package:hrm/core/widgets/app_widget/bottom_nav_bar.dart';

class NavigationHelper extends StatefulWidget {
  final Widget child;
  final String currentRoute;
  final VoidCallback? onProfilePressed;
  final VoidCallback? onHomeRefresh;
  final bool isLoggedIn;
  final String? profileImage;

  const NavigationHelper({
    super.key,
    required this.child,
    required this.currentRoute,
    this.onProfilePressed,
    this.onHomeRefresh,
    this.isLoggedIn = false,
    this.profileImage,
  });

  @override
  State<NavigationHelper> createState() => _NavigationHelperState();
}

class _NavigationHelperState extends State<NavigationHelper> {
  late final MainShellController _controller;
  final PreferencesRepository _loginRepo = PreferencesRepository();

  String _userName = 'User';
  String _greeting = 'Good Morning';
  String? _avatarUrl;
  bool _isLoadingUserData = true;

  @override
  void initState() {
    super.initState();
    _controller = Get.put(MainShellController(), permanent: true);
    _loadUserData();
  }

  @override
  void didUpdateWidget(NavigationHelper oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.currentRoute != widget.currentRoute) {
      _controller.updateCurrentRoute(widget.currentRoute);
    }
  }

  Future<void> _loadUserData() async {
    try {
      final userData = await _loginRepo.getUserData();

      if (userData != null) {
        setState(() {
          _userName = userData.username;
          _greeting = _getGreeting();
          _isLoadingUserData = false;
        });
      } else {
        setState(() {
          _userName = 'User';
          _greeting = _getGreeting();
          _isLoadingUserData = false;
        });
      }
    } catch (e) {
      print('Error loading user data: $e');
      setState(() {
        _userName = 'User';
        _greeting = _getGreeting();
        _isLoadingUserData = false;
      });
    }
  }

  String _getGreeting() {
    final hour = DateTime.now().hour;
    if (hour < 12) {
      return 'Good Morning';
    } else if (hour < 17) {
      return 'Good Afternoon';
    } else {
      return 'Good Evening';
    }
  }

  void _navigateToIndex(int index) {
    final route = _controller.getRouteByIndex(index);
    if (route == null) return;

    context.go(route);
  }

  void _handleHomeRefresh() {
    final selectedIndex = _controller.getSelectedIndex(widget.currentRoute);
    if (selectedIndex == RouteConstants.defaultHomeIndex) {
      widget.onHomeRefresh?.call();
    }
  }

  Future<void> _handleBackNavigation() async {
    final isHomeRoute = _controller.isHomeRoute(widget.currentRoute);
    if (!isHomeRoute) {
      _navigateToIndex(RouteConstants.defaultHomeIndex);
    }
  }

  void _handlePopInvoked(bool didPop) {
    if (!didPop) _handleBackNavigation();
  }

  @override
  Widget build(BuildContext context) {
    final selectedIndex = _controller.getSelectedIndex(widget.currentRoute);
    final shouldShowBottomNavBar = _controller.shouldShowBottomNavBar(
      widget.currentRoute,
    );
    final shouldShowAppBar = _controller.shouldShowappbar(widget.currentRoute);

    return PopScope(
      canPop: false,
      onPopInvoked: _handlePopInvoked,
      child: Scaffold(
        appBar: (_isLoadingUserData || !shouldShowAppBar)
            ? null
            : CustomAppBar(
                userName: _userName,
                greeting: _greeting,
                avatarUrl: _avatarUrl,
                showLocation: false,
                onMenuPressed: () {
                  print('Menu pressed');
                },
                onNotificationPressed: () {
                  print('Notification pressed');
                },
              ),
        body: Column(
          children: [
            // const NetworkBanner(),
            Expanded(child: widget.child),
          ],
        ),
        bottomNavigationBar: shouldShowBottomNavBar
            ? BottomNavBarWidget(
                currentIndex: selectedIndex,
                onTap: _navigateToIndex,
                // : _handleHomeRefresh,
              )
            : null,
      ),
    );
  }
}

class MainShellController extends GetxController {
  final _currentRoute = ''.obs;

  String get currentRoute => _currentRoute.value;

  void updateCurrentRoute(String route) {
    _currentRoute.value = route;
  }

  int getSelectedIndex(String route) {
    if (route.isEmpty) return RouteConstants.defaultHomeIndex;

    String baseRoute = route;
    if (route.contains('?')) {
      baseRoute = route.split('?').first;
    }

    final index = RouteConstants.getIndexByRoute(baseRoute);

    if (index == -1) {
      if (baseRoute.startsWith(RouteName.logs)) {
        return RouteConstants.getIndexByRoute(RouteName.logs);
      }
      if (baseRoute.startsWith(RouteName.profile)) {
        return RouteConstants.getIndexByRoute(RouteName.profile);
      }
      if (baseRoute.startsWith(RouteName.setting)) {
        return RouteConstants.getIndexByRoute(RouteName.setting);
      }
      return RouteConstants.defaultHomeIndex;
    }

    return index;
  }

  int getNextValidIndex(int currentIndex) =>
      RouteConstants.getNextValidIndex(currentIndex);

  int getPreviousValidIndex(int currentIndex) =>
      RouteConstants.getPreviousValidIndex(currentIndex);

  String? getRouteByIndex(int index) => RouteConstants.getRouteByIndex(index);

  bool shouldShowBottomNavBar(String route) =>
      RouteConstants.shouldShowNavBar(route);
      
  bool shouldShowappbar(String route) =>
      RouteConstants.shouldShowAppbar(route);

  bool isHomeRoute(String route) {
    final index = getSelectedIndex(route);
    return index == RouteConstants.defaultHomeIndex ||
        route == RouteName.dashboard ||
        route == '/';
  }
}