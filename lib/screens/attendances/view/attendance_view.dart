import 'package:flutter/material.dart';
import 'package:hrm/screens/attendances/provoider/attendance_log_provoider.dart';
import 'package:hrm/screens/attendances/view/mobile/attendances_log.dart';
import 'package:provider/provider.dart';
import 'package:hrm/core/repo/localdb_repo.dart';
import 'package:hrm/core/repo/prefernces_repo.dart';
import 'package:hrm/screens/attendances/repo/attendances_repo.dart';

class AttendanceView extends StatelessWidget {
  const AttendanceView({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        Provider<LocalDBRepository>(create: (_) => LocalDBRepository.instance),

        Provider<PreferencesRepository>(create: (_) => PreferencesRepository()),

        Provider<AttendancesRepo>(
          create: (context) => AttendancesRepo(
            context.read<LocalDBRepository>(),
            context.read<PreferencesRepository>(),
          ),
        ),

        ChangeNotifierProvider<AttendanceLogProvider>(
          create: (context) =>
              AttendanceLogProvider(repo: context.read<AttendancesRepo>())
                ..loadAttendanceLogs(
                  month: DateTime.now().month,
                  year: DateTime.now().year,
                ),
        ),
      ],
      child: const AttendanceLogsScreen(),
    );
  }
}
