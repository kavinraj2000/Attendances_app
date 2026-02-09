import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:hrm/core/helper/attendances_helper.dart';
import 'package:hrm/screens/attendances/bloc/attendances_bloc.dart';


const Color kPurpleHeader = Color(0xFF5B5FC7);
const Color kActiveCardBg = Color(0xFF5B9CF5);
const Color kInactiveCardBg = Color(0xFFF4F5F7);
const Color kTimelineLineColor = Color(0xFFDDDFE5);
const Color kTimelineNodeActive = Color(0xFF5B9CF5);
const Color kTimelineNodeInactive = Color(0xFFD0D3DB);
const Color kTitleDark = Color(0xFF1A1A2E);
const Color kSubtitleGrey = Color(0xFF8A8FA3);
const Color kLabelColor = Color(0xFF8A8FA3);
const Color kValueColor = Color(0xFF1A1A2E);
const Color kAbsentColor = Color(0xFFE53935);
const Color kPresentColor = Color(0xFF43A047);
const Color kCardBg = Color(0xFFF0F2F8);


enum AttendanceStatus { present, absent, halfDay, leave }

class AttendanceData extends Equatable {
  final DateTime date;
  final DateTime? checkInTime;
  final DateTime? checkOutTime;
  final AttendanceStatus status;

  const AttendanceData({
    required this.date,
    this.checkInTime,
    this.checkOutTime,
    required this.status,
  });

  int get totalWorkingMinutes {
    if (checkInTime == null || checkOutTime == null) return 0;

    if (checkOutTime!.isBefore(checkInTime!)) return 0;

    return checkOutTime!.difference(checkInTime!).inMinutes;
  }

  int? get extraWorkingMinutes {
    if (checkInTime == null || checkOutTime == null) return null;
    return totalWorkingMinutes - (8 * 60);
  }

  @override
  List<Object?> get props => [
        date,
        checkInTime,
        checkOutTime,
        status,
      ];
}


Future<void> showAttendancePopup(
  BuildContext context,
  AttendanceData data, {
  bool updateBlocSelection = true,
}) {
  final bloc = context.read<AttendanceLogsBloc>();

  if (updateBlocSelection) {
    bloc.add(SelectDate(data.date));
  }

  return showGeneralDialog(
    context: context,
    barrierDismissible: true,
    barrierLabel: 'Attendance Details',
    barrierColor: Colors.black.withOpacity(0.45),
    transitionDuration: const Duration(milliseconds: 280),
    transitionBuilder: (ctx, anim, _, child) {
      final curve = CurvedAnimation(parent: anim, curve: Curves.easeOutCubic);
      return SlideTransition(
        position: Tween(
          begin: const Offset(0, 0.12),
          end: Offset.zero,
        ).animate(curve),
        child: FadeTransition(opacity: curve, child: child),
      );
    },
    pageBuilder: (ctx, _, __) {
      return BlocProvider.value(
        value: bloc,
        child: AttendancePopup(data: data),
      );
    },
  ).then((_) {
    if (updateBlocSelection) {
      bloc.add(const ClearSelectedDate());
    }
  });
}

/* -------------------- FROM BLOC -------------------- */

Future<void> showAttendancePopupFromBloc(
  BuildContext context,
  DateTime date,
) {
  final bloc = context.read<AttendanceLogsBloc>();
  final state = bloc.state;

  if (state.status == AttendancesStatus.loading) {
    _showErrorSnackBar(context, 'Attendance data not loaded');
    return Future.value();
  }

  final model = state.getAttendanceForDate(date);

  if (model == null) {
    _showInfoSnackBar(
      context,
      'No attendance record for ${_formatDateShort(date)}',
    );
    return Future.value();
  }

  final data = convertToAttendanceData(model, date);
  return showAttendancePopup(context, data);
}

/* -------------------- UI -------------------- */

class AttendancePopup extends StatelessWidget {
  final AttendanceData data;
  const AttendancePopup({super.key, required this.data});

  @override
  Widget build(BuildContext context) {
    return PopScope(
      onPopInvoked: (didPop) {
        if (didPop) {
          context.read<AttendanceLogsBloc>().add(const ClearSelectedDate());
        }
      },
      child: Align(
        alignment: Alignment.center,
        child: Material(
          color: Colors.transparent,
          child: Container(
            width: MediaQuery.of(context).size.width * 0.9,
            constraints: const BoxConstraints(maxWidth: 440),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(18),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.14),
                  blurRadius: 28,
                  offset: const Offset(0, 10),
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                _PopupHeader(
                  title: 'Attendance Details',
                  onClose: () {
                    context
                        .read<AttendanceLogsBloc>()
                        .add(const ClearSelectedDate());
                    context.pop();
                  },
                ),
                _AttendanceBody(data: data),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/* -------------------- BODY -------------------- */

class _AttendanceBody extends StatelessWidget {
  final AttendanceData data;
  const _AttendanceBody({required this.data});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(22),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            _formatDate(data.date),
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: kValueColor,
            ),
          ),
          const SizedBox(height: 18),
          Row(
            children: [
              Expanded(
                child: _InfoCard(
                  label: 'CHECK IN',
                  value: _fmtNullable(data.checkInTime),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _InfoCard(
                  label: 'CHECK OUT',
                  value: _fmtNullable(data.checkOutTime),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _InfoCard(
                  label: 'TOTAL HOURS',
                  value: _totalStr(data),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _InfoCard(
                  label: 'EXTRA HOURS',
                  value: _extraStr(data),
                ),
              ),
            ],
          ),
          const SizedBox(height: 22),
          const Text(
            'STATUS',
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: kLabelColor,
            ),
          ),
          const SizedBox(height: 8),
          _StatusCard(status: data.status),
        ],
      ),
    );
  }
}


String _fmtNullable(DateTime? t) => t == null ? '--:--' : _fmtTime(t);

String _totalStr(AttendanceData data) {
  final m = data.totalWorkingMinutes;
  return '${(m ~/ 60).toString().padLeft(2, '0')}h ${(m % 60).toString().padLeft(2, '0')}m';
}

String _extraStr(AttendanceData data) {
  final e = data.extraWorkingMinutes;
  if (e == null || e <= 0) return '--';
  return '${(e ~/ 60).toString().padLeft(2, '0')}h ${(e % 60).toString().padLeft(2, '0')}m';
}

String _fmtTime(DateTime t) {
  final h = t.hour > 12 ? t.hour - 12 : (t.hour == 0 ? 12 : t.hour);
  final m = t.minute.toString().padLeft(2, '0');
  return '$h:$m ${t.hour >= 12 ? "PM" : "AM"}';
}

String _formatDate(DateTime d) =>
    '${_weekday[d.weekday - 1]}, ${_months[d.month]} ${d.day}, ${d.year}';

String _formatDateShort(DateTime d) =>
    '${_monthsShort[d.month - 1]} ${d.day}, ${d.year}';


class _StatusCard extends StatelessWidget {
  final AttendanceStatus status;
  const _StatusCard({required this.status});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: kCardBg,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Text(
        status.name.toUpperCase(),
        style: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w700,
          color: switch (status) {
            AttendanceStatus.present => kPresentColor,
            AttendanceStatus.absent => kAbsentColor,
            AttendanceStatus.halfDay => Colors.orange,
            AttendanceStatus.leave => Colors.blue,
          },
        ),
      ),
    );
  }
}

/* -------------------- CONSTANTS -------------------- */

const _months = [
  '',
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

const _monthsShort = [
  'Jan','Feb','Mar','Apr','May','Jun',
  'Jul','Aug','Sep','Oct','Nov','Dec'
];

const _weekday = [
  'Monday','Tuesday','Wednesday',
  'Thursday','Friday','Saturday','Sunday'
];


void _showErrorSnackBar(BuildContext context, String message) {
  ScaffoldMessenger.of(context)
      .showSnackBar(SnackBar(backgroundColor: Colors.red, content: Text(message)));
}

void _showInfoSnackBar(BuildContext context, String message) {
  ScaffoldMessenger.of(context)
      .showSnackBar(SnackBar(backgroundColor: kPurpleHeader, content: Text(message)));
}


class _PopupHeader extends StatelessWidget {
  final String title;
  final VoidCallback onClose;

  const _PopupHeader({required this.title, required this.onClose});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: kPurpleHeader,
      padding: const EdgeInsets.all(18),
      child: Row(
        children: [
          const Icon(Icons.calendar_month, color: Colors.white),
          const SizedBox(width: 10),
          Text(
            title,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: Colors.white,
            ),
          ),
          const Spacer(),
          GestureDetector(
            onTap: onClose,
            child: const Icon(Icons.close, color: Colors.white),
          ),
        ],
      ),
    );
  }
}

class _InfoCard extends StatelessWidget {
  final String label, value;
  const _InfoCard({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: kCardBg,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: const TextStyle(fontSize: 11)),
          const SizedBox(height: 8),
          Text(
            value,
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}

