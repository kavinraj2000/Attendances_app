part of 'dashboard_bloc.dart';

abstract class DashboardEvent extends Equatable {
  const DashboardEvent();

  @override
  List<Object?> get props => [];
}

class InitializeDashboard extends DashboardEvent {
  const InitializeDashboard();
}

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

class RefreshDashboard extends DashboardEvent {
  const RefreshDashboard();

  @override
  String toString() => 'RefreshDashboard()';
}

class SelectDay extends DashboardEvent {
  final DateTime selectedDay;
  final DateTime focusedDay;

  const SelectDay(this.selectedDay, this.focusedDay);

  @override
  List<Object?> get props => [selectedDay, focusedDay];

  @override
  String toString() => 'SelectDay(selected: $selectedDay, focused: $focusedDay)';
}

class ChangeCalendarFormat extends DashboardEvent {
  final CalendarFormat format;

  const ChangeCalendarFormat(this.format);

  @override
  List<Object?> get props => [format];

  @override
  String toString() => 'ChangeCalendarFormat($format)';
}

class ChangePage extends DashboardEvent {
  final DateTime focusedDay;

  const ChangePage(this.focusedDay);

  @override
  List<Object?> get props => [focusedDay];

  @override
  String toString() => 'ChangePage($focusedDay)';
}