import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/intl.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/utils/id_generator.dart';
import '../../../../core/widgets/app_text_field.dart';
import '../../domain/entities/course.dart';
import '../../domain/entities/deliverable.dart';
import '../courses_strings.dart';
import '../cubit/course_cubit.dart';
import 'type_glyph.dart';

/// Result of the deliverable form: the built [deliverable] plus, when a course
/// picker was shown, the chosen [courseId].
typedef _FormResult = ({String? courseId, Deliverable deliverable});

/// Adds a deliverable to an existing course. Shows a course picker unless
/// [lockedCourse] is provided. No-ops with a snackbar when there are no courses.
Future<void> showAddDeliverableSheet(
  BuildContext context, {
  Course? lockedCourse,
}) async {
  final cubit = context.read<CourseCubit>();
  final messenger = ScaffoldMessenger.of(context);
  final courses = cubit.courses;

  if (courses.isEmpty) {
    messenger.showSnackBar(
      const SnackBar(content: Text(CoursesStrings.noCoursesToAddTo)),
    );
    return;
  }

  final result = await showModalBottomSheet<_FormResult>(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (_) => _DeliverableFormSheet(
      courses: courses,
      lockedCourse: lockedCourse,
    ),
  );

  if (result == null || result.courseId == null) return;
  await cubit.addDeliverable(result.courseId!, result.deliverable);
  messenger.showSnackBar(
    const SnackBar(content: Text(CoursesStrings.deliverableAdded)),
  );
}

/// Builds a standalone deliverable (no course picker) for the new-course flow.
Future<Deliverable?> showNewDeliverableSheet(BuildContext context) async {
  final result = await showModalBottomSheet<_FormResult>(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (_) => const _DeliverableFormSheet(courses: []),
  );
  return result?.deliverable;
}

class _DeliverableFormSheet extends StatefulWidget {
  /// Available courses for the picker. Empty list hides the picker (the form
  /// then just returns a deliverable).
  final List<Course> courses;
  final Course? lockedCourse;

  const _DeliverableFormSheet({required this.courses, this.lockedCourse});

  @override
  State<_DeliverableFormSheet> createState() => _DeliverableFormSheetState();
}

class _DeliverableFormSheetState extends State<_DeliverableFormSheet> {
  final _titleController = TextEditingController();
  final _weightController = TextEditingController();
  DeliverableType _type = DeliverableType.assignment;
  DateTime? _date;
  String? _selectedCourseId;
  String? _error;

  bool get _showPicker => widget.courses.isNotEmpty;

  @override
  void initState() {
    super.initState();
    _selectedCourseId =
        widget.lockedCourse?.id ?? widget.courses.firstOrNull?.id;
  }

  @override
  void dispose() {
    _titleController.dispose();
    _weightController.dispose();
    super.dispose();
  }

  Future<void> _pickDate() async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: _date ?? now,
      firstDate: DateTime(now.year - 1),
      lastDate: DateTime(now.year + 3),
    );
    if (picked != null) setState(() => _date = picked);
  }

  void _submit() {
    final title = _titleController.text.trim();
    if (title.isEmpty) {
      setState(() => _error = CoursesStrings.enterDeliverableTitle);
      return;
    }
    if (_showPicker && _selectedCourseId == null) {
      setState(() => _error = CoursesStrings.chooseCourseFirst);
      return;
    }

    final raw = double.tryParse(_weightController.text.trim());
    final weight = raw != null ? (raw / 100).clamp(0.0, 1.0) : null;

    final deliverable = Deliverable(
      id: generateId(),
      title: title,
      type: _type,
      date: _date,
      weight: weight,
      isClear: true,
    );

    Navigator.of(context).pop<_FormResult>(
      (courseId: _showPicker ? _selectedCourseId : null, deliverable: deliverable),
    );
  }

  @override
  Widget build(BuildContext context) {
    final c = context.c;
    final hasDate = _date != null;

    return Padding(
      padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
      child: Container(
        decoration: BoxDecoration(
          color: c.surface,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24.r)),
        ),
        padding: EdgeInsets.fromLTRB(
          20.w,
          12.h,
          20.w,
          20.h + MediaQuery.of(context).padding.bottom,
        ),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 40.w,
                  height: 4.h,
                  decoration: BoxDecoration(
                    color: c.border,
                    borderRadius: BorderRadius.circular(2.r),
                  ),
                ),
              ),
              SizedBox(height: 18.h),
              Text(
                CoursesStrings.newDeliverable,
                style: TextStyle(
                  fontSize: 17.sp,
                  fontWeight: FontWeight.w800,
                  color: c.textPrimary,
                  letterSpacing: -0.3,
                ),
              ),
              SizedBox(height: 16.h),

              // Course picker (only when attaching to an existing course)
              if (_showPicker) ...[
                _FieldLabel(CoursesStrings.courseField),
                SizedBox(height: 6.h),
                _FieldBox(
                  child: DropdownButton<String>(
                    value: _selectedCourseId,
                    isExpanded: true,
                    isDense: true,
                    underline: const SizedBox(),
                    hint: Text(
                      CoursesStrings.chooseCourse,
                      style: TextStyle(fontSize: 14.sp, color: c.textMuted),
                    ),
                    onChanged: widget.lockedCourse != null
                        ? null
                        : (v) => setState(() => _selectedCourseId = v),
                    items: [
                      for (final course in widget.courses)
                        DropdownMenuItem(
                          value: course.id,
                          child: Text(
                            course.title,
                            style: TextStyle(
                              fontSize: 14.sp,
                              color: c.textPrimary,
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
                SizedBox(height: 14.h),
              ],

              // Title
              _FieldLabel(CoursesStrings.title),
              SizedBox(height: 6.h),
              AppTextField(
                controller: _titleController,
                hintText: CoursesStrings.deliverableTitleHint,
                textInputAction: TextInputAction.done,
                onChanged: (_) {
                  if (_error != null) setState(() => _error = null);
                },
              ),
              SizedBox(height: 14.h),

              // Type
              _FieldLabel(CoursesStrings.type),
              SizedBox(height: 6.h),
              _FieldBox(
                child: DropdownButton<DeliverableType>(
                  value: _type,
                  isExpanded: true,
                  isDense: true,
                  underline: const SizedBox(),
                  onChanged: (v) {
                    if (v != null) setState(() => _type = v);
                  },
                  items: DeliverableType.values
                      .map((t) => DropdownMenuItem(
                            value: t,
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(typeIcon(t),
                                    size: 16.sp, color: c.textSecondary),
                                SizedBox(width: 8.w),
                                Text(
                                  typeLabel(t),
                                  style: TextStyle(
                                      fontSize: 14.sp, color: c.textPrimary),
                                ),
                              ],
                            ),
                          ))
                      .toList(),
                ),
              ),
              SizedBox(height: 14.h),

              // Weight + Date in a row
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _FieldLabel(CoursesStrings.weightPercentLabel),
                        SizedBox(height: 6.h),
                        AppTextField(
                          controller: _weightController,
                          hintText: '—',
                          numeric: true,
                        ),
                      ],
                    ),
                  ),
                  SizedBox(width: 12.w),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _FieldLabel(CoursesStrings.dueDate),
                        SizedBox(height: 6.h),
                        _FieldBox(
                          child: InkWell(
                            onTap: _pickDate,
                            child: Row(
                              children: [
                                Icon(Icons.calendar_today_outlined,
                                    size: 15.sp, color: c.textMuted),
                                SizedBox(width: 8.w),
                                Expanded(
                                  child: Text(
                                    hasDate
                                        ? DateFormat('d MMM yyyy', 'ar')
                                            .format(_date!)
                                        : CoursesStrings.tapToSet,
                                    style: TextStyle(
                                      fontSize: 13.sp,
                                      color: hasDate
                                          ? c.textPrimary
                                          : c.textMuted,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),

              if (_error != null) ...[
                SizedBox(height: 12.h),
                Text(
                  _error!,
                  style: TextStyle(
                    fontSize: 12.5.sp,
                    color: c.warningFg,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],

              SizedBox(height: 20.h),
              SizedBox(
                width: double.infinity,
                child: _PrimaryButton(
                  icon: Icons.check_rounded,
                  label: CoursesStrings.addAction,
                  onTap: _submit,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ── Shared form bits ──────────────────────────────────────────────────────────

class _FieldLabel extends StatelessWidget {
  final String text;
  const _FieldLabel(this.text);

  @override
  Widget build(BuildContext context) {
    final c = context.c;
    return Text(
      text,
      style: TextStyle(
        fontSize: 12.5.sp,
        fontWeight: FontWeight.w600,
        color: c.textSecondary,
      ),
    );
  }
}

class _FieldBox extends StatelessWidget {
  final Widget child;
  const _FieldBox({required this.child});

  @override
  Widget build(BuildContext context) {
    final c = context.c;
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 12.h),
      decoration: BoxDecoration(
        color: c.surfaceAlt,
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(color: c.border),
      ),
      child: child,
    );
  }
}

class _PrimaryButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const _PrimaryButton({
    required this.icon,
    required this.label,
    required this.onTap,
  });

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
          padding: EdgeInsets.symmetric(vertical: 15.h),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 18.sp, color: Colors.white),
              SizedBox(width: 8.w),
              Text(
                label,
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w700,
                  fontSize: 15.sp,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
