import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hrm/screens/leave/leave_req_form/bloc/leave_req_form_bloc.dart';
import 'package:hrm/screens/leave/leave_req_form/repo/leave_req_form_repo.dart';
import 'package:hrm/screens/leave/leave_req_form/view/mobile/leave_req_form_mobile_view.dart';
import 'package:logger/logger.dart';

class LeaveReqFormView extends StatelessWidget {
  final int? id;

  const LeaveReqFormView({super.key, this.id});

  @override
  Widget build(BuildContext context) {
    Logger().d('LeaveReqFormView id: $id');

    return BlocProvider(
      create: (_) {
        final bloc = LeaveReqFormBloc(LeaveFormRepository());

        bloc.add(InitialLeaverequestevent(intialvalue: id));

        return bloc;
      },
      child: LeaveFormMobileView(),
    );
  }
}
