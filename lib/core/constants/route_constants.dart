import 'package:hrm/app/route_name.dart';
import 'package:hrm/core/constants/constants.dart';
import 'package:hrm/core/model/nav_item.dart';

class ROUTECONSTANTS {
  ROUTECONSTANTS();

  final List<String> routesWithoutNavBar = [
    RouteName.leavereq,
  ];

  final List<String> routesWithoutAppbar = [];

  final List<String> routesWithoutStoryButton = [];

  final List<NavItem> navbar = [
    NavItem(
      index: 0,
      path: RouteName.dashboard,
      icon: Constants.icon.home,
      label: 'Home',
      isDefault: true,
    ),
    NavItem(
      index: 1,
      path: RouteName.logs,
      icon: Constants.icon.calander,
      label: 'Logs',
    ),
    NavItem(
      index: 2,
      path: RouteName.leavelist,
      icon: Constants.icon.calander,
      label: 'Leave',
    ),
  ];


  List<String> get navigationRoutes =>
      navbar.map((item) => item.path).toList();

  int get defaultHomeIndex =>
      navbar.indexWhere((item) => item.isDefault);

  int get storyIndex =>
      navbar.indexWhere((item) => item.skipInNavBar);

  List<NavItem> get navbarItems =>
      navbar.where((item) => !item.skipInNavBar).toList();

  bool shouldShowNavBar(String currentRoute) =>
      !routesWithoutNavBar
          .any((route) => currentRoute.contains(route));

  bool shouldShowAppbar(String currentRoute) =>
      !routesWithoutAppbar
          .any((route) => currentRoute.contains(route));

  bool shouldShowStoryButton(String currentRoute) =>
      !routesWithoutStoryButton
          .any((route) => currentRoute.contains(route));

  String? getRouteByIndex(int index) {
    if (index < 0 || index >= navbar.length) return null;
    return navbar[index].path;
  }

  int getIndexByRoute(String route) {
    final cleanRoute =
        route.startsWith('/') ? route.substring(1) : route;

    for (int i = 0; i < navbar.length; i++) {
      final pattern = navbar[i].path;
      final cleanPattern =
          pattern.startsWith('/')
              ? pattern.substring(1)
              : pattern;

      if (cleanRoute == cleanPattern ||
          cleanRoute.startsWith('$cleanPattern/')) {
        return i;
      }
    }

    return defaultHomeIndex;
  }
}