import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hrm/app/route.dart';
import 'package:hrm/core/auth/bloc/auth_bloc.dart';
import 'package:hrm/core/auth/repo/auth_repo.dart';
import 'package:hrm/core/repo/prefernces_repo.dart';
import 'package:hrm/core/theme/app_theme/app_theme.dart';
import 'package:hrm/core/util/util.dart';

class App extends StatelessWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) =>
          AuthBloc(AuthRepo(context.read<PreferencesRepository>())),
      child: Builder(
        builder: (context) {
          return MaterialApp.router(
            debugShowCheckedModeBanner: false,
            themeMode: ThemeMode.system,
            theme: AppTheme.lightTheme,
            routerConfig: Routes(
              context.read<AuthBloc>(), // ✅ SAME INSTANCE
            ).router,
            builder: (context, child) {
              return Util(child: child);
            },
          );
        },
      ),
    );
  }
}
