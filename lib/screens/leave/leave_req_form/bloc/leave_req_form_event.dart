part of 'leave_req_form_bloc.dart';

abstract class LeaveFormReqevent extends Equatable {
  const LeaveFormReqevent();

  @override
  List<Object?> get props => [];
}

class InitialLeaverequestevent extends LeaveFormReqevent {
  final int? intialvalue;

  const InitialLeaverequestevent({this.intialvalue});

  @override
  List<Object?> get props => [intialvalue];
}

class UpdateLeaverequestevent extends LeaveFormReqevent {
  final LeaveRequestModel leaveRequestModel;

  const UpdateLeaverequestevent({required this.leaveRequestModel});

  @override
  List<Object?> get props => [leaveRequestModel];
}

class SubmitLeaveFormreq extends LeaveFormReqevent {
  final LeaveRequestModel leaveRequestModel;

  const SubmitLeaveFormreq({required this.leaveRequestModel});

  @override
  List<Object?> get props => [leaveRequestModel];
}
