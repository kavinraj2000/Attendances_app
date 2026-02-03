part of 'dashboard_bloc.dart';

abstract class DashboardEvent extends Equatable {
  const DashboardEvent();

  @override
  List<Object?> get props => [];
}

class InitializeDashboard extends DashboardEvent {
  final int employeeId;

  const InitializeDashboard(this.employeeId);

  @override
  List<Object?> get props => [employeeId];
}

// ✅ FIX: CheckIn event should not require CheckInModel parameter
class CheckIn extends DashboardEvent {
  const CheckIn();

  @override
  List<Object?> get props => [];
}

// ✅ FIX: CheckOut event with optional updatedBy parameter
class CheckOut extends DashboardEvent {
  final String? updatedBy;

  const CheckOut({this.updatedBy});

  @override
  List<Object?> get props => [updatedBy];
}

class UpdateTimer extends DashboardEvent {
  const UpdateTimer();
}

class SelectDay extends DashboardEvent {
  final DateTime selectedDay;
  final DateTime focusedDay;

  const SelectDay({
    required this.selectedDay,
    required this.focusedDay,
  });

  @override
  List<Object?> get props => [selectedDay, focusedDay];
}

class ChangeCalendarFormat extends DashboardEvent {
  final CalendarFormat format;

  const ChangeCalendarFormat(this.format);

  @override
  List<Object?> get props => [format];
}

class ChangePage extends DashboardEvent {
  final DateTime focusedDay;

  const ChangePage(this.focusedDay);

  @override
  List<Object?> get props => [focusedDay];
}