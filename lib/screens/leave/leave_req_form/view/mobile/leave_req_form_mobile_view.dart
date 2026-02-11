import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:hrm/core/model/leave_req_model.dart';
import 'package:hrm/screens/leave/leave_req_form/bloc/leave_req_form_bloc.dart';
import 'package:intl/intl.dart';
import 'package:logger/web.dart';

class LeaveFormMobileView extends StatelessWidget {
  LeaveFormMobileView({super.key});

  final GlobalKey<FormBuilderState> _formKey = GlobalKey<FormBuilderState>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: BlocBuilder<LeaveReqFormBloc, LeaveReqFormState>(
          buildWhen: (p, c) => p.initialvalue != c.initialvalue,
          builder: (context, state) {
            return Text(
              state.isEditing ? 'Edit Leave Request' : 'New Leave Request',
            );
          },
        ),
        elevation: 0,
      ),
      body: BlocListener<LeaveReqFormBloc, LeaveReqFormState>(
        listener: (context, state) {
          if (state.status == LeaveReqFormStaus.submitted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: Colors.green,
                behavior: SnackBarBehavior.floating,
                duration: const Duration(seconds: 2),
              ),
            );
            Navigator.pop(context, true); // Return true to indicate success
          }

          if (state.status == LeaveReqFormStaus.failure) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: Colors.red,
                behavior: SnackBarBehavior.floating,
                action: SnackBarAction(
                  label: 'Dismiss',
                  textColor: Colors.white,
                  onPressed: () {
                    ScaffoldMessenger.of(context).hideCurrentSnackBar();
                  },
                ),
              ),
            );
          }
        },
        child: BlocBuilder<LeaveReqFormBloc, LeaveReqFormState>(
          builder: (context, state) {
            if (state.status == LeaveReqFormStaus.loading) {
              return const Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    CircularProgressIndicator(),
                    SizedBox(height: 16),
                    Text(
                      'Loading...',
                      style: TextStyle(fontSize: 14, color: Colors.grey),
                    ),
                  ],
                ),
              );
            }

            // Get the leave data if editing
            final leaveData = state.currentLeaveRequest;

            return SafeArea(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: FormBuilder(
                  key: _formKey,
                  initialValue: {
                    if (leaveData != null) ...{
                      'leave_type': leaveData.leaveType,
                      'start_date': leaveData.startDate,
                      'end_date': leaveData.endDate,
                      'reason': leaveData.reason,
                    },
                  },
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Info banner for editing
                      if (state.isEditing) ...[
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Colors.blue.shade50,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: Colors.blue.shade200),
                          ),
                          child: Row(
                            children: [
                              Icon(
                                Icons.info_outline,
                                color: Colors.blue.shade700,
                                size: 20,
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Text(
                                  'You are editing an existing leave request',
                                  style: TextStyle(
                                    color: Colors.blue.shade700,
                                    fontSize: 13,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 20),
                      ],

                      // Leave Type
                      _buildSectionLabel('Leave Type', isRequired: true),
                      const SizedBox(height: 8),
                      FormBuilderDropdown<String>(
                        name: 'leave_type',
                        decoration: _inputDecoration('Select Leave Type'),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please select a leave type';
                          }
                          return null;
                        },
                        items: const [
                          DropdownMenuItem(
                            value: 'CASUAL',
                            child: Text('Casual Leave'),
                          ),
                          DropdownMenuItem(
                            value: 'SICK',
                            child: Text('Sick Leave'),
                          ),
                          DropdownMenuItem(
                            value: 'EARNED',
                            child: Text('Earned Leave'),
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),

                      // Dates
                      Row(
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                _buildSectionLabel(
                                  'From Date',
                                  isRequired: true,
                                ),
                                const SizedBox(height: 8),
                                FormBuilderDateTimePicker(
                                  name: 'start_date',
                                  inputType: InputType.date,
                                  format: DateFormat('dd/MM/yyyy'),
                                  decoration: _inputDecoration('Select date'),
                                  firstDate: DateTime.now(),
                                  lastDate: DateTime.now().add(
                                    const Duration(days: 365),
                                  ),
                                  validator: (value) {
                                    if (value == null) {
                                      return 'Required';
                                    }
                                    return null;
                                  },
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                _buildSectionLabel('To Date', isRequired: true),
                                const SizedBox(height: 8),
                                FormBuilderDateTimePicker(
                                  name: 'end_date',
                                  inputType: InputType.date,
                                  format: DateFormat('dd/MM/yyyy'),
                                  decoration: _inputDecoration('Select date'),
                                  firstDate: DateTime.now(),
                                  lastDate: DateTime.now().add(
                                    const Duration(days: 365),
                                  ),
                                  validator: (value) {
                                    if (value == null) {
                                      return 'Required';
                                    }
                                    final startDate =
                                        _formKey
                                                .currentState
                                                ?.fields['start_date']
                                                ?.value
                                            as DateTime?;
                                    if (startDate != null &&
                                        value.isBefore(startDate)) {
                                      return 'Invalid date';
                                    }
                                    return null;
                                  },
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),

                      // Leave Duration Display
                      BlocBuilder<LeaveReqFormBloc, LeaveReqFormState>(
                        builder: (context, state) {
                          return _buildLeaveDurationInfo();
                        },
                      ),
                      const SizedBox(height: 20),

                      // Reason
                      _buildSectionLabel('Reason', isRequired: true),
                      const SizedBox(height: 8),
                      FormBuilderTextField(
                        name: 'reason',
                        maxLines: 5,
                        maxLength: 500,
                        decoration:
                            _inputDecoration(
                              'Enter reason for leave...',
                            ).copyWith(
                              counterText: '',
                              helperText:
                                  'Provide a clear reason for your leave',
                            ),
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return 'Please provide a reason';
                          }
                          if (value.trim().length < 10) {
                            return 'Reason must be at least 10 characters';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 32),

                      // Buttons
                      Row(
                        children: [
                          Expanded(
                            child: ElevatedButton.icon(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFF00D084),
                                foregroundColor: Colors.white,
                                padding: const EdgeInsets.symmetric(
                                  vertical: 16,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                elevation: 0,
                              ),
                              icon: state.status == LeaveReqFormStaus.loading
                                  ? const SizedBox(
                                      height: 20,
                                      width: 20,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2,
                                        valueColor:
                                            AlwaysStoppedAnimation<Color>(
                                              Colors.white,
                                            ),
                                      ),
                                    )
                                  : Icon(
                                      state.isEditing
                                          ? Icons.update
                                          : Icons.send,
                                    ),
                              label: Text(
                                state.isEditing
                                    ? 'Update Request'
                                    : 'Submit Request',
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              onPressed:
                                  state.status == LeaveReqFormStaus.loading
                                  ? null
                                  : () => _handleSubmit(context, state),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: OutlinedButton(
                              style: OutlinedButton.styleFrom(
                                foregroundColor: Colors.grey.shade700,
                                padding: const EdgeInsets.symmetric(
                                  vertical: 16,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                side: BorderSide(color: Colors.grey.shade300),
                              ),
                              onPressed:
                                  state.status == LeaveReqFormStaus.loading
                                  ? null
                                  : () => _handleCancel(context),
                              child: const Text(
                                'Cancel',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildSectionLabel(String text, {bool isRequired = false}) {
    return Row(
      children: [
        Text(
          text,
          style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 15),
        ),
        if (isRequired)
          const Text(
            ' *',
            style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold),
          ),
      ],
    );
  }

  Widget _buildLeaveDurationInfo() {
    return FormBuilderField(
      name: 'duration_info',
      builder: (FormFieldState field) {
        final startDate =
            _formKey.currentState?.fields['start_date']?.value as DateTime?;
        final endDate =
            _formKey.currentState?.fields['end_date']?.value as DateTime?;

        if (startDate != null &&
            endDate != null &&
            !endDate.isBefore(startDate)) {
          final duration = endDate.difference(startDate).inDays + 1;
          return Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.green.shade50,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.green.shade200),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.calendar_today,
                  color: Colors.green.shade700,
                  size: 20,
                ),
                const SizedBox(width: 12),
                Text(
                  'Total Leave Duration: $duration ${duration == 1 ? 'day' : 'days'}',
                  style: TextStyle(
                    color: Colors.green.shade700,
                    fontWeight: FontWeight.w600,
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          );
        }
        return const SizedBox.shrink();
      },
    );
  }

void _handleSubmit(BuildContext context, LeaveReqFormState state) {
  if (_formKey.currentState?.saveAndValidate() ?? false) {
    final formValues = _formKey.currentState!.value;

    final model = LeaveRequestModel(
      id: state.initialvalue,
      leaveType: formValues['leave_type'] as String,
      startDate: formValues['start_date'] as DateTime,
      endDate: formValues['end_date'] as DateTime,
      reason: formValues['reason'] as String,
    );
    
    if (model.id == null) {
      context.read<LeaveReqFormBloc>().add(
        SubmitLeaveFormreq(leaveRequestModel: model),
      );
    } else {
      context.read<LeaveReqFormBloc>().add(
        UpdateLeaverequestevent(leaveRequestModel: model),
        
      );
      Logger().d('UpdateLeaverequestevent::${model.id}');
    }
  } else {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Please fill in all required fields correctly'),
        backgroundColor: Colors.orange,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }
}

  void _handleCancel(BuildContext context) {
    final hasChanges = _formKey.currentState?.instantValue.isNotEmpty ?? false;

    if (hasChanges) {
      showDialog(
        context: context,
        builder: (dialogContext) => AlertDialog(
          title: const Text('Discard Changes?'),
          content: const Text(
            'You have unsaved changes. Are you sure you want to discard them?',
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: const Text('Continue Editing'),
            ),
            TextButton(
              onPressed: () {
                Navigator.pop(dialogContext);
                Navigator.pop(context, false);
              },
              style: TextButton.styleFrom(foregroundColor: Colors.red),
              child: const Text('Discard'),
            ),
          ],
        ),
      );
    } else {
      Navigator.pop(context, false);
    }
  }

  InputDecoration _inputDecoration(String hint) {
    return InputDecoration(
      hintText: hint,
      hintStyle: TextStyle(color: Colors.grey.shade400, fontSize: 14),
      filled: true,
      fillColor: Colors.grey.shade50,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide.none,
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: Colors.grey.shade200),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Color(0xFF00D084), width: 2),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: Colors.red.shade300),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Colors.red, width: 2),
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
    );
  }
}
