import 'package:go_router/go_router.dart';
import 'package:hrm/app/route_name.dart';
import 'package:hrm/core/auth/bloc/auth_bloc.dart';
import 'package:hrm/core/auth/view/auth_page.dart';
import 'package:hrm/core/auth/view/mobile/otp_page.dart';
import 'package:hrm/core/helper/navigation_helper.dart';
import 'package:hrm/core/helper/route_helper.dart';
import 'package:hrm/core/repo/prefernces_repo.dart';
import 'package:hrm/core/services/image_capture_service.dart';
import 'package:hrm/screens/attendances/view/attendance_view.dart';
import 'package:hrm/screens/dashboard/dashboard_view.dart';
import 'package:hrm/screens/leave/leave_req_form/view/leave_req_form_view.dart';
import 'package:hrm/screens/leave/leave_req_list/view/leave_req_list_view.dart';
import 'package:hrm/screens/profile/view/mobile/profile_mobile_view_page.dart';
import 'package:hrm/screens/profile/view/profile_view.dart';
import 'package:logger/logger.dart';

class Routes {
  final AuthBloc authBloc;
  late final GoRouter router;

  Routes(this.authBloc) {
    router = GoRouter(
      initialLocation: RouteName.login,
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
            Logger().d('RouteName.otp::$email');
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
            final Map<String, dynamic>? id =
                state.extra as Map<String, dynamic>?;
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
             GoRoute(
          name: RouteName.profile,
          path: RouteName.profile,
          pageBuilder: (context, state) => NoTransitionPage(
            key: state.pageKey,
            child: NavigationHelper(
              currentRoute: state.matchedLocation,
              child: ProfileView(),
            ),
          ),
        ),
      ],
      redirect: (context, state) async {
        final authState = authBloc.state;
        final location = state.matchedLocation;
        final PreferencesRepository preferencesRepository =
            PreferencesRepository();

        final isLoginPage = location == RouteName.login;
        final isOtpPage = location == RouteName.otp;
        final isAuthPage = isLoginPage || isOtpPage;

        final isLoggedIn = await preferencesRepository.isLoggedIn();
        final isAuthSuccess = await preferencesRepository.isAuthSuccess();
        final token = await preferencesRepository.getToken();

        Logger().d('Redirect Check:');
        Logger().d('- Location: $location');
        Logger().d('- isLoggedIn: $isLoggedIn');
        Logger().d(
          '- isAuthSuccess: $isAuthSuccess::::- authState.status: ${authState.status}::::',
        );
        Logger().d('- authState.status: ${authState.status}');

        if (authState.status == AuthStatus.loading) {
          return null;
        }

        final isAuthenticated =
            (authState.status == AuthStatus.success) ||
            (isLoggedIn && isAuthSuccess && token != null);

        if (isAuthenticated) {
          Logger().d('User is authenticated');
          if (isAuthPage) {
            Logger().d('Redirecting to dashboard from auth page');
            return RouteName.dashboard;
          }
          return null;
        }

        if (authState.status == AuthStatus.otpsend) {
          final otpRoute = '${RouteName.otp}?email=${authState.email}';
          Logger().d('OTP sent, redirecting to: $otpRoute');
          if (isOtpPage) return null;
          return otpRoute;
        }

        Logger().d('User is NOT authenticated');
        if (!isAuthPage) {
          Logger().d('Redirecting to login page');
          return RouteName.login;
        }

        return null;
      },
      refreshListenable: GoRouterRefreshStream(authBloc.stream),
    );
  }
}
