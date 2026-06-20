import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';

import '../../../../core/theme/app_colors.dart';
import '../../domain/entities/course.dart';
import '../../domain/entities/deliverable.dart';
import '../courses_strings.dart';
import '../cubit/course_cubit.dart';
import '../widgets/all_deliverables_widget.dart';
import '../widgets/deliverable_detail_sheet.dart';
import '../widgets/type_glyph.dart';

class TimelinePage extends StatelessWidget {
  const TimelinePage({super.key});

  @override
  Widget build(BuildContext context) {
    final c = context.c;
    // Rebuild on course changes.
    context.watch<CourseCubit>();
    final cubit = context.read<CourseCubit>();
    final upcoming = cubit.upcomingItem;

    return Scaffold(
      backgroundColor: c.background,
      body: SafeArea(
        bottom: false,
        child: ListView(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 120),
          children: [
            _Header(
              courseCount: cubit.courses.length,
              onExport: () => _export(context, cubit),
            ),
            const SizedBox(height: 8),
            if (cubit.uncertainCount > 0) ...[
              _UncertainBanner(count: cubit.uncertainCount),
              const SizedBox(height: 12),
            ],
            if (upcoming != null) ...[
              _UpcomingCard(
                deliverable: upcoming.deliverable,
                course: upcoming.course,
              ),
              const SizedBox(height: 24),
            ],
            AllDeliverablesWidget(
              courses: cubit.courses,
              skipDeliverableId: upcoming?.deliverable.id,
            ),
          ],
        ),
      ),
    );
  }

  void _export(BuildContext context, CourseCubit cubit) {
    cubit.exportToCalendar();
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text(CoursesStrings.calendarExportComingSoon)),
    );
  }
}

// ── Header ──────────────────────────────────────────────────────────────────────

class _Header extends StatelessWidget {
  final int courseCount;
  final VoidCallback onExport;

  const _Header({required this.courseCount, required this.onExport});

  String get _greeting {
    final h = DateTime.now().hour;
    if (h < 12) return CoursesStrings.goodMorning;
    if (h < 18) return CoursesStrings.goodAfternoon;
    return CoursesStrings.goodEvening;
  }

  @override
  Widget build(BuildContext context) {
    final c = context.c;
    return Padding(
      padding: const EdgeInsetsDirectional.fromSTEB(4, 12, 0, 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _greeting,
                  style: TextStyle(
                    fontSize: 14,
                    color: c.textSecondary,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  DateFormat('EEEE، d MMMM', 'ar').format(DateTime.now()),
                  style: TextStyle(
                    fontSize: 26,
                    fontWeight: FontWeight.w800,
                    color: c.textPrimary,
                    letterSpacing: -0.5,
                  ),
                ),
              ],
            ),
          ),
          _IconButton(icon: Icons.ios_share_rounded, onTap: onExport),
        ],
      ),
    );
  }
}

class _IconButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;
  const _IconButton({required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final c = context.c;
    return Material(
      color: c.surface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: c.border),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(10),
          child: Icon(icon, size: 20, color: c.textSecondary),
        ),
      ),
    );
  }
}

// ── Upcoming hero card ────────────────────────────────────────────────────────

class _UpcomingCard extends StatelessWidget {
  final Deliverable deliverable;
  final Course course;

  const _UpcomingCard({required this.deliverable, required this.course});

  @override
  Widget build(BuildContext context) {
    final base = courseColorRaw(course.color);
    final hasDate = deliverable.date != null;
    final daysLeft =
        hasDate ? deliverable.date!.difference(DateTime.now()).inDays : null;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(22),
        onTap: () => showDeliverableDetail(context, deliverable, course),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(22),
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                base,
                Color.lerp(base, Colors.black, 0.22)!,
              ],
            ),
            boxShadow: [
              BoxShadow(
                color: base.withValues(alpha: 0.35),
                blurRadius: 20,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  _glassPill(
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(typeIcon(deliverable.type),
                            size: 12, color: Colors.white),
                        const SizedBox(width: 5),
                        Text(
                          typeLabel(deliverable.type),
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w700,
                            fontSize: 12,
                            letterSpacing: 0.2,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const Spacer(),
                  if (daysLeft != null)
                    _glassPill(
                      child: Text(
                        daysLeft <= 0
                            ? CoursesStrings.today
                            : daysLeft == 1
                                ? CoursesStrings.tomorrow
                                : CoursesStrings.inDays(daysLeft),
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w700,
                          fontSize: 12,
                        ),
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 16),
              Text(
                deliverable.title,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 22,
                  fontWeight: FontWeight.w700,
                  letterSpacing: -0.4,
                  height: 1.2,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                course.title,
                style: TextStyle(
                  color: Colors.white.withValues(alpha: 0.78),
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  const Icon(Icons.calendar_today_outlined,
                      size: 14, color: Colors.white70),
                  const SizedBox(width: 6),
                  Text(
                    hasDate
                        ? DateFormat('EEE، d MMM', 'ar').format(deliverable.date!)
                        : (deliverable.rawDateText ?? CoursesStrings.dateTba),
                    style: TextStyle(
                      color: Colors.white.withValues(alpha: 0.9),
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                      fontStyle: hasDate ? FontStyle.normal : FontStyle.italic,
                    ),
                  ),
                  if (deliverable.weight != null) ...[
                    const SizedBox(width: 12),
                    const Icon(Icons.bar_chart_rounded,
                        size: 14, color: Colors.white70),
                    const SizedBox(width: 4),
                    Text(
                      deliverable.weightPercentage,
                      style: TextStyle(
                        color: Colors.white.withValues(alpha: 0.9),
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ],
              ),
              if (!deliverable.isClear) ...[
                const SizedBox(height: 14),
                Container(
                  padding: const EdgeInsets.fromLTRB(12, 9, 12, 9),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.16),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.auto_awesome,
                          size: 14, color: Colors.white),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          deliverable.confidenceNotes ??
                              CoursesStrings.aiNeedsHelp,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                      const Icon(Icons.chevron_right_rounded,
                          size: 18, color: Colors.white70),
                    ],
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _glassPill({required Widget child}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.22),
        borderRadius: BorderRadius.circular(20),
      ),
      child: child,
    );
  }
}

// ── Uncertain items banner ────────────────────────────────────────────────────

class _UncertainBanner extends StatelessWidget {
  final int count;
  const _UncertainBanner({required this.count});

  @override
  Widget build(BuildContext context) {
    final c = context.c;
    return Material(
      color: c.warningBg,
      borderRadius: BorderRadius.circular(14),
      child: InkWell(
        borderRadius: BorderRadius.circular(14),
        onTap: () => _showUncertainSheet(context),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: c.warning.withValues(alpha: 0.4)),
          ),
          child: Row(
            children: [
              Icon(Icons.auto_awesome, size: 16, color: c.warningFg),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  CoursesStrings.uncertainBanner(count),
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: c.warningFg,
                  ),
                ),
              ),
              Icon(Icons.chevron_right_rounded, size: 18, color: c.warningFg),
            ],
          ),
        ),
      ),
    );
  }

  void _showUncertainSheet(BuildContext context) {
    final cubit = context.read<CourseCubit>();
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => BlocProvider.value(
        value: cubit,
        child: const _UncertainSheet(),
      ),
    );
  }
}

class _UncertainSheet extends StatelessWidget {
  const _UncertainSheet();

  @override
  Widget build(BuildContext context) {
    final c = context.c;
    // Rebuild as items get resolved.
    context.watch<CourseCubit>();
    final uncertain = context
        .read<CourseCubit>()
        .sortedDeliverables
        .where((i) => !i.deliverable.isClear)
        .toList();

    return DraggableScrollableSheet(
      initialChildSize: 0.6,
      maxChildSize: 0.9,
      minChildSize: 0.4,
      builder: (_, controller) => Container(
        decoration: BoxDecoration(
          color: c.surface,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
              child: Row(
                children: [
                  Icon(Icons.auto_awesome, size: 18, color: c.warning),
                  const SizedBox(width: 8),
                  Text(
                    CoursesStrings.itemsNeedingReview,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: c.textPrimary,
                    ),
                  ),
                  const Spacer(),
                  Text(
                    '${uncertain.length}',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: c.textMuted,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 4),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Align(
                alignment: AlignmentDirectional.centerStart,
                child: Text(
                  CoursesStrings.tapToSetExactDate,
                  style: TextStyle(fontSize: 12.5, color: c.textSecondary),
                ),
              ),
            ),
            const SizedBox(height: 12),
            Expanded(
              child: ListView.separated(
                controller: controller,
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 32),
                itemCount: uncertain.length,
                separatorBuilder: (_, _) => const SizedBox(height: 8),
                itemBuilder: (ctx, i) {
                  final item = uncertain[i];
                  return _UncertainTile(
                    deliverable: item.deliverable,
                    course: item.course,
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _UncertainTile extends StatelessWidget {
  final Deliverable deliverable;
  final Course course;
  const _UncertainTile({required this.deliverable, required this.course});

  @override
  Widget build(BuildContext context) {
    final c = context.c;
    final color = courseColorRaw(course.color);

    return Material(
      color: c.surfaceAlt,
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () => _pickDate(context),
        child: Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: c.warning.withValues(alpha: 0.5)),
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
                child: Icon(Icons.auto_awesome, size: 16, color: c.warning),
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
                        color: c.textMuted,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      deliverable.title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 13.5,
                        fontWeight: FontWeight.w600,
                        color: c.textPrimary,
                      ),
                    ),
                    if (deliverable.rawDateText != null)
                      Text(
                        deliverable.rawDateText!,
                        style: TextStyle(
                          fontSize: 11.5,
                          fontStyle: FontStyle.italic,
                          color: c.warning,
                        ),
                      ),
                  ],
                ),
              ),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                decoration: BoxDecoration(
                  color: c.accent.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  CoursesStrings.setDate,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    color: c.accent,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _pickDate(BuildContext context) async {
    final cubit = context.read<CourseCubit>();
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: now,
      firstDate: DateTime(now.year - 1),
      lastDate: DateTime(now.year + 3),
    );
    if (picked == null) return;
    await cubit.updateDeliverableDate(course.id, deliverable.id, picked);
  }
}
