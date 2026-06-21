import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../../../core/theme/app_colors.dart';
import '../../domain/entities/course.dart';
import '../../domain/entities/deliverable.dart';
import '../courses_strings.dart';
import '../cubit/course_cubit.dart';
import '../widgets/course_form_sheet.dart';
import '../widgets/deliverable_form_sheet.dart';
import '../widgets/type_glyph.dart';

/// Reviews freshly parsed [courses] before they're committed. Courses and their
/// deliverables can be edited inline, and deliverables swiped away, all against
/// local state — nothing is persisted until the user confirms.
class CourseConfirmationPage extends StatefulWidget {
  final List<Course> courses;

  const CourseConfirmationPage({super.key, required this.courses});

  @override
  State<CourseConfirmationPage> createState() => _CourseConfirmationPageState();
}

class _CourseConfirmationPageState extends State<CourseConfirmationPage> {
  late List<Course> _courses;

  @override
  void initState() {
    super.initState();
    _courses = List.of(widget.courses);
  }

  void _replaceCourse(Course updated) {
    setState(() {
      _courses = [
        for (final course in _courses)
          course.id == updated.id ? updated : course,
      ];
    });
  }

  Course _withDeliverables(Course course, List<Deliverable> deliverables) =>
      Course(
        id: course.id,
        title: course.title,
        color: course.color,
        iconKey: course.iconKey,
        deliverables: deliverables,
      );

  Future<void> _editCourse(Course course) async {
    final updated = await showEditCourseDetailsSheet(context, course);
    if (updated != null) _replaceCourse(updated);
  }

  Future<void> _editDeliverable(Course course, Deliverable deliverable) async {
    final updated = await showEditDeliverableSheet(context, deliverable);
    if (updated == null) return;
    _replaceCourse(
      _withDeliverables(course, [
        for (final d in course.deliverables)
          d.id == updated.id ? updated : d,
      ]),
    );
  }

  Future<bool> _confirmDeleteDeliverable(
      Course course, Deliverable deliverable) async {
    final c = context.c;
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: c.surface,
        title: Text(
          CoursesStrings.removeDeliverableTitle,
          style: TextStyle(color: c.textPrimary),
        ),
        content: Text(
          CoursesStrings.removeDeliverableBody(deliverable.title),
          style: TextStyle(color: c.textSecondary),
        ),
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
    if (confirmed != true) return false;
    _replaceCourse(
      _withDeliverables(course, [
        for (final d in course.deliverables)
          if (d.id != deliverable.id) d,
      ]),
    );
    return true;
  }

  Future<void> _confirm() async {
    final cubit = context.read<CourseCubit>();
    final messenger = ScaffoldMessenger.of(context);
    for (final course in _courses) {
      await cubit.addCourse(course);
    }
    if (mounted) context.pop();
    messenger.showSnackBar(
      SnackBar(
        content: Text(
          _courses.length == 1
              ? CoursesStrings.courseAdded
              : CoursesStrings.coursesAdded(_courses.length),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final c = context.c;
    final courseLabel = CoursesStrings.courseCountLabel(_courses.length);

    return Scaffold(
      backgroundColor: c.background,
      appBar: AppBar(
        title: const Text(CoursesStrings.reviewCourses),
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: () => context.pop(),
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.separated(
              padding: EdgeInsets.all(16.r),
              itemCount: _courses.length,
              separatorBuilder: (_, _) => SizedBox(height: 12.h),
              itemBuilder: (_, i) {
                final course = _courses[i];
                return _CourseCard(
                  course: course,
                  onEditCourse: () => _editCourse(course),
                  onEditDeliverable: (d) => _editDeliverable(course, d),
                  onDeleteDeliverable: (d) =>
                      _confirmDeleteDeliverable(course, d),
                );
              },
            ),
          ),
          _ConfirmBar(
            courseLabel: courseLabel,
            onCancel: () => context.pop(),
            onConfirm: _confirm,
          ),
        ],
      ),
    );
  }
}

// ── Course card ───────────────────────────────────────────────────────────────

class _CourseCard extends StatelessWidget {
  final Course course;
  final VoidCallback onEditCourse;
  final ValueChanged<Deliverable> onEditDeliverable;
  final Future<bool> Function(Deliverable) onDeleteDeliverable;

  const _CourseCard({
    required this.course,
    required this.onEditCourse,
    required this.onEditDeliverable,
    required this.onDeleteDeliverable,
  });

  @override
  Widget build(BuildContext context) {
    final c = context.c;
    final color = courseColor(context, course.color);
    return Container(
      decoration: BoxDecoration(
        color: c.surface,
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(color: c.border),
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Material(
            color: color,
            child: InkWell(
              onTap: onEditCourse,
              child: Padding(
                padding: EdgeInsets.fromLTRB(16.w, 14.h, 16.w, 14.h),
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        course.title,
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 16.sp,
                          fontWeight: FontWeight.w700,
                          letterSpacing: -0.2,
                        ),
                      ),
                    ),
                    Icon(Icons.edit_outlined, size: 16.sp, color: Colors.white),
                    SizedBox(width: 8.w),
                    Container(
                      padding:
                          EdgeInsets.symmetric(horizontal: 8.w, vertical: 3.h),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.22),
                        borderRadius: BorderRadius.circular(20.r),
                      ),
                      child: Text(
                        CoursesStrings.itemsBadge(course.deliverables.length),
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 12.sp,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          for (final d in course.deliverables)
            Dismissible(
              key: ValueKey('confirm-deliverable-${course.id}-${d.id}'),
              direction: DismissDirection.endToStart,
              background: const _SwipeDeleteBackground(),
              confirmDismiss: (_) => onDeleteDeliverable(d),
              child: _DeliverableRow(
                deliverable: d,
                courseColor: color,
                isLast: d == course.deliverables.last,
                onTap: () => onEditDeliverable(d),
              ),
            ),
        ],
      ),
    );
  }
}

// ── Swipe-to-delete background ────────────────────────────────────────────────

/// The red "delete" affordance revealed as a deliverable row is swiped away.
class _SwipeDeleteBackground extends StatelessWidget {
  const _SwipeDeleteBackground();

  @override
  Widget build(BuildContext context) {
    final error = Theme.of(context).colorScheme.error;
    return Container(
      color: error.withValues(alpha: 0.12),
      padding: EdgeInsetsDirectional.only(end: 20.w),
      alignment: AlignmentDirectional.centerEnd,
      child: Icon(Icons.delete_outline_rounded, size: 22.sp, color: error),
    );
  }
}

// ── Deliverable row ───────────────────────────────────────────────────────────

class _DeliverableRow extends StatelessWidget {
  final Deliverable deliverable;
  final Color courseColor;
  final bool isLast;
  final VoidCallback onTap;

  const _DeliverableRow({
    required this.deliverable,
    required this.courseColor,
    required this.isLast,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final c = context.c;
    final hasDate = deliverable.date != null;

    return Material(
      color: c.surface,
      child: InkWell(
        onTap: onTap,
        child: Container(
          decoration: BoxDecoration(
            border: isLast
                ? null
                : Border(bottom: BorderSide(color: c.borderSubtle)),
          ),
          padding: EdgeInsets.fromLTRB(16.w, 12.h, 16.w, 12.h),
          child: Row(
            children: [
              Container(
                width: 32.r,
                height: 32.r,
                decoration: BoxDecoration(
                  color: courseColor.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(8.r),
                ),
                child: Icon(typeIcon(deliverable.type),
                    size: 16.sp, color: courseColor),
              ),
              SizedBox(width: 12.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            deliverable.title,
                            style: TextStyle(
                              fontSize: 13.5.sp,
                              fontWeight: FontWeight.w600,
                              color: c.textPrimary,
                            ),
                          ),
                        ),
                        if (!deliverable.isClear)
                          Tooltip(
                            message: CoursesStrings.dateNeedsReview,
                            child: Icon(Icons.auto_awesome,
                                size: 13.sp, color: c.warning),
                          ),
                      ],
                    ),
                    SizedBox(height: 2.h),
                    Text(
                      hasDate
                          ? DateFormat('EEE، d MMM', 'ar')
                              .format(deliverable.date!)
                          : (deliverable.rawDateText ?? CoursesStrings.dateTba),
                      style: TextStyle(
                        fontSize: 12.sp,
                        color: hasDate ? c.textSecondary : c.warning,
                        fontStyle: hasDate ? FontStyle.normal : FontStyle.italic,
                      ),
                    ),
                  ],
                ),
              ),
              if (deliverable.weight != null) ...[
                SizedBox(width: 8.w),
                Text(
                  deliverable.weightPercentage,
                  style: TextStyle(
                    fontSize: 12.sp,
                    fontWeight: FontWeight.w600,
                    color: c.textMuted,
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

// ── Bottom confirm bar ────────────────────────────────────────────────────────

class _ConfirmBar extends StatelessWidget {
  final String courseLabel;
  final VoidCallback onCancel;
  final VoidCallback onConfirm;

  const _ConfirmBar({
    required this.courseLabel,
    required this.onCancel,
    required this.onConfirm,
  });

  @override
  Widget build(BuildContext context) {
    final c = context.c;
    return Container(
      decoration: BoxDecoration(
        color: c.surface,
        border: Border(top: BorderSide(color: c.border)),
      ),
      padding: EdgeInsets.fromLTRB(
        16.w,
        12.h,
        16.w,
        12.h + MediaQuery.of(context).padding.bottom,
      ),
      child: Row(
        children: [
          Expanded(
              child: _OutlineButton(
                  label: CoursesStrings.cancel, onTap: onCancel)),
          SizedBox(width: 10.w),
          Expanded(
            flex: 2,
            child: _FilledButton(
                label: CoursesStrings.addCourses(courseLabel),
                onTap: onConfirm),
          ),
        ],
      ),
    );
  }
}

class _FilledButton extends StatelessWidget {
  final String label;
  final VoidCallback onTap;
  const _FilledButton({required this.label, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final c = context.c;
    return Material(
      color: c.accent,
      borderRadius: BorderRadius.circular(14.r),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(14.r),
        child: Padding(
          padding: EdgeInsets.symmetric(vertical: 14.h),
          child: Text(
            label,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w700,
              fontSize: 15.sp,
              letterSpacing: -0.1,
            ),
          ),
        ),
      ),
    );
  }
}

class _OutlineButton extends StatelessWidget {
  final String label;
  final VoidCallback onTap;
  const _OutlineButton({required this.label, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final c = context.c;
    return Material(
      color: c.surface,
      borderRadius: BorderRadius.circular(14.r),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(14.r),
        child: Container(
          padding: EdgeInsets.symmetric(vertical: 14.h),
          decoration: BoxDecoration(
            border: Border.all(color: c.border),
            borderRadius: BorderRadius.circular(14.r),
          ),
          child: Text(
            label,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: c.textPrimary,
              fontWeight: FontWeight.w700,
              fontSize: 14.sp,
            ),
          ),
        ),
      ),
    );
  }
}
