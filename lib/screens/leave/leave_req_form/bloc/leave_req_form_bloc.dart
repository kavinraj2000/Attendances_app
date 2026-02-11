import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hrm/core/model/attances_model.dart';
import 'package:hrm/core/model/leave_req_model.dart';
import 'package:hrm/screens/leave/leave_req_form/repo/leave_req_form_repo.dart';
import 'package:logger/logger.dart';

part 'leave_req_form_event.dart';
part 'leave_req_form_state.dart';

class LeaveReqFormBloc extends Bloc<LeaveFormReqevent, LeaveReqFormState> {
  final LeaveFormRepository repo;
  final Logger log = Logger();

  LeaveReqFormBloc(this.repo) : super(LeaveReqFormState.initial()) {
    on<InitialLeaverequestevent>(_onInitialLeaveRequest);
    on<UpdateLeaverequestevent>(_onUpdateLeaveRequest);
    on<SubmitLeaveFormreq>(_onSubmitLeaveRequest);
  }

  Future<void> _onInitialLeaveRequest(
    InitialLeaverequestevent event,
    Emitter<LeaveReqFormState> emit,
  ) async {
    try {
      log.d('InitialLeaverequestevent:${event.intialvalue}');
      emit(state.copyWith(status: LeaveReqFormStaus.loading));
      final id = event.intialvalue;
      emit(state.copyWith(status: LeaveReqFormStaus.ready, initialvalue: id));
    } catch (e, s) {
      log.e('Initial leave request failed $e');
      emit(
        state.copyWith(
          status: LeaveReqFormStaus.failure,
          message: e.toString(),
        ),
      );
    }
  }

  Future<void> _onUpdateLeaveRequest(
    UpdateLeaverequestevent event,
    Emitter<LeaveReqFormState> emit,
  ) async {
    try {
      log.d('UpdateLeaverequestevent received');
      log.d('Event data: ${event.leaveRequestModel.toJson()}');

      // Validation checks
      if (state.initialvalue == null || state.initialvalue! <= 0) {
        throw Exception(
          'Invalid leave request ID. Cannot update without valid ID',
        );
      }

      emit(state.copyWith(status: LeaveReqFormStaus.loading));

      final existingData = state.currentLeaveRequest;

      final LeaveRequestModel modelToUpdate;

      if (existingData != null) {
        modelToUpdate = existingData.copyWith(
          id: state.initialvalue,
          leaveType: event.leaveRequestModel.leaveType,
          startDate: event.leaveRequestModel.startDate,
          endDate: event.leaveRequestModel.endDate,
          reason: event.leaveRequestModel.reason,
        );
      } else {
        modelToUpdate = event.leaveRequestModel.copyWith(
          id: state.initialvalue,
        );
      }

      log.d('Updating leave request ID: ${state.initialvalue}');
      log.d('Final payload: ${modelToUpdate.toJson()}');

      final updatedLeaveRequest = await repo.updateLeaveRequest(
        leaveRequestId: state.initialvalue!,
        leaveType: modelToUpdate.leaveType,
        reason: modelToUpdate.reason,
        startDate: modelToUpdate.startDate,
        endDate: modelToUpdate.endDate,
      );

      log.i('Leave request updated successfully');
      log.d('Updated leave request: ${updatedLeaveRequest.toJson()}');

      emit(
        state.copyWith(
          status: LeaveReqFormStaus.submitted,
          message: 'Leave request updated successfully',
          updaterequestmodel: [updatedLeaveRequest],
          leaverequestmodel: [updatedLeaveRequest], 
        ),
      );
    } catch (e, s) {
      log.e('Update leave request failed', error: e, stackTrace: s);

      emit(
        state.copyWith(
          status: LeaveReqFormStaus.failure,
          message:'$e',
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

      final isEditing = state.initialvalue != null && state.initialvalue! > 0;

      if (isEditing) {
        log.d('Delegating to update handler');
        add(
          UpdateLeaverequestevent(leaveRequestModel: event.leaveRequestModel),
        );
      } else {
        await repo.leaverequest(
          enddate: event.leaveRequestModel.endDate,
          leaveType: event.leaveRequestModel.leaveType,
          reason: event.leaveRequestModel.reason,
          startdate: event.leaveRequestModel.startDate,
        );
      }
    } catch (e) {
      log.e('Failed to submit leave request: $e');
      emit(
        state.copyWith(
          status: LeaveReqFormStaus.failure,
          message: '_onSubmitLeaveRequest ($e)',
        ),
      );
    }
  }
}
