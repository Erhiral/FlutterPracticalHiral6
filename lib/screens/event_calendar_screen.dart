import 'package:flutter/material.dart';
import 'package:hiralfutterpractical/core/app_colors.dart';
import 'package:hiralfutterpractical/core/size_utils.dart';
import 'package:hiralfutterpractical/models/event_session.dart';
import 'package:hiralfutterpractical/services/event_service.dart';
import 'package:get/get.dart';
import 'package:hiralfutterpractical/routes/app_routes.dart';
import 'package:hiralfutterpractical/widgets/fab_button.dart';
import 'package:hiralfutterpractical/controllers/bottom_bar_controller.dart';

class EventCalendarScreen extends StatefulWidget {
  const EventCalendarScreen({super.key});

  @override
  State<EventCalendarScreen> createState() => _EventCalendarScreenState();
}

class _EventCalendarScreenState extends State<EventCalendarScreen> {
  late Future<List<EventSession>> _future;
  DateTime _visibleMonth = DateTime(DateTime.now().year, DateTime.now().month);

  @override
  void initState() {
    super.initState();
    _future = EventService.fetchSessions().then((sessions) {
      // If API returns sessions for past/future months (e.g., 2022-01),
      // start the calendar on the earliest session's month so colors show up immediately.
      if (sessions.isNotEmpty) {
        final earliest = sessions
            .map((s) => s.eventSessionDate)
            .reduce((a, b) => a.isBefore(b) ? a : b);
        if (mounted) {
          setState(() {
            _visibleMonth = DateTime(earliest.year, earliest.month);
          });
        }
      }
      return sessions;
    });
    // Mark notifications as read after first frame to avoid Obx rebuild during build phase
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final bb = Get.put(BottomBarController(), permanent: true);
      bb.markRead();
    });
  }

  void _prevMonth() {
    setState(() {
      _visibleMonth = DateTime(_visibleMonth.year, _visibleMonth.month - 1);
    });
  }

  void _nextMonth() {
    setState(() {
      _visibleMonth = DateTime(_visibleMonth.year, _visibleMonth.month + 1);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: Text(
          _monthTitle(_visibleMonth),
          style: TextStyle(color: Colors.black, fontSize: Screen.sp(16), fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        leading: IconButton(
          onPressed: _prevMonth,
          icon: const Icon(Icons.chevron_left, color: Colors.black),
        ),
        actions: [
          IconButton(
            onPressed: _nextMonth,
            icon: const Icon(Icons.chevron_right, color: Colors.black),
          ),
        ],
      ),
      body: FutureBuilder<List<EventSession>>(
        future: _future,
        builder: (context, snap) {
          if (snap.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snap.hasError) {
            return Center(
              child: Padding(
                padding: EdgeInsets.all(Screen.wp(6)),
                child: Text(
                  'Failed to load data\n${snap.error}',
                  style: TextStyle(color: AppColors.textSecondary, fontSize: Screen.sp(12)),
                  textAlign: TextAlign.center,
                ),
              ),
            );
          }
          final sessions = snap.data ?? [];
          final byDay = _groupByDay(sessions);
          // Debug: print month and summary of items for visible month
          assert(() {
            print('EventCalendar: visibleMonth=' + _monthTitle(_visibleMonth) + ' totalSessions=' + sessions.length.toString());
            int monthCount = 0;
            byDay.forEach((day, items) {
              if (day.year == _visibleMonth.year && day.month == _visibleMonth.month) {
                monthCount += items.length;
              }
            });
            print('EventCalendar: sessionsInVisibleMonth=' + monthCount.toString());
            return true;
          }());

          return ListView(
            padding: EdgeInsets.symmetric(horizontal: Screen.wp(4), vertical: Screen.hp(1.5)),
            children: [
              _WeekHeader(),
              Gap.h(Screen.hp(1)),
              _MonthGrid(
                month: _visibleMonth,
                byDay: byDay,
              ),
              Gap.h(Screen.hp(2)),
              _Legend(),
            ],
          );
        },
      ),
    );
  }

  Map<DateTime, List<EventSession>> _groupByDay(List<EventSession> list) {
    final map = <DateTime, List<EventSession>>{};
    for (final s in list) {
      final dayKey = DateTime(s.eventSessionDate.year, s.eventSessionDate.month, s.eventSessionDate.day);
      map.putIfAbsent(dayKey, () => []).add(s);
    }
    return map;
  }

  String _monthTitle(DateTime month) {
    final names = const [
      'January', 'February', 'March', 'April', 'May', 'June', 'July', 'August', 'September', 'October', 'November', 'December'
    ];
    return '${names[month.month - 1]} ${month.year}';
  }
}

class _WeekHeader extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    const labels = ['Sun', 'Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat'];
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        for (final l in labels)
          Expanded(
            child: Center(
              child: Text(
                l,
                style: TextStyle(color: Colors.black54, fontSize: Screen.sp(12)),
              ),
            ),
          ),
      ],
    );
  }
}

class _MonthGrid extends StatelessWidget {
  final DateTime month;
  final Map<DateTime, List<EventSession>> byDay;

  const _MonthGrid({required this.month, required this.byDay});

  @override
  Widget build(BuildContext context) {
    final first = DateTime(month.year, month.month, 1);
    final daysInMonth = DateTime(month.year, month.month + 1, 0).day;
    final startWeekday = first.weekday % 7; // 0=Sun ... 6=Sat

    final cells = <Widget>[];
    for (int i = 0; i < startWeekday; i++) {
      cells.add(const SizedBox());
    }
    for (int d = 1; d <= daysInMonth; d++) {
      final date = DateTime(month.year, month.month, d);
      final items = byDay[date] ?? const <EventSession>[];
      cells.add(_DayCell(date: date, items: items));
    }

    return GridView.count(
      physics: const NeverScrollableScrollPhysics(),
      shrinkWrap: true,
      crossAxisCount: 7,
      crossAxisSpacing: Screen.wp(2),
      mainAxisSpacing: Screen.wp(2),
      children: cells,
    );
  }
}

class _DayCell extends StatelessWidget {
  final DateTime date;
  final List<EventSession> items;
  const _DayCell({required this.date, required this.items});

  Color _statusColorFor(EventSession s) {
    // Color rules:
    // Available = light blue
    // Booked = dark blue (if before current Date then Green)
    // Canceled = Red
    // NotAttended = Yellow
    // Full = Pink

    if (s.isCanceled) return Colors.red; // canceled dominates
    if (s.isClassSessionFull) return const Color(0xFFFFC1C1); // light pink

    final now = DateTime.now();
    final isPast = DateTime(date.year, date.month, date.day).isBefore(DateTime(now.year, now.month, now.day));

    if (s.isBooked) {
      return isPast ? Colors.green[800]! : const Color(0xFF1F2B5C); // dark blue when future, green when past
    }
    if (s.isNotAttended) return Colors.yellow[700]!;
    if (s.isAvailable) return const Color(0xFFD8DFF8); // light blue

    // default subtle grey when no status
    return AppColors.divider;
  }

  @override
  Widget build(BuildContext context) {
    final hasAny = items.isNotEmpty;
    final color = hasAny ? _statusColorFor(items.first) : const Color(0xFFE8ECF4);
    final textColor = _useDarkText(color) ? Colors.black : Colors.white;

    return Column(
      children: [
        Container(
          width: Screen.wp(8),
          height: Screen.wp(8),
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
          ),
          alignment: Alignment.center,
          child: Text(
            '${date.day}',
            style: TextStyle(
              color: textColor,
              fontWeight: FontWeight.w600,
              fontSize: Screen.sp(12),
            ),
          ),
        ),
      ],
    );
  }

  bool _useDarkText(Color c) {
    // If background is light, use dark text, else white text
    return c.computeLuminance() > 0.5;
  }
}

class _Legend extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: Screen.wp(6),
      runSpacing: Screen.hp(1),
      children: const [
        _LegendItem(label: 'Available', color: Color(0xFFD8DFF8)),
        _LegendItem(label: 'Booked', color: Color(0xFF1F2B5C)),
        _LegendItem(label: 'Attended', color: Colors.green),
        _LegendItem(label: 'Full', color: Color(0xFFFFC1C1)),
        _LegendItem(label: 'Canceled', color: Colors.red),
        _LegendItem(label: 'Not Attended', color: Colors.yellow),
      ],
    );
  }
}

class _LegendItem extends StatelessWidget {
  final String label;
  final Color color;
  const _LegendItem({required this.label, required this.color});
  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: Screen.wp(4.5),
          height: Screen.wp(4.5),
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        SizedBox(width: Screen.wp(1.8)),
        Text(label, style: TextStyle(color: AppColors.surface, fontSize: Screen.sp(12))),
      ],
    );
  }
}
