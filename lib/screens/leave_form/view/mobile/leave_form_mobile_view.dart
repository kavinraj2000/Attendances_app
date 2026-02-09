import 'package:flutter/material.dart';
import 'package:hrm/screens/leave_form/view/mobile/widget/custom_form_builder.dart';

class LeaveRequestForm extends StatefulWidget {
  const LeaveRequestForm({Key? key}) : super(key: key);

  @override
  State<LeaveRequestForm> createState() => _LeaveRequestFormState();
}

class _LeaveRequestFormState extends State<LeaveRequestForm> {
  final _formKey = GlobalKey<FormState>();

  String? _selectedLeaveType;
  DateTime? _fromDate;
  DateTime? _toDate;
  final TextEditingController _reasonController = TextEditingController();

  final List<String> _leaveTypes = [
    'Sick Leave',
    'Casual Leave',
    'Annual Leave',
    'Maternity Leave',
    'Paternity Leave',
    'Unpaid Leave',
  ];

  @override
  void initState() {
    super.initState();
    _fromDate = DateTime(2026, 2, 9);
    _toDate = DateTime(2026, 2, 10);
  }

  @override
  void dispose() {
    _reasonController.dispose();
    super.dispose();
  }

  void _submitRequest() {
    if (_formKey.currentState!.validate()) {
      if (_selectedLeaveType == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Please select a leave type'),
            backgroundColor: Colors.red,
          ),
        );
        return;
      }

      if (_fromDate == null || _toDate == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Please select dates'),
            backgroundColor: Colors.red,
          ),
        );
        return;
      }

      final leaveRequest = {
        'leaveType': _selectedLeaveType,
        'fromDate': _fromDate,
        'toDate': _toDate,
        'reason': _reasonController.text,
      };

      print('Leave Request Submitted: $leaveRequest');

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Leave request submitted successfully!'),
          backgroundColor: Colors.green,
        ),
      );

      Navigator.pop(context);
    }
  }

  void _cancelRequest() {
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Container(
        width: MediaQuery.of(context).size.width * 0.9,
        constraints: const BoxConstraints(maxWidth: 600),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Header
            Container(
              decoration: const BoxDecoration(
                color: Color(0xFF5B6FED),
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(16),
                  topRight: Radius.circular(16),
                ),
              ),
              padding: const EdgeInsets.all(20),
              child: Row(
                children: [
                  const Icon(
                    Icons.add_circle_outline,
                    color: Colors.white,
                    size: 28,
                  ),
                  const SizedBox(width: 12),
                  const Expanded(
                    child: Text(
                      'New Leave Request',
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ),
                  IconButton(
                    onPressed: _cancelRequest,
                    icon: const Icon(Icons.close, color: Colors.white),
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                  ),
                ],
              ),
            ),

            // Form Content
            Flexible(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(24),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      // Leave Type Dropdown
                      CustomFormBuilder.buildDropdownField(
                        label: 'Leave Type',
                        value: _selectedLeaveType,
                        items: _leaveTypes,
                        hint: 'Select Leave Type',
                        onChanged: (value) {
                          setState(() {
                            _selectedLeaveType = value;
                          });
                        },
                      ),
                      const SizedBox(height: 24),

                      // Date Range
                      Row(
                        children: [
                          Expanded(
                            child: CustomFormBuilder.buildDateField(
                              context: context,
                              label: 'From Date',
                              selectedDate: _fromDate,
                              onDateSelected: (date) {
                                setState(() {
                                  _fromDate = date;
                                  // Adjust to date if it's before from date
                                  if (_toDate != null && _toDate!.isBefore(date)) {
                                    _toDate = date;
                                  }
                                });
                              },
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: CustomFormBuilder.buildDateField(
                              context: context,
                              label: 'To Date',
                              selectedDate: _toDate,
                              firstDate: _fromDate,
                              onDateSelected: (date) {
                                setState(() {
                                  _toDate = date;
                                });
                              },
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 24),

                      // Reason Text Field
                      CustomFormBuilder.buildTextField(
                        label: 'Reason',
                        controller: _reasonController,
                        hint: 'Enter reason for leave...',
                        maxLines: 5,
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return 'Please enter a reason for leave';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 32),

                      // Action Buttons
                      Row(
                        children: [
                          Expanded(
                            child: CustomFormBuilder.buildButton(
                              text: 'Submit Request',
                              icon: Icons.send,
                              onPressed: _submitRequest,
                              backgroundColor: const Color(0xFF00D9B5),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: CustomFormBuilder.buildButton(
                              text: 'Cancel',
                              onPressed: _cancelRequest,
                              isOutlined: true,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}