enum WeekDay {
  monday,
  tuesday,
  wednesday,
  thursday,
  friday,
  saturday,
  sunday;

  static WeekDay fromDateTime(DateTime date) {
    return WeekDay.values[date.weekday - 1];
  }

  String get displayName {
    switch (this) {
      case WeekDay.monday:    return 'Monday';
      case WeekDay.tuesday:   return 'Tuesday';
      case WeekDay.wednesday: return 'Wednesday';
      case WeekDay.thursday:  return 'Thursday';
      case WeekDay.friday:    return 'Friday';
      case WeekDay.saturday:  return 'Saturday';
      case WeekDay.sunday:    return 'Sunday';
    }
  }

  String get shortName {
    switch (this) {
      case WeekDay.monday:    return 'M';
      case WeekDay.tuesday:   return 'T';
      case WeekDay.wednesday: return 'W';
      case WeekDay.thursday:  return 'T';
      case WeekDay.friday:    return 'F';
      case WeekDay.saturday:  return 'S';
      case WeekDay.sunday:    return 'S';
    }
  }

  bool get isWeekend =>
      this == WeekDay.saturday || this == WeekDay.sunday;
}