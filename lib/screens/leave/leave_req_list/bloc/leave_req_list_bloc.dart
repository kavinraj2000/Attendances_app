import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hrm/core/model/leave_list_model.dart';
import 'package:hrm/core/model/leave_req_model.dart';
import 'package:hrm/screens/leave/leave_req_list/repo/leave_req_list_repo.dart';
import 'package:logger/logger.dart';

part 'leave_req_list_event.dart';
part 'leave_req_list_state.dart';

class LeaveReqListBloc extends Bloc<LeaveReqListEvent, LeaveReqListState> {
  final LeaveReqListRepo repo;
  final Logger log = Logger();

  LeaveReqListBloc(this.repo) : super(LeaveReqListState.initial()) {
    on<InitialLeaverequestListevent>(_onInitialLeaveList);
  }

  Future<void> _onInitialLeaveList(
    InitialLeaverequestListevent event,
    Emitter<LeaveReqListState> emit,
  ) async {
    try {
      emit(state.copyWith(status: LeaveReqListStatus.loading));

      final leaveList = await repo.leaverequest();
      log.d('Leave list loaded: ${leaveList.length}');

      emit(
        state.copyWith(status: LeaveReqListStatus.loaded, leaveList: leaveList),
      );
    } catch (e, stackTrace) {
      log.e('Leave list load failed', error: e, stackTrace: stackTrace);

      emit(
        state.copyWith(
          status: LeaveReqListStatus.failure,
          message: e.toString(),
        ),
      );
    }
  }
}
