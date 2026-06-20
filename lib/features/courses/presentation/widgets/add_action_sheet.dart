import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../core/theme/app_colors.dart';
import '../courses_strings.dart';

/// The actions offered when the user taps the center "+" FAB.
enum AddAction { syllabus, deliverable, course }

/// Presents the "+" menu and resolves with the chosen [AddAction] (or `null`
/// if dismissed).
Future<AddAction?> showAddActionSheet(BuildContext context) {
  return showModalBottomSheet<AddAction>(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (_) => const _AddActionSheet(),
  );
}

class _AddActionSheet extends StatelessWidget {
  const _AddActionSheet();

  @override
  Widget build(BuildContext context) {
    final c = context.c;
    return Container(
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
            CoursesStrings.addMenuTitle,
            style: TextStyle(
              fontSize: 17.sp,
              fontWeight: FontWeight.w800,
              color: c.textPrimary,
              letterSpacing: -0.3,
            ),
          ),
          SizedBox(height: 16.h),
          _ActionTile(
            icon: Icons.auto_awesome_rounded,
            title: CoursesStrings.addSyllabusOption,
            subtitle: CoursesStrings.addSyllabusOptionSubtitle,
            onTap: () => Navigator.of(context).pop(AddAction.syllabus),
          ),
          SizedBox(height: 10.h),
          _ActionTile(
            icon: Icons.playlist_add_rounded,
            title: CoursesStrings.addDeliverableOption,
            subtitle: CoursesStrings.addDeliverableOptionSubtitle,
            onTap: () => Navigator.of(context).pop(AddAction.deliverable),
          ),
          SizedBox(height: 10.h),
          _ActionTile(
            icon: Icons.create_new_folder_outlined,
            title: CoursesStrings.addCourseOption,
            subtitle: CoursesStrings.addCourseOptionSubtitle,
            onTap: () => Navigator.of(context).pop(AddAction.course),
          ),
        ],
      ),
    );
  }
}

class _ActionTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  const _ActionTile({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final c = context.c;
    return Material(
      color: c.surfaceAlt,
      borderRadius: BorderRadius.circular(14.r),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(14.r),
        child: Container(
          padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 14.h),
          decoration: BoxDecoration(
            border: Border.all(color: c.border),
            borderRadius: BorderRadius.circular(14.r),
          ),
          child: Row(
            children: [
              Container(
                width: 44.r,
                height: 44.r,
                decoration: BoxDecoration(
                  color: c.accent.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(12.r),
                ),
                child: Icon(icon, size: 22.sp, color: c.accent),
              ),
              SizedBox(width: 12.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: TextStyle(
                        fontSize: 15.sp,
                        fontWeight: FontWeight.w700,
                        color: c.textPrimary,
                      ),
                    ),
                    SizedBox(height: 2.h),
                    Text(
                      subtitle,
                      style: TextStyle(
                        fontSize: 12.5.sp,
                        color: c.textSecondary,
                        height: 1.3,
                      ),
                    ),
                  ],
                ),
              ),
              Icon(Icons.chevron_left_rounded, size: 22.sp, color: c.textMuted),
            ],
          ),
        ),
      ),
    );
  }
}
