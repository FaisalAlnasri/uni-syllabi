import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';

import '../../../../core/theme/app_colors.dart';
import '../../domain/entities/course.dart';
import '../../domain/entities/deliverable.dart';
import '../courses_strings.dart';
import '../cubit/course_cubit.dart';
import '../widgets/deliverable_detail_sheet.dart';
import '../widgets/type_glyph.dart';

/// First day of the week for the calendar grid. Saturday matches the common
/// Arabic-locale convention.
const int _firstWeekday = DateTime.saturday;

class CalendarPage extends StatefulWidget {
  const CalendarPage({super.key});

  @override
  State<CalendarPage> createState() => _CalendarPageState();
}

class _CalendarPageState extends State<CalendarPage> {
  late DateTime _month;
  late DateTime _selected;

  // Cached deliverable-by-day map; rebuilt only when courses list changes.
  List<Course>? _cachedCourses;
  Map<DateTime, List<({Deliverable deliverable, Course course})>> _byDay = {};

  @override
  void initState() {
    super.initState();
    final now = DateTime.now();
    _month = DateTime(now.year, now.month);
    _selected = DateTime(now.year, now.month, now.day);
  }

  static DateTime _dayKey(DateTime d) => DateTime(d.year, d.month, d.day);

  Map<DateTime, List<({Deliverable deliverable, Course course})>> _buildByDay(
      List<Course> courses) {
    final map = <DateTime, List<({Deliverable deliverable, Course course})>>{};
    for (final course in courses) {
      for (final d in course.deliverables) {
        if (d.date == null) continue;
        final key = _dayKey(d.date!);
        map.putIfAbsent(key, () => []).add((deliverable: d, course: course));
      }
    }
    return map;
  }

  void _changeMonth(int delta) {
    setState(() => _month = DateTime(_month.year, _month.month + delta));
  }

  @override
  Widget build(BuildContext context) {
    final c = context.c;
    final courses = context.watch<CourseCubit>().state.courses;

    // Rebuild only when the courses reference changes.
    if (!identical(_cachedCourses, courses)) {
      _cachedCourses = courses;
      _byDay = _buildByDay(courses);
    }

    final selectedItems = _byDay[_dayKey(_selected)] ?? [];

    return Scaffold(
      backgroundColor: c.background,
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            _MonthHeader(
              month: _month,
              onPrev: () => _changeMonth(-1),
              onNext: () => _changeMonth(1),
            ),
            const _WeekdayRow(),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              child: _MonthGrid(
                month: _month,
                selected: _selected,
                byDay: _byDay,
                onSelect: (d) => setState(() => _selected = d),
              ),
            ),
            const SizedBox(height: 8),
            Expanded(
              child: _DayAgenda(date: _selected, items: selectedItems),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Month header ──────────────────────────────────────────────────────────────

class _MonthHeader extends StatelessWidget {
  final DateTime month;
  final VoidCallback onPrev;
  final VoidCallback onNext;

  const _MonthHeader({
    required this.month,
    required this.onPrev,
    required this.onNext,
  });

  @override
  Widget build(BuildContext context) {
    final c = context.c;
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 12),
      child: Row(
        children: [
          Text(
            DateFormat('MMMM yyyy', 'ar').format(month),
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.w800,
              color: c.textPrimary,
              letterSpacing: -0.4,
            ),
          ),
          const Spacer(),
          // Directional chevrons so prev/next match reading direction.
          _RoundIcon(icon: Icons.chevron_left_rounded, onTap: onPrev),
          const SizedBox(width: 8),
          _RoundIcon(icon: Icons.chevron_right_rounded, onTap: onNext),
        ],
      ),
    );
  }
}

class _RoundIcon extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;
  const _RoundIcon({required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final c = context.c;
    return Material(
      color: c.surface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
        side: BorderSide(color: c.border),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(10),
        child: Padding(
          padding: const EdgeInsets.all(6),
          child: Icon(icon, size: 22, color: c.textSecondary),
        ),
      ),
    );
  }
}

// ── Weekday row ───────────────────────────────────────────────────────────────

class _WeekdayRow extends StatelessWidget {
  const _WeekdayRow();

  /// Narrow localized weekday labels starting from [_firstWeekday].
  List<String> _labels() {
    // 2024-01-06 is a Saturday — anchor and walk forward 7 days.
    final saturday = DateTime(2024, 1, 6);
    final offset = (_firstWeekday - DateTime.saturday + 7) % 7;
    return List.generate(7, (i) {
      final day = saturday.add(Duration(days: offset + i));
      return DateFormat('EEEEE', 'ar').format(day); // narrow, locale-aware
    });
  }

  @override
  Widget build(BuildContext context) {
    final c = context.c;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: Row(
        children: [
          for (final d in _labels())
            Expanded(
              child: Center(
                child: Text(
                  d,
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    color: c.textMuted,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

// ── Month grid ────────────────────────────────────────────────────────────────

class _MonthGrid extends StatelessWidget {
  final DateTime month;
  final DateTime selected;
  final Map<DateTime, List<({Deliverable deliverable, Course course})>> byDay;
  final ValueChanged<DateTime> onSelect;

  const _MonthGrid({
    required this.month,
    required this.selected,
    required this.byDay,
    required this.onSelect,
  });

  @override
  Widget build(BuildContext context) {
    final first = DateTime(month.year, month.month, 1);
    final daysInMonth = DateTime(month.year, month.month + 1, 0).day;
    // Blank leading cells before the 1st, relative to the first day of week.
    final leadingBlanks = (first.weekday - _firstWeekday + 7) % 7;
    final totalCells = leadingBlanks + daysInMonth;
    final rows = (totalCells / 7.0).ceil();

    final today = DateTime.now();
    final todayKey = DateTime(today.year, today.month, today.day);

    return Column(
      children: [
        for (int r = 0; r < rows; r++)
          Row(
            children: [
              for (int col = 0; col < 7; col++)
                Expanded(
                  child: _buildCell(
                    context,
                    r * 7 + col - leadingBlanks + 1,
                    daysInMonth,
                    todayKey,
                  ),
                ),
            ],
          ),
      ],
    );
  }

  Widget _buildCell(
      BuildContext context, int day, int daysInMonth, DateTime todayKey) {
    if (day < 1 || day > daysInMonth) {
      return const AspectRatio(aspectRatio: 1, child: SizedBox());
    }
    final c = context.c;
    final date = DateTime(month.year, month.month, day);
    final items = byDay[date] ?? const [];
    final isSelected =
        date == DateTime(selected.year, selected.month, selected.day);
    final isToday = date == todayKey;

    return AspectRatio(
      aspectRatio: 1,
      child: Padding(
        padding: const EdgeInsets.all(2.5),
        child: Material(
          color: isSelected ? c.accent : Colors.transparent,
          borderRadius: BorderRadius.circular(10),
          child: InkWell(
            onTap: () => onSelect(date),
            borderRadius: BorderRadius.circular(10),
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10),
                border: isToday && !isSelected
                    ? Border.all(color: c.accent, width: 1.5)
                    : null,
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    '$day',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: isToday || isSelected
                          ? FontWeight.w800
                          : FontWeight.w500,
                      color: isSelected
                          ? Colors.white
                          : isToday
                              ? c.accent
                              : c.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 3),
                  _Dots(items: items, onSurface: isSelected),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _Dots extends StatelessWidget {
  final List<({Deliverable deliverable, Course course})> items;
  final bool onSurface;

  const _Dots({required this.items, required this.onSurface});

  @override
  Widget build(BuildContext context) {
    if (items.isEmpty) return const SizedBox(height: 5);
    final shown = items.take(3).toList();
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        for (final it in shown)
          Container(
            width: 5,
            height: 5,
            margin: const EdgeInsets.symmetric(horizontal: 1),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: onSurface
                  ? Colors.white
                  : courseColor(context, it.course.color),
            ),
          ),
      ],
    );
  }
}

// ── Day agenda ────────────────────────────────────────────────────────────────

class _DayAgenda extends StatelessWidget {
  final DateTime date;
  final List<({Deliverable deliverable, Course course})> items;

  const _DayAgenda({required this.date, required this.items});

  @override
  Widget build(BuildContext context) {
    final c = context.c;
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: c.surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        border: Border(top: BorderSide(color: c.borderSubtle)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 18, 20, 12),
            child: Text(
              DateFormat('EEEE، d MMMM', 'ar').format(date),
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w700,
                color: c.textPrimary,
              ),
            ),
          ),
          Expanded(
            child: items.isEmpty
                ? Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.event_available_outlined,
                            size: 28, color: c.textMuted),
                        const SizedBox(height: 8),
                        Text(
                          CoursesStrings.nothingDueThisDay,
                          style: TextStyle(fontSize: 13, color: c.textMuted),
                        ),
                      ],
                    ),
                  )
                : ListView.separated(
                    padding: const EdgeInsets.fromLTRB(16, 0, 16, 120),
                    itemCount: items.length,
                    separatorBuilder: (_, _) => const SizedBox(height: 10),
                    itemBuilder: (_, i) => _AgendaTile(
                      deliverable: items[i].deliverable,
                      course: items[i].course,
                    ),
                  ),
          ),
        ],
      ),
    );
  }
}

class _AgendaTile extends StatelessWidget {
  final Deliverable deliverable;
  final Course course;

  const _AgendaTile({required this.deliverable, required this.course});

  @override
  Widget build(BuildContext context) {
    final c = context.c;
    final color = courseColor(context, course.color);
    return Material(
      color: c.surfaceAlt,
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () => showDeliverableDetail(context, deliverable, course),
        child: Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: c.border),
          ),
          child: Row(
            children: [
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(9),
                ),
                child: Icon(typeIcon(deliverable.type), size: 17, color: color),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      course.title,
                      style: TextStyle(
                        fontSize: 10.5,
                        fontWeight: FontWeight.w700,
                        color: color,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      deliverable.title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: c.textPrimary,
                      ),
                    ),
                  ],
                ),
              ),
              if (deliverable.weight != null)
                Text(
                  deliverable.weightPercentage,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: c.textMuted,
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
