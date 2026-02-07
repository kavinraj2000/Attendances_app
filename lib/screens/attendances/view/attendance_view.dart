import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hrm/core/repo/localdb_repo.dart';
import 'package:hrm/core/repo/prefernces_repo.dart';
import 'package:hrm/screens/attendances/bloc/attendances_bloc.dart';
import 'package:hrm/screens/attendances/repo/attendances_repo.dart';
import 'package:hrm/screens/attendances/view/mobile/attances_mobile_view.dart';

class AttendanceView extends StatelessWidget {
  const AttendanceView({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiRepositoryProvider(
      providers: [
        RepositoryProvider<LocalDBRepository>(
          create: (_) => LocalDBRepository(),
        ),
        RepositoryProvider<PreferencesRepository>(
          create: (_) => PreferencesRepository(),
        ),
      ],
      child: BlocProvider<AttendanceLogsBloc>(
        create: (context) => AttendanceLogsBloc(
          repository: AttendancesRepo(
            context.read<LocalDBRepository>(),
            context.read<PreferencesRepository>(),
          ),
        )..add(
            LoadAttendanceLogs(
              month: DateTime.now().month,
              year: DateTime.now().year,
            ),
          ),
        child: const AttendanceLogsScreen(),
      ),
    );
  }
}
