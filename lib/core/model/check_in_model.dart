class CheckInModel {
  final int employeeId;
  final int? attendanceId;

  final DateTime? checkinTime;
  final double? checkinLatitude;
  final double? checkinLongitude;
  final String? checkinImage;
  final String? createdBy;

  // --- Check-out fields ---
  final DateTime? checkoutTime;
  final double? checkoutLatitude;
  final double? checkoutLongitude;
  final String? checkoutImage;
  final String? modifiedBy;

  const CheckInModel({
   required this.employeeId,
    this.attendanceId,
    this.checkinTime,
    this.checkinLatitude,
    this.checkinLongitude,
    this.checkinImage,
    this.createdBy,
    this.checkoutTime,
    this.checkoutLatitude,
    this.checkoutLongitude,
    this.checkoutImage,
    this.modifiedBy,
  });

  /// --------------- from JSON ---------------
  factory CheckInModel.fromJson(Map<String, dynamic> json) {
    final Map<String, dynamic> map =
        json.containsKey('data') ? json['data'] as Map<String, dynamic> : json;

    return CheckInModel(
      employeeId: map['employee_id'] as int,
      attendanceId: map['attendance_id'] as int?,
      checkinTime: map['checkin_time'] != null
          ? DateTime.parse(map['checkin_time'])
          : null,
      checkinLatitude: (map['checkin_latitude'] as num?)?.toDouble(),
      checkinLongitude: (map['checkin_longitude'] as num?)?.toDouble(),
      checkinImage: map['checkin_image'] as String?,
      createdBy: map['created_by'] as String?,
      checkoutTime: map['checkout_time'] != null
          ? DateTime.parse(map['checkout_time'])
          : null,
      checkoutLatitude: (map['checkout_latitude'] as num?)?.toDouble(),
      checkoutLongitude: (map['checkout_longitude'] as num?)?.toDouble(),
      checkoutImage: map['checkout_image'] as String?,
      modifiedBy: map['modified_by'] as String?,
    );
  }

  /// --------------- to JSON ---------------
  Map<String, dynamic> toJson() {
    return {
      'employee_id': employeeId,
      'attendance_id': attendanceId,
      'checkin_time': checkinTime?.toIso8601String(),
      'checkin_latitude': checkinLatitude,
      'checkin_longitude': checkinLongitude,
      'checkin_image': checkinImage,
      'created_by': createdBy,
      'checkout_time': checkoutTime?.toIso8601String(),
      'checkout_latitude': checkoutLatitude,
      'checkout_longitude': checkoutLongitude,
      'checkout_image': checkoutImage,
      'modified_by': modifiedBy,
    };
  }

  /// --------------- copyWith ---------------
  CheckInModel copyWith({
    int? employeeId,
    int? attendanceId,
    DateTime? checkinTime,
    double? checkinLatitude,
    double? checkinLongitude,
    String? checkinImage,
    String? createdBy,
    DateTime? checkoutTime,
    double? checkoutLatitude,
    double? checkoutLongitude,
    String? checkoutImage,
    String? modifiedBy,
  }) {
    return CheckInModel(
      employeeId: employeeId ?? this.employeeId,
      attendanceId: attendanceId ?? this.attendanceId,
      checkinTime: checkinTime ?? this.checkinTime,
      checkinLatitude: checkinLatitude ?? this.checkinLatitude,
      checkinLongitude: checkinLongitude ?? this.checkinLongitude,
      checkinImage: checkinImage ?? this.checkinImage,
      createdBy: createdBy ?? this.createdBy,
      checkoutTime: checkoutTime ?? this.checkoutTime,
      checkoutLatitude: checkoutLatitude ?? this.checkoutLatitude,
      checkoutLongitude: checkoutLongitude ?? this.checkoutLongitude,
      checkoutImage: checkoutImage ?? this.checkoutImage,
      modifiedBy: modifiedBy ?? this.modifiedBy,
    );
  }
}