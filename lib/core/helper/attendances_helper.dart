import 'package:hrm/core/model/attances_model.dart';
import 'package:hrm/core/widgets/attances_popup_widget.dart';


AttendanceData convertToAttendanceData(
  AttendanceModel model,
  DateTime date,
) {
  return AttendanceData(
    date: date,
    checkInTime: model.checkinTime,
    checkOutTime: model.checkoutTime,
    status: _mapStatus(model.attendanceStatus),
  );
}

AttendanceStatus _mapStatus(String? status) {
  switch (status?.toUpperCase()) {
    case 'PRESENT':
      return AttendanceStatus.present;
    case 'ABSENT':
      return AttendanceStatus.absent;
    case 'HALF_DAY':
      return AttendanceStatus.halfDay;
    case 'LEAVE':
      return AttendanceStatus.leave;
    default:
      return AttendanceStatus.absent;
  }
}

