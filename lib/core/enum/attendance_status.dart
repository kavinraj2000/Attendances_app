enum AttendanceStatus {
  present,
  absent,
  leave,
  halfDay,
  pending,
  unknown;

  static AttendanceStatus fromString(String? value) {
    switch (value?.toUpperCase()) {
      case 'PRESENT':
        return AttendanceStatus.present;
      case 'ABSENT':
        return AttendanceStatus.absent;
      case 'LEAVE':
        return AttendanceStatus.leave;
      case 'HALF_DAY':
        return AttendanceStatus.halfDay;
      case 'PENDING':
        return AttendanceStatus.pending;
      default:
        return AttendanceStatus.unknown;
    }
  }

  String toApiString() {
    switch (this) {
      case AttendanceStatus.present:
        return 'PRESENT';
      case AttendanceStatus.absent:
        return 'ABSENT';
      case AttendanceStatus.leave:
        return 'LEAVE';
      case AttendanceStatus.halfDay:
        return 'HALF_DAY';
      case AttendanceStatus.pending:
        return 'PENDING';
      case AttendanceStatus.unknown:
        return 'UNKNOWN';
    }
  }
}