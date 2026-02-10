import 'package:equatable/equatable.dart';

class LeaveRequestResponse extends Equatable {
  final String status;
  final String message;
  final List<LeaveRequestListModel> data;

  const LeaveRequestResponse({
    required this.status,
    required this.message,
    required this.data,
  });

  factory LeaveRequestResponse.fromJson(Map<String, dynamic> json) {
    return LeaveRequestResponse(
      status: json['status']?.toString() ?? '',
      message: json['message']?.toString() ?? '',
      data: (json['data'] as List<dynamic>? ?? [])
          .map(
            (e) => LeaveRequestListModel.fromJson(
              e as Map<String, dynamic>,
            ),
          )
          .toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'status': status,
      'message': message,
      'data': data.map((e) => e.toJson()).toList(),
    };
  }

  LeaveRequestResponse copyWith({
    String? status,
    String? message,
    List<LeaveRequestListModel>? data,
  }) {
    return LeaveRequestResponse(
      status: status ?? this.status,
      message: message ?? this.message,
      data: data ?? this.data,
    );
  }

  @override
  List<Object?> get props => [status, message, data];
}


class LeaveRequestListModel {
  final int id;
  final int employeeId;
  final String leaveType;
  final DateTime startDate;
  final DateTime endDate;
  final double totalDays;
  final String reason;
  final String status;

  final String? approvedBy;
  final DateTime? approvedAt;
  final String? rejectionReason;

  final DateTime created;
  final String? createdBy;
  final DateTime modified;
  final String? modifiedBy;

  final int deleteFlag;
  final int companyId;

  LeaveRequestListModel({
    required this.id,
    required this.employeeId,
    required this.leaveType,
    required this.startDate,
    required this.endDate,
    required this.totalDays,
    required this.reason,
    required this.status,
    this.approvedBy,
    this.approvedAt,
    this.rejectionReason,
    required this.created,
    this.createdBy,
    required this.modified,
    this.modifiedBy,
    required this.deleteFlag,
    required this.companyId,
  });

 factory LeaveRequestListModel.fromJson(Map<String, dynamic> json) {
  return LeaveRequestListModel(
    id: json['id'] ?? 0,
    employeeId: json['employee_id'] ?? 0,

    leaveType: (json['leave_type'] ?? '').toString(),

    startDate: json['start_date'] != null
        ? DateTime.parse(json['start_date'])
        : DateTime.now(),

    endDate: json['end_date'] != null
        ? DateTime.parse(json['end_date'])
        : DateTime.now(),

    totalDays: double.tryParse(json['total_days']?.toString() ?? '0') ?? 0.0,

    reason: (json['reason'] ?? '').toString(),

    status: (json['status'] ?? '').toString(),

    approvedBy: json['approved_by']?.toString(),

    approvedAt: json['approved_at'] != null
        ? DateTime.parse(json['approved_at'])
        : null,

    rejectionReason: json['rejection_reason']?.toString(),

    created: json['created'] != null
        ? DateTime.parse(json['created'])
        : DateTime.now(),

    createdBy: json['created_by']?.toString(),

    modified: json['modified'] != null
        ? DateTime.parse(json['modified'])
        : DateTime.now(),

    modifiedBy: json['modified_by']?.toString(),

    deleteFlag: json['delete_flag'] ?? 0,
    companyId: json['company_id'] ?? 0,
  );
}


  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'employee_id': employeeId,
      'leave_type': leaveType,
      'start_date': startDate.toIso8601String(),
      'end_date': endDate.toIso8601String(),
      'total_days': totalDays,
      'reason': reason,
      'status': status,
      'approved_by': approvedBy,
      'approved_at': approvedAt?.toIso8601String(),
      'rejection_reason': rejectionReason,
      'created': created.toIso8601String(),
      'created_by': createdBy,
      'modified': modified.toIso8601String(),
      'modified_by': modifiedBy,
      'delete_flag': deleteFlag,
      'company_id': companyId,
    };
  }
}
