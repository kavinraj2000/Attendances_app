import 'package:get_it/get_it.dart';
import 'package:hrm/core/auth/bloc/auth_bloc.dart';
import 'package:hrm/core/auth/repo/auth_repo.dart';
import 'package:hrm/core/repo/api_repo.dart';
import 'package:hrm/core/repo/prefernces_repo.dart';

final GetIt getIt = GetIt.instance;

void setupLocator() {
  getIt.registerLazySingleton<Api>(() => Api());

  getIt.registerLazySingleton<AuthRepo>(
    () => AuthRepo(getIt<PreferencesRepository>()),
  );
  getIt.registerFactory<AuthBloc>(() => AuthBloc(getIt<AuthRepo>()));
}
