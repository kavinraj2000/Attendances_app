
part of 'leave_req_form_bloc.dart';

enum LeaveReqFormStaus { 
  initial, 
  loading, 
  ready, 
  submitted, 
  failure 
}

class LeaveReqFormState extends Equatable {
  final LeaveReqFormStaus status;
  final String message;
  final List<LeaveRequestModel> leaverequestmodel;
  final List<LeaveRequestModel> updaterequestmodel;
  final List<AttendanceModel>? attendanceList;
  final int? initialvalue;

  const LeaveReqFormState({
    required this.leaverequestmodel,
    required this.updaterequestmodel,
    required this.message,
    required this.status,
    required this.initialvalue,
    this.attendanceList,
  });

  factory LeaveReqFormState.initial() {
    return const LeaveReqFormState(
      initialvalue: null,
      leaverequestmodel: [],
      message: '',
      status: LeaveReqFormStaus.initial,
      attendanceList: [],
      updaterequestmodel: [],
    );
  }

  /// Returns true if the form is in edit mode
  bool get isEditing => initialvalue != null && initialvalue! > 0;

  /// Returns the current leave request data if available
  LeaveRequestModel? get currentLeaveRequest {
    if (leaverequestmodel.isNotEmpty) {
      return leaverequestmodel.first;
    }
    return null;
  }

  LeaveReqFormState copyWith({
    LeaveReqFormStaus? status,
    int? initialvalue,
    String? message,
    List<LeaveRequestModel>? leaverequestmodel,
    List<LeaveRequestModel>? updaterequestmodel,
    List<AttendanceModel>? attendanceList,
  }) {
    return LeaveReqFormState(
      initialvalue: initialvalue ?? this.initialvalue,
      leaverequestmodel: leaverequestmodel ?? this.leaverequestmodel,
      message: message ?? this.message,
      status: status ?? this.status,
      updaterequestmodel: updaterequestmodel ?? this.updaterequestmodel,
      attendanceList: attendanceList ?? this.attendanceList,
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
      ];
}