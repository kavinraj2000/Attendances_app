import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hrm/screens/dashboard/bloc/dashboard_bloc.dart';
import 'package:hrm/screens/dashboard/repo/dashboard_repo.dart';
import 'package:hrm/screens/dashboard/view/dashboard_mobile_view.dart';

class DashboardView extends StatelessWidget {
  const DashboardView({super.key});

  @override
  Widget build(BuildContext context) {
    return RepositoryProvider<DashboardRepository>(
      create: (_) => DashboardRepository(),
      child: BlocProvider<DashboardBloc>(
        create: (context) => DashboardBloc(
          context.read<DashboardRepository>()
        ),
        child: const DashboardMobileView(),
      ),
    );
  }
}