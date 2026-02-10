part of 'leave_req_form_bloc.dart';

enum LeaveReqFormStaus { initial, loading, ready, submitted, failure }

class LeaveReqFormState extends Equatable {
  final LeaveReqFormStaus status;
  final String message;
  final List<LeaveRequestModel> leaverequestmodel;
  final List<AttendanceModel>? attendanceList;

  const LeaveReqFormState({
    required this.leaverequestmodel,
    required this.message,
    required this.status,
    this.attendanceList,
  });

  factory LeaveReqFormState.initial() {
    return LeaveReqFormState(
      leaverequestmodel: [],
      message: '',
      status: LeaveReqFormStaus.initial,
      attendanceList: [],
    );
  }
  LeaveReqFormState copyWith({
    LeaveReqFormStaus? status,
    String? message,
    List<LeaveRequestModel>? leaverequestmodel,
    List<AttendanceModel>? attendanceList,
  }) {
    return LeaveReqFormState(
      leaverequestmodel: leaverequestmodel ?? this.leaverequestmodel,
      message: message ?? this.message,
      status: status ?? this.status,
      attendanceList: attendanceList ?? this.attendanceList,
    );
  }

  @override
  List<Object?> get props => [
    leaverequestmodel,
    message,
    status,
    attendanceList,
  ];
}
