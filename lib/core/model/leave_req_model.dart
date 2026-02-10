class LeaveRequestModel {
  final String leaveType;
  final DateTime startDate;
  final DateTime endDate;
  final String reason;

  const LeaveRequestModel({
    required this.leaveType,
    required this.startDate,
    required this.endDate,
    required this.reason,
  });

  factory LeaveRequestModel.fromJson(Map<String, dynamic> json) {
    final data = json['data'] as Map<String, dynamic>;

    return LeaveRequestModel(
      leaveType: data['leave_type'] as String,
      startDate: DateTime.parse(data['start_date'] as String),
      endDate: DateTime.parse(data['end_date'] as String),
      reason: data['reason'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'leave_type': leaveType,
      'start_date': _formatDate(startDate),
      'end_date': _formatDate(endDate),
      'reason': reason,
    };
  }

  LeaveRequestModel copyWith({
    String? leaveType,
    DateTime? startDate,
    DateTime? endDate,
    String? reason,
  }) {
    return LeaveRequestModel(
      leaveType: leaveType ?? this.leaveType,
      startDate: startDate ?? this.startDate,
      endDate: endDate ?? this.endDate,
      reason: reason ?? this.reason,
    );
  }

  static String _formatDate(DateTime date) =>
      '${date.year.toString().padLeft(4, '0')}-'
      '${date.month.toString().padLeft(2, '0')}-'
      '${date.day.toString().padLeft(2, '0')}';
}
