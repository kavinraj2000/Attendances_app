import 'package:flutter/material.dart';

Future<DateTime?> showModernDatePicker({
  required BuildContext context,
  DateTime? initialDate,
  DateTime? firstDate,
  DateTime? lastDate,
  Color primaryColor = const Color(0xFFF5A623),
  Color backgroundColor = Colors.white,
}) async {
  return showDialog<DateTime>(
    context: context,
    builder: (context) => ModernDatePickerDialog(
      initialDate: initialDate ?? DateTime.now(),
      firstDate: firstDate ?? DateTime(2020),
      lastDate: lastDate ?? DateTime(2030),
      primaryColor: primaryColor,
      backgroundColor: backgroundColor,
    ),
  );
}

class ModernDatePickerDialog extends StatefulWidget {
  final DateTime initialDate;
  final DateTime firstDate;
  final DateTime lastDate;
  final Color primaryColor;
  final Color backgroundColor;

  const ModernDatePickerDialog({
    super.key,
    required this.initialDate,
    required this.firstDate,
    required this.lastDate,
    required this.primaryColor,
    required this.backgroundColor,
  });

  @override
  State<ModernDatePickerDialog> createState() => _ModernDatePickerDialogState();
}

class _ModernDatePickerDialogState extends State<ModernDatePickerDialog> {
  late DateTime selectedDate;
  late int currentMonth;
  late int currentYear;

  @override
  void initState() {
    super.initState();
    selectedDate = widget.initialDate;
    currentMonth = selectedDate.month;
    currentYear = selectedDate.year;
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      backgroundColor: widget.backgroundColor,
      child: Container(
        width: MediaQuery.of(context).size.width * 0.9,
        constraints: const BoxConstraints(maxWidth: 400),
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildHeader(),
            const SizedBox(height: 24),
            _buildMonthYearSelectors(),
            const SizedBox(height: 24),
            _buildWeekdayHeaders(),
            const SizedBox(height: 12),
            _buildCalendarGrid(),
            const SizedBox(height: 24),
            _buildConfirmButton(),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        const Text(
          'Select Date',
          style: TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.bold,
            color: Color(0xFF2C3E50),
          ),
        ),
        _buildDateIcon(),
      ],
    );
  }

  Widget _buildDateIcon() {
    return Container(
      width: 70,
      height: 70,
      decoration: BoxDecoration(
        color: widget.primaryColor,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: widget.primaryColor.withOpacity(0.3),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Container(
            height: 8,
            decoration: BoxDecoration(
              color: widget.primaryColor.withOpacity(0.8),
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(12),
                topRight: Radius.circular(12),
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                Container(
                  width: 4,
                  height: 12,
                  margin: const EdgeInsets.only(top: -2),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.8),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                Container(
                  width: 4,
                  height: 12,
                  margin: const EdgeInsets.only(top: -2),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.8),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: Center(
              child: Text(
                '${selectedDate.day.toString().padLeft(2, '0')}',
                style: const TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMonthYearSelectors() {
    return Row(
      children: [
        Expanded(child: _buildMonthDropdown()),
        const SizedBox(width: 16),
        Expanded(child: _buildYearDropdown()),
      ],
    );
  }

  Widget _buildMonthDropdown() {
    final months = [
      'January', 'February', 'March', 'April', 'May', 'June',
      'July', 'August', 'September', 'October', 'November', 'December',
    ];

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: const Color(0xFFF5F7FA),
        borderRadius: BorderRadius.circular(12),
      ),
      child: DropdownButton<int>(
        value: currentMonth,
        isExpanded: true,
        underline: const SizedBox(),
        icon: const Icon(Icons.keyboard_arrow_down, color: Color(0xFF2C3E50)),
        style: const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w600,
          color: Color(0xFF2C3E50),
        ),
        items: List.generate(12, (index) {
          return DropdownMenuItem(
            value: index + 1,
            child: Text(months[index]),
          );
        }),
        onChanged: (value) {
          if (value != null) {
            setState(() {
              currentMonth = value;
            });
          }
        },
      ),
    );
  }

  Widget _buildYearDropdown() {
    final years = List.generate(
      widget.lastDate.year - widget.firstDate.year + 1,
      (index) => widget.firstDate.year + index,
    );

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: const Color(0xFFF5F7FA),
        borderRadius: BorderRadius.circular(12),
      ),
      child: DropdownButton<int>(
        value: currentYear,
        isExpanded: true,
        underline: const SizedBox(),
        icon: const Icon(Icons.keyboard_arrow_down, color: Color(0xFF2C3E50)),
        style: const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w600,
          color: Color(0xFF2C3E50),
        ),
        items: years.map((year) {
          return DropdownMenuItem(
            value: year,
            child: Text('$year'),
          );
        }).toList(),
        onChanged: (value) {
          if (value != null) {
            setState(() {
              currentYear = value;
            });
          }
        },
      ),
    );
  }

  Widget _buildWeekdayHeaders() {
    final weekdays = ['SUN', 'MON', 'TUE', 'WED', 'THU', 'FRI', 'SAT'];

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: weekdays.asMap().entries.map((entry) {
        final isSunday = entry.key == 0;
        return Expanded(
          child: Center(
            child: Text(
              entry.value,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w700,
                color: isSunday ? widget.primaryColor : const Color(0xFF2C3E50),
                letterSpacing: 0.5,
              ),
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildCalendarGrid() {
    final daysInMonth = DateTime(currentYear, currentMonth + 1, 0).day;
    final firstDayOfMonth = DateTime(currentYear, currentMonth, 1).weekday;
    
    // Adjust for Sunday being 0
    final startOffset = firstDayOfMonth == 7 ? 0 : firstDayOfMonth;
    
    final List<Widget> dayWidgets = [];

    // Add empty cells for days before month starts
    for (int i = 0; i < startOffset; i++) {
      final prevMonthDay = DateTime(currentYear, currentMonth, 0).day - startOffset + i + 1;
      dayWidgets.add(_buildDayCell(
        prevMonthDay,
        isCurrentMonth: false,
        date: DateTime(currentYear, currentMonth - 1, prevMonthDay),
      ));
    }

    // Add current month days
    for (int day = 1; day <= daysInMonth; day++) {
      final date = DateTime(currentYear, currentMonth, day);
      dayWidgets.add(_buildDayCell(
        day,
        isCurrentMonth: true,
        date: date,
      ));
    }

    // Add next month days to fill grid
    final remainingCells = 42 - dayWidgets.length; // 6 rows * 7 days
    for (int day = 1; day <= remainingCells && dayWidgets.length < 42; day++) {
      dayWidgets.add(_buildDayCell(
        day,
        isCurrentMonth: false,
        date: DateTime(currentYear, currentMonth + 1, day),
      ));
    }

    return GridView.count(
      crossAxisCount: 7,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      mainAxisSpacing: 8,
      crossAxisSpacing: 8,
      children: dayWidgets,
    );
  }

  Widget _buildDayCell(int day, {required bool isCurrentMonth, required DateTime date}) {
    final isSunday = date.weekday == 7;
    final isSelected = selectedDate.year == date.year &&
        selectedDate.month == date.month &&
        selectedDate.day == date.day;
    
    final isToday = DateTime.now().year == date.year &&
        DateTime.now().month == date.month &&
        DateTime.now().day == date.day;

    Color textColor;
    Color? backgroundColor;
    FontWeight fontWeight = FontWeight.normal;
    bool hasUnderline = false;

    if (!isCurrentMonth) {
      textColor = const Color(0xFFBDC3C7);
    } else if (isSelected) {
      backgroundColor = widget.primaryColor;
      textColor = Colors.white;
      fontWeight = FontWeight.bold;
      hasUnderline = true;
    } else if (isSunday) {
      textColor = widget.primaryColor;
      fontWeight = FontWeight.w600;
    } else {
      textColor = const Color(0xFF2C3E50);
      fontWeight = FontWeight.w600;
    }

    return GestureDetector(
      onTap: isCurrentMonth
          ? () {
              setState(() {
                selectedDate = date;
              });
            }
          : null,
      child: Container(
        decoration: BoxDecoration(
          color: backgroundColor,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Stack(
          children: [
            Center(
              child: Text(
                '$day',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: fontWeight,
                  color: textColor,
                ),
              ),
            ),
            if (hasUnderline)
              Positioned(
                bottom: 4,
                left: 0,
                right: 0,
                child: Center(
                  child: Container(
                    width: 20,
                    height: 2,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(1),
                    ),
                  ),
                ),
              ),
            if (isToday && !isSelected)
              Positioned(
                bottom: 4,
                left: 0,
                right: 0,
                child: Center(
                  child: Container(
                    width: 4,
                    height: 4,
                    decoration: BoxDecoration(
                      color: widget.primaryColor,
                      shape: BoxShape.circle,
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildConfirmButton() {
    return SizedBox(
      width: double.infinity,
      height: 56,
      child: ElevatedButton(
        onPressed: () {
          Navigator.of(context).pop(selectedDate);
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: widget.primaryColor,
          foregroundColor: Colors.white,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
        ),
        child: const Text(
          'Confirm',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            letterSpacing: 0.5,
          ),
        ),
      ),
    );
  }
}