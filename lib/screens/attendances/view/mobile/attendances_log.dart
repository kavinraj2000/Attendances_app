import 'package:flutter/material.dart';
import 'package:hrm/screens/attendances/provoider/attendance_log_provoider.dart';
import 'package:provider/provider.dart';
import 'package:hrm/core/enum/attendance_status.dart';
import 'package:hrm/core/model/attances_model.dart';
import 'package:hrm/core/util/attendance_util.dart';

class AttendanceLogsScreen extends StatelessWidget {
  const AttendanceLogsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final status = context.select<AttendanceLogProvider, AttendanceLogStatus>(
      (p) => p.status,
    );

    return Scaffold(
      backgroundColor: Colors.white,
      body: () {
        if (status == AttendanceLogStatus.loading) {
          return const Center(
            child: CircularProgressIndicator(color: _kAccent, strokeWidth: 2.5),
          );
        }

        if (status == AttendanceLogStatus.error) {
          return _ErrorView(
            message:
                context.read<AttendanceLogProvider>().errorMessage ??
                'Something went wrong',
            onRetry: () {
              final p = context.read<AttendanceLogProvider>();
              p.loadAttendanceLogs(month: p.currentMonth, year: p.currentYear);
            },
          );
        }

        return const SafeArea(
          child: Column(
            children: [
              _TopBarWidget(),
              _CalendarCardWidget(),
              SizedBox(height: 4),
              Expanded(child: _DayDetailPanelWidget()),
            ],
          ),
        );
      }(),
    );
  }
}

class _TopBarWidget extends StatelessWidget {
  const _TopBarWidget();

  @override
  Widget build(BuildContext context) {
    final month = context.select<AttendanceLogProvider, int>(
      (p) => p.currentMonth,
    );
    final year = context.select<AttendanceLogProvider, int>(
      (p) => p.currentYear,
    );

    final isBusy = context.select<AttendanceLogProvider, bool>(
      (p) => p.isChangingMonth,
    );

    return _TopBar(
      month: month,
      year: year,
      isBusy: isBusy,
      onPrev: isBusy
          ? null
          : () {
              final p = context.read<AttendanceLogProvider>();
              p.changeMonth(DateTime(p.currentYear, p.currentMonth - 1, 1));
            },
      onNext: isBusy
          ? null
          : () {
              final p = context.read<AttendanceLogProvider>();
              p.changeMonth(DateTime(p.currentYear, p.currentMonth + 1, 1));
            },
    );
  }
}

class _CalendarCardWidget extends StatelessWidget {
  const _CalendarCardWidget();

  @override
  Widget build(BuildContext context) {
    final month = context.select<AttendanceLogProvider, int>(
      (p) => p.currentMonth,
    );
    final year = context.select<AttendanceLogProvider, int>(
      (p) => p.currentYear,
    );
    final records = context
        .select<AttendanceLogProvider, List<AttendanceModel>>(
          (p) => p.scheduleData,
        );
    final selectedDay = context.select<AttendanceLogProvider, DateTime>(
      (p) => p.selectedDate ?? DateTime.now(),
    );

    final isChangingMonth = context.select<AttendanceLogProvider, bool>(
      (p) => p.isChangingMonth,
    );

    return Stack(
      children: [
        _CalendarCard(
          month: month,
          year: year,
          records: records,
          selectedDay: selectedDay,
          onDaySelected: (d) =>
              context.read<AttendanceLogProvider>().selectDate(d),
        ),

        AnimatedOpacity(
          opacity: isChangingMonth ? 1.0 : 0.0,
          duration: const Duration(milliseconds: 200),
          child: IgnorePointer(
            ignoring: !isChangingMonth,
            child: Container(
              margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.75),
                borderRadius: BorderRadius.circular(24),
              ),
              height: 300,
              child: const Center(
                child: CircularProgressIndicator(
                  color: _kAccent,
                  strokeWidth: 2,
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _DayDetailPanelWidget extends StatelessWidget {
  const _DayDetailPanelWidget();

  @override
  Widget build(BuildContext context) {
    final selectedDay = context.select<AttendanceLogProvider, DateTime>(
      (p) => p.selectedDate ?? DateTime.now(),
    );
    final selectedRecord = context
        .select<AttendanceLogProvider, AttendanceModel?>(
          (p) => p.recordForDate(p.selectedDate ?? DateTime.now()),
        );
    final summary = context
        .select<AttendanceLogProvider, Map<AttendanceStatus, int>>(
          (p) => p.summary,
        );

    return _DayDetailPanel(
      selectedDay: selectedDay,
      selectedRecord: selectedRecord,
      summary: summary,
    );
  }
}

class _ErrorView extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;

  const _ErrorView({required this.message, required this.onRetry});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(22),
              decoration: BoxDecoration(
                color: const Color(0xFFF44336).withOpacity(0.08),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.wifi_off_rounded,
                size: 38,
                color: Color(0xFFF44336),
              ),
            ),
            const SizedBox(height: 16),
            Text(
              message,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 14,
                color: _kSub,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 20),
            ElevatedButton.icon(
              onPressed: onRetry,
              icon: const Icon(Icons.refresh_rounded, size: 18),
              label: const Text('Retry'),
              style: ElevatedButton.styleFrom(
                backgroundColor: _kAccent,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30),
                ),
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 12,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _TopBar extends StatelessWidget {
  final int month, year;
  final bool isBusy;
  final VoidCallback? onPrev;
  final VoidCallback? onNext;

  const _TopBar({
    required this.month,
    required this.year,
    required this.isBusy,
    required this.onPrev,
    required this.onNext,
  });

  @override
  Widget build(BuildContext context) {
    final monthName = AttendanceUtils.getMonthName(month);
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 14, 20, 6),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 9),
            decoration: BoxDecoration(
              color: _kCard,
              borderRadius: BorderRadius.circular(30),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(
                  Icons.calendar_month_outlined,
                  size: 16,
                  color: _kText,
                ),
                const SizedBox(width: 6),
                AnimatedSwitcher(
                  duration: const Duration(milliseconds: 250),
                  transitionBuilder: (child, animation) =>
                      FadeTransition(opacity: animation, child: child),
                  child: Text(
                    '$monthName  $year',
                    key: ValueKey('$month-$year'),
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      color: _kText,
                    ),
                  ),
                ),
                const SizedBox(width: 4),
              ],
            ),
          ),
          const Spacer(),
          AnimatedOpacity(
            opacity: isBusy ? 0.4 : 1.0,
            duration: const Duration(milliseconds: 200),
            child: Row(
              children: [
                _NavBtn(icon: Icons.chevron_left_rounded, onTap: onPrev),
                const SizedBox(width: 8),
                _NavBtn(icon: Icons.chevron_right_rounded, onTap: onNext),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _NavBtn extends StatelessWidget {
  final IconData icon;
  final VoidCallback? onTap;

  const _NavBtn({required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 36,
        height: 36,
        decoration: BoxDecoration(
          color: _kCard,
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.06),
              blurRadius: 6,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Icon(icon, size: 20, color: _kText),
      ),
    );
  }
}

class _CalendarCard extends StatelessWidget {
  final int month, year;
  final List<AttendanceModel> records;
  final DateTime selectedDay;
  final ValueChanged<DateTime> onDaySelected;

  const _CalendarCard({
    required this.month,
    required this.year,
    required this.records,
    required this.selectedDay,
    required this.onDaySelected,
  });

  static const _headers = ['M', 'T', 'W', 'T', 'F', 'S', 'S'];

  @override
  Widget build(BuildContext context) {
    final firstWeekday = DateTime(year, month, 1).weekday;
    final startOffset = firstWeekday - 1;
    final daysInMonth = DateTime(year, month + 1, 0).day;
    final now = DateTime.now();

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      padding: const EdgeInsets.fromLTRB(12, 16, 12, 14),
      decoration: BoxDecoration(
        color: _kCard,
        borderRadius: BorderRadius.circular(24),
      ),
      child: Column(
        children: [
          Row(
            children: _headers.asMap().entries.map((e) {
              final isWknd = e.key == 5 || e.key == 6;
              return Expanded(
                child: Center(
                  child: Text(
                    e.value,
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: isWknd ? _kWeekend.withOpacity(0.6) : _kSub,
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
          const SizedBox(height: 8),
          AnimatedSwitcher(
            duration: const Duration(milliseconds: 300),
            transitionBuilder: (child, animation) =>
                FadeTransition(opacity: animation, child: child),
            child: KeyedSubtree(
              key: ValueKey('$month-$year'),
              child: _buildGrid(startOffset, daysInMonth, now),
            ),
          ),
          const SizedBox(height: 10),
          Container(
            width: 36,
            height: 4,
            decoration: BoxDecoration(
              color: const Color(0xFFE0E0EA),
              borderRadius: BorderRadius.circular(2),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGrid(int startOffset, int daysInMonth, DateTime now) {
    final totalCells = startOffset + daysInMonth;
    final rows = (totalCells / 7).ceil();

    return Column(
      children: List.generate(rows, (r) {
        return Row(
          children: List.generate(7, (c) {
            final cellIdx = r * 7 + c;
            final dayNum = cellIdx - startOffset + 1;

            if (cellIdx < startOffset || dayNum > daysInMonth) {
              return const Expanded(child: SizedBox(height: 52));
            }

            final date = DateTime(year, month, dayNum);
            final isToday =
                date.year == now.year &&
                date.month == now.month &&
                date.day == now.day;
            final isSelected =
                date.year == selectedDay.year &&
                date.month == selectedDay.month &&
                date.day == selectedDay.day;
            final isFuture = date.isAfter(now);
            final isWeekend =
                date.weekday == DateTime.saturday ||
                date.weekday == DateTime.sunday;
            final record = _findRecord(date);
            final dotColor = record != null
                ? _statusColor(record.attendanceStatus!)
                : null;

            return Expanded(
              child: GestureDetector(
                onTap: isFuture ? null : () => onDaySelected(date),
                child: SizedBox(
                  height: 52,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      AnimatedContainer(
                        duration: const Duration(milliseconds: 180),
                        width: 36,
                        height: 36,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: isSelected
                              ? _kAccent
                              : isToday
                              ? _kAccent.withOpacity(0.13)
                              : Colors.transparent,
                          border: isToday && !isSelected
                              ? Border.all(
                                  color: _kAccent.withOpacity(0.45),
                                  width: 1.5,
                                )
                              : null,
                        ),
                        child: Center(
                          child: Text(
                            '$dayNum',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: isSelected || isToday
                                  ? FontWeight.w700
                                  : FontWeight.w500,
                              color: isSelected
                                  ? Colors.white
                                  : isFuture
                                  ? const Color(0xFFCCCCDD)
                                  : isWeekend
                                  ? _kWeekend
                                  : _kText,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 2),
                      if (dotColor != null)
                        Container(
                          width: 4,
                          height: 4,
                          decoration: BoxDecoration(
                            color: isSelected ? Colors.white60 : dotColor,
                            shape: BoxShape.circle,
                          ),
                        )
                      else
                        const SizedBox(height: 4),
                    ],
                  ),
                ),
              ),
            );
          }),
        );
      }),
    );
  }

  AttendanceModel? _findRecord(DateTime date) {
    for (final r in records) {
      try {
        final d = DateTime.parse(r.attendanceDate.toString());
        if (d.year == date.year && d.month == date.month && d.day == date.day) {
          return r;
        }
      } catch (_) {}
    }
    return null;
  }
}

class _DayDetailPanel extends StatelessWidget {
  final DateTime selectedDay;
  final AttendanceModel? selectedRecord;
  final Map<AttendanceStatus, int> summary;

  const _DayDetailPanel({
    required this.selectedDay,
    required this.selectedRecord,
    required this.summary,
  });

  static const _weekdays = [
    'Monday',
    'Tuesday',
    'Wednesday',
    'Thursday',
    'Friday',
    'Saturday',
    'Sunday',
  ];
  static const _months = [
    'January',
    'February',
    'March',
    'April',
    'May',
    'June',
    'July',
    'August',
    'September',
    'October',
    'November',
    'December',
  ];

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    final isToday =
        selectedDay.year == now.year &&
        selectedDay.month == now.month &&
        selectedDay.day == now.day;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(22, 10, 22, 10),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '${selectedDay.day}',
                    style: const TextStyle(
                      fontSize: 38,
                      fontWeight: FontWeight.w800,
                      color: _kText,
                      height: 1,
                    ),
                  ),
                  Text(
                    _weekdays[selectedDay.weekday - 1],
                    style: const TextStyle(
                      fontSize: 12,
                      color: _kSub,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
              const SizedBox(width: 14),
              Padding(
                padding: const EdgeInsets.only(bottom: 4),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      isToday ? 'Today' : _months[selectedDay.month - 1],
                      style: const TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.w700,
                        color: _kText,
                      ),
                    ),
                    if (selectedRecord != null)
                      Text(
                        selectedRecord!.attendanceStatus.toString(),
                        style: TextStyle(
                          fontSize: 12,
                          color: _statusColor(
                            selectedRecord!.attendanceStatus!,
                          ),
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                  ],
                ),
              ),
              const Spacer(),
            ],
          ),
        ),
        Expanded(
          child: selectedRecord == null
              ? _EmptyDay(isToday: isToday)
              : ListView(
                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 20),
                  children: [
                    _AttendanceRecordTile(record: selectedRecord!),
                    const SizedBox(height: 14),
                  ],
                ),
        ),
      ],
    );
  }
}

class _AttendanceRecordTile extends StatelessWidget {
  final AttendanceModel record;

  const _AttendanceRecordTile({required this.record});

  @override
  Widget build(BuildContext context) {
    final color = _statusColor(record.attendanceStatus!);
    final checkIn = _fmtTime(record.checkinTime?.toString());
    final checkOut = _fmtTime(record.checkoutTime?.toString());

    return Container(
      decoration: BoxDecoration(
        color: _kCard,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 12,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.fromLTRB(16, 14, 16, 12),
            decoration: BoxDecoration(
              color: color.withOpacity(0.07),
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(18),
              ),
            ),
            child: Row(
              children: [
                Container(
                  width: 8,
                  height: 8,
                  decoration: BoxDecoration(
                    color: color,
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  record.attendanceStatus.toString(),
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    color: color,
                    letterSpacing: 0.5,
                  ),
                ),
                const Spacer(),
                const Icon(Icons.more_horiz, color: _kSub, size: 20),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 14, 16, 16),
            child: Row(
              children: [
                _TimeChip(
                  label: 'Check In',
                  time: checkIn,
                  icon: Icons.login_rounded,
                  color: const Color(0xFF4CAF50),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  child: Container(
                    width: 24,
                    height: 1,
                    color: const Color(0xFFE0E0EA),
                  ),
                ),
                _TimeChip(
                  label: 'Check Out',
                  time: checkOut,
                  icon: Icons.logout_rounded,
                  color: const Color(0xFFF44336),
                ),
                const Spacer(),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      _duration(
                        record.checkinTime?.toString(),
                        record.checkoutTime?.toString(),
                      ),
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w800,
                        color: _kText,
                      ),
                    ),
                    const Text(
                      'hrs worked',
                      style: TextStyle(fontSize: 9, color: _kSub),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _fmtTime(String? raw) {
    if (raw == null || raw.isEmpty || raw == 'null') return '--:--';
    try {
      final dt = DateTime.parse(raw);
      final h = dt.hour % 12 == 0 ? 12 : dt.hour % 12;
      final m = dt.minute.toString().padLeft(2, '0');
      final p = dt.hour < 12 ? 'AM' : 'PM';
      return '$h:$m $p';
    } catch (_) {
      return raw;
    }
  }

  String _duration(String? inRaw, String? outRaw) {
    if (inRaw == null || outRaw == null || inRaw == 'null' || outRaw == 'null')
      return '--';
    try {
      final inTime = DateTime.parse(inRaw);
      final outTime = DateTime.parse(outRaw);
      final mins = outTime.difference(inTime).inMinutes;
      if (mins <= 0) return '--';
      final h = mins ~/ 60;
      final m = mins % 60;
      return '$h.${(m / 6).round()}';
    } catch (_) {
      return '--';
    }
  }
}

class _TimeChip extends StatelessWidget {
  final String label, time;
  final IconData icon;
  final Color color;

  const _TimeChip({
    required this.label,
    required this.time,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, size: 11, color: color),
            const SizedBox(width: 4),
            Text(
              label,
              style: const TextStyle(
                fontSize: 10,
                color: _kSub,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
        const SizedBox(height: 3),
        Text(
          time,
          style: const TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w700,
            color: _kText,
          ),
        ),
      ],
    );
  }
}

class _EmptyDay extends StatelessWidget {
  final bool isToday;

  const _EmptyDay({required this.isToday});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(22),
            decoration: BoxDecoration(
              color: _kAccent.withOpacity(0.08),
              shape: BoxShape.circle,
            ),
            child: Icon(
              isToday ? Icons.login_rounded : Icons.event_busy_rounded,
              size: 38,
              color: _kAccent.withOpacity(0.6),
            ),
          ),
          const SizedBox(height: 14),
          Text(
            isToday ? 'No check-in yet today' : 'No record for this day',
            style: const TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w600,
              color: _kSub,
            ),
          ),
        ],
      ),
    );
  }
}

const _kCard = Colors.white;
const _kAccent = Color(0xFFFF6B4A);
const _kText = Color(0xFF1A1A2E);
const _kSub = Color(0xFF9E9EAF);
const _kWeekend = Color(0xFFFF6B4A);

Color _statusColor(AttendanceStatus status) {
  switch (status) {
    case AttendanceStatus.present:
      return const Color(0xFF4CAF50);
    case AttendanceStatus.absent:
      return const Color(0xFFF44336);
    case AttendanceStatus.halfDay:
      return const Color(0xFFFF9800);
    case AttendanceStatus.pending:
      return const Color(0xFF2196F3);
    case AttendanceStatus.leave:
      return const Color(0xFF9C27B0);
    case AttendanceStatus.unknown:
      return _kSub;
  }
}
