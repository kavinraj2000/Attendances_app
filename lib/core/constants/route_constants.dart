import 'package:hrm/app/route_name.dart';
import 'package:hrm/core/constants/constants.dart';

class RouteConstants {
  RouteConstants();

  static const List<String> routesWithoutNavBar = [
    // '/search',
    // '/productdetail',
    // '/notificationInfo',
    // '/joinUs',
    // '/notification',
  ];

  // Routes where AppBar should be hidden
  static const List<String> routesWithoutAppbar = [
    // RouteName.logs,
    // Add more routes here that shouldn't show the AppBar
    // RouteName.setting,
    // RouteName.profile,
    // '/custom-page',
  ];

  static const List<String> routesWithoutStoryButton = [
    // '/search',
    // '/productdetail',
    // '/productinfo',
    // '/joinUs',
  ];

  static List<Map<String, dynamic>> navbar = [
    {
      'index': 0,
      'path': RouteName.dashboard,
      'icon': Constants.icon.home,
      'label': 'Home',
    },
    {
      'index': 1,
      'path': RouteName.logs,
      'icon': Constants.icon.calander,
      'label': 'Logs',
    },
    {
      'index': 2,
      'path': RouteName.profile,
      'icon': Constants.icon.profile,
      'label': 'Profile',
      'isDefault': true,
    },
    {
      'index': 3,
      'path': RouteName.leavelist,
      'icon': Constants.icon.calander,
      'label': 'Leave',
    },
  ];

  static List<String> get navigationRoutes {
    return navbar.map((item) => item['path'] as String).toList();
  }

  static int get defaultHomeIndex {
    return navbar.indexWhere((item) => item['isDefault'] == true);
  }

  static int get storyIndex {
    return navbar.indexWhere((item) => item['skipInNavBar'] == true);
  }

  static List<Map<String, dynamic>> get navbarItems {
    return navbar.where((item) => item['skipInNavBar'] != true).toList();
  }

  static bool shouldShowNavBar(String currentRoute) {
    return !routesWithoutNavBar.any((route) => currentRoute.contains(route));
  }

  static bool shouldShowAppbar(String currentRoute) {
    return !routesWithoutAppbar.any((route) => currentRoute.contains(route));
  }

  static bool shouldShowStoryButton(String currentRoute) {
    return !routesWithoutStoryButton.any(
      (route) => currentRoute.contains(route),
    );
  }

  static String? getRouteByIndex(int index) {
    if (index < 0 || index >= navbar.length) return null;
    return navbar[index]['path'] as String?;
  }

  static int getIndexByRoute(String route) {
    final cleanRoute = route.startsWith('/') ? route.substring(1) : route;

    for (int i = 0; i < navbar.length; i++) {
      final routePattern = navbar[i]['path'] as String;
      final cleanPattern = routePattern.startsWith('/')
          ? routePattern.substring(1)
          : routePattern;

      if (cleanRoute == cleanPattern ||
          cleanRoute.startsWith('$cleanPattern/')) {
        return i;
      }
    }

    return defaultHomeIndex;
  }

  static int getNextValidIndex(int currentIndex) {
    if (currentIndex < 0 || currentIndex >= navbar.length) {
      return defaultHomeIndex;
    }

    int nextIndex = currentIndex + 1;

    if (nextIndex == storyIndex) {
      nextIndex++;
    }

    if (nextIndex >= navbar.length) {
      return currentIndex;
    }

    return nextIndex;
  }

  static int getPreviousValidIndex(int currentIndex) {
    if (currentIndex < 0 || currentIndex >= navbar.length) {
      return defaultHomeIndex;
    }

    int prevIndex = currentIndex - 1;

    if (prevIndex == storyIndex) {
      prevIndex--;
    }

    if (prevIndex < 0) {
      return currentIndex;
    }

    return prevIndex;
  }
}