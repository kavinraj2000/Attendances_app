import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get/get.dart';
import 'package:go_router/go_router.dart';
import 'package:hrm/app/route_name.dart';
import 'package:hrm/core/auth/bloc/auth_bloc.dart';
import 'package:hrm/core/constants/constants.dart';
import 'package:hrm/core/repo/prefernces_repo.dart';
import 'package:hrm/core/widgets/app_widget.dart';
import 'package:hrm/core/widgets/bottom_nav_bar.dart';

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
  final PreferencesRepository _authRepo = PreferencesRepository();

  String _userName = 'User';

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
      final userData = await _authRepo.getUserData();

      setState(() {
        _userName = userData?.username ?? 'User';
      });
    } catch (e) {
      debugPrint('Error loading user data: $e');
      setState(() {
        _userName = 'User';
      });
    }
  }


  void _navigateToIndex(int index) {
    final route = _controller.getRouteByIndex(index);
    if (route == null) return;
    context.go(route);
  }

  Future<void> _handleBackNavigation() async {
    final isHomeRoute = _controller.isHomeRoute(widget.currentRoute);
    if (!isHomeRoute) {
      _navigateToIndex(Constants.route.defaultHomeIndex);
    }
  }

  void _handlePopInvoked(bool didPop) {
    if (!didPop) _handleBackNavigation();
  }

  @override
  Widget build(BuildContext context) {
    final selectedIndex =
        _controller.getSelectedIndex(widget.currentRoute);

    final shouldShowBottomNavBar =
        _controller.shouldShowBottomNavBar(widget.currentRoute);

    return BlocListener<AuthBloc, AuthState>(
      listenWhen: (previous, current) =>
          previous.status != current.status,
      listener: (context, state) {
        if (state.status == AuthStatus.initial) {
          context.goNamed(RouteName.login);
        }
      },
      child: PopScope(
        canPop: false,
        onPopInvoked: _handlePopInvoked,
        child: Scaffold(
          appBar: Constants.route.shouldShowAppbar(widget.currentRoute)
              ? CustomAppBar(
                  userName: _userName,
                  onLogoutPressed: () {
                    context.read<AuthBloc>().add(LogoutRequested());
                  },
                  onNotificationPressed: () {
                    debugPrint('Notification pressed');
                  },
                )
              : null,
          body: Column(
            children: [
              Expanded(child: widget.child),
            ],
          ),
          bottomNavigationBar: shouldShowBottomNavBar
              ? BottomNavBarWidget(
                  currentIndex: selectedIndex,
                  onTap: _navigateToIndex,
                )
              : null,
        ),
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
    if (route.isEmpty) return Constants.route.defaultHomeIndex;

    String baseRoute = route.contains('?')
        ? route.split('?').first
        : route;

    final index = Constants.route.getIndexByRoute(baseRoute);

    if (index == -1) {
      if (baseRoute.startsWith(RouteName.logs)) {
        return Constants.route.getIndexByRoute(RouteName.logs);
      }
      if (baseRoute.startsWith(RouteName.profile)) {
        return Constants.route.getIndexByRoute(RouteName.profile);
      }
      if (baseRoute.startsWith(RouteName.setting)) {
        return Constants.route.getIndexByRoute(RouteName.setting);
      }
      return Constants.route.defaultHomeIndex;
    }

    return index;
  }

  int getNextValidIndex(int currentIndex) =>
      Constants.route.getIndexByRoute(currentIndex.toString());

  int getPreviousValidIndex(int currentIndex) =>
      Constants.route.getIndexByRoute(currentIndex.toString());

  String? getRouteByIndex(int index) =>
      Constants.route.getRouteByIndex(index);

  bool shouldShowBottomNavBar(String route) =>
      Constants.route.shouldShowNavBar(route);

  bool shouldShowAppbar(String route) =>
      Constants.route.shouldShowAppbar(route);

  bool isHomeRoute(String route) {
    final index = getSelectedIndex(route);
    return index == Constants.route.defaultHomeIndex ||
        route == RouteName.dashboard ||
        route == '/';
  }
}