import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hrm/screens/leave/leave_req_form/bloc/leave_req_form_bloc.dart';
import 'package:hrm/screens/leave/leave_req_form/repo/leave_req_form_repo.dart';
import 'package:hrm/screens/leave/leave_req_form/view/mobile/leave_req_form_mobile_view.dart';

class LeaveReqFormView extends StatelessWidget {
  const LeaveReqFormView({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => LeaveReqFormBloc(LeaveFormRepository()),
      child: LeaveFormMobileView(),
    );
  }
}
