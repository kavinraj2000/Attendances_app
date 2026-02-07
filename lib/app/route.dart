import 'package:go_router/go_router.dart';
import 'package:hrm/app/route_name.dart';
import 'package:hrm/core/helper/navigation_helper.dart';
import 'package:hrm/screens/attendances/view/attendance_view.dart';
import 'package:hrm/screens/attendances/view/mobile/attances_mobile_view.dart';
import 'package:hrm/screens/dashboard/dashboard_view.dart';
import 'package:hrm/screens/login/view/login_view.dart';

class Routes {
  late final GoRouter router;

  Routes() {
    router = GoRouter(
      initialLocation: RouteName.login,
      routes: [
        GoRoute(
          name: RouteName.login,
          path: RouteName.login,
          builder: (context, state) => LoginPage(),
        ),

        GoRoute(
          name: RouteName.dashboard,
          path: RouteName.dashboard,
          pageBuilder: (context, state) => NoTransitionPage(
            key: state.pageKey,
            child: NavigationHelper(
              currentRoute: state.matchedLocation,
              child: DashboardView(),
            ),
          ),
        ),
          GoRoute(
          name: RouteName.logs,
          path: RouteName.logs,
          pageBuilder: (context, state) => NoTransitionPage(
            key: state.pageKey,
            child: NavigationHelper(
              currentRoute: state.matchedLocation,
              child: AttendanceView(),
            ),
          ),
        ),
      ],
    );
  }
}
