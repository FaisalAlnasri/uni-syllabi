import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/utils/id_generator.dart';
import '../../../../core/widgets/app_text_field.dart';
import '../../domain/entities/course.dart';
import '../../domain/entities/deliverable.dart';
import '../courses_strings.dart';
import '../cubit/course_cubit.dart';
import 'course_glyph.dart';
import 'deliverable_form_sheet.dart';
import 'icon_choice_picker.dart';
import 'type_glyph.dart';

/// Preset course colors (match the seed palette style).
const List<String> _coursePalette = [
  '#1D4ED8',
  '#6D28D9',
  '#B45309',
  '#0F766E',
  '#BE123C',
  '#0369A1',
  '#4D7C0F',
  '#DB2777',
];

/// Presents the "create course" form. On completion adds the course via the
/// [CourseCubit] and shows a confirmation snackbar.
Future<void> showCreateCourseSheet(BuildContext context) async {
  final cubit = context.read<CourseCubit>();
  final messenger = ScaffoldMessenger.of(context);

  final course = await showModalBottomSheet<Course>(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (_) => BlocProvider.value(
      value: cubit,
      child: const _CourseFormSheet(),
    ),
  );

  if (course == null) return;
  await cubit.addCourse(course);
  messenger.showSnackBar(
    const SnackBar(content: Text(CoursesStrings.courseCreated)),
  );
}

/// Presents the "edit course" form (title/color/icon) for an existing [course]
/// and persists the changes via the [CourseCubit]. Deliverables are managed
/// separately, so they're carried over unchanged.
Future<void> showEditCourseSheet(BuildContext context, Course course) async {
  final cubit = context.read<CourseCubit>();
  final messenger = ScaffoldMessenger.of(context);

  final updated = await showModalBottomSheet<Course>(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (_) => BlocProvider.value(
      value: cubit,
      child: _CourseFormSheet(initial: course),
    ),
  );

  if (updated == null) return;
  await cubit.updateCourse(updated);
  messenger.showSnackBar(
    const SnackBar(content: Text(CoursesStrings.courseUpdated)),
  );
}

/// Edits an existing [course]'s details (title/color/icon) and returns the
/// updated copy, or null when cancelled. Deliverables are carried over
/// unchanged and nothing is persisted — review flows that hold not-yet-saved
/// courses in local state manage persistence themselves.
Future<Course?> showEditCourseDetailsSheet(
  BuildContext context,
  Course course,
) {
  return showModalBottomSheet<Course>(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (_) => _CourseFormSheet(initial: course),
  );
}

class _CourseFormSheet extends StatefulWidget {
  /// When non-null the form edits this course (title/color/icon) instead of
  /// creating a new one.
  final Course? initial;

  const _CourseFormSheet({this.initial});

  @override
  State<_CourseFormSheet> createState() => _CourseFormSheetState();
}

class _CourseFormSheetState extends State<_CourseFormSheet> {
  late final TextEditingController _titleController;
  late String _color;
  String? _iconKey;
  final List<Deliverable> _deliverables = [];
  String? _error;

  bool get _isEditing => widget.initial != null;

  @override
  void initState() {
    super.initState();
    final initial = widget.initial;
    _titleController = TextEditingController(text: initial?.title ?? '');
    _color = initial?.color ?? _coursePalette.first;
    _iconKey = initial?.iconKey;
  }

  @override
  void dispose() {
    _titleController.dispose();
    super.dispose();
  }

  Future<void> _addDeliverable() async {
    final deliverable = await showNewDeliverableSheet(context);
    if (deliverable != null) {
      setState(() => _deliverables.add(deliverable));
    }
  }

  void _removeDeliverable(Deliverable d) {
    setState(() => _deliverables.remove(d));
  }

  void _submit() {
    final title = _titleController.text.trim();
    if (title.isEmpty) {
      setState(() => _error = CoursesStrings.enterCourseTitle);
      return;
    }
    final initial = widget.initial;
    Navigator.of(context).pop<Course>(
      Course(
        id: initial?.id ?? generateId(),
        title: title,
        color: _color,
        iconKey: _iconKey,
        deliverables:
            initial?.deliverables ?? List.unmodifiable(_deliverables),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final c = context.c;

    return Padding(
      padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
      child: Container(
        constraints: BoxConstraints(
          maxHeight: MediaQuery.of(context).size.height * 0.85,
        ),
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
                _isEditing ? CoursesStrings.editCourse : CoursesStrings.newCourse,
                style: TextStyle(
                  fontSize: 17.sp,
                  fontWeight: FontWeight.w800,
                  color: c.textPrimary,
                  letterSpacing: -0.3,
                ),
              ),
              SizedBox(height: 16.h),

              // Title
              _FieldLabel(CoursesStrings.courseTitleField),
              SizedBox(height: 6.h),
              AppTextField(
                controller: _titleController,
                hintText: CoursesStrings.courseTitleHint,
                textInputAction: TextInputAction.done,
                onChanged: (_) {
                  if (_error != null) setState(() => _error = null);
                },
              ),
              SizedBox(height: 16.h),

              // Color
              _FieldLabel(CoursesStrings.courseColorField),
              SizedBox(height: 8.h),
              Wrap(
                spacing: 12.w,
                runSpacing: 12.h,
                children: [
                  for (final hex in _coursePalette)
                    _ColorDot(
                      color: courseColor(context, hex),
                      selected: hex == _color,
                      onTap: () => setState(() => _color = hex),
                    ),
                ],
              ),
              SizedBox(height: 18.h),

              // Icon
              _FieldLabel(CoursesStrings.iconField),
              SizedBox(height: 8.h),
              IconChoicePicker(
                autoIcon: kDefaultCourseIcon,
                icons: kCourseIcons,
                selectedKey: _iconKey,
                onSelected: (k) => setState(() => _iconKey = k),
              ),
              SizedBox(height: 18.h),

              // Optional deliverables (creation only — managed elsewhere once
              // the course exists)
              if (!_isEditing) ...[
                Row(
                  children: [
                    Expanded(
                        child: _FieldLabel(CoursesStrings.optionalDeliverables)),
                    TextButton.icon(
                      onPressed: _addDeliverable,
                      icon: Icon(Icons.add_rounded, size: 18.sp, color: c.accent),
                      label: Text(
                        CoursesStrings.addAction,
                        style: TextStyle(
                          color: c.accent,
                          fontWeight: FontWeight.w700,
                          fontSize: 13.sp,
                        ),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 4.h),
                if (_deliverables.isEmpty)
                  Text(
                    CoursesStrings.noDeliverablesYet,
                    style: TextStyle(
                      fontSize: 12.5.sp,
                      color: c.textMuted,
                      height: 1.4,
                    ),
                  )
                else
                  for (final d in _deliverables)
                    Padding(
                      padding: EdgeInsets.only(bottom: 8.h),
                      child: _DeliverableChip(
                        deliverable: d,
                        color: courseColor(context, _color),
                        onRemove: () => _removeDeliverable(d),
                      ),
                    ),
              ],

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
                child: Material(
                  color: c.accent,
                  borderRadius: BorderRadius.circular(14.r),
                  child: InkWell(
                    onTap: _submit,
                    borderRadius: BorderRadius.circular(14.r),
                    child: Padding(
                      padding: EdgeInsets.symmetric(vertical: 15.h),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.check_rounded,
                              size: 18.sp, color: Colors.white),
                          SizedBox(width: 8.w),
                          Text(
                            _isEditing
                                ? CoursesStrings.saveChanges
                                : CoursesStrings.createCourse,
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
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ── Bits ──────────────────────────────────────────────────────────────────────

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

class _ColorDot extends StatelessWidget {
  final Color color;
  final bool selected;
  final VoidCallback onTap;

  const _ColorDot({
    required this.color,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final c = context.c;
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 36.r,
        height: 36.r,
        decoration: BoxDecoration(
          color: color,
          shape: BoxShape.circle,
          border: Border.all(
            color: selected ? c.textPrimary : Colors.transparent,
            width: 2.5,
          ),
        ),
        child: selected
            ? Icon(Icons.check_rounded, size: 18.sp, color: Colors.white)
            : null,
      ),
    );
  }
}

class _DeliverableChip extends StatelessWidget {
  final Deliverable deliverable;
  final Color color;
  final VoidCallback onRemove;

  const _DeliverableChip({
    required this.deliverable,
    required this.color,
    required this.onRemove,
  });

  @override
  Widget build(BuildContext context) {
    final c = context.c;
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 10.h),
      decoration: BoxDecoration(
        color: c.surfaceAlt,
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(color: c.border),
      ),
      child: Row(
        children: [
          Container(
            width: 32.r,
            height: 32.r,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(8.r),
            ),
            child: Icon(typeIcon(deliverable.type), size: 16.sp, color: color),
          ),
          SizedBox(width: 10.w),
          Expanded(
            child: Text(
              deliverable.title,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontSize: 13.5.sp,
                fontWeight: FontWeight.w600,
                color: c.textPrimary,
              ),
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
          IconButton(
            onPressed: onRemove,
            visualDensity: VisualDensity.compact,
            icon: Icon(Icons.close_rounded, size: 18.sp, color: c.textMuted),
          ),
        ],
      ),
    );
  }
}
