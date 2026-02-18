import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:hrm/core/helper/attendances_helper.dart';
import 'package:hrm/core/model/attances_model.dart';
import 'package:hrm/screens/attendances/bloc/attendances_bloc.dart';
import 'package:logger/logger.dart';

/* -------------------- COLORS -------------------- */

const Color kPurpleHeader = Color(0xFF5B5FC7);
const Color kAbsentColor = Color(0xFFE53935);
const Color kPresentColor = Color(0xFF43A047);
const Color kCardBg = Color(0xFFF0F2F8);
const Color kLabelColor = Color(0xFF8A8FA3);
const Color kValueColor = Color(0xFF1A1A2E);

/* -------------------- MODEL -------------------- */

class AttendanceData extends Equatable {
  final DateTime date;
  final DateTime? checkInTime;
  final DateTime? checkOutTime;
  final AttendanceModel? data;

  const AttendanceData({
    required this.date,
    this.checkInTime,
    this.checkOutTime,
    this.data,
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
  List<Object?> get props => [date, checkInTime, checkOutTime, data];
}

/* -------------------- PUBLIC ENTRY -------------------- */

Future<void> showAttendancePopupFromBloc(
  BuildContext context,
  DateTime date,
) {
  final bloc = context.read<AttendanceLogsBloc>();
  final state = bloc.state;

  if (state.status != AttendanceLogStatus.success) {
    _showErrorSnackBar(context, 'Attendance data not loaded');
    return Future.value();
  }

  final AttendanceModel? model =
      _findAttendanceByDate(state.scheduleData, date);

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

/* -------------------- POPUP -------------------- */

Future<void> showAttendancePopup(
  BuildContext context,
  AttendanceData data,
) {
  final bloc = context.read<AttendanceLogsBloc>();
  Logger().d('Popup Attendance → ${data.data}');

  bloc.add(SelectDate(data.date));

  return showGeneralDialog(
    context: context,
    barrierDismissible: true,
    barrierLabel: 'Attendance Details',
    barrierColor: Colors.black.withOpacity(0.45),
    transitionDuration: const Duration(milliseconds: 280),
    transitionBuilder: (_, anim, __, child) {
      final curve =
          CurvedAnimation(parent: anim, curve: Curves.easeOutCubic);
      return SlideTransition(
        position: Tween(
          begin: const Offset(0, 0.12),
          end: Offset.zero,
        ).animate(curve),
        child: FadeTransition(opacity: curve, child: child),
      );
    },
    pageBuilder: (_, __, ___) {
      return BlocProvider.value(
        value: bloc,
        child: AttendancePopup(data: data),
      );
    },
  ).then((_) => bloc.add(const ClearSelectedDate()));
}

/* -------------------- UI -------------------- */

class AttendancePopup extends StatelessWidget {
  final AttendanceData data;
  const AttendancePopup({super.key, required this.data});

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.center,
      child: Material(
        color: Colors.transparent,
        child: Container(
          width: MediaQuery.of(context).size.width * 0.9,
          constraints: const BoxConstraints(maxWidth: 440),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(18),
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
    );
  }
}

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
          Text(_formatDate(data.date),
              style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: kValueColor)),
          const SizedBox(height: 16),
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
          _InfoCard(
            label: 'STATUS',
            value: data.data?.attendanceStatus ?? 'UNKNOWN',
          ),
        ],
      ),
    );
  }
}

/* -------------------- HELPERS -------------------- */

AttendanceModel? _findAttendanceByDate(
  List<AttendanceModel> list,
  DateTime date,
) {
  for (final item in list) {
    try {
      final d = DateTime.parse(item.attendanceDate);
      if (d.year == date.year &&
          d.month == date.month &&
          d.day == date.day) {
        return item;
      }
    } catch (_) {}
  }
  return null;
}

String _fmtNullable(DateTime? t) =>
    t == null ? '--:--' : '${t.hour}:${t.minute.toString().padLeft(2, '0')}';

String _formatDate(DateTime d) =>
    '${_weekday[d.weekday - 1]}, ${_months[d.month - 1]} ${d.day}, ${d.year}';

String _formatDateShort(DateTime d) =>
    '${_monthsShort[d.month - 1]} ${d.day}, ${d.year}';

/* -------------------- UI COMPONENTS -------------------- */

class _PopupHeader extends StatelessWidget {
  final String title;
  final VoidCallback onClose;
  const _PopupHeader({required this.title, required this.onClose});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      color: kPurpleHeader,
      child: Row(
        children: [
          const Icon(Icons.calendar_month, color: Colors.white),
          const SizedBox(width: 10),
          Text(title,
              style: const TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.w600)),
          const Spacer(),
          GestureDetector(
            onTap: onClose,
            child: const Icon(Icons.close, color: Colors.white),
          )
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
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: kCardBg,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label,
              style: const TextStyle(
                  fontSize: 12, color: kLabelColor)),
          const SizedBox(height: 8),
          Text(value,
              style: const TextStyle(
                  fontSize: 18, fontWeight: FontWeight.w700)),
        ],
      ),
    );
  }
}



const _months = [
  'January','February','March','April','May','June',
  'July','August','September','October','November','December'
];

const _monthsShort = [
  'Jan','Feb','Mar','Apr','May','Jun',
  'Jul','Aug','Sep','Oct','Nov','Dec'
];

const _weekday = [
  'Monday','Tuesday','Wednesday','Thursday',
  'Friday','Saturday','Sunday'
];


void _showErrorSnackBar(BuildContext context, String msg) {
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(backgroundColor: Colors.red, content: Text(msg)),
  );
}

void _showInfoSnackBar(BuildContext context, String msg) {
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(backgroundColor: kPurpleHeader, content: Text(msg)),
  );
}
