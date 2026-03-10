import 'package:flutter/material.dart';
import 'package:hrm/core/enum/week_days.dart';
import 'package:hrm/screens/attendances/provoider/attendance_log_provoider.dart';
import 'package:provider/provider.dart';
import 'package:hrm/core/enum/attendance_status.dart';
import 'package:hrm/core/model/attances_model.dart';
import 'package:hrm/core/util/attendance_util.dart';

// ─── Design tokens ─────────────────────────────────────────────────────────
const _kBg = Color(0xFFFAFAFA);
const _kCard = Colors.white;
const _kAccent = Color(0xFFFF6B4A);
const _kAccentSoft = Color(0xFFFFF0ED);
const _kText = Color(0xFF111111);
const _kTextMid = Color(0xFF555566);
const _kSub = Color(0xFFB0B0BE);
const _kBorder = Color(0xFFF0F0F5);
const _kWeekend = Color(0xFFFF6B4A);

Color _statusColor(AttendanceStatus s) => switch (s) {
  AttendanceStatus.present => const Color(0xFF00C48C),
  AttendanceStatus.absent => const Color(0xFFFF4D4D),
  AttendanceStatus.halfDay => const Color(0xFFFFAA00),
  AttendanceStatus.pending => const Color(0xFF4E9EFF),
  AttendanceStatus.leave => const Color(0xFFAA7EFF),
  AttendanceStatus.unknown => _kSub,
};

// ─── Root screen ─────────────────────────────────────────────────────────────
class AttendanceLogsScreen extends StatelessWidget {
  const AttendanceLogsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final status = context.select<AttendanceLogProvider, AttendanceLogStatus>(
      (p) => p.status,
    );

    return Scaffold(
      backgroundColor: _kBg,
      body: switch (status) {
        AttendanceLogStatus.loading => const Center(
          child: CircularProgressIndicator(color: _kAccent, strokeWidth: 1.5),
        ),
        AttendanceLogStatus.error => _ErrorView(
          message:
              context.read<AttendanceLogProvider>().errorMessage ??
              'Something went wrong',
          onRetry: () {
            final p = context.read<AttendanceLogProvider>();
            p.loadAttendanceLogs(month: p.currentMonth, year: p.currentYear);
          },
        ),
        _ => const SafeArea(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _TopBarWidget(),
              _CalendarCardWidget(),
              SizedBox(height: 4),
              Expanded(child: _DayDetailPanelWidget()),
            ],
          ),
        ),
      },
    );
  }
}

// ─── Provider-connected widgets ───────────────────────────────────────────────
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
              p.changeMonth(DateTime(p.currentYear, p.currentMonth - 1));
            },
      onNext: isBusy
          ? null
          : () {
              final p = context.read<AttendanceLogProvider>();
              p.changeMonth(DateTime(p.currentYear, p.currentMonth + 1));
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
    final selected = context.select<AttendanceLogProvider, DateTime>(
      (p) => p.selectedDate ?? DateTime.now(),
    );
    final changing = context.select<AttendanceLogProvider, bool>(
      (p) => p.isChangingMonth,
    );

    return Stack(
      children: [
        _CalendarCard(
          month: month,
          year: year,
          records: records,
          selectedDay: selected,
          onDaySelected: (d) =>
              context.read<AttendanceLogProvider>().selectDate(d),
        ),
        if (changing)
          Positioned.fill(
            child: Container(
              margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.82),
                borderRadius: BorderRadius.circular(20),
              ),
              child: const Center(
                child: CircularProgressIndicator(
                  color: _kAccent,
                  strokeWidth: 1.5,
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
    final selected = context.select<AttendanceLogProvider, DateTime>(
      (p) => p.selectedDate ?? DateTime.now(),
    );
    final record = context.select<AttendanceLogProvider, AttendanceModel?>(
      (p) => p.recordForDate(p.selectedDate ?? DateTime.now()),
    );
    final summary = context
        .select<AttendanceLogProvider, Map<AttendanceStatus, int>>(
          (p) => p.summary,
        );
    return _DayDetailPanel(
      selectedDay: selected,
      selectedRecord: record,
      summary: summary,
    );
  }
}

// ─── Top bar ──────────────────────────────────────────────────────────────────
class _TopBar extends StatelessWidget {
  final int month, year;
  final bool isBusy;
  final VoidCallback? onPrev, onNext;

  const _TopBar({
    required this.month,
    required this.year,
    required this.isBusy,
    required this.onPrev,
    required this.onNext,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Attendance',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w800,
                  color: _kText,
                  letterSpacing: -0.5,
                  height: 1.1,
                ),
              ),
              const SizedBox(height: 2),
              AnimatedSwitcher(
                duration: const Duration(milliseconds: 220),
                transitionBuilder: (c, a) =>
                    FadeTransition(opacity: a, child: c),
                child: Text(
                  '${AttendanceUtils.getMonthName(month)} $year',
                  key: ValueKey('$month-$year'),
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                    color: _kSub,
                    letterSpacing: 0.1,
                  ),
                ),
              ),
            ],
          ),
          const Spacer(),
          AnimatedOpacity(
            opacity: isBusy ? 0.3 : 1.0,
            duration: const Duration(milliseconds: 180),
            child: Row(
              children: [
                _NavBtn(icon: Icons.chevron_left_rounded, onTap: onPrev),
                const SizedBox(width: 6),
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
        width: 32,
        height: 32,
        decoration: BoxDecoration(
          color: _kCard,
          shape: BoxShape.circle,
          border: Border.all(color: _kBorder, width: 1.2),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 6,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Icon(icon, size: 16, color: _kTextMid),
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

  // ✅ Derived from WeekDay enum instead of hardcoded strings
  static final _hdrs = WeekDay.values.map((d) => d.shortName).toList();

  @override
  Widget build(BuildContext context) {
    final firstWeekday = DateTime(year, month, 1).weekday - 1;
    final daysInMonth = DateTime(year, month + 1, 0).day;
    final now = DateTime.now();

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      padding: const EdgeInsets.fromLTRB(12, 14, 12, 12),
      decoration: BoxDecoration(
        color: _kCard,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: _kBorder, width: 1),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 20,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            children: _hdrs.asMap().entries.map((e) {
              // ✅ Using WeekDay.values index to check weekend
              final isWknd = WeekDay.values[e.key].isWeekend;
              return Expanded(
                child: Center(
                  child: Text(
                    e.value,
                    style: TextStyle(
                      fontSize: 9,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 0.4,
                      color: isWknd ? _kWeekend.withOpacity(0.6) : _kSub,
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
          const SizedBox(height: 8),
          Container(height: 0.5, color: _kBorder),
          const SizedBox(height: 6),
          AnimatedSwitcher(
            duration: const Duration(milliseconds: 280),
            transitionBuilder: (c, a) => FadeTransition(opacity: a, child: c),
            child: KeyedSubtree(
              key: ValueKey('$month-$year'),
              child: _CalendarGrid(
                firstWeekday: firstWeekday,
                daysInMonth: daysInMonth,
                month: month,
                year: year,
                now: now,
                selectedDay: selectedDay,
                records: records,
                onDaySelected: onDaySelected,
              ),
            ),
          ),
          const SizedBox(height: 8),
          Center(
            child: Container(
              width: 32,
              height: 3,
              decoration: BoxDecoration(
                color: _kBorder,
                borderRadius: BorderRadius.circular(4),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _CalendarGrid extends StatelessWidget {
  final int firstWeekday, daysInMonth, month, year;
  final DateTime now, selectedDay;
  final List<AttendanceModel> records;
  final ValueChanged<DateTime> onDaySelected;

  const _CalendarGrid({
    required this.firstWeekday,
    required this.daysInMonth,
    required this.month,
    required this.year,
    required this.now,
    required this.selectedDay,
    required this.records,
    required this.onDaySelected,
  });

  AttendanceModel? _record(DateTime d) {
    for (final r in records) {
      try {
        final rd = DateTime.parse(r.attendanceDate.toString());
        if (rd.year == d.year && rd.month == d.month && rd.day == d.day)
          return r;
      } catch (_) {}
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    final rows = ((firstWeekday + daysInMonth) / 7).ceil();
    return Column(
      children: List.generate(
        rows,
        (r) => Row(
          children: List.generate(7, (c) {
            final idx = r * 7 + c;
            final day = idx - firstWeekday + 1;
            if (idx < firstWeekday || day > daysInMonth) {
              return const Expanded(child: SizedBox(height: 40));
            }
            final date = DateTime(year, month, day);
            final isToday =
                date.year == now.year &&
                date.month == now.month &&
                date.day == now.day;
            final isSel =
                date.year == selectedDay.year &&
                date.month == selectedDay.month &&
                date.day == selectedDay.day;
            final isFuture = date.isAfter(now);
            // ✅ Using WeekDay enum instead of date.weekday >= 6
            final isWknd = WeekDay.fromDateTime(date).isWeekend;
            final rec = _record(date);
            final dotColor = rec != null
                ? _statusColor(rec.attendanceStatus!)
                : null;

            return Expanded(
              child: GestureDetector(
                onTap: isFuture ? null : () => onDaySelected(date),
                child: SizedBox(
                  height: 40,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      AnimatedContainer(
                        duration: const Duration(milliseconds: 180),
                        width: 28,
                        height: 28,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: isSel
                              ? _kAccent
                              : isToday
                              ? _kAccentSoft
                              : Colors.transparent,
                          border: isToday && !isSel
                              ? Border.all(
                                  color: _kAccent.withOpacity(0.35),
                                  width: 1,
                                )
                              : null,
                        ),
                        child: Center(
                          child: Text(
                            '$day',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: isSel || isToday
                                  ? FontWeight.w700
                                  : FontWeight.w500,
                              color: isSel
                                  ? Colors.white
                                  : isFuture
                                  ? _kBorder
                                  : isWknd
                                  ? _kWeekend
                                  : _kText,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 2),
                      dotColor != null
                          ? Container(
                              width: 3.5,
                              height: 3.5,
                              decoration: BoxDecoration(
                                color: isSel
                                    ? Colors.white.withOpacity(0.7)
                                    : dotColor,
                                shape: BoxShape.circle,
                              ),
                            )
                          : const SizedBox(height: 3.5),
                    ],
                  ),
                ),
              ),
            );
          }),
        ),
      ),
    );
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

  static const _mn = [
    'January', 'February', 'March', 'April',
    'May', 'June', 'July', 'August',
    'September', 'October', 'November', 'December',
  ];

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    final isToday =
        selectedDay.year == now.year &&
        selectedDay.month == now.month &&
        selectedDay.day == now.day;

    // ✅ Using WeekDay enum for display name
    final weekDayName = WeekDay.fromDateTime(selectedDay).displayName;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 10, 20, 0),
          child: Row(
            children: [
              const SizedBox(width: 8),
            ],
          ),
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 6, 20, 4),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Container(
                width: 3,
                height: 16,
                decoration: BoxDecoration(
                  color: _kAccent,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(width: 8),
              Text(
                '${selectedDay.day}',
                style: const TextStyle(
                  fontSize: 40,
                  fontWeight: FontWeight.w800,
                  color: _kText,
                  height: 1,
                  letterSpacing: -1,
                ),
              ),
              const SizedBox(width: 10),
              Padding(
                padding: const EdgeInsets.only(bottom: 4),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      isToday ? 'Today' : _mn[selectedDay.month - 1],
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        color: _kText,
                        height: 1.1,
                      ),
                    ),
                    // ✅ Fixed: using WeekDay enum displayName
                    Text(
                      weekDayName,
                      style: const TextStyle(
                        fontSize: 11,
                        color: _kAccent,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
              if (selectedRecord != null) ...[
                const Spacer(),
                _StatusBadge(status: selectedRecord!.attendanceStatus!),
              ],
            ],
          ),
        ),

        Container(
          margin: const EdgeInsets.symmetric(horizontal: 20),
          height: 0.5,
          color: _kBorder,
        ),
        const SizedBox(height: 6),
        Expanded(
          child: selectedRecord == null
              ? _EmptyDay(isToday: isToday)
              : ListView(
                  padding: const EdgeInsets.fromLTRB(16, 4, 16, 20),
                  children: [_AttendanceRecordTile(record: selectedRecord!)],
                ),
        ),
      ],
    );
  }
}

class _StatusBadge extends StatelessWidget {
  final AttendanceStatus status;
  const _StatusBadge({required this.status});

  @override
  Widget build(BuildContext context) {
    final color = _statusColor(status);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: color.withOpacity(0.08),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 5,
            height: 5,
            decoration: BoxDecoration(color: color, shape: BoxShape.circle),
          ),
          const SizedBox(width: 5),
          Text(
            status.toString(),
            style: TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.w700,
              color: color,
              letterSpacing: 0.3,
            ),
          ),
        ],
      ),
    );
  }
}

class _SummaryRow extends StatelessWidget {
  final Map<AttendanceStatus, int> summary;
  const _SummaryRow({required this.summary});

  @override
  Widget build(BuildContext context) {
    final items = summary.entries.where((e) => e.value > 0).take(5).toList();
    return SizedBox(
      height: 30,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 20),
        itemCount: items.length,
        separatorBuilder: (_, __) => const SizedBox(width: 6),
        itemBuilder: (_, i) {
          final e = items[i];
          final c = _statusColor(e.key);
          return Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
            decoration: BoxDecoration(
              color: c.withOpacity(0.07),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 4,
                  height: 4,
                  decoration: BoxDecoration(color: c, shape: BoxShape.circle),
                ),
                const SizedBox(width: 5),
                Text(
                  '${e.value}  ${e.key.toString()}',
                  style: TextStyle(
                    fontSize: 9.5,
                    fontWeight: FontWeight.w600,
                    color: c,
                    letterSpacing: 0.2,
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

class _AttendanceRecordTile extends StatelessWidget {
  final AttendanceModel record;
  const _AttendanceRecordTile({required this.record});

  String _fmt(String? raw) {
    if (raw == null || raw.isEmpty || raw == 'null') return '--:--';
    try {
      final dt = DateTime.parse(raw);
      final h = dt.hour % 12 == 0 ? 12 : dt.hour % 12;
      final m = dt.minute.toString().padLeft(2, '0');
      return '$h:$m ${dt.hour < 12 ? 'AM' : 'PM'}';
    } catch (_) {
      return raw;
    }
  }

  String _dur(String? i, String? o) {
    if (i == null || o == null || i == 'null' || o == 'null') return '--';
    try {
      final mins = DateTime.parse(o).difference(DateTime.parse(i)).inMinutes;
      if (mins <= 0) return '--';
      return '${mins ~/ 60}h ${mins % 60}m';
    } catch (_) {
      return '--';
    }
  }

  @override
  Widget build(BuildContext context) {
    final color = _statusColor(record.attendanceStatus!);
    final checkIn = _fmt(record.checkinTime?.toString());
    final checkOut = _fmt(record.checkoutTime?.toString());
    final dur = _dur(
      record.checkinTime?.toString(),
      record.checkoutTime?.toString(),
    );

    return Container(
      decoration: BoxDecoration(
        color: _kCard,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: _kBorder, width: 1),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            decoration: BoxDecoration(
              color: color.withOpacity(0.05),
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(16),
              ),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        width: 5,
                        height: 5,
                        decoration: BoxDecoration(
                          color: color,
                          shape: BoxShape.circle,
                        ),
                      ),
                      const SizedBox(width: 5),
                      Text(
                        record.attendanceStatus.toString(),
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.w700,
                          color: color,
                          letterSpacing: 0.3,
                        ),
                      ),
                    ],
                  ),
                ),
                const Spacer(),
                RichText(
                  text: TextSpan(
                    children: [
                      TextSpan(
                        text: dur,
                        style: const TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w800,
                          color: _kText,
                        ),
                      ),
                      const TextSpan(
                        text: '  worked',
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.w500,
                          color: _kSub,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          Container(height: 0.5, color: _kBorder),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
            child: Row(
              children: [
                _TimeBlock(
                  label: 'Check In',
                  time: checkIn,
                  icon: Icons.login_rounded,
                  color: const Color(0xFF00C48C),
                ),
                Expanded(
                  child: Center(
                    child: Container(
                      height: 1,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            const Color(0xFF00C48C).withOpacity(0.4),
                            const Color(0xFFFF4D4D).withOpacity(0.4),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
                _TimeBlock(
                  label: 'Check Out',
                  time: checkOut,
                  icon: Icons.logout_rounded,
                  color: const Color(0xFFFF4D4D),
                  right: true,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _TimeBlock extends StatelessWidget {
  final String label, time;
  final IconData icon;
  final Color color;
  final bool right;

  const _TimeBlock({
    required this.label,
    required this.time,
    required this.icon,
    required this.color,
    this.right = false,
  });

  @override
  Widget build(BuildContext context) {
    final labelRow = Row(
      mainAxisSize: MainAxisSize.min,
      children: right
          ? [
              Text(
                label,
                style: const TextStyle(
                  fontSize: 9.5,
                  color: _kSub,
                  fontWeight: FontWeight.w500,
                  letterSpacing: 0.3,
                ),
              ),
              const SizedBox(width: 4),
              Icon(icon, size: 10, color: color),
            ]
          : [
              Icon(icon, size: 10, color: color),
              const SizedBox(width: 4),
              Text(
                label,
                style: const TextStyle(
                  fontSize: 9.5,
                  color: _kSub,
                  fontWeight: FontWeight.w500,
                  letterSpacing: 0.3,
                ),
              ),
            ],
    );
    return Column(
      crossAxisAlignment: right
          ? CrossAxisAlignment.end
          : CrossAxisAlignment.start,
      children: [
        labelRow,
        const SizedBox(height: 4),
        Text(
          time,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w800,
            color: _kText,
            letterSpacing: -0.5,
            height: 1,
          ),
        ),
      ],
    );
  }
}

// ─── Empty day ────────────────────────────────────────────────────────────────
class _EmptyDay extends StatelessWidget {
  final bool isToday;
  const _EmptyDay({required this.isToday});

  @override
  Widget build(BuildContext context) => Center(
    child: Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Container(
          width: 56,
          height: 56,
          decoration: const BoxDecoration(
            color: _kAccentSoft,
            shape: BoxShape.circle,
          ),
          child: Icon(
            isToday ? Icons.login_rounded : Icons.event_busy_rounded,
            size: 22,
            color: Color(0xFFFF6B4A),
          ),
        ),
        const SizedBox(height: 12),
        Text(
          isToday ? 'No check-in yet today' : 'No record for this day',
          style: const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: _kSub,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          isToday
              ? 'Check in when you arrive'
              : 'This day has no attendance data',
          style: const TextStyle(
            fontSize: 10,
            color: _kSub,
            fontWeight: FontWeight.w400,
          ),
        ),
      ],
    ),
  );
}

// ─── Error view ───────────────────────────────────────────────────────────────
class _ErrorView extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;
  const _ErrorView({required this.message, required this.onRetry});

  @override
  Widget build(BuildContext context) => Center(
    child: Padding(
      padding: const EdgeInsets.symmetric(horizontal: 32),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              color: const Color(0xFFFF4D4D).withOpacity(0.07),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.wifi_off_rounded,
              size: 24,
              color: Color(0xFFFF4D4D),
            ),
          ),
          const SizedBox(height: 14),
          Text(
            message,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 12,
              color: _kTextMid,
              fontWeight: FontWeight.w500,
              height: 1.5,
            ),
          ),
          const SizedBox(height: 18),
          GestureDetector(
            onTap: onRetry,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 10),
              decoration: BoxDecoration(
                color: _kAccent,
                borderRadius: BorderRadius.circular(28),
                boxShadow: [
                  BoxShadow(
                    color: _kAccent.withOpacity(0.28),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: const Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.refresh_rounded, size: 14, color: Colors.white),
                  SizedBox(width: 6),
                  Text(
                    'Try again',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                      letterSpacing: 0.2,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    ),
  );
}