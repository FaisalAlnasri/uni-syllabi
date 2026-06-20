import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/intl.dart';

import '../../../../core/theme/app_colors.dart';
import '../../domain/entities/course.dart';
import '../../domain/entities/deliverable.dart';
import '../courses_strings.dart';
import 'deliverable_detail_sheet.dart';
import 'type_glyph.dart';

/// Groups deliverables into action-ordered urgency buckets so the list answers
/// one question at a glance: *what do I need to act on, and when?*
///
/// Order: Today → This week → Later → Needs a date → Past (collapsed).
/// "Today" is the visual hero; the past is tucked away and quiet.
class AllDeliverablesWidget extends StatefulWidget {
  final List<Course> courses;
  final String? skipDeliverableId;

  const AllDeliverablesWidget({
    super.key,
    required this.courses,
    this.skipDeliverableId,
  });

  @override
  State<AllDeliverablesWidget> createState() => _AllDeliverablesWidgetState();
}

enum _Bucket { today, thisWeek, later, unscheduled, past }

typedef _Item = ({Deliverable deliverable, Course course});

class _AllDeliverablesWidgetState extends State<AllDeliverablesWidget> {
  bool _pastExpanded = false;

  // ── Bucketing ────────────────────────────────────────────────────────────

  static _Bucket _bucketOf(Deliverable d, DateTime today) {
    final date = d.date;
    if (date == null) return _Bucket.unscheduled;
    final target = DateTime(date.year, date.month, date.day);
    final diff = target.difference(today).inDays;
    if (diff < 0) return _Bucket.past;
    if (diff == 0) return _Bucket.today;
    if (diff <= 6) return _Bucket.thisWeek;
    return _Bucket.later;
  }

  Map<_Bucket, List<_Item>> _group() {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);

    final buckets = {for (final b in _Bucket.values) b: <_Item>[]};
    for (final course in widget.courses) {
      for (final d in course.deliverables) {
        if (d.id == widget.skipDeliverableId) continue;
        buckets[_bucketOf(d, today)]!
            .add((deliverable: d, course: course));
      }
    }

    int byDateAsc(_Item a, _Item b) =>
        a.deliverable.date!.compareTo(b.deliverable.date!);

    buckets[_Bucket.today]!.sort(byDateAsc);
    buckets[_Bucket.thisWeek]!.sort(byDateAsc);
    buckets[_Bucket.later]!.sort(byDateAsc);
    // Most recently passed first — that's what's still on your mind.
    buckets[_Bucket.past]!.sort((a, b) => byDateAsc(b, a));
    return buckets;
  }

  // ── Build ────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    final groups = _group();
    final hasAny = groups.values.any((l) => l.isNotEmpty);
    if (!hasAny) return const _EmptyState();

    final past = groups[_Bucket.past]!;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _liveSection(context, _Bucket.today, groups[_Bucket.today]!),
        _liveSection(context, _Bucket.thisWeek, groups[_Bucket.thisWeek]!),
        _liveSection(context, _Bucket.later, groups[_Bucket.later]!),
        _liveSection(
            context, _Bucket.unscheduled, groups[_Bucket.unscheduled]!),
        if (past.isNotEmpty) _pastSection(context, past),
      ],
    );
  }

  Widget _liveSection(BuildContext context, _Bucket bucket, List<_Item> items) {
    if (items.isEmpty) return const SizedBox.shrink();
    return Padding(
      padding: EdgeInsets.only(bottom: 4.h),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _SectionHeader(bucket: bucket, count: items.length),
          SizedBox(height: 8.h),
          _TimelineSection(items: items, bucket: bucket),
          SizedBox(height: 12.h),
        ],
      ),
    );
  }

  Widget _pastSection(BuildContext context, List<_Item> items) {
    return Padding(
      padding: EdgeInsets.only(top: 4.h),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _SectionHeader(
            bucket: _Bucket.past,
            count: items.length,
            expanded: _pastExpanded,
            onTap: () => setState(() => _pastExpanded = !_pastExpanded),
          ),
          if (_pastExpanded) ...[
            SizedBox(height: 8.h),
            _TimelineSection(items: items, bucket: _Bucket.past),
          ],
        ],
      ),
    );
  }
}

// ── Bucket presentation ──────────────────────────────────────────────────────

extension on _Bucket {
  String get label => switch (this) {
        _Bucket.today => CoursesStrings.todayGroup,
        _Bucket.thisWeek => CoursesStrings.thisWeekGroup,
        _Bucket.later => CoursesStrings.laterGroup,
        _Bucket.unscheduled => CoursesStrings.unscheduledGroup,
        _Bucket.past => CoursesStrings.pastGroup,
      };

  IconData get icon => switch (this) {
        _Bucket.today => Icons.today_rounded,
        _Bucket.thisWeek => Icons.date_range_rounded,
        _Bucket.later => Icons.calendar_month_rounded,
        _Bucket.unscheduled => Icons.edit_calendar_outlined,
        _Bucket.past => Icons.history_rounded,
      };

  Color tone(AppColors c) => switch (this) {
        _Bucket.today => c.accent,
        _Bucket.thisWeek => c.textPrimary,
        _Bucket.later => c.textSecondary,
        _Bucket.unscheduled => c.warning,
        _Bucket.past => c.textMuted,
      };
}

// ── Section header ───────────────────────────────────────────────────────────

class _SectionHeader extends StatelessWidget {
  final _Bucket bucket;
  final int count;
  final bool? expanded; // non-null → collapsible (past)
  final VoidCallback? onTap;

  const _SectionHeader({
    required this.bucket,
    required this.count,
    this.expanded,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final c = context.c;
    final tone = bucket.tone(c);
    final emphasised = bucket == _Bucket.today;

    final row = Padding(
      padding: EdgeInsets.symmetric(vertical: 4.h),
      child: Row(
        children: [
          Icon(bucket.icon, size: 15.sp, color: tone),
          SizedBox(width: 7.w),
          Text(
            bucket.label,
            style: TextStyle(
              fontSize: 13.sp,
              fontWeight: emphasised ? FontWeight.w800 : FontWeight.w700,
              color: emphasised ? c.textPrimary : c.textSecondary,
            ),
          ),
          SizedBox(width: 7.w),
          Container(
            padding: EdgeInsets.symmetric(horizontal: 7.w, vertical: 1.h),
            decoration: BoxDecoration(
              color: emphasised
                  ? tone.withValues(alpha: 0.14)
                  : c.surfaceMuted,
              borderRadius: BorderRadius.circular(8.r),
            ),
            child: Text(
              '$count',
              style: TextStyle(
                fontSize: 11.sp,
                fontWeight: FontWeight.w700,
                color: emphasised ? tone : c.textMuted,
              ),
            ),
          ),
          const Spacer(),
          if (expanded != null)
            AnimatedRotation(
              turns: expanded! ? 0.5 : 0,
              duration: const Duration(milliseconds: 180),
              child: Icon(Icons.keyboard_arrow_down_rounded,
                  size: 20.sp, color: c.textMuted),
            ),
        ],
      ),
    );

    if (onTap == null) return row;
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(10.r),
        child: row,
      ),
    );
  }
}

// ── Timeline section (spine + cards) ─────────────────────────────────────────

class _TimelineSection extends StatelessWidget {
  final List<_Item> items;
  final _Bucket bucket;

  const _TimelineSection({required this.items, required this.bucket});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        for (int i = 0; i < items.length; i++)
          _TimelineItem(
            deliverable: items[i].deliverable,
            course: items[i].course,
            bucket: bucket,
            isLast: i == items.length - 1,
          ),
      ],
    );
  }
}

class _TimelineItem extends StatelessWidget {
  final Deliverable deliverable;
  final Course course;
  final _Bucket bucket;
  final bool isLast;

  const _TimelineItem({
    required this.deliverable,
    required this.course,
    required this.bucket,
    required this.isLast,
  });

  @override
  Widget build(BuildContext context) {
    final c = context.c;
    final color = courseColor(context, course.color);
    final hasWarning = deliverable.confidenceNotes != null;

    return Padding(
      padding: EdgeInsets.only(bottom: 8.h),
      child: IntrinsicHeight(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Spine sits on the start side (mirrors correctly under RTL).
            SizedBox(
              width: 28.w,
              child: Column(
                children: [
                  SizedBox(height: 20.h),
                  _SpineDot(
                    color: color,
                    bucket: bucket,
                    hasWarning: hasWarning,
                  ),
                  if (!isLast)
                    Expanded(child: Container(width: 1.5.w, color: c.spineLine)),
                ],
              ),
            ),
            Expanded(
              child: _DeliverableCard(
                deliverable: deliverable,
                course: course,
                color: color,
                bucket: bucket,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SpineDot extends StatelessWidget {
  final Color color;
  final _Bucket bucket;
  final bool hasWarning;

  const _SpineDot({
    required this.color,
    required this.bucket,
    required this.hasWarning,
  });

  @override
  Widget build(BuildContext context) {
    final c = context.c;
    final isPast = bucket == _Bucket.past;
    final isToday = bucket == _Bucket.today;

    final ringColor = hasWarning
        ? c.warning
        : isPast
            ? c.textMuted
            : color;

    // Today is filled (solid presence); everything else is an outlined ring.
    return Container(
      width: isToday ? 12.r : 10.r,
      height: isToday ? 12.r : 10.r,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: isToday
            ? ringColor
            : isPast
                ? c.surfaceMuted
                : c.surface,
        border: Border.all(color: ringColor, width: 2),
      ),
    );
  }
}

// ── Deliverable card ─────────────────────────────────────────────────────────

class _DeliverableCard extends StatelessWidget {
  final Deliverable deliverable;
  final Course course;
  final Color color;
  final _Bucket bucket;

  const _DeliverableCard({
    required this.deliverable,
    required this.course,
    required this.color,
    required this.bucket,
  });

  bool get _isPast => bucket == _Bucket.past;
  bool get _isUnscheduled => bucket == _Bucket.unscheduled;

  @override
  Widget build(BuildContext context) {
    final c = context.c;
    final hasWarning = deliverable.confidenceNotes != null;

    final borderColor = hasWarning || _isUnscheduled ? c.warning : c.border;
    final borderWidth = hasWarning || _isUnscheduled ? 1.5 : 1.0;

    return Opacity(
      opacity: _isPast ? 0.62 : 1.0,
      child: Material(
        color: c.surface,
        borderRadius: BorderRadius.circular(12.r),
        child: InkWell(
          borderRadius: BorderRadius.circular(12.r),
          onTap: () => showDeliverableDetail(context, deliverable, course),
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12.r),
              border: Border.all(color: borderColor, width: borderWidth),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  height: 3.h,
                  decoration: BoxDecoration(
                    color: color,
                    borderRadius:
                        BorderRadius.vertical(top: Radius.circular(12.r)),
                  ),
                ),
                Padding(
                  padding: EdgeInsets.all(10.r),
                  child: Row(
                    children: [
                      Container(
                        width: 34.r,
                        height: 34.r,
                        decoration: BoxDecoration(
                          color: color.withValues(alpha: 0.12),
                          borderRadius: BorderRadius.circular(8.r),
                        ),
                        child: Icon(typeIcon(deliverable.type),
                            size: 16.sp, color: color),
                      ),
                      SizedBox(width: 10.w),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Course · type — a quick, scannable label line.
                            Text(
                              '${course.title} · ${typeLabel(deliverable.type)}',
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                fontSize: 10.sp,
                                fontWeight: FontWeight.w600,
                                color: color,
                                letterSpacing: 0.2,
                              ),
                            ),
                            SizedBox(height: 2.h),
                            Text(
                              deliverable.title,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                fontSize: 13.sp,
                                fontWeight: FontWeight.w600,
                                color: _isPast ? c.textSecondary : c.textPrimary,
                              ),
                            ),
                          ],
                        ),
                      ),
                      SizedBox(width: 8.w),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          _DatePill(deliverable: deliverable, bucket: bucket),
                          if (_trailingBadges(context).isNotEmpty) ...[
                            SizedBox(height: 5.h),
                            Row(
                              mainAxisSize: MainAxisSize.min,
                              children: _trailingBadges(context),
                            ),
                          ],
                        ],
                      ),
                    ],
                  ),
                ),
                if (deliverable.confidenceNotes != null)
                  _ConfidenceNote(note: deliverable.confidenceNotes!),
              ],
            ),
          ),
        ),
      ),
    );
  }

  List<Widget> _trailingBadges(BuildContext context) {
    final hasWarning = deliverable.confidenceNotes != null;
    return [
      if (hasWarning && !_isPast) _Badge.needsReview(context),
      if (deliverable.weight != null) ...[
        if (hasWarning && !_isPast) SizedBox(width: 4.w),
        _Badge.weight(context, deliverable.weightPercentage),
      ],
    ];
  }
}

// ── Date pill ────────────────────────────────────────────────────────────────

/// A compact, always-meaningful relative-time chip. Never renders blank: an
/// undated item reads "حدد تاريخًا" (an invitation to act), not an empty gap.
class _DatePill extends StatelessWidget {
  final Deliverable deliverable;
  final _Bucket bucket;

  const _DatePill({required this.deliverable, required this.bucket});

  @override
  Widget build(BuildContext context) {
    final c = context.c;
    final (label, fg, emphasise) = _content(context, c);

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 3.h),
      decoration: BoxDecoration(
        color: emphasise ? fg.withValues(alpha: 0.12) : Colors.transparent,
        borderRadius: BorderRadius.circular(7.r),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 12.sp,
          fontWeight: emphasise ? FontWeight.w800 : FontWeight.w600,
          color: fg,
        ),
      ),
    );
  }

  /// Returns (label, color, emphasise-with-background).
  (String, Color, bool) _content(BuildContext context, AppColors c) {
    if (deliverable.date == null) {
      return (CoursesStrings.setDateHint, c.warning, true);
    }

    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final t = deliverable.date!;
    final target = DateTime(t.year, t.month, t.day);
    final diff = target.difference(today).inDays;

    final dueToday = context.isDark
        ? const Color(0xFFF87171)
        : const Color(0xFFB91C1C);

    if (diff == 0) return (CoursesStrings.today, dueToday, true);
    if (diff == 1) return (CoursesStrings.tomorrow, c.warning, true);
    if (diff == -1) return (CoursesStrings.yesterday, c.textMuted, false);
    if (diff > 1 && diff <= 6) {
      return (CoursesStrings.inDays(diff), c.textPrimary, false);
    }
    if (diff.abs() < 365) {
      return (DateFormat('d MMM', 'ar').format(t),
          bucket == _Bucket.past ? c.textMuted : c.textPrimary, false);
    }
    return (DateFormat('d MMM yyyy', 'ar').format(t),
        bucket == _Bucket.past ? c.textMuted : c.textPrimary, false);
  }
}

// ── Confidence note ──────────────────────────────────────────────────────────

class _ConfidenceNote extends StatelessWidget {
  final String note;
  const _ConfidenceNote({required this.note});

  @override
  Widget build(BuildContext context) {
    final c = context.c;
    return Container(
      width: double.infinity,
      padding: EdgeInsets.fromLTRB(10.w, 7.h, 10.w, 9.h),
      decoration: BoxDecoration(
        color: c.warningBg,
        borderRadius: BorderRadius.vertical(bottom: Radius.circular(11.r)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: EdgeInsetsDirectional.only(top: 1.h),
            child:
                Icon(Icons.info_outline_rounded, size: 13.sp, color: c.warningFg),
          ),
          SizedBox(width: 6.w),
          Expanded(
            child: Text(
              note,
              style: TextStyle(fontSize: 11.sp, color: c.warningFg, height: 1.45),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Badge ────────────────────────────────────────────────────────────────────

class _Badge extends StatelessWidget {
  final String label;
  final Color bg;
  final Color fg;
  final IconData? icon;

  const _Badge({
    required this.label,
    required this.bg,
    required this.fg,
    this.icon,
  });

  factory _Badge.weight(BuildContext context, String text) => _Badge(
        label: text,
        bg: context.c.surfaceMuted,
        fg: context.c.textMuted,
      );

  factory _Badge.needsReview(BuildContext context) => _Badge(
        label: CoursesStrings.needsReview,
        bg: context.c.warningBg,
        fg: context.c.warningFg,
        icon: Icons.warning_amber_rounded,
      );

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 5.w, vertical: 2.h),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(4.r),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            Icon(icon, size: 9.sp, color: fg),
            SizedBox(width: 2.w),
          ],
          Text(
            label,
            style: TextStyle(
              fontSize: 10.sp,
              fontWeight: FontWeight.w600,
              color: fg,
            ),
          ),
        ],
      ),
    );
  }
}

// ── Empty state ──────────────────────────────────────────────────────────────

class _EmptyState extends StatelessWidget {
  const _EmptyState();

  @override
  Widget build(BuildContext context) {
    final c = context.c;
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 48.h),
      child: Column(
        children: [
          Container(
            width: 64.r,
            height: 64.r,
            decoration: BoxDecoration(
              color: c.surfaceMuted,
              shape: BoxShape.circle,
            ),
            child: Icon(Icons.event_available_outlined,
                size: 30.sp, color: c.textMuted),
          ),
          SizedBox(height: 14.h),
          Text(
            CoursesStrings.nothingScheduled,
            style: TextStyle(
              fontSize: 15.sp,
              fontWeight: FontWeight.w700,
              color: c.textPrimary,
            ),
          ),
          SizedBox(height: 4.h),
          Text(
            CoursesStrings.addSyllabusHint,
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 13.sp, color: c.textMuted, height: 1.4),
          ),
        ],
      ),
    );
  }
}
