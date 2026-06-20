import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../../../core/theme/app_colors.dart';
import '../../domain/entities/course.dart';
import '../../domain/entities/deliverable.dart';
import '../courses_strings.dart';
import '../cubit/course_cubit.dart';
import '../widgets/type_glyph.dart';

class CourseConfirmationPage extends StatelessWidget {
  final List<Course> courses;

  const CourseConfirmationPage({super.key, required this.courses});

  Future<void> _confirm(BuildContext context) async {
    final cubit = context.read<CourseCubit>();
    final messenger = ScaffoldMessenger.of(context);
    for (final course in courses) {
      await cubit.addCourse(course);
    }
    if (context.mounted) context.pop();
    messenger.showSnackBar(
      SnackBar(
        content: Text(
          courses.length == 1
              ? CoursesStrings.courseAdded
              : CoursesStrings.coursesAdded(courses.length),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final c = context.c;
    final courseLabel = CoursesStrings.courseCountLabel(courses.length);

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
              padding: const EdgeInsets.all(16),
              itemCount: courses.length,
              separatorBuilder: (_, _) => const SizedBox(height: 12),
              itemBuilder: (_, i) => _CourseCard(course: courses[i]),
            ),
          ),
          _ConfirmBar(
            courseLabel: courseLabel,
            onCancel: () => context.pop(),
            onConfirm: () => _confirm(context),
          ),
        ],
      ),
    );
  }
}

// ── Course card ───────────────────────────────────────────────────────────────

class _CourseCard extends StatelessWidget {
  final Course course;

  const _CourseCard({required this.course});

  @override
  Widget build(BuildContext context) {
    final c = context.c;
    final color = courseColor(context, course.color);
    return Container(
      decoration: BoxDecoration(
        color: c.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: c.border),
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.fromLTRB(16, 14, 16, 14),
            color: color,
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    course.title,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      letterSpacing: -0.2,
                    ),
                  ),
                ),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.22),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    CoursesStrings.itemsBadge(course.deliverables.length),
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
          ),
          ...course.deliverables.map(
            (d) => _DeliverableRow(
              deliverable: d,
              courseColor: color,
              isLast: d == course.deliverables.last,
            ),
          ),
        ],
      ),
    );
  }
}

// ── Deliverable row ───────────────────────────────────────────────────────────

class _DeliverableRow extends StatelessWidget {
  final Deliverable deliverable;
  final Color courseColor;
  final bool isLast;

  const _DeliverableRow({
    required this.deliverable,
    required this.courseColor,
    required this.isLast,
  });

  @override
  Widget build(BuildContext context) {
    final c = context.c;
    final hasDate = deliverable.date != null;

    return Container(
      decoration: BoxDecoration(
        border: isLast
            ? null
            : Border(bottom: BorderSide(color: c.borderSubtle)),
      ),
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
      child: Row(
        children: [
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: courseColor.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(8),
            ),
            child:
                Icon(typeIcon(deliverable.type), size: 16, color: courseColor),
          ),
          const SizedBox(width: 12),
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
                          fontSize: 13.5,
                          fontWeight: FontWeight.w600,
                          color: c.textPrimary,
                        ),
                      ),
                    ),
                    if (!deliverable.isClear)
                      Tooltip(
                        message: CoursesStrings.dateNeedsReview,
                        child: Icon(Icons.auto_awesome,
                            size: 13, color: c.warning),
                      ),
                  ],
                ),
                const SizedBox(height: 2),
                Text(
                  hasDate
                      ? DateFormat('EEE، d MMM', 'ar').format(deliverable.date!)
                      : (deliverable.rawDateText ?? CoursesStrings.dateTba),
                  style: TextStyle(
                    fontSize: 12,
                    color: hasDate ? c.textSecondary : c.warning,
                    fontStyle: hasDate ? FontStyle.normal : FontStyle.italic,
                  ),
                ),
              ],
            ),
          ),
          if (deliverable.weight != null) ...[
            const SizedBox(width: 8),
            Text(
              deliverable.weightPercentage,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: c.textMuted,
              ),
            ),
          ],
        ],
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
        16,
        12,
        16,
        12 + MediaQuery.of(context).padding.bottom,
      ),
      child: Row(
        children: [
          Expanded(
              child: _OutlineButton(
                  label: CoursesStrings.cancel, onTap: onCancel)),
          const SizedBox(width: 10),
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
      borderRadius: BorderRadius.circular(14),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(14),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 14),
          child: Text(
            label,
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w700,
              fontSize: 15,
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
      borderRadius: BorderRadius.circular(14),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(14),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 14),
          decoration: BoxDecoration(
            border: Border.all(color: c.border),
            borderRadius: BorderRadius.circular(14),
          ),
          child: Text(
            label,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: c.textPrimary,
              fontWeight: FontWeight.w700,
              fontSize: 14,
            ),
          ),
        ),
      ),
    );
  }
}
