import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:hrm/core/constants/constants.dart';
import 'package:hrm/core/util/toast_util.dart';
import 'package:hrm/core/widgets/greeting_widget.dart' as GreetingData;
import 'package:hrm/screens/dashboard/provoider/dashboard_provoider.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

class _DS {
  static const indigo     = Color(0xFF4F52C8);
  static const indigoLight= Color(0xFF7B7FE8);
  static const indigoDark = Color(0xFF3336A0);
  static const rose       = Color(0xFFEF4565);
  static const roseLight  = Color(0xFFFF7090);
  static const emerald    = Color(0xFF0DB870);
  static const ink        = Color(0xFF16163A);
  static const inkSoft    = Color(0xFF4A4A7A);
  static const muted      = Color(0xFF9B9BBF);
  static const surface    = Color(0xFFF4F5FF);
  static const divider    = Color(0xFFEAEAF5);

  static List<BoxShadow> card = [
    BoxShadow(color: indigo.withOpacity(0.09), blurRadius: 24, offset: Offset(0, 8), spreadRadius: -4),
    BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 6, offset: Offset(0, 2)),
  ];

  static List<BoxShadow> btn(Color c) => [
    BoxShadow(color: c.withOpacity(0.38), blurRadius: 14, offset: Offset(0, 6), spreadRadius: -2),
  ];
}

class DashboardMobileView extends StatefulWidget {
  const DashboardMobileView({super.key});
  @override
  State<DashboardMobileView> createState() => _DashboardMobileViewState();
}

class _DashboardMobileViewState extends State<DashboardMobileView> {
  CheckInStatus? _prevStatus;

  @override
  Widget build(BuildContext context) {
    return Consumer<DashboardProvider>(
      builder: (context, provider, _) {
        // Toast on status change
        if (provider.loadingStatus == DashboardLoadingStatus.success &&
            _prevStatus != provider.checkInStatus) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (provider.checkInStatus == CheckInStatus.checkedIn) {
              ToastUtil.checkIn(context: context);
            } else if (provider.checkInStatus == CheckInStatus.checkedOut) {
              ToastUtil.checkOut(context: context);
            }
          });
          _prevStatus = provider.checkInStatus;
        }

        final isCheckedIn = provider.checkInStatus == CheckInStatus.checkedIn;
        final now = DateTime.now();
        final greetingData = GreetingData.getGreetingData();

        return Scaffold(
          backgroundColor: _DS.surface,
          body: Column(
            children: [
              _Header(provider: provider, greetingData: greetingData),
          
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(16, 14, 16, 14),
                  child: Column(
                    children: [
                      _AttendanceCard(provider: provider, now: now, isCheckedIn: isCheckedIn),
                      const SizedBox(height: 14),
                      _StatsRow(provider: provider),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _Header extends StatelessWidget {
  const _Header({required this.provider, required this.greetingData});
  final DashboardProvider provider;
  final dynamic greetingData;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration:  BoxDecoration(
        gradient:Constants.color.primaryGradient,
        
        //  LinearGradient(
        //   begin: Alignment.topLeft,
        //   end: Alignment.bottomRight,
        //   colors: [Constants.color.primaryGradient],
        //   stops: [0.0, 0.5, 1.0],
        // ),
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(28),
          bottomRight: Radius.circular(28),
        ),
      ),
      child: Stack(
        children: [
          Positioned(right: -30, top: -30, child: _Blob(size: 140, opacity: 0.07)),
          Positioned(left: -20, bottom: -40, child: _Blob(size: 110, opacity: 0.05)),

          Padding(
            padding: const EdgeInsets.fromLTRB(20, 18, 20, 20),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // Left: greeting + name
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        greetingData.text,
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.white.withOpacity(0.75),
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        provider.userName.isNotEmpty ? provider.userName : 'Guest',
                        style: const TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.w800,
                          color: Colors.white,
                          letterSpacing: -0.5,
                          height: 1.1,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 10),
                      // Live clock
                      StreamBuilder<void>(
                        stream: Stream.periodic(const Duration(seconds: 1)),
                        builder: (_, __) {
                          final n = DateTime.now();
                          return Container(
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.13),
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(color: Colors.white.withOpacity(0.18), width: 1),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(Icons.access_time_rounded,
                                    color: Colors.white.withOpacity(0.85), size: 14),
                                const SizedBox(width: 6),
                                Text(
                                  DateFormat('HH:mm:ss').format(n),
                                  style: const TextStyle(
                                    fontSize: 15,
                                    fontWeight: FontWeight.w800,
                                    color: Colors.white,
                                    letterSpacing: 1.2,
                                    fontFeatures: [FontFeature.tabularFigures()],
                                  ),
                                ),
                              ],
                            ),
                          );
                        },
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 14),
                // Right: avatar illustration + date
                Column(
                  children: [
                    Container(
                      width: 56,
                      height: 56,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.white.withOpacity(0.15),
                        border: Border.all(color: Colors.white.withOpacity(0.3), width: 2),
                      ),
                      child: ClipOval(
                        child: Image.asset(greetingData.image, fit: BoxFit.cover),
                      ),
                    ),
                    const SizedBox(height: 6),
                    StreamBuilder<void>(
                      stream: Stream.periodic(const Duration(seconds: 60)),
                      builder: (_, __) => Text(
                        DateFormat('d MMM').format(DateTime.now()),
                        style: TextStyle(
                          fontSize: 11,
                          color: Colors.white.withOpacity(0.7),
                          fontWeight: FontWeight.w700,
                        ),
                      ),
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
}

class _Blob extends StatelessWidget {
  const _Blob({required this.size, required this.opacity});
  final double size;
  final double opacity;
  @override
  Widget build(BuildContext context) => Container(
        width: size, height: size,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: Colors.white.withOpacity(opacity),
        ),
      );
}

// ─── Attendance Card ──────────────────────────────────────────────────────────
class _AttendanceCard extends StatelessWidget {
  const _AttendanceCard({
    required this.provider,
    required this.now,
    required this.isCheckedIn,
  });
  final DashboardProvider provider;
  final DateTime now;
  final bool isCheckedIn;

  String _suffix(int d) {
    if (d >= 11 && d <= 13) return 'th';
    switch (d % 10) {
      case 1: return 'st';
      case 2: return 'nd';
      case 3: return 'rd';
      default: return 'th';
    }
  }

  @override
  Widget build(BuildContext context) {
    final monday = now.subtract(Duration(days: now.weekday - 1));
    const labels = ['M', 'T', 'W', 'Th', 'F'];
    final today = DateTime(now.year, now.month, now.day);

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: _DS.card,
      ),
      child: Column(
        children: [
          // ── Action bar ──────────────────────────────────────────────
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 14, 16, 12),
            child: Row(
              children: [
                Container(
                  width: 38, height: 38,
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFF6F72E8), Color(0xFF4F52C8)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: _DS.btn(_DS.indigo),
                  ),
                  child: const Icon(Icons.event_available_rounded, color: Colors.white, size: 18),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Take attendance today',
                        style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: _DS.ink),
                      ),
                      Text(
                        isCheckedIn ? "Tap to check out" : 'Not checked in yet',
                        style: const TextStyle(fontSize: 10, color: _DS.muted, fontWeight: FontWeight.w500),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 10),
                _SubmitButton(provider: provider, isCheckedIn: isCheckedIn),
              ],
            ),
          ),

          // ── Thin divider ──
          Container(height: 1, margin: const EdgeInsets.symmetric(horizontal: 16), color: _DS.divider),

          // ── Date row ────────────────────────────────────────────────
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  DateFormat('d').format(now),
                  style: const TextStyle(
                    fontSize: 52, fontWeight: FontWeight.w900,
                    color: _DS.ink, height: 1, letterSpacing: -2,
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(bottom: 6),
                  child: Text(
                    _suffix(now.day),
                    style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w800, color: _DS.indigo),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.only(bottom: 4),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          DateFormat('EEEE').format(now),
                          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w800, color: _DS.ink, letterSpacing: -0.2),
                        ),
                        Text(
                          DateFormat('MMMM yyyy').format(now),
                          style: const TextStyle(fontSize: 11, color: _DS.muted, fontWeight: FontWeight.w600),
                        ),
                      ],
                    ),
                  ),
                ),
                Container(
                  width: 34, height: 34,
                  margin: const EdgeInsets.only(bottom: 4),
                  decoration: BoxDecoration(
                    color: _DS.surface,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: _DS.divider, width: 1.5),
                  ),
                  child: const Icon(Icons.chevron_right_rounded, color: _DS.muted, size: 18),
                ),
              ],
            ),
          ),

          // ── Week dots ───────────────────────────────────────────────
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 14, 16, 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      width: 3, height: 13,
                      decoration: BoxDecoration(color: _DS.indigo, borderRadius: BorderRadius.circular(2)),
                    ),
                    const SizedBox(width: 7),
                    const Text(
                      'This week status',
                      style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: _DS.inkSoft),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: List.generate(5, (i) {
                    final date = monday.add(Duration(days: i));
                    final thisDay = DateTime(date.year, date.month, date.day);
                    final isToday = thisDay == today;
                    final isFuture = thisDay.isAfter(today);

                    _DotState state;
                    if (isFuture) {
                      state = _DotState.future;
                    } else {
                      final hasRecord = provider.attendanceList.any((a) {
                        if (a.checkinTime == null) return false;
                        final d = a.checkinTime!;
                        return d.year == date.year && d.month == date.month && d.day == date.day;
                      });
                      if (isToday && !hasRecord) {
                        state = (provider.checkInStatus == CheckInStatus.checkedIn ||
                                provider.checkInStatus == CheckInStatus.checkedOut)
                            ? _DotState.present
                            : _DotState.absent;
                      } else {
                        state = hasRecord ? _DotState.present : _DotState.absent;
                      }
                    }

                    return _WeekDot(
                      label: labels[i],
                      dayNum: date.day.toString(),
                      state: state,
                      isToday: isToday,
                    );
                  }),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _SubmitButton extends StatefulWidget {
  const _SubmitButton({required this.provider, required this.isCheckedIn});
  final DashboardProvider provider;
  final bool isCheckedIn;
  @override
  State<_SubmitButton> createState() => _SubmitButtonState();
}

class _SubmitButtonState extends State<_SubmitButton> with SingleTickerProviderStateMixin {
  late AnimationController _sc;
  @override
  void initState() {
    super.initState();
    _sc = AnimationController(vsync: this, duration: const Duration(milliseconds: 110),
        lowerBound: 0.94, upperBound: 1.0, value: 1.0);
  }
  @override
  void dispose() { _sc.dispose(); super.dispose(); }

  void _tap() {
    if (widget.provider.isLoading) return;
    HapticFeedback.mediumImpact();
    _sc.reverse().then((_) => _sc.forward());
    widget.isCheckedIn ? widget.provider.checkOut() : widget.provider.checkIn();
  }

  @override
  Widget build(BuildContext context) {
    final color = widget.isCheckedIn ? _DS.rose : _DS.indigo;
    return ScaleTransition(
      scale: _sc,
      child: GestureDetector(
        onTap: _tap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: widget.isCheckedIn
                  ? [_DS.roseLight, _DS.rose]
                  : [_DS.indigoLight, _DS.indigo],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(12),
            boxShadow: _DS.btn(color),
          ),
          child: widget.provider.isLoading
              ? const SizedBox(
                  width: 14, height: 14,
                  child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
              : Text(
                  widget.isCheckedIn ? 'Check Out' : 'Check In',
                  style: const TextStyle(
                    color: Colors.white, fontSize: 12,
                    fontWeight: FontWeight.w800, letterSpacing: 0.2,
                  ),
                ),
        ),
      ),
    );
  }
}

enum _DotState { present, absent, future }

class _WeekDot extends StatelessWidget {
  const _WeekDot({required this.label, required this.dayNum, required this.state, required this.isToday});
  final String label;
  final String dayNum;
  final _DotState state;
  final bool isToday;

  @override
  Widget build(BuildContext context) {
    Color bg; Color border; Color labelColor; Widget child;

    switch (state) {
      case _DotState.present:
        bg = _DS.indigo; border = _DS.indigo; labelColor = isToday ? _DS.indigo : _DS.muted;
        child = const Icon(Icons.check_rounded, color: Colors.white, size: 15);
        break;
      case _DotState.absent:
        bg = _DS.rose.withOpacity(0.10); border = _DS.rose.withOpacity(0.35);
        labelColor = isToday ? _DS.rose : _DS.muted;
        child = Icon(Icons.close_rounded, color: _DS.rose.withOpacity(0.8), size: 13);
        break;
      case _DotState.future:
        bg = Colors.transparent; border = _DS.divider; labelColor = _DS.muted;
        child = Text(dayNum, style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w600, color: _DS.muted));
        break;
    }

    final dotSize = isToday ? 38.0 : 32.0;

    return Column(
      children: [
        Text(label, style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: labelColor)),
        const SizedBox(height: 6),
        if (isToday)
          Container(
            width: dotSize, height: dotSize,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(
                color: state == _DotState.absent ? _DS.rose : _DS.indigo, width: 2),
            ),
            child: Padding(
              padding: const EdgeInsets.all(3),
              child: Container(
                decoration: BoxDecoration(
                  shape: BoxShape.circle, color: bg,
                  boxShadow: state == _DotState.present ? _DS.btn(_DS.indigo) : null,
                ),
                child: Center(child: child),
              ),
            ),
          )
        else
          Container(
            width: dotSize, height: dotSize,
            decoration: BoxDecoration(
              shape: BoxShape.circle, color: bg,
              border: Border.all(color: border, width: 1.5),
              boxShadow: state == _DotState.present
                  ? [BoxShadow(color: _DS.indigo.withOpacity(0.22), blurRadius: 8, offset: Offset(0, 3))]
                  : null,
            ),
            child: Center(child: child),
          ),
      ],
    );
  }
}

class _StatsRow extends StatelessWidget {
  const _StatsRow({required this.provider});
  final DashboardProvider provider;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: _StatCard(
            label: 'Check In',
            value: provider.checkInTimeFormatted ?? '--:--',
            icon: Icons.login_rounded,
            iconColor: _DS.emerald,
            accentColor: _DS.emerald,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _StatCard(
            label: 'Check Out',
            value: provider.checkOutTimeFormatted ?? '--:--',
            icon: Icons.logout_rounded,
            iconColor: _DS.rose,
            accentColor: _DS.rose,
          ),
        ),
      ],
    );
  }
}

class _StatCard extends StatelessWidget {
  const _StatCard({
    required this.label,
    required this.value,
    required this.icon,
    required this.iconColor,
    required this.accentColor,
  });
  final String label, value;
  final IconData icon;
  final Color iconColor, accentColor;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: _DS.card,
      ),
      child: Row(
        children: [
          Container(
            width: 36, height: 36,
            decoration: BoxDecoration(
              color: accentColor.withOpacity(0.10),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: iconColor, size: 18),
          ),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label, style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w600, color: _DS.muted, letterSpacing: 0.3)),
              const SizedBox(height: 2),
              Text(
                value,
                style: TextStyle(
                  fontSize: 20, fontWeight: FontWeight.w900,
                  color: _DS.ink, letterSpacing: -0.5,
                  fontFeatures: const [FontFeature.tabularFigures()],
                ),
              ),
            ],
          ),
          const Spacer(),
          Container(
            width: 7, height: 7,
            decoration: BoxDecoration(
              shape: BoxShape.circle, color: accentColor,
              boxShadow: [BoxShadow(color: accentColor.withOpacity(0.4), blurRadius: 5, spreadRadius: 1)],
            ),
          ),
        ],
      ),
    );
  }
}