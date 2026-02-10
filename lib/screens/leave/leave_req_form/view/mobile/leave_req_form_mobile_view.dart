import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:hrm/core/model/leave_req_model.dart';
import 'package:hrm/screens/leave/leave_req_form/bloc/leave_req_form_bloc.dart';
import 'package:intl/intl.dart';

class LeaveFormMobileView extends StatelessWidget {
  LeaveFormMobileView({super.key});

  final GlobalKey<FormBuilderState> _formKey = GlobalKey<FormBuilderState>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('New Leave Request'),
      ),

      /// 🔔 LISTENER → for success / failure actions
      body: BlocListener<LeaveReqFormBloc, LeaveReqFormState>(
        listener: (context, state) {
          if (state.status == LeaveReqFormStaus.submitted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(state.message)),
            );
            Navigator.pop(context);
          }

          if (state.status == LeaveReqFormStaus.failure) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(state.message)),
            );
          }
        },

        child: BlocBuilder<LeaveReqFormBloc, LeaveReqFormState>(
          builder: (context, state) {
            if (state.status == LeaveReqFormStaus.loading) {
              return const Center(child: CircularProgressIndicator());
            }

            /// ✅ FORM SHOULD BE SHOWN FOR INITIAL + SUCCESS
            return Padding(
              padding: const EdgeInsets.all(16),
              child: FormBuilder(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    /// Leave Type
                    const Text(
                      'Leave Type',
                      style: TextStyle(fontWeight: FontWeight.w600),
                    ),
                    const SizedBox(height: 8),
                    FormBuilderDropdown<String>(
                      name: 'leave_type',
                      decoration: _inputDecoration('Select Leave Type'),
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

                    const SizedBox(height: 16),

                    /// Dates
                    Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'From Date',
                                style: TextStyle(fontWeight: FontWeight.w600),
                              ),
                              const SizedBox(height: 8),
                              FormBuilderDateTimePicker(
                                name: 'start_date',
                                inputType: InputType.date,
                                format: DateFormat('dd/MM/yyyy'),
                                decoration: _inputDecoration('From Date'),
                               
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'To Date',
                                style: TextStyle(fontWeight: FontWeight.w600),
                              ),
                              const SizedBox(height: 8),
                              FormBuilderDateTimePicker(
                                name: 'end_date',
                                inputType: InputType.date,
                                format: DateFormat('dd/MM/yyyy'),
                                decoration: _inputDecoration('To Date'),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 16),

                    /// Reason
                    const Text(
                      'Reason',
                      style: TextStyle(fontWeight: FontWeight.w600),
                    ),
                    const SizedBox(height: 8),
                    FormBuilderTextField(
                      name: 'reason',
                      maxLines: 4,
                      decoration:
                          _inputDecoration('Enter reason for leave...'),
                  
                    ),

                    const Spacer(),

                    /// Buttons
                    Row(
                      children: [
                        Expanded(
                          child: ElevatedButton.icon(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF00D084),
                              padding: const EdgeInsets.symmetric(
                                vertical: 14,
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(30),
                              ),
                            ),
                            icon: const Icon(Icons.send),
                            label: const Text('Submit Request'),
                            onPressed: state.status ==
                                    LeaveReqFormStaus.loading
                                ? null
                                : () {
                                    final formState =
                                        _formKey.currentState;
                                    if (formState == null) return;

                                    if (formState.saveAndValidate()) {
                                      final value = formState.value;

                                      final model = LeaveRequestModel(
                                        leaveType:
                                            value['leave_type'] as String,
                                        startDate:
                                            value['start_date'] as DateTime,
                                        endDate:
                                            value['end_date'] as DateTime,
                                        reason:
                                            value['reason'] as String,
                                      );

                                      context
                                          .read<LeaveReqFormBloc>()
                                          .add(
                                            SubmitLeaveFormreq(
                                              leaveRequestModel: model,
                                            ),
                                          );
                                    }
                                  },
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.grey.shade300,
                              foregroundColor: Colors.black,
                              padding: const EdgeInsets.symmetric(
                                vertical: 14,
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(30),
                              ),
                            ),
                            onPressed: () => Navigator.pop(context),
                            child: const Text('Cancel'),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  InputDecoration _inputDecoration(String hint) {
    return InputDecoration(
      hintText: hint,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: Colors.grey.shade300),
      ),
    );
  }
}
