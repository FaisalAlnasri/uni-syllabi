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
import '../widgets/deliverable_form_sheet.dart';
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

    return Scaffold(
      backgroundColor: c.background,
      appBar: AppBar(title: Text(live.title)),
      body: ListView(
        padding: EdgeInsets.fromLTRB(16.w, 8.h, 16.w, 32.h),
        children: [
          SizedBox(height: 8.h),
          Padding(
            padding: EdgeInsetsDirectional.only(start: 4.w, bottom: 10.h),
            child: Row(
              children: [
                Expanded(
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
                _AddDeliverableButton(course: live),
              ],
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
          SizedBox(height: 12.h),
          _DeleteCourseButton(course: live),
        ],
      ),
    );
  }
}

/// Compact pill button that opens the deliverable form locked to [course],
/// then appends the result through the cubit.
class _AddDeliverableButton extends StatelessWidget {
  final Course course;
  const _AddDeliverableButton({required this.course});

  @override
  Widget build(BuildContext context) {
    final c = context.c;
    final accent = c.accent;

    return Material(
      color: accent.withValues(alpha: 0.10),
      borderRadius: BorderRadius.circular(20.r),
      child: InkWell(
        borderRadius: BorderRadius.circular(20.r),
        onTap: () => showAddDeliverableSheet(context, lockedCourse: course),
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.add_rounded, size: 16.sp, color: accent),
              SizedBox(width: 4.w),
              Text(
                CoursesStrings.addDeliverableOption,
                style: TextStyle(
                  color: accent,
                  fontWeight: FontWeight.w700,
                  fontSize: 12.sp,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Confirms a destructive action through a standard dialog. Returns `true` when
/// the user taps the confirm button.
Future<bool> _confirmDelete(
  BuildContext context, {
  required String title,
  required String body,
}) async {
  final c = context.c;
  final result = await showDialog<bool>(
    context: context,
    builder: (ctx) => AlertDialog(
      backgroundColor: c.surface,
      title: Text(title, style: TextStyle(color: c.textPrimary)),
      content: Text(body, style: TextStyle(color: c.textSecondary)),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(ctx).pop(false),
          child: Text(
            CoursesStrings.cancel,
            style: TextStyle(color: c.textSecondary),
          ),
        ),
        TextButton(
          onPressed: () => Navigator.of(ctx).pop(true),
          child: Text(
            CoursesStrings.remove,
            style: TextStyle(
              color: Theme.of(ctx).colorScheme.error,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
      ],
    ),
  );
  return result ?? false;
}

class _DeleteCourseButton extends StatelessWidget {
  final Course course;
  const _DeleteCourseButton({required this.course});

  @override
  Widget build(BuildContext context) {
    final error = Theme.of(context).colorScheme.error;

    return SizedBox(
      width: double.infinity,
      child: Material(
        color: error.withValues(alpha: 0.10),
        borderRadius: BorderRadius.circular(14.r),
        child: InkWell(
          borderRadius: BorderRadius.circular(14.r),
          onTap: () async {
            final cubit = context.read<CourseCubit>();
            final messenger = ScaffoldMessenger.of(context);
            final router = Navigator.of(context);
            final confirmed = await _confirmDelete(
              context,
              title: CoursesStrings.removeCourseTitle,
              body: CoursesStrings.removeCourseBody(course.title),
            );
            if (!confirmed) return;
            await cubit.deleteCourse(course.id);
            router.pop();
            messenger.showSnackBar(
              const SnackBar(content: Text(CoursesStrings.courseDeleted)),
            );
          },
          child: Padding(
            padding: EdgeInsets.symmetric(vertical: 15.h),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.delete_outline_rounded, size: 18.sp, color: error),
                SizedBox(width: 8.w),
                Text(
                  CoursesStrings.deleteCourse,
                  style: TextStyle(
                    color: error,
                    fontWeight: FontWeight.w700,
                    fontSize: 15.sp,
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
              SizedBox(width: 4.w),
              IconButton(
                onPressed: () async {
                  final cubit = context.read<CourseCubit>();
                  final messenger = ScaffoldMessenger.of(context);
                  final confirmed = await _confirmDelete(
                    context,
                    title: CoursesStrings.removeDeliverableTitle,
                    body: CoursesStrings.removeDeliverableBody(
                        deliverable.title),
                  );
                  if (!confirmed) return;
                  await cubit.deleteDeliverable(course.id, deliverable.id);
                  messenger.showSnackBar(
                    const SnackBar(
                      content: Text(CoursesStrings.deliverableDeleted),
                    ),
                  );
                },
                visualDensity: VisualDensity.compact,
                padding: EdgeInsets.zero,
                constraints: BoxConstraints(minWidth: 32.r, minHeight: 32.r),
                icon: Icon(
                  Icons.delete_outline_rounded,
                  size: 18.sp,
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
