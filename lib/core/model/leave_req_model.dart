class LeaveRequestModel {
  final int? id;
  final int? leavetypeID;
  final String leaveType;
  final DateTime startDate;
  final DateTime endDate;
  final String reason;

  const LeaveRequestModel({
    this.id,
    required this.leaveType,
    required this.startDate,
    required this.endDate,
    required this.reason,
    this.leavetypeID,
  });

  factory LeaveRequestModel.fromJson(Map<String, dynamic> json) {
    final data = json['data'] as Map<String, dynamic>;

    return LeaveRequestModel(
      leaveType: data['leave_type'] as String,
      startDate: DateTime.parse(data['start_date'] as String),
      endDate: DateTime.parse(data['end_date'] as String),
      reason: data['reason'] as String,
      id: data['id'] ,
      leavetypeID: data['leave_type_id'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id':id,
      'leave_type': leaveType,
      'start_date': _formatDate(startDate),
      'end_date': _formatDate(endDate),
      'reason': reason,
      'leave_type_id':leavetypeID,
    };
  }

  LeaveRequestModel copyWith({
    int?id,
    String? leaveType,
    DateTime? startDate,
    DateTime? endDate,
    int?leaveTypeID,
    String? reason,
  }) {
    return LeaveRequestModel(
      id: id ?? this.id,
      leaveType: leaveType ?? this.leaveType,
      startDate: startDate ?? this.startDate,
      endDate: endDate ?? this.endDate,
      reason: reason ?? this.reason,
      leavetypeID: leaveTypeID ?? leavetypeID
    );
  }

  static String _formatDate(DateTime date) =>
      '${date.year.toString().padLeft(4, '0')}-'
      '${date.month.toString().padLeft(2, '0')}-'
      '${date.day.toString().padLeft(2, '0')}';
}
