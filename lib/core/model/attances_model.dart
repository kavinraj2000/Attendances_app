// attendance_model.dart - Enhanced version with all required fields

import 'package:equatable/equatable.dart';

class AttendanceModel extends Equatable {
  final String? id;
  final String employeeId;
  final String attendanceDate;
  final DateTime? checkinTime;
  final DateTime? checkoutTime;
  final double? checkinLatitude;
  final double? checkinLongitude;
  final double? checkoutLatitude;
  final double? checkoutLongitude;
  final String? checkinImage;
  final String? checkoutImage;
  final String? createdBy;
  final String? modifiedBy;
  final DateTime? createdAt;
  final DateTime? modifiedAt;

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
    this.createdBy,
    this.modifiedBy,
    this.createdAt,
    this.modifiedAt,
  });

  /// Creates a copy with modified fields
  AttendanceModel copyWith({
    String? id,
    String? employeeId,
    String? attendanceDate,
    DateTime? checkinTime,
    DateTime? checkoutTime,
    double? checkinLatitude,
    double? checkinLongitude,
    double? checkoutLatitude,
    double? checkoutLongitude,
    String? checkinImage,
    String? checkoutImage,
    String? createdBy,
    String? modifiedBy,
    DateTime? createdAt,
    DateTime? modifiedAt,
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
      createdBy: createdBy ?? this.createdBy,
      modifiedBy: modifiedBy ?? this.modifiedBy,
      createdAt: createdAt ?? this.createdAt,
      modifiedAt: modifiedAt ?? this.modifiedAt,
    );
  }

  /// Creates from JSON
  factory AttendanceModel.fromJson(Map<String, dynamic> json) {
    return AttendanceModel(
      id: json['id']?.toString(),
      employeeId: json['employee_id']?.toString() ?? '',
      attendanceDate: json['attendance_date']?.toString() ?? '',
      checkinTime: _parseDateTime(json['checkin_time']),
      checkoutTime: _parseDateTime(json['checkout_time']),
      checkinLatitude: _parseDouble(json['checkin_latitude']),
      checkinLongitude: _parseDouble(json['checkin_longitude']),
      checkoutLatitude: _parseDouble(json['checkout_latitude']),
      checkoutLongitude: _parseDouble(json['checkout_longitude']),
      checkinImage: json['checkin_image']?.toString(),
      checkoutImage: json['checkout_image']?.toString(),
      createdBy: json['created_by']?.toString(),
      modifiedBy: json['modified_by']?.toString(),
      createdAt: _parseDateTime(json['created_at']),
      modifiedAt: _parseDateTime(json['modified_at']),
    );
  }

  /// Converts to JSON
  Map<String, dynamic> toJson() {
    return {
      if (id != null) 'id': id,
      'employee_id': employeeId,
      'attendance_date': attendanceDate,
      if (checkinTime != null) 'checkin_time': checkinTime!.toIso8601String(),
      if (checkoutTime != null) 'checkout_time': checkoutTime!.toIso8601String(),
      if (checkinLatitude != null) 'checkin_latitude': checkinLatitude,
      if (checkinLongitude != null) 'checkin_longitude': checkinLongitude,
      if (checkoutLatitude != null) 'checkout_latitude': checkoutLatitude,
      if (checkoutLongitude != null) 'checkout_longitude': checkoutLongitude,
      if (checkinImage != null) 'checkin_image': checkinImage,
      if (checkoutImage != null) 'checkout_image': checkoutImage,
      if (createdBy != null) 'created_by': createdBy,
      if (modifiedBy != null) 'modified_by': modifiedBy,
      if (createdAt != null) 'created_at': createdAt!.toIso8601String(),
      if (modifiedAt != null) 'modified_at': modifiedAt!.toIso8601String(),
    };
  }

  /// Checks if user is currently checked in
  bool get isCheckedIn => checkinTime != null && checkoutTime == null;

  /// Checks if attendance is complete (both check-in and check-out done)
  bool get isComplete => checkinTime != null && checkoutTime != null;

  /// Calculates working duration
  Duration get workingDuration {
    if (checkinTime == null) return Duration.zero;
    
    final endTime = checkoutTime ?? DateTime.now();
    final duration = endTime.difference(checkinTime!);
    
    return duration.isNegative ? Duration.zero : duration;
  }

  /// Formats working duration as hours and minutes
  String get formattedDuration {
    final duration = workingDuration;
    final hours = duration.inHours;
    final minutes = duration.inMinutes.remainder(60);
    return '${hours}h ${minutes}m';
  }

  @override
  List<Object?> get props => [
        id,
        employeeId,
        attendanceDate,
        checkinTime,
        checkoutTime,
        checkinLatitude,
        checkinLongitude,
        checkoutLatitude,
        checkoutLongitude,
        checkinImage,
        checkoutImage,
        createdBy,
        modifiedBy,
        createdAt,
        modifiedAt,
      ];

  @override
  String toString() {
    return 'AttendanceModel('
        'id: $id, '
        'employeeId: $employeeId, '
        'date: $attendanceDate, '
        'checkin: $checkinTime, '
        'checkout: $checkoutTime'
        ')';
  }

  // ───────────────── HELPER METHODS ─────────────────

  static DateTime? _parseDateTime(dynamic value) {
    if (value == null) return null;
    if (value is DateTime) return value;
    
    try {
      return DateTime.parse(value.toString());
    } catch (e) {
      return null;
    }
  }

  static double? _parseDouble(dynamic value) {
    if (value == null) return null;
    if (value is double) return value;
    if (value is int) return value.toDouble();
    
    try {
      return double.parse(value.toString());
    } catch (e) {
      return null;
    }
  }
}