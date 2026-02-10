import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hrm/core/model/attances_model.dart';
import 'package:hrm/core/model/leave_req_model.dart';
import 'package:hrm/screens/leave/leave_req_form/repo/leave_req_form_repo.dart';
import 'package:logger/logger.dart';

part 'leave_req_form_event.dart';
part 'leave_req_form_state.dart';

class LeaveReqFormBloc
    extends Bloc<LeaveFormReqevent, LeaveReqFormState> {
  final LeaveFormRepository repo;
  final Logger log = Logger();

  LeaveReqFormBloc(this.repo)
      : super(LeaveReqFormState.initial()) {
    on<InitialLeaverequestevent>(_onInitialLeaveRequest);
    on<SubmitLeaveFormreq>(_onSubmitLeaveRequest);
  }

  Future<void> _onInitialLeaveRequest(
    InitialLeaverequestevent event,
    Emitter<LeaveReqFormState> emit,
  ) async {
    try {
      emit(state.copyWith(status: LeaveReqFormStaus.loading));

      emit(
        state.copyWith(
          status: LeaveReqFormStaus.ready,
        ),
      );
    } catch (e, s) {
      log.e('Initial leave request failed $e', );
      emit(
        state.copyWith(
          status: LeaveReqFormStaus.failure,
          message: e.toString(),
        ),
      );
    }
  }

  Future<void> _onSubmitLeaveRequest(
    SubmitLeaveFormreq event,
    Emitter<LeaveReqFormState> emit,
  ) async {
    try {
      emit(state.copyWith(status: LeaveReqFormStaus.loading));

      await repo.leaverequest(
        leaveType: event.leaveRequestModel.leaveType,
        reason: event.leaveRequestModel.reason,
        startdate: event.leaveRequestModel.startDate,
        enddate: event.leaveRequestModel.endDate,
      );

      log.i('Leave request submitted successfully');

      emit(
        state.copyWith(
          status: LeaveReqFormStaus.submitted,
          message: 'Leave request submitted successfully',
        ),
      );
    } catch (e, s) {
      log.e('Submit leave request failed  $e', );
      emit(
        state.copyWith(
          status: LeaveReqFormStaus.failure,
          message: e.toString(),
        ),
      );
    }
  }
}
