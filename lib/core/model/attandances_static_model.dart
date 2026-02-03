import 'package:equatable/equatable.dart';

class AttendanceStatsModel extends Equatable {
  final int totalDays;
  final int presentDays;
  final int absentDays;
  final int lateDays;
  final Duration totalWorkHours;
  final Duration averageWorkHours;

  const AttendanceStatsModel({
    required this.totalDays,
    required this.presentDays,
    required this.absentDays,
    required this.lateDays,
    required this.totalWorkHours,
    required this.averageWorkHours,
  });

  factory AttendanceStatsModel.fromJson(Map<String, dynamic> json) {
    return AttendanceStatsModel(
      totalDays: json['total_days'] as int,
      presentDays: json['present_days'] as int,
      absentDays: json['absent_days'] as int,
      lateDays: json['late_days'] as int,
      totalWorkHours: Duration(seconds: json['total_work_hours'] as int),
      averageWorkHours: Duration(seconds: json['average_work_hours'] as int),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'total_days': totalDays,
      'present_days': presentDays,
      'absent_days': absentDays,
      'late_days': lateDays,
      'total_work_hours': totalWorkHours.inSeconds,
      'average_work_hours': averageWorkHours.inSeconds,
    };
  }

  double get attendancePercentage {
    if (totalDays == 0) return 0.0;
    return (presentDays / totalDays) * 100;
  }

  @override
  List<Object?> get props => [
        totalDays,
        presentDays,
        absentDays,
        lateDays,
        totalWorkHours,
        averageWorkHours,
      ];
}


