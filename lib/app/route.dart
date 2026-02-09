import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:hrm/app/route_name.dart';
import 'package:hrm/core/auth/bloc/auth_bloc.dart';
import 'package:hrm/core/auth/view/auth_page.dart';
import 'package:hrm/core/helper/navigation_helper.dart';
import 'package:hrm/screens/attendances/view/attendance_view.dart';
import 'package:hrm/screens/dashboard/dashboard_view.dart';
import 'package:hrm/screens/leave_form/view/mobile/leave_form_mobile_view.dart';

class Routes {
  late final GoRouter router;

  Routes() {
    router = GoRouter(
      initialLocation: RouteName.login,
      routes: [
        GoRoute(
          name: RouteName.login,
          path: RouteName.login,
          builder: (context, state) => AuthPage(),
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
        GoRoute(
          name: RouteName.leave,
          path: RouteName.leave,
          pageBuilder: (context, state) => NoTransitionPage(
            key: state.pageKey,
            child: NavigationHelper(
              currentRoute: state.matchedLocation,
              child: LeaveRequestForm(),
            ),
          ),
        ),
      ],
      redirect: (context, state) {
        final authState = context.read<AuthBloc>().state;
        final isLoginRoute = state.matchedLocation == RouteName.login;

        if (authState.status == AuthStatus.loading) {
          return null;
        }

        if (authState.status == AuthStatus.failure && !isLoginRoute) {
          return RouteName.login;
        }

        if (authState.status == AuthStatus.success && isLoginRoute) {
          return RouteName.dashboard;
        }

        return null;
      },
    );
  }
}
