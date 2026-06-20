import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../../../core/di/service_locator.dart';
import '../../../../core/router/app_routes.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../paywall/domain/subscription.dart';
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
          padding: EdgeInsets.fromLTRB(16.w, 8.h, 16.w, 120.h),
          children: [
            _Header(
              courseCount: cubit.courses.length,
              onExport: () => _export(context, cubit),
            ),
            SizedBox(height: 12.h),
            if (cubit.uncertainCount > 0) ...[
              _UncertainBanner(count: cubit.uncertainCount),
              SizedBox(height: 12.h),
            ],
            if (upcoming != null) ...[
              _UpcomingCard(
                deliverable: upcoming.deliverable,
                course: upcoming.course,
              ),
              SizedBox(height: 24.h),
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
    // Calendar export is premium-gated.
    if (!sl<PurchasesRepository>().isSubscriber) {
      context.push(AppRoutes.paywall);
      return;
    }
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
      padding: EdgeInsetsDirectional.fromSTEB(4.w, 12.h, 0, 4.h),
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
                    fontSize: 12.sp,
                    color: c.textSecondary,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                SizedBox(height: 2.h),
                Text(
                  DateFormat('EEEE، d MMMM', 'ar').format(DateTime.now()),
                  style: TextStyle(
                    fontSize: 18.sp,
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
        borderRadius: BorderRadius.circular(12.r),
        side: BorderSide(color: c.border),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12.r),
        child: Padding(
          padding: EdgeInsets.all(10.r),
          child: Icon(icon, size: 20.sp, color: c.textSecondary),
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
        borderRadius: BorderRadius.circular(22.r),
        onTap: () => showDeliverableDetail(context, deliverable, course),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(22.r),
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
                blurRadius: 20.r,
                offset: Offset(0, 10.h),
              ),
            ],
          ),
          padding: EdgeInsets.all(20.r),
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
                            size: 12.sp, color: Colors.white),
                        SizedBox(width: 5.w),
                        Text(
                          typeLabel(deliverable.type),
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w700,
                            fontSize: 12.sp,
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
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w700,
                          fontSize: 12.sp,
                        ),
                      ),
                    ),
                ],
              ),
              SizedBox(height: 16.h),
              Text(
                deliverable.title,
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 22.sp,
                  fontWeight: FontWeight.w700,
                  letterSpacing: -0.4,
                  height: 1.2,
                ),
              ),
              SizedBox(height: 6.h),
              Text(
                course.title,
                style: TextStyle(
                  color: Colors.white.withValues(alpha: 0.78),
                  fontSize: 14.sp,
                  fontWeight: FontWeight.w500,
                ),
              ),
              SizedBox(height: 16.h),
              Row(
                children: [
                  Icon(Icons.calendar_today_outlined,
                      size: 14.sp, color: Colors.white70),
                  SizedBox(width: 6.w),
                  Text(
                    hasDate
                        ? DateFormat('EEE، d MMM', 'ar').format(deliverable.date!)
                        : (deliverable.rawDateText ?? CoursesStrings.dateTba),
                    style: TextStyle(
                      color: Colors.white.withValues(alpha: 0.9),
                      fontSize: 13.sp,
                      fontWeight: FontWeight.w500,
                      fontStyle: hasDate ? FontStyle.normal : FontStyle.italic,
                    ),
                  ),
                  if (deliverable.weight != null) ...[
                    SizedBox(width: 12.w),
                    Icon(Icons.bar_chart_rounded,
                        size: 14.sp, color: Colors.white70),
                    SizedBox(width: 4.w),
                    Text(
                      deliverable.weightPercentage,
                      style: TextStyle(
                        color: Colors.white.withValues(alpha: 0.9),
                        fontSize: 13.sp,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ],
              ),
              if (!deliverable.isClear) ...[
                SizedBox(height: 14.h),
                Container(
                  padding: EdgeInsets.fromLTRB(12.w, 9.h, 12.w, 9.h),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.16),
                    borderRadius: BorderRadius.circular(12.r),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.auto_awesome,
                          size: 14.sp, color: Colors.white),
                      SizedBox(width: 8.w),
                      Expanded(
                        child: Text(
                          deliverable.confidenceNotes ??
                              CoursesStrings.aiNeedsHelp,
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 12.sp,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                      Icon(Icons.chevron_right_rounded,
                          size: 18.sp, color: Colors.white70),
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
      padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 5.h),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.22),
        borderRadius: BorderRadius.circular(20.r),
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
      borderRadius: BorderRadius.circular(14.r),
      child: InkWell(
        borderRadius: BorderRadius.circular(14.r),
        onTap: () => _showUncertainSheet(context),
        child: Container(
          padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 12.h),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(14.r),
            border: Border.all(color: c.warning.withValues(alpha: 0.4)),
          ),
          child: Row(
            children: [
              Icon(Icons.auto_awesome, size: 16.sp, color: c.warningFg),
              SizedBox(width: 10.w),
              Expanded(
                child: Text(
                  CoursesStrings.uncertainBanner(count),
                  style: TextStyle(
                    fontSize: 13.sp,
                    fontWeight: FontWeight.w600,
                    color: c.warningFg,
                  ),
                ),
              ),
              Icon(Icons.chevron_right_rounded, size: 18.sp, color: c.warningFg),
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
          borderRadius: BorderRadius.vertical(top: Radius.circular(24.r)),
        ),
        child: Column(
          children: [
            Padding(
              padding: EdgeInsets.fromLTRB(20.w, 16.h, 20.w, 0),
              child: Row(
                children: [
                  Icon(Icons.auto_awesome, size: 18.sp, color: c.warning),
                  SizedBox(width: 8.w),
                  Text(
                    CoursesStrings.itemsNeedingReview,
                    style: TextStyle(
                      fontSize: 16.sp,
                      fontWeight: FontWeight.w700,
                      color: c.textPrimary,
                    ),
                  ),
                  const Spacer(),
                  Text(
                    '${uncertain.length}',
                    style: TextStyle(
                      fontSize: 14.sp,
                      fontWeight: FontWeight.w600,
                      color: c.textMuted,
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: 4.h),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 20.w),
              child: Align(
                alignment: AlignmentDirectional.centerStart,
                child: Text(
                  CoursesStrings.tapToSetExactDate,
                  style: TextStyle(fontSize: 12.5.sp, color: c.textSecondary),
                ),
              ),
            ),
            SizedBox(height: 12.h),
            Expanded(
              child: ListView.separated(
                controller: controller,
                padding: EdgeInsets.fromLTRB(16.w, 0, 16.w, 32.h),
                itemCount: uncertain.length,
                separatorBuilder: (_, _) => SizedBox(height: 8.h),
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
      borderRadius: BorderRadius.circular(12.r),
      child: InkWell(
        borderRadius: BorderRadius.circular(12.r),
        onTap: () => _pickDate(context),
        child: Container(
          padding: EdgeInsets.all(12.r),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12.r),
            border: Border.all(color: c.warning.withValues(alpha: 0.5)),
          ),
          child: Row(
            children: [
              Container(
                width: 36.r,
                height: 36.r,
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(9.r),
                ),
                child: Icon(Icons.auto_awesome, size: 16.sp, color: c.warning),
              ),
              SizedBox(width: 12.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      course.title,
                      style: TextStyle(
                        fontSize: 10.5.sp,
                        fontWeight: FontWeight.w700,
                        color: c.textMuted,
                      ),
                    ),
                    SizedBox(height: 2.h),
                    Text(
                      deliverable.title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 13.5.sp,
                        fontWeight: FontWeight.w600,
                        color: c.textPrimary,
                      ),
                    ),
                    if (deliverable.rawDateText != null)
                      Text(
                        deliverable.rawDateText!,
                        style: TextStyle(
                          fontSize: 11.5.sp,
                          fontStyle: FontStyle.italic,
                          color: c.warning,
                        ),
                      ),
                  ],
                ),
              ),
              Container(
                padding:
                    EdgeInsets.symmetric(horizontal: 10.w, vertical: 6.h),
                decoration: BoxDecoration(
                  color: c.accent.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(8.r),
                ),
                child: Text(
                  CoursesStrings.setDate,
                  style: TextStyle(
                    fontSize: 12.sp,
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
