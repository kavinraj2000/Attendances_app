import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hrm/screens/leave/leave_req_list/bloc/leave_req_list_bloc.dart';
import 'package:hrm/screens/leave/leave_req_list/repo/leave_req_list_repo.dart';
import 'package:hrm/screens/leave/leave_req_list/view/mobile/leave_req_list_mobile_view.dart';

class LeaveReqListView extends StatelessWidget {
  const LeaveReqListView({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider<LeaveReqListBloc>(
      create: (context) => LeaveReqListBloc(
        LeaveReqListRepo(),
      )..add(InitialLeaverequestListevent()),
      child: const LeaveRequestsListPage(),
    );
  }
}
