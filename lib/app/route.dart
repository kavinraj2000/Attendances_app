import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:hrm/app/route_name.dart';
import 'package:hrm/core/auth/bloc/auth_bloc.dart';
import 'package:hrm/core/auth/view/auth_page.dart';
import 'package:hrm/core/auth/view/mobile/otp_checkin_page.dart';
import 'package:hrm/core/auth/view/mobile/otp_page.dart';
import 'package:hrm/core/helper/navigation_helper.dart';
import 'package:hrm/core/helper/route_helper.dart';
import 'package:hrm/core/services/image_capture_service.dart';
import 'package:hrm/screens/attendances/view/attendance_view.dart';
import 'package:hrm/screens/dashboard/dashboard_view.dart';
import 'package:hrm/screens/leave/leave_req_form/view/leave_req_form_view.dart';
import 'package:hrm/screens/leave/leave_req_list/view/leave_req_list_view.dart';
import 'package:logger/logger.dart';

class Routes {
  final AuthBloc authBloc;
  late final GoRouter router;

  Routes(this.authBloc) {
    router = GoRouter(
      initialLocation: RouteName.otp,
      routes: [
        GoRoute(
          name: RouteName.login,
          path: RouteName.login,
          builder: (context, state) => AuthPage(),
        ),
        GoRoute(
          name: RouteName.otp,
          path: RouteName.otp,
          builder: (context, state) {
            final email = state.uri.queryParameters['email'];
            log.d('RouteName.otp::$email');
            return OtpPage(email: email ?? '');
          },
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
          name: RouteName.leavereq,
          path: RouteName.leavereq,
          pageBuilder: (context, state) {
            final int? id = state.extra as int?;
            Logger().d('RouteName.leavereq:update::$id');
            return NoTransitionPage(
              key: state.pageKey,
              child: NavigationHelper(
                currentRoute: state.matchedLocation,
                child: LeaveReqFormView(id: id),
              ),
            );
          },
        ),
        GoRoute(
          name: RouteName.leavelist,
          path: RouteName.leavelist,
          pageBuilder: (context, state) => NoTransitionPage(
            key: state.pageKey,
            child: NavigationHelper(
              currentRoute: state.matchedLocation,
              child: LeaveReqListView(),
            ),
          ),
        ),
      ],
      // redirect: (context, state) {
      //   final authState = authBloc.state;
      //   final location = state.matchedLocation;

      //   final isLoginPage = location == RouteName.login;
      //   final isOtpPage = location == RouteName.otp;
      //   final isAuthPage = isLoginPage || isOtpPage;

      //   // Don't redirect while loading
      //   if (authState.status == AuthStatus.loading) {
      //     return null;
      //   }

      //   // User is authenticated (success status)
      //   final isAuthenticated = authState.status == AuthStatus.success;

      //   if (isAuthenticated) {
      //     // If already authenticated and trying to access auth pages, redirect to dashboard
      //     if (isAuthPage) {
      //       return RouteName.dashboard;
      //     }
      //     // Allow access to protected pages
      //     return null;
      //   }

      //   if (authState.status == AuthStatus.otpsend) {
      //     if (isLoginPage) {
      //       return '${RouteName.otp}?email=${authState.email}';
      //     }
      //     if (isOtpPage) {
      //       return null;
      //     }
      //     // Trying to access protected pages while OTP pending - redirect to OTP
      //     return '${RouteName.otp}?email=${authState.email}';
      //   }

      //   if (isOtpPage) {
      //     return RouteName.login;
      //   }

      //   if (!isAuthPage) {
      //     return RouteName.login;
      //   }

      //   return null;
      // },
      refreshListenable: GoRouterRefreshStream(authBloc.stream),
    );
  }
}
