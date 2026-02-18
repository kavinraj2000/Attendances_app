part of 'leave_req_form_bloc.dart';

abstract class LeaveFormReqevent extends Equatable {
  const LeaveFormReqevent();

  @override
  List<Object?> get props => [];
}

class InitialLeaverequestevent extends LeaveFormReqevent {
  final Map<String,dynamic> ? intialvalue;
  final LeaveRequestModel? leaveRequestModel;

  const InitialLeaverequestevent({
     this.intialvalue,
     this.leaveRequestModel,
  });

  @override
  List<Object?> get props => [intialvalue, leaveRequestModel];
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
