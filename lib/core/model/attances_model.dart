import 'package:equatable/equatable.dart';
import 'package:hrm/core/enum/attendance_status.dart';

class AttendanceModel extends Equatable {
  final int? id;
  final String employeeId;
  final DateTime attendanceDate;
  final DateTime? checkinTime;
  final double? checkinLatitude;
  final double? checkinLongitude;
  final String? checkinImage;
  final DateTime? checkoutTime;
  final double? checkoutLatitude;
  final double? checkoutLongitude;
  final String? checkoutImage;
  final AttendanceStatus? attendanceStatus;
  final String? totalWorkHours;
  final String? remarks;
  final DateTime? created;
  final DateTime? modified;

  const AttendanceModel({
    this.id,
    required this.employeeId,
    required this.attendanceDate,
    this.checkinTime,
    this.checkoutTime,
    this.checkinLatitude,
    this.checkinLongitude,
    this.checkoutLatitude,
    this.checkoutLongitude,
    this.checkinImage,
    this.checkoutImage,
     this.attendanceStatus,
    this.totalWorkHours,
    this.remarks,
    this.created,
    this.modified,
  });

  bool get isActiveCheckIn {
    if (checkinTime == null) return false;
    if (checkoutTime != null) return false;
    if (attendanceStatus == AttendanceStatus.pending) return false;

    final diffHours = DateTime.now().difference(checkinTime!).inHours;
    return diffHours <= 24;
  }

  bool get isComplete => checkinTime != null && checkoutTime != null;

  Duration get workingDuration {
    if (checkinTime == null) return Duration.zero;

    final end = checkoutTime ?? DateTime.now();

    return end.isAfter(checkinTime!)
        ? end.difference(checkinTime!)
        : Duration.zero;
  }

  String get formattedDuration {
    final d = workingDuration;
    return '${d.inHours}h ${d.inMinutes.remainder(60)}m';
  }

  AttendanceModel copyWith({
    int? id,
    String? employeeId,
    DateTime? attendanceDate,
    DateTime? checkinTime,
    DateTime? checkoutTime,
    double? checkinLatitude,
    double? checkinLongitude,
    double? checkoutLatitude,
    double? checkoutLongitude,
    String? checkinImage,
    String? checkoutImage,
    AttendanceStatus? attendanceStatus,
    String? totalWorkHours,
    String? remarks,
    DateTime? created,
    DateTime? modified,
  }) {
    return AttendanceModel(
      id: id ?? this.id,
      employeeId: employeeId ?? this.employeeId,
      attendanceDate: attendanceDate ?? this.attendanceDate,
      checkinTime: checkinTime ?? this.checkinTime,
      checkoutTime: checkoutTime ?? this.checkoutTime,
      checkinLatitude: checkinLatitude ?? this.checkinLatitude,
      checkinLongitude: checkinLongitude ?? this.checkinLongitude,
      checkoutLatitude: checkoutLatitude ?? this.checkoutLatitude,
      checkoutLongitude: checkoutLongitude ?? this.checkoutLongitude,
      checkinImage: checkinImage ?? this.checkinImage,
      checkoutImage: checkoutImage ?? this.checkoutImage,
      attendanceStatus: attendanceStatus ?? this.attendanceStatus,
      totalWorkHours: totalWorkHours ?? this.totalWorkHours,
      remarks: remarks ?? this.remarks,
      created: created ?? this.created,
      modified: modified ?? this.modified,
    );
  }

  factory AttendanceModel.fromJson(Map<String, dynamic> json) {
    return AttendanceModel(
      id: _parseInt(json['id']),
      employeeId: json['employee_id']?.toString() ?? '',
      attendanceDate: DateTime.parse(json['attendance_date']),
      checkinTime: _parseDate(json['checkin_time']),
      checkoutTime: _parseDate(json['checkout_time']),
      checkinLatitude: _parseDouble(json['checkin_latitude']),
      checkinLongitude: _parseDouble(json['checkin_longitude']),
      checkoutLatitude: _parseDouble(json['checkout_latitude']),
      checkoutLongitude: _parseDouble(json['checkout_longitude']),
      checkinImage: json['checkin_image']?.toString(),
      checkoutImage: json['checkout_image']?.toString(),
      attendanceStatus: AttendanceStatus.fromString(json['attendance_status']),
      totalWorkHours: json['total_work_hours']?.toString(),
      remarks: json['remarks']?.toString(),
      created: _parseDate(json['created']),
      modified: _parseDate(json['modified']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'employee_id': employeeId,
      'attendance_date': attendanceDate.toIso8601String(),
      'checkin_time': checkinTime?.toUtc().toIso8601String(),
      'checkin_latitude': checkinLatitude,
      'checkin_longitude': checkinLongitude,
      'checkin_image': checkinImage,
      'checkout_time': checkoutTime?.toUtc().toIso8601String(),
      'checkout_latitude': checkoutLatitude,
      'checkout_longitude': checkoutLongitude,
      'checkout_image': checkoutImage,
      'attendance_status': attendanceStatus,
      'total_work_hours': totalWorkHours,
      'remarks': remarks,
      'created': created?.toUtc().toIso8601String(),
      'modified': modified?.toUtc().toIso8601String(),
    };
  }

  static DateTime? _parseDate(dynamic value) {
    if (value == null) return null;
    try {
      return DateTime.parse(value.toString());
    } catch (_) {
      return null;
    }
  }

  static double? _parseDouble(dynamic v) {
    if (v == null) return null;
    return double.tryParse(v.toString());
  }

  static int? _parseInt(dynamic v) {
    if (v == null) return null;
    return int.tryParse(v.toString());
  }

  @override
  List<Object?> get props => [
    id,
    employeeId,
    attendanceDate,
    checkinTime,
    checkoutTime,
    attendanceStatus,
  ];
}
