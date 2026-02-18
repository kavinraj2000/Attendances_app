import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hrm/screens/profile/bloc/profile_bloc.dart';
import 'package:hrm/screens/profile/view/mobile/profile_mobile_view_page.dart';

class ProfileView extends StatelessWidget {
  const ProfileView({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
        create: (_) => ProfileBloc(),
        child: const ProfilePage(),
      );
  }
}