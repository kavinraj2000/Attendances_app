part of 'dashboard_bloc.dart';

abstract class DashboardEvent extends Equatable {
  const DashboardEvent();

  @override
  List<Object?> get props => [];
}

class InitializeDashboard extends DashboardEvent {}

class CheckIn extends DashboardEvent {}

class CheckOut extends DashboardEvent {}

class SelectDate extends DashboardEvent {
  final DateTime date;

  const SelectDate(this.date);

  @override
  List<Object?> get props => [date];
}

class UpdateCalendarMonth extends DashboardEvent {
  final DateTime month;

  const UpdateCalendarMonth(this.month);

  @override
  List<Object?> get props => [month];
}

class LoadDashboardData extends DashboardEvent {}

class RefreshDashboardData extends DashboardEvent {}