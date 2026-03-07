import 'package:flutter/material.dart';
import 'package:hrm/screens/dashboard/provoider/dashboard_provoider.dart';
import 'package:hrm/screens/dashboard/repo/dashboard_repo.dart';
import 'package:hrm/screens/dashboard/view/dashboard_mobile_view.dart';
import 'package:provider/provider.dart';

class DashboardView extends StatelessWidget {
  const DashboardView({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) =>
          DashboardProvider(DashboardRepository())..initialize(),
      child: const DashboardMobileView(),
    );
  }
}