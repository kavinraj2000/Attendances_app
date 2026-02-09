import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hrm/core/auth/bloc/auth_bloc.dart';
import 'package:hrm/core/auth/repo/auth_repo.dart';
import 'package:hrm/core/auth/view/mobile/auth_login_view.dart';
import 'package:hrm/core/repo/prefernces_repo.dart';

class AuthPage extends StatelessWidget {
  const AuthPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) =>
          AuthBloc(AuthRepo(context.read<PreferencesRepository>()))
            ..add(const CheckAuthStatus()),
      child: const AuthloginView(),
    );
  }
}
