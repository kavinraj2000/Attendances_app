import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:go_router/go_router.dart';
import 'package:hrm/core/model/leave_req_model.dart';
import 'package:hrm/core/util/toast_util.dart';
import 'package:hrm/screens/leave/leave_req_form/bloc/leave_req_form_bloc.dart';
import 'package:intl/intl.dart';
import 'package:logger/logger.dart';

class LeaveFormMobileView extends StatefulWidget {
  const LeaveFormMobileView({super.key});

  @override
  State<LeaveFormMobileView> createState() => _LeaveFormMobileViewState();
}

class _LeaveFormMobileViewState extends State<LeaveFormMobileView> {
  final _formKey = GlobalKey<FormBuilderState>();
  final Logger _logger = Logger();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: BlocBuilder<LeaveReqFormBloc, LeaveReqFormState>(
          buildWhen: (p, c) => p.isEditing != c.isEditing,
          builder: (_, state) {
            return Text(
              state.isEditing ? 'Edit Leave Request' : 'New Leave Request',
            );
          },
        ),
      ),
      body: BlocListener<LeaveReqFormBloc, LeaveReqFormState>(
        listener: (context, state) {
          if (state.status == LeaveReqFormStaus.submitted) {
            ToastUtil.success(
              context: context,
              message: state.isEditing
                  ? 'Leave request updated successfully'
                  : 'Leave request submitted successfully',
            );
            context.pop();
          }

          if (state.status == LeaveReqFormStaus.failure) {
            ToastUtil.error(context: context, message: state.message);
          }
        },
        child: BlocBuilder<LeaveReqFormBloc, LeaveReqFormState>(
          buildWhen: (p, c) =>
              p.status != c.status ||
              p.currentLeaveRequest != c.currentLeaveRequest,
          builder: (context, state) {
            if (state.status == LeaveReqFormStaus.loading) {
              return const Center(child: CircularProgressIndicator());
            }

            if (state.status == LeaveReqFormStaus.ready) {
              return _buildForm(context, state, state.initialvalue);
            }

            return const SizedBox.shrink();
          },
        ),
      ),
    );
  }

  Widget _buildForm(
    BuildContext context,
    LeaveReqFormState state,
    Map<String, dynamic>? leave,
  ) {
    _logger.d('Editing Leave: ${leave?['leave_type']}');

    return SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: FormBuilder(
          key: _formKey,
          initialValue: {
            'leave_type': leave?['leave_type'],
            'start_date': leave?['start_date'] != null
                ? DateTime.tryParse(leave!['start_date'])
                : null,
            'end_date': leave?['end_date'] != null
                ? DateTime.tryParse(leave!['end_date'])
                : null,
            'reason': leave?['reason'],
          },
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _section('Leave Type', true),

              FormBuilderDropdown<String>(
                name: 'leave_type',
                decoration: _decoration('Select Leave Type'),
                items: const [
                  DropdownMenuItem(value: 'CASUAL', child: Text('CASUAL')),
                  DropdownMenuItem(value: 'SICK', child: Text('SICK')),
                  DropdownMenuItem(value: 'WFH', child: Text('WFH')),
                  DropdownMenuItem(value: 'ANNUAL', child: Text('ANNUAL')),
                ],
              ),

              const SizedBox(height: 20),

              Row(
                children: [
                  Expanded(
                    child: FormBuilderDateTimePicker(
                      name: 'start_date',
                      inputType: InputType.date,
                      format: DateFormat('dd/MM/yyyy'),
                      decoration: _decoration('From Date'),
                      onChanged: (_) => setState(() {}),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: FormBuilderDateTimePicker(
                      name: 'end_date',
                      inputType: InputType.date,
                      format: DateFormat('dd/MM/yyyy'),
                      decoration: _decoration('To Date'),
                      onChanged: (_) => setState(() {}),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 16),
              _leaveDuration(),

              const SizedBox(height: 20),
              _section('Reason', true),

              FormBuilderTextField(
                name: 'reason',
                maxLines: 4,
                decoration: _decoration('Enter reason'),
              ),

              const SizedBox(height: 32),

              Row(
                children: [
                  Expanded(
                    child: ElevatedButton(
                      onPressed: state.status == LeaveReqFormStaus.loading
                          ? null
                          : () => _submit(context, state),
                      child: Text(state.isEditing ? 'Update' : 'Submit'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => _cancel(context),
                      child: const Text('Cancel'),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _leaveDuration() {
    if (_formKey.currentState == null) {
      return const SizedBox.shrink();
    }

    final start =
        _formKey.currentState!.fields['start_date']?.value as DateTime?;
    final end = _formKey.currentState!.fields['end_date']?.value as DateTime?;

    if (start != null && end != null) {
      if (end.isBefore(start)) {
        return const Text(
          'Invalid date range',
          style: TextStyle(color: Colors.red),
        );
      }

      final days = end.difference(start).inDays + 1;
      return Text(
        'Total Leave: $days day(s)',
        style: const TextStyle(fontWeight: FontWeight.w600),
      );
    }

    return const SizedBox.shrink();
  }

  void _submit(BuildContext context, LeaveReqFormState state) {
    if (!_formKey.currentState!.saveAndValidate()) return;

    final v = _formKey.currentState!.value;

    if ((v['end_date'] as DateTime).isBefore(v['start_date'] as DateTime)) {
      ToastUtil.error(
        context: context,
        message: 'End date cannot be before start date',
      );
      return;
    }

    final model = LeaveRequestModel(
      id: state.currentLeaveRequest?.id,
      leaveType: v['leave_type'],
      startDate: v['start_date'],
      endDate: v['end_date'],
      reason: v['reason'],
    );

    _logger.d('Submitting Leave: $model');

    context.read<LeaveReqFormBloc>().add(
      state.isEditing
          ? UpdateLeaverequestevent(leaveRequestModel: model)
          : SubmitLeaveFormreq(leaveRequestModel: model),
    );
  }

  void _cancel(BuildContext context) {
    if (_formKey.currentState?.isDirty ?? false) {
      showDialog(
        context: context,
        builder: (_) => AlertDialog(
          title: const Text('Discard changes?'),
          actions: [
            TextButton(onPressed: () => context.pop(), child: const Text('No')),
            TextButton(
              onPressed: () {
                context.pop();
                context.pop();
              },
              child: const Text('Yes'),
            ),
          ],
        ),
      );
    } else {
      context.pop();
    }
  }

  Widget _section(String title, bool required) => Padding(
    padding: const EdgeInsets.only(bottom: 8),
    child: Row(
      children: [
        Text(title, style: const TextStyle(fontWeight: FontWeight.w600)),
        if (required) const Text('*', style: TextStyle(color: Colors.red)),
      ],
    ),
  );

  InputDecoration _decoration(String hint) => InputDecoration(
    hintText: hint,
    filled: true,
    fillColor: Colors.grey.shade50,
    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
  );
}
