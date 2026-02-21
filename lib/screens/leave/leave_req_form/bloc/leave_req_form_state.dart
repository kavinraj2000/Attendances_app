part of 'leave_req_form_bloc.dart';

enum LeaveReqFormStaus { initial, loading, ready, submitted, failure }

class LeaveReqFormState extends Equatable {
  final LeaveReqFormStaus status;
  final String message;
  final List<LeaveRequestModel> leaverequestmodel;
  final List<LeaveRequestModel> updaterequestmodel;
  final List<AttendanceModel>? attendanceList;
  final LeaveRequestModel? leaveRequest;
  final Map<String, dynamic>? initialvalue;

  const LeaveReqFormState({
    required this.leaverequestmodel,
    required this.updaterequestmodel,
    required this.message,
    required this.status,
    required this.initialvalue,
    this.attendanceList,
    this.leaveRequest,
  });

  factory LeaveReqFormState.initial() {
    return const LeaveReqFormState(
      initialvalue: null,
      leaverequestmodel: [],
      message: '',
      status: LeaveReqFormStaus.initial,
      attendanceList: [],
      updaterequestmodel: [],
      leaveRequest: null,
    );
  }

  bool get isEditing => initialvalue != null && initialvalue!['id'] > 0;

  LeaveRequestModel? get currentLeaveRequest {
    if (leaverequestmodel.isNotEmpty) {
      return leaverequestmodel.first;
    }
    return null;
  }

  LeaveReqFormState copyWith({
    LeaveReqFormStaus? status,
    Map<String, dynamic>? initialvalue,
    String? message,
    List<LeaveRequestModel>? leaverequestmodel,
    List<LeaveRequestModel>? updaterequestmodel,
    List<AttendanceModel>? attendanceList,
    LeaveRequestModel? leaveRequest,
  }) {
    return LeaveReqFormState(
      initialvalue: initialvalue ?? this.initialvalue,
      leaverequestmodel: leaverequestmodel ?? this.leaverequestmodel,
      message: message ?? this.message,
      status: status ?? this.status,
      updaterequestmodel: updaterequestmodel ?? this.updaterequestmodel,
      attendanceList: attendanceList ?? this.attendanceList,
      leaveRequest: leaveRequest ?? this.leaveRequest,
    );
  }

  @override
  List<Object?> get props => [
    initialvalue,
    leaverequestmodel,
    message,
    status,
    attendanceList,
    updaterequestmodel,
    leaveRequest,
  ];
}
