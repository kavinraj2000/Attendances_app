import 'package:equatable/equatable.dart';

enum AttendanceStatus {
  present,
  absent,
  checkedIn,
  checkedOut,
}

AttendanceStatus attendanceStatusFromString(String? value) {
  switch (value?.toUpperCase()) {
    case 'PRESENT':
      return AttendanceStatus.present;
    case 'CHECKED_IN':
      return AttendanceStatus.checkedIn;
    case 'CHECKED_OUT':
      return AttendanceStatus.checkedOut;
    case 'ABSENT':
    default:
      return AttendanceStatus.absent;
  }
}

String attendanceStatusToString(AttendanceStatus status) {
  switch (status) {
    case AttendanceStatus.present:
      return 'PRESENT';
    case AttendanceStatus.checkedIn:
      return 'CHECKED_IN';
    case AttendanceStatus.checkedOut:
      return 'CHECKED_OUT';
    case AttendanceStatus.absent:
    return 'ABSENT';
  }
}

class AttendanceModel extends Equatable {
  final int id;
  final int employeeId;
  final DateTime attendanceDate;

  final DateTime? checkInTime;
  final double? checkInLatitude;
  final double? checkInLongitude;
  final String? checkInImage;

  final DateTime? checkOutTime;
  final double? checkOutLatitude;
  final double? checkOutLongitude;
  final String? checkOutImage;

  final Duration? totalWorkHours;
  final AttendanceStatus status;
  final String? remarks;

  const AttendanceModel({
    required this.id,
    required this.employeeId,
    required this.attendanceDate,
    this.checkInTime,
    this.checkInLatitude,
    this.checkInLongitude,
    this.checkInImage,
    this.checkOutTime,
    this.checkOutLatitude,
    this.checkOutLongitude,
    this.checkOutImage,
    this.totalWorkHours,
    required this.status,
    this.remarks,
  });

  factory AttendanceModel.fromJson(Map<String, dynamic> json) {
    return AttendanceModel(
      id: json['id'] as int,
      employeeId: json['employee_id'] as int,
      attendanceDate: DateTime.parse(json['attendance_date']),

      checkInTime: json['checkin_time'] != null
          ? DateTime.parse(json['checkin_time'])
          : null,
      checkInLatitude: (json['checkin_latitude'] as num?)?.toDouble(),
      checkInLongitude: (json['checkin_longitude'] as num?)?.toDouble(),
      checkInImage: json['checkin_image'] as String?,

      checkOutTime: json['checkout_time'] != null
          ? DateTime.parse(json['checkout_time'])
          : null,
      checkOutLatitude: (json['checkout_latitude'] as num?)?.toDouble(),
      checkOutLongitude: (json['checkout_longitude'] as num?)?.toDouble(),
      checkOutImage: json['checkout_image'] as String?,

      totalWorkHours: json['total_work_hours'] != null
          ? Duration(minutes: json['total_work_hours'])
          : null,

      status: attendanceStatusFromString(json['attendance_status']),
      remarks: json['remarks'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'employee_id': employeeId,
      'attendance_date': attendanceDate.toIso8601String().split('T').first,

      'checkin_time': checkInTime?.toIso8601String(),
      'checkin_latitude': checkInLatitude,
      'checkin_longitude': checkInLongitude,
      'checkin_image': checkInImage,

      'checkout_time': checkOutTime?.toIso8601String(),
      'checkout_latitude': checkOutLatitude,
      'checkout_longitude': checkOutLongitude,
      'checkout_image': checkOutImage,

      'total_work_hours': totalWorkHours?.inMinutes,
      'attendance_status': attendanceStatusToString(status),
      'remarks': remarks,
    };
  }

  AttendanceModel copyWith({
    DateTime? checkInTime,
    DateTime? checkOutTime,
    Duration? totalWorkHours,
    AttendanceStatus? status,
    String? remarks,
  }) {
    return AttendanceModel(
      id: id,
      employeeId: employeeId,
      attendanceDate: attendanceDate,

      checkInTime: checkInTime ?? this.checkInTime,
      checkInLatitude: checkInLatitude,
      checkInLongitude: checkInLongitude,
      checkInImage: checkInImage,

      checkOutTime: checkOutTime ?? this.checkOutTime,
      checkOutLatitude: checkOutLatitude,
      checkOutLongitude: checkOutLongitude,
      checkOutImage: checkOutImage,

      totalWorkHours: totalWorkHours ?? this.totalWorkHours,
      status: status ?? this.status,
      remarks: remarks ?? this.remarks,
    );
  }

  bool get isAbsent => status == AttendanceStatus.absent;
  bool get isCheckedIn => checkInTime != null && checkOutTime == null;
  bool get isCheckedOut => checkInTime != null && checkOutTime != null;

  @override
  List<Object?> get props => [
        id,
        employeeId,
        attendanceDate,
        checkInTime,
        checkOutTime,
        status,
        totalWorkHours,
        remarks,
      ];
}
