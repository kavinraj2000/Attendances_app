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
    data: model, 
  );
}