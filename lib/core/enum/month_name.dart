enum MonthName {
  january,
  february,
  march,
  april,
  may,
  june,
  july,
  august,
  september,
  october,
  november,
  december;

  static MonthName fromInt(int month) {
    return MonthName.values[month - 1];
  }

  String get displayName {
    switch (this) {
      case MonthName.january:
        return 'January';
      case MonthName.february:
        return 'February';
      case MonthName.march:
        return 'March';
      case MonthName.april:
        return 'April';
      case MonthName.may:
        return 'May';
      case MonthName.june:
        return 'June';
      case MonthName.july:
        return 'July';
      case MonthName.august:
        return 'August';
      case MonthName.september:
        return 'September';
      case MonthName.october:
        return 'October';
      case MonthName.november:
        return 'November';
      case MonthName.december:
        return 'December';
    }
  }

  String get shortName {
    switch (this) {
      case MonthName.january:
        return 'Jan';
      case MonthName.february:
        return 'Feb';
      case MonthName.march:
        return 'Mar';
      case MonthName.april:
        return 'Apr';
      case MonthName.may:
        return 'May';
      case MonthName.june:
        return 'Jun';
      case MonthName.july:
        return 'Jul';
      case MonthName.august:
        return 'Aug';
      case MonthName.september:
        return 'Sep';
      case MonthName.october:
        return 'Oct';
      case MonthName.november:
        return 'Nov';
      case MonthName.december:
        return 'Dec';
    }
  }
}
