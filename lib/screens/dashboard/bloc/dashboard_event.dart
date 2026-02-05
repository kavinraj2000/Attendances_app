// dashboard_event.dart

part of 'dashboard_bloc.dart';

abstract class DashboardEvent extends Equatable {
  const DashboardEvent();

  @override
  List<Object?> get props => [];
}

/// Initialize dashboard with attendance data
class InitializeDashboard extends DashboardEvent {
  const InitializeDashboard();
}

/// Perform check-in operation
class CheckIn extends DashboardEvent {
  const CheckIn();

  @override
  String toString() => 'CheckIn()';
}

class CheckOut extends DashboardEvent {
  const CheckOut();

  @override
  String toString() => 'CheckOut()';
}

/// Refresh attendance data
class RefreshDashboard extends DashboardEvent {
  const RefreshDashboard();

  @override
  String toString() => 'RefreshDashboard()';
}

/// Select a specific day in calendar
class SelectDay extends DashboardEvent {
  final DateTime selectedDay;
  final DateTime focusedDay;

  const SelectDay(this.selectedDay, this.focusedDay);

  @override
  List<Object?> get props => [selectedDay, focusedDay];

  @override
  String toString() => 'SelectDay(selected: $selectedDay, focused: $focusedDay)';
}

/// Change calendar display format
class ChangeCalendarFormat extends DashboardEvent {
  final CalendarFormat format;

  const ChangeCalendarFormat(this.format);

  @override
  List<Object?> get props => [format];

  @override
  String toString() => 'ChangeCalendarFormat($format)';
}

/// Change calendar page/month
class ChangePage extends DashboardEvent {
  final DateTime focusedDay;

  const ChangePage(this.focusedDay);

  @override
  List<Object?> get props => [focusedDay];

  @override
  String toString() => 'ChangePage($focusedDay)';
}