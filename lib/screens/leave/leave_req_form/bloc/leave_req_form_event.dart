part of 'leave_req_form_bloc.dart';

abstract class LeaveFormReqevent {}

class InitialLeaverequestevent extends LeaveFormReqevent {}

class SubmitLeaveFormreq extends LeaveFormReqevent {
  final LeaveRequestModel leaveRequestModel;

  SubmitLeaveFormreq({required this.leaveRequestModel});
}
