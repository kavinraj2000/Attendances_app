import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hrm/app/app.dart';
import 'package:hrm/core/auth/bloc/auth_bloc.dart';
import 'package:hrm/core/auth/repo/auth_repo.dart';
import 'package:hrm/core/extension/setup_locator.dart';
import 'package:hrm/core/repo/localdb_repo.dart';
import 'package:hrm/core/repo/prefernces_repo.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  setupLocator();
  runApp(
    MultiRepositoryProvider(
      providers: [
        RepositoryProvider<LocalDBRepository>(
          create: (_) => LocalDBRepository(),
        ),
        RepositoryProvider<PreferencesRepository>(
          create: (_) => PreferencesRepository(),
        ),
      ],
      child: MultiBlocProvider(
        providers: [
          BlocProvider<AuthBloc>(
            create: (context) =>
                AuthBloc(AuthRepo(context.read<PreferencesRepository>()))
                  ..add(CheckAuthStatus()),
          ),
        ],
        child: App(),
      ),
    ),
  );
}
