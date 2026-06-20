import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/router/app_routes.dart';
import '../../../../core/theme/app_colors.dart';
import '../../domain/entities/course.dart';
import '../courses_strings.dart';
import '../cubit/course_cubit.dart';
import '../widgets/course_glyph.dart';

class CoursesPage extends StatelessWidget {
  const CoursesPage({super.key});

  @override
  Widget build(BuildContext context) {
    final c = context.c;
    final courses = context.watch<CourseCubit>().state.courses;

    return Scaffold(
      backgroundColor: c.background,
      body: SafeArea(
        bottom: false,
        child: courses.isEmpty
            ? const _Empty()
            : ListView(
                padding: EdgeInsets.fromLTRB(16.w, 12.h, 16.w, 120.h),
                children: [
                  Padding(
                    padding: EdgeInsetsDirectional.fromSTEB(4.w, 8.h, 4.w, 16.h),
                    child: Text(
                      CoursesStrings.coursesTitle,
                      style: TextStyle(
                        fontSize: 28.sp,
                        fontWeight: FontWeight.w800,
                        color: c.textPrimary,
                        letterSpacing: -0.5,
                      ),
                    ),
                  ),
                  for (final course in courses)
                    Padding(
                      padding: EdgeInsets.only(bottom: 12.h),
                      child: _CourseCard(course: course),
                    ),
                ],
              ),
      ),
    );
  }
}

class _CourseCard extends StatelessWidget {
  final Course course;
  const _CourseCard({required this.course});

  @override
  Widget build(BuildContext context) {
    final c = context.c;
    final color = courseColor(context, course.color);
    final count = course.deliverables.length;
    final next = course.nextDeliverable;

    return Material(
      color: c.surface,
      borderRadius: BorderRadius.circular(16.r),
      child: InkWell(
        borderRadius: BorderRadius.circular(16.r),
        onTap: () => context.push(AppRoutes.courseDetail, extra: course),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16.r),
            border: Border.all(color: c.border),
          ),
          clipBehavior: Clip.antiAlias,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Container(height: 4.h, color: color),
              Padding(
                padding: EdgeInsets.all(16.r),
                child: Row(
                  children: [
                    Container(
                      width: 46.r,
                      height: 46.r,
                      decoration: BoxDecoration(
                        color: color.withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(12.r),
                      ),
                      child: Icon(courseIcon(course.iconKey), color: color),
                    ),
                    SizedBox(width: 14.w),
                    Expanded(
                      child: Text(
                        course.title,
                        style: TextStyle(
                          fontSize: 16.sp,
                          fontWeight: FontWeight.w700,
                          color: c.textPrimary,
                        ),
                      ),
                    ),
                    Container(
                      padding: EdgeInsets.symmetric(
                          horizontal: 9.w, vertical: 4.h),
                      decoration: BoxDecoration(
                        color: c.surfaceMuted,
                        borderRadius: BorderRadius.circular(20.r),
                      ),
                      child: Text(
                        '$count',
                        style: TextStyle(
                          fontSize: 12.sp,
                          fontWeight: FontWeight.w700,
                          color: c.textSecondary,
                        ),
                      ),
                    ),
                    SizedBox(width: 4.w),
                    Icon(Icons.chevron_right_rounded, color: c.textMuted),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _Empty extends StatelessWidget {
  const _Empty();

  @override
  Widget build(BuildContext context) {
    final c = context.c;
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 64.r,
            height: 64.r,
            decoration: BoxDecoration(
              color: c.surfaceMuted,
              shape: BoxShape.circle,
            ),
            child: Icon(Icons.menu_book_rounded, size: 30.sp, color: c.textMuted),
          ),
          SizedBox(height: 14.h),
          Text(
            CoursesStrings.noCoursesYet,
            style: TextStyle(
              fontSize: 15.sp,
              fontWeight: FontWeight.w700,
              color: c.textPrimary,
            ),
          ),
          SizedBox(height: 4.h),
          Text(
            CoursesStrings.addFirstSyllabus,
            style: TextStyle(fontSize: 13.sp, color: c.textMuted),
          ),
        ],
      ),
    );
  }
}
