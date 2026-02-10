part of 'leave_req_list_bloc.dart';

enum LeaveReqListStatus { initial, loading, loaded, success, failure }

class LeaveReqListState extends Equatable {
  final LeaveReqListStatus status;
  final String message;
  final List<LeaveRequestListModel> leaveList;
  final List<LeaveRequestModel> leaverequestmodel;

  const LeaveReqListState({
    required this.status,
    required this.message,
    required this.leaveList,
    required this.leaverequestmodel,
  });

  factory LeaveReqListState.initial() {
    return const LeaveReqListState(
      status: LeaveReqListStatus.initial,
      message: '',
      leaveList: [],
      leaverequestmodel: [],
    );
  }

  LeaveReqListState copyWith({
    LeaveReqListStatus? status,
    String? message,
    List<LeaveRequestListModel>? leaveList,
    List<LeaveRequestModel>? leaverequestmodel,
  }) {
    return LeaveReqListState(
      status: status ?? this.status,
      message: message ?? this.message,
      leaveList: leaveList ?? this.leaveList,
      leaverequestmodel: leaverequestmodel ?? this.leaverequestmodel,
    );
  }

  @override
  List<Object?> get props => [status, message, leaveList, leaverequestmodel];
}
