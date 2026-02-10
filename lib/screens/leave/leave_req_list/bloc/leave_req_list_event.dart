part of 'leave_req_list_bloc.dart';

abstract class LeaveReqListEvent {}

class InitialLeaverequestListevent extends LeaveReqListEvent {}

class Updateleaverequestevent extends LeaveReqListEvent {
  final LeaveRequestModel leaveRequestModel;

  Updateleaverequestevent(this.leaveRequestModel);
}
