import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hrm/app/app.dart';
import 'package:hrm/core/repo/localdb_repo.dart';
import 'package:hrm/core/repo/prefernces_repo.dart';


void main() {
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
      child: const App(),
    ),
  );
}



