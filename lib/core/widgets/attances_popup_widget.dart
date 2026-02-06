import 'package:flutter/material.dart';


const Color kPurpleHeader            = Color(0xFF5B5FC7);
const Color kActiveCardBg            = Color(0xFF5B9CF5);
const Color kInactiveCardBg          = Color(0xFFF4F5F7);
const Color kTimelineLineColor       = Color(0xFFDDDFE5);
const Color kTimelineNodeActive      = Color(0xFF5B9CF5);
const Color kTimelineNodeInactive    = Color(0xFFD0D3DB);
const Color kTitleDark               = Color(0xFF1A1A2E);
const Color kSubtitleGrey            = Color(0xFF8A8FA3);
const Color kLabelColor              = Color(0xFF8A8FA3);
const Color kValueColor              = Color(0xFF1A1A2E);
const Color kAbsentColor             = Color(0xFFE53935);
const Color kPresentColor            = Color(0xFF43A047);
const Color kCardBg                  = Color(0xFFF0F2F8);


enum AttendanceStatus { present, absent, halfDay, leave }

class AttendanceData {
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
    return checkOutTime!.difference(checkInTime!).inMinutes;
  }

  int? get extraWorkingMinutes {
    if (checkInTime == null || checkOutTime == null) return null;
    return totalWorkingMinutes - (8 * 60);
  }
}

class ScheduleItem {
  final String title;
  final DateTime time;
  final bool isActive;
  final int avatarCount;
  final IconData? categoryIcon;

  const ScheduleItem({
    required this.title,
    required this.time,
    this.isActive = false,
    this.avatarCount = 0,
    this.categoryIcon,
  });
}

// ─── Sample Data ───────────────────────────────────────────────────────────



// ─── Public helpers — call these from dashboard_mobile_view ────────────────

Future<void> showAttendancePopup(BuildContext context, AttendanceData data) {
  return showGeneralDialog(
    context: context,
    barrierDismissible: true,
    barrierLabel: 'Attendance Details',
    barrierColor: Colors.black.withOpacity(0.45),
    transitionDuration: const Duration(milliseconds: 280),
    transitionBuilder: (ctx, anim, _, child) {
      final c = CurvedAnimation(parent: anim, curve: Curves.easeOutCubic);
      return SlideTransition(
        position: Tween<Offset>(begin: const Offset(0, 0.12), end: Offset.zero).animate(c),
        child: FadeTransition(opacity: c, child: child),
      );
    },
    pageBuilder: (ctx, _, __) => AttendancePopup(data: data),
  );
}

Future<void> showSchedulePopup(BuildContext context, List<ScheduleItem> items) {
  return showGeneralDialog(
    context: context,
    barrierDismissible: true,
    barrierLabel: 'Schedule',
    barrierColor: Colors.black.withOpacity(0.45),
    transitionDuration: const Duration(milliseconds: 280),
    transitionBuilder: (ctx, anim, _, child) {
      final c = CurvedAnimation(parent: anim, curve: Curves.easeOutCubic);
      return SlideTransition(
        position: Tween<Offset>(begin: const Offset(0, 0.12), end: Offset.zero).animate(c),
        child: FadeTransition(opacity: c, child: child),
      );
    },
    pageBuilder: (ctx, _, __) => ScheduleTimelinePopup(items: items),
  );
}


class ScheduleTimelinePopup extends StatelessWidget {
  final List<ScheduleItem> items;
  const ScheduleTimelinePopup({super.key, required this.items});

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.center,
      child: Material(
        color: Colors.transparent,
        child: Container(
          width: MediaQuery.of(context).size.width * 0.92,
          constraints: const BoxConstraints(maxWidth: 420),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(color: Colors.black.withOpacity(0.13), blurRadius: 24, offset: const Offset(0, 8)),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                _PopupHeader(title: "Today's Schedule", onClose: () => Navigator.of(context).pop()),
                Padding(
                  padding: const EdgeInsets.only(left: 20, right: 16, top: 12, bottom: 16),
                  child: ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: items.length,
                    itemBuilder: (_, i) => _TimelineRow(item: items[i], isLast: i == items.length - 1),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}


class _PopupHeader extends StatelessWidget {
  final String title;
  final IconData? icon;
  final VoidCallback onClose;

  const _PopupHeader({
    super.key,
    required this.title,
    this.icon,
    required this.onClose,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      color: kPurpleHeader,
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Icon(icon ?? Icons.schedule_rounded, color: Colors.white, size: 22),
          const SizedBox(width: 10),
          Text(title,
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600, color: Colors.white)),
          const Spacer(),
          GestureDetector(
            onTap: onClose,
            child: Container(
              width: 32, height: 32,
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.20),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(Icons.close_rounded, size: 18, color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }
}


class _TimelineRow extends StatelessWidget {
  final ScheduleItem item;
  final bool isLast;
  const _TimelineRow({super.key, required this.item, required this.isLast});

  @override
  Widget build(BuildContext context) {
    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          SizedBox(
            width: 18,
            child: Column(
              children: [
                const SizedBox(height: 18), 
                Container(
                  width: 14, height: 14,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    border: Border.all(
                      color: item.isActive ? kTimelineNodeActive : kTimelineNodeInactive,
                      width: item.isActive ? 3 : 2,
                    ),
                    shape: BoxShape.circle,
                  ),
                ),
                if (!isLast)
                  Expanded(child: Container(width: 2, color: kTimelineLineColor))
                else
                  const Expanded(child: SizedBox()),
              ],
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: item.isActive ? _ActiveCard(item: item) : _InactiveCard(item: item),
            ),
          ),
        ],
      ),
    );
  }
}


class _InactiveCard extends StatelessWidget {
  final ScheduleItem item;
  const _InactiveCard({super.key, required this.item});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(color: kInactiveCardBg, borderRadius: BorderRadius.circular(16)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(item.title,
                  style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w700, color: kTitleDark)),
              Text(_fmtTime(item.time),
                  style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: kTitleDark)),
            ],
          ),
          const SizedBox(height: 4),
        
        ],
      ),
    );
  }
}


class _ActiveCard extends StatelessWidget {
  final ScheduleItem item;
  const _ActiveCard({super.key, required this.item});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: kActiveCardBg, borderRadius: BorderRadius.circular(16)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(item.title,
                  style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: Colors.white)),
              Text(_fmtTime(item.time),
                  style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: Colors.white)),
            ],
          ),
          const SizedBox(height: 6),
  
          const SizedBox(height: 14),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              if (item.avatarCount > 0) _AvatarStack(count: item.avatarCount),
              if (item.categoryIcon != null)
                Container(
                  width: 38, height: 38,
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.22),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(item.categoryIcon, color: Colors.white, size: 20),
                ),
            ],
          ),
        ],
      ),
    );
  }
}


class _AvatarStack extends StatelessWidget {
  final int count;
  const _AvatarStack({super.key, required this.count});

  static const _colors = [
    Color(0xFFEF9A9A), Color(0xFF80CBC4),
    Color(0xFFFFCC80), Color(0xFFCE93D8), Color(0xFF90CAF9),
  ];

  @override
  Widget build(BuildContext context) {
    const double sz = 32, overlap = 10;
    return SizedBox(
      width: sz + (count - 1) * (sz - overlap),
      height: sz,
      child: Stack(
        children: List.generate(count, (i) => Positioned(
          left: i * (sz - overlap),
          child: Container(
            width: sz, height: sz,
            decoration: BoxDecoration(
              color: _colors[i % _colors.length],
              shape: BoxShape.circle,
              border: Border.all(color: Colors.white, width: 2),
            ),
            child: const Icon(Icons.person, size: 18, color: Colors.white),
          ),
        )),
      ),
    );
  }
}



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
          width: MediaQuery.of(context).size.width * 0.90,
          constraints: const BoxConstraints(maxWidth: 440),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(18),
            boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.14), blurRadius: 28, offset: const Offset(0, 10))],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(18),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                _PopupHeader(title: 'Attendance Details', icon: Icons.calendar_month_rounded, onClose: () => Navigator.of(context).pop()),
                _AttBody(data: data),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _AttBody extends StatelessWidget {
  final AttendanceData data;
  const _AttBody({super.key, required this.data});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(22),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(_formatDate(data.date),
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: kValueColor)),
          const SizedBox(height: 18),
          Row(children: [
            Expanded(child: _InfoCard(label: 'CHECK IN TIME',  value: _fmtNullable(data.checkInTime))),
            const SizedBox(width: 12),
            Expanded(child: _InfoCard(label: 'CHECK OUT TIME', value: _fmtNullable(data.checkOutTime))),
          ]),
          const SizedBox(height: 12),
          Row(children: [
            Expanded(child: _InfoCard(label: 'TOTAL WORKING HOURS', value: _totalStr())),
            const SizedBox(width: 12),
            Expanded(child: _InfoCard(label: 'EXTRA WORKING HOURS', value: _extraStr())),
          ]),
          const SizedBox(height: 22),
          const Text('STATUS',
              style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: kLabelColor, letterSpacing: 0.5)),
          const SizedBox(height: 8),
          _StatusCard(status: data.status),
        ],
      ),
    );
  }

  static String _formatDate(DateTime d) {
    const m = ['','January','February','March','April','May','June','July','August','September','October','November','December'];
    const w = ['Monday','Tuesday','Wednesday','Thursday','Friday','Saturday','Sunday'];
    return '${w[d.weekday-1]}, ${m[d.month]} ${d.day}, ${d.year}';
  }

  static String _fmtNullable(DateTime? t) => t == null ? '--:--' : _fmtTime(t);

  String _totalStr() {
    final m = data.totalWorkingMinutes;
    return '${(m~/60).toString().padLeft(2,'0')}h ${(m%60).toString().padLeft(2,'0')}m hrs';
  }

  String _extraStr() {
    final e = data.extraWorkingMinutes;
    if (e == null || e < 0) return '-- hrs';
    return '${(e~/60).toString().padLeft(2,'0')}h ${(e%60).toString().padLeft(2,'0')}m hrs';
  }
}

class _InfoCard extends StatelessWidget {
  final String label, value;
  const _InfoCard({super.key, required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: kCardBg, borderRadius: BorderRadius.circular(14)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: kLabelColor, letterSpacing: 0.4)),
          const SizedBox(height: 8),
          Text(value, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w700, color: kValueColor)),
        ],
      ),
    );
  }
}

class _StatusCard extends StatelessWidget {
  final AttendanceStatus status;
  const _StatusCard({super.key, required this.status});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
      decoration: BoxDecoration(color: kCardBg, borderRadius: BorderRadius.circular(14)),
      child: Text(_label(), style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: _color())),
    );
  }

  String _label() => switch (status) {
    AttendanceStatus.present  => 'PRESENT',
    AttendanceStatus.absent   => 'ABSENT',
    AttendanceStatus.halfDay  => 'HALF DAY',
    AttendanceStatus.leave    => 'ON LEAVE',
  };

  Color _color() => switch (status) {
    AttendanceStatus.present  => kPresentColor,
    AttendanceStatus.absent   => kAbsentColor,
    AttendanceStatus.halfDay  => const Color(0xFFFFA726),
    AttendanceStatus.leave    => const Color(0xFF42A5F5),
  };
}


String _fmtTime(DateTime t) {
  final h = t.hour > 12 ? t.hour - 12 : (t.hour == 0 ? 12 : t.hour);
  final m = t.minute.toString().padLeft(2, '0');
  return '$h:$m ${t.hour >= 12 ? "PM" : "AM"}';
}