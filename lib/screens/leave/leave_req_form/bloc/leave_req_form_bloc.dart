import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hrm/core/model/attances_model.dart';
import 'package:hrm/core/model/leave_model.dart';
import 'package:hrm/core/model/leave_req_model.dart';
import 'package:hrm/screens/leave/leave_req_form/repo/leave_req_form_repo.dart';
import 'package:logger/logger.dart';

part 'leave_req_form_event.dart';
part 'leave_req_form_state.dart';

class LeaveReqFormBloc extends Bloc<LeaveFormReqevent, LeaveReqFormState> {
  final LeaveFormRepository repo;
  final Logger log = Logger();

  LeaveReqFormBloc(this.repo) : super(LeaveReqFormState.initial()) {
    on<InitialLeaverequestevent>(_onInitial);
    on<SubmitLeaveFormreq>(_onCreate);
    on<UpdateLeaverequestevent>(_onUpdate);
  }

  String _cleanError(Object e) {
    final msg = e.toString();
    return msg.startsWith('Exception: ')
        ? msg.replaceFirst('Exception: ', '')
        : msg;
  }

  Future<void> _onInitial(
    InitialLeaverequestevent event,
    Emitter<LeaveReqFormState> emit,
  ) async {
    try {
      emit(state.copyWith(status: LeaveReqFormStaus.loading));

      final leaveTypes = await repo.getLeaveReason();
      log.d('_onInitial::leaveTypes::::${leaveTypes.length}');

      emit(
        state.copyWith(
          status: LeaveReqFormStaus.ready,
          initialvalue: event.intialvalue,
          leavetype: leaveTypes,
        ),
      );
    } catch (e) {
      emit(
        state.copyWith(
          status: LeaveReqFormStaus.failure,
          message: e.toString(),
        ),
      );
    }
  }

  Future<void> _onCreate(
    SubmitLeaveFormreq event,
    Emitter<LeaveReqFormState> emit,
  ) async {
    try {
      emit(state.copyWith(status: LeaveReqFormStaus.loading));

      final created = await repo.leaverequest(
        leaveTypeID: event.leaveRequestModel.leavetypeID,
        leaveType: event.leaveRequestModel.leaveType,
        startdate: event.leaveRequestModel.startDate,
        enddate: event.leaveRequestModel.endDate,
        reason: event.leaveRequestModel.reason,
      );
log.d('SubmitLeaveFormreq:::${created.leavetypeID}');
      emit(
        state.copyWith(
          status: LeaveReqFormStaus.submitted,
          message: 'Leave request submitted successfully',
          leaverequestmodel: [created],
        ),
      );
    } catch (e, s) {
      log.e('Create failed', error: e, stackTrace: s);
      emit(
        state.copyWith(
          status: LeaveReqFormStaus.failure,
          message: _cleanError(e),
        ),
      );
    }
  }

  Future<void> _onUpdate(
    UpdateLeaverequestevent event,
    Emitter<LeaveReqFormState> emit,
  ) async {
    try {
      if (state.initialvalue == null) {
        throw Exception('Invalid leave request ID');
      }
      log.d('UpdateLeaverequestevent:${state.initialvalue!['id']}');
      emit(state.copyWith(status: LeaveReqFormStaus.loading));

      final updated = await repo.updateLeaveRequest(
        leaveRequestId: state.initialvalue!['id'],
        leaveType: event.leaveRequestModel.leaveType,
        startDate: event.leaveRequestModel.startDate,
        endDate: event.leaveRequestModel.endDate,
        reason: event.leaveRequestModel.reason,
      );

      emit(
        state.copyWith(
          status: LeaveReqFormStaus.submitted,
          message: 'Leave request updated successfully',
          leaverequestmodel: [updated],
        ),
      );
    } catch (e, s) {
      log.e('Update failed', error: e, stackTrace: s);
      emit(
        state.copyWith(
          status: LeaveReqFormStaus.failure,
          message: _cleanError(e),
        ),
      );
    }
  }
}
