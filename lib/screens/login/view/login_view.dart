import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hrm/screens/login/bloc/login_bloc.dart';
import 'package:hrm/screens/login/repo/login_repo.dart';
import 'package:hrm/screens/login/view/mobile/login_mobile_view.dart';

class LoginPage extends StatelessWidget {
  const LoginPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) =>
          LoginBloc(LoginRepo())..add(const CheckLoginStatus()),
      child: const LoginMobileView(),
    );
  }
}
