import 'package:equatable/equatable.dart';

class AttendanceModel extends Equatable {
  final int? id;
  final String employeeId;
  final String attendanceDate;

  // Check-in
  final DateTime? checkinTime;
  final double? checkinLatitude;
  final double? checkinLongitude;
  final String? checkinImage;

  // Check-out
  final DateTime? checkoutTime;
  final double? checkoutLatitude;
  final double? checkoutLongitude;
  final String? checkoutImage;

  // Status
  final String? attendanceStatus;
  final String? status;

  // Metadata
  final DateTime? createdAt;
  final DateTime? updatedAt;

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
    this.status,
    this.createdAt,
    this.updatedAt,
  });

  // ───────────────── BUSINESS LOGIC ─────────────────

  bool get isActiveCheckIn {
    if (checkinTime == null) return false;
    if (checkoutTime != null) return false;
    if (attendanceStatus == 'PENDING') return false;

    final diffHours =
        DateTime.now().difference(checkinTime!).inHours;

    return diffHours <= 24;
  }

  bool get isComplete =>
      checkinTime != null && checkoutTime != null;

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

  // ───────────────── COPY WITH ─────────────────

  AttendanceModel copyWith({
    int? id,
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
    String? attendanceStatus,
    String? status,
    DateTime? createdAt,
    DateTime? updatedAt,
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
      status: status ?? this.status,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  // ───────────────── JSON ─────────────────

  factory AttendanceModel.fromJson(Map<String, dynamic> json) {
    return AttendanceModel(
      id: _parseInt(json['id']),
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
      attendanceStatus: json['attendance_status']?.toString(),
      status: json['status']?.toString(),
      createdAt: _parseDateTime(json['created_at']),
      updatedAt: _parseDateTime(json['updated_at']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'employee_id': employeeId,
      'attendance_date': attendanceDate,

      'checkin_time': checkinTime?.toIso8601String(),
      'checkin_latitude': checkinLatitude,
      'checkin_longitude': checkinLongitude,
      'checkin_image': checkinImage,

      'checkout_time': checkoutTime?.toIso8601String(),
      'checkout_latitude': checkoutLatitude,
      'checkout_longitude': checkoutLongitude,
      'checkout_image': checkoutImage,

      'attendance_status': attendanceStatus,
      'status': status,

      'created_at': createdAt?.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String(),
    };
  }


  static DateTime? _parseDateTime(dynamic v) {
    if (v == null) return null;
    try {
      return DateTime.parse(v.toString());
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
        status,
      ];
}
