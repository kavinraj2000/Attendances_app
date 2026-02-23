class LeaveModel {
  final int? id;
  final String leaveCode;
  final String leaveName;
  final String description;
  final double maxDaysPerYear;
  final bool carryForwardAllowed;
  final double maxCarryForwardDays;
  final bool monthlyAccrual;
  final double accrualPerMonth;
  final bool encashmentAllowed;
  final String genderApplicable;
  final bool deleteFlag;
  final DateTime created;
  final String createdBy;
  final DateTime modified;
  final String? modifiedBy;
  final int companyId;

  LeaveModel({
     this.id,
    required this.leaveCode,
    required this.leaveName,
    required this.description,
    required this.maxDaysPerYear,
    required this.carryForwardAllowed,
    required this.maxCarryForwardDays,
    required this.monthlyAccrual,
    required this.accrualPerMonth,
    required this.encashmentAllowed,
    required this.genderApplicable,
    required this.deleteFlag,
    required this.created,
    required this.createdBy,
    required this.modified,
    this.modifiedBy,
    required this.companyId,
  });

  factory LeaveModel.fromJson(Map<String, dynamic> json) {
    return LeaveModel(
      id: json['id'] ?? 0,
      leaveCode: json['leave_code'] ?? '',
      leaveName: json['leave_name'] ?? '',
      description: json['description'] ?? '',
      maxDaysPerYear: double.tryParse(json['max_days_per_year'].toString()) ?? 0.0,
      carryForwardAllowed: json['carry_forward_allowed'] == 1,
      maxCarryForwardDays:
          double.tryParse(json['max_carry_forward_days'].toString()) ?? 0.0,
      monthlyAccrual: json['monthly_accrual'] == 1,
      accrualPerMonth:
          double.tryParse(json['accrual_per_month'].toString()) ?? 0.0,
      encashmentAllowed: json['encashment_allowed'] == 1,
      genderApplicable: json['gender_applicable'] ?? '',
      deleteFlag: json['delete_flag'] == 1,
      created: DateTime.parse(json['created']),
      createdBy: json['created_by'] ?? '',
      modified: DateTime.parse(json['modified']),
      modifiedBy: json['modified_by'],
      companyId: json['company_id'] ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'leave_code': leaveCode,
      'leave_name': leaveName,
      'description': description,
      'max_days_per_year': maxDaysPerYear.toStringAsFixed(2),
      'carry_forward_allowed': carryForwardAllowed ? 1 : 0,
      'max_carry_forward_days': maxCarryForwardDays.toStringAsFixed(2),
      'monthly_accrual': monthlyAccrual ? 1 : 0,
      'accrual_per_month': accrualPerMonth.toStringAsFixed(2),
      'encashment_allowed': encashmentAllowed ? 1 : 0,
      'gender_applicable': genderApplicable,
      'delete_flag': deleteFlag ? 1 : 0,
      'created': created.toIso8601String(),
      'created_by': createdBy,
      'modified': modified.toIso8601String(),
      'modified_by': modifiedBy,
      'company_id': companyId,
    };
  }
}