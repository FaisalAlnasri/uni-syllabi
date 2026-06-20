import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/intl.dart';

import '../../../../core/theme/app_colors.dart';
import '../../domain/entities/course.dart';
import '../../domain/entities/deliverable.dart';
import '../courses_strings.dart';
import '../cubit/course_cubit.dart';
import '../widgets/deliverable_detail_sheet.dart';
import '../widgets/type_glyph.dart';

class CourseDetailPage extends StatelessWidget {
  final Course course;

  const CourseDetailPage({super.key, required this.course});

  @override
  Widget build(BuildContext context) {
    final c = context.c;
    final color = courseColor(context, course.color);

    // Re-read the live course from the cubit so edits reflect instantly.
    context.watch<CourseCubit>();
    final live = context.read<CourseCubit>().courses.firstWhere(
          (e) => e.id == course.id,
          orElse: () => course,
        );

    final sorted = [...live.deliverables]..sort((a, b) {
        final da = a.date, db = b.date;
        if (da == null && db == null) return 0;
        if (da == null) return 1;
        if (db == null) return -1;
        return da.compareTo(db);
      });

    final totalWeight = live.deliverables
        .where((d) => d.weight != null)
        .fold<double>(0, (s, d) => s + d.weight!);

    return Scaffold(
      backgroundColor: c.background,
      appBar: AppBar(title: Text(live.title)),
      body: ListView(
        padding: EdgeInsets.fromLTRB(16.w, 8.h, 16.w, 32.h),
        children: [
          _SummaryCard(
            color: color,
            itemCount: live.deliverables.length,
            totalWeight: totalWeight,
          ),
          SizedBox(height: 20.h),
          Padding(
            padding: EdgeInsetsDirectional.only(start: 4.w, bottom: 10.h),
            child: Text(
              CoursesStrings.deliverablesSection,
              style: TextStyle(
                fontSize: 11.sp,
                fontWeight: FontWeight.w700,
                color: c.textMuted,
                letterSpacing: 0.8,
              ),
            ),
          ),
          for (final d in sorted)
            Padding(
              padding: EdgeInsets.only(bottom: 10.h),
              child: _DeliverableTile(
                deliverable: d,
                course: live,
                color: color,
              ),
            ),
        ],
      ),
    );
  }
}

class _SummaryCard extends StatelessWidget {
  final Color color;
  final int itemCount;
  final double totalWeight;

  const _SummaryCard({
    required this.color,
    required this.itemCount,
    required this.totalWeight,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(18.r),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [color, Color.lerp(color, Colors.black, 0.22)!],
        ),
        boxShadow: [
          BoxShadow(
            color: color.withValues(alpha: 0.3),
            blurRadius: 18.r,
            offset: Offset(0, 8.h),
          ),
        ],
      ),
      padding: EdgeInsets.all(20.r),
      child: Row(
        children: [
          _Stat(value: '$itemCount', label: CoursesStrings.deliverables),
          Container(
            width: 1.w,
            height: 36.h,
            color: Colors.white.withValues(alpha: 0.25),
            margin: EdgeInsets.symmetric(horizontal: 20.w),
          ),
          _Stat(
            value: totalWeight > 0
                ? '${(totalWeight * 100).toStringAsFixed(0)}%'
                : '—',
            label: CoursesStrings.gradedWeight,
          ),
        ],
      ),
    );
  }
}

class _Stat extends StatelessWidget {
  final String value;
  final String label;
  const _Stat({required this.value, required this.label});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          value,
          style: TextStyle(
            color: Colors.white,
            fontSize: 24.sp,
            fontWeight: FontWeight.w800,
          ),
        ),
        SizedBox(height: 2.h),
        Text(
          label,
          style: TextStyle(
            color: Colors.white.withValues(alpha: 0.8),
            fontSize: 12.sp,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }
}

class _DeliverableTile extends StatelessWidget {
  final Deliverable deliverable;
  final Course course;
  final Color color;

  const _DeliverableTile({
    required this.deliverable,
    required this.course,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    final c = context.c;
    final hasDate = deliverable.date != null;
    final hasWarning = deliverable.confidenceNotes != null;

    return Material(
      color: c.surface,
      borderRadius: BorderRadius.circular(12.r),
      child: InkWell(
        borderRadius: BorderRadius.circular(12.r),
        onTap: () => showDeliverableDetail(context, deliverable, course),
        child: Container(
          padding: EdgeInsets.all(12.r),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12.r),
            border: Border.all(
              color: hasWarning ? c.warning : c.border,
              width: hasWarning ? 1.5 : 1,
            ),
          ),
          child: Row(
            children: [
              Container(
                width: 38.r,
                height: 38.r,
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(10.r),
                ),
                child: Icon(typeIcon(deliverable.type), size: 18.sp, color: color),
              ),
              SizedBox(width: 12.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      deliverable.title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 14.sp,
                        fontWeight: FontWeight.w600,
                        color: c.textPrimary,
                      ),
                    ),
                    SizedBox(height: 3.h),
                    Text(
                      hasDate
                          ? DateFormat('EEE، d MMM yyyy', 'ar')
                              .format(deliverable.date!)
                          : (deliverable.rawDateText ?? CoursesStrings.dateTba),
                      style: TextStyle(
                        fontSize: 12.sp,
                        color: hasDate ? c.textSecondary : c.warning,
                        fontStyle:
                            hasDate ? FontStyle.normal : FontStyle.italic,
                      ),
                    ),
                  ],
                ),
              ),
              if (deliverable.weight != null)
                Text(
                  deliverable.weightPercentage,
                  style: TextStyle(
                    fontSize: 13.sp,
                    fontWeight: FontWeight.w700,
                    color: c.textSecondary,
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
