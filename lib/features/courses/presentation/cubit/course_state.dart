import 'package:equatable/equatable.dart';

import '../../domain/entities/course.dart';

class CourseState extends Equatable {
  final List<Course> courses;
  final bool loading;

  const CourseState({
    this.courses = const [],
    this.loading = false,
  });

  CourseState copyWith({
    List<Course>? courses,
    bool? loading,
  }) {
    return CourseState(
      courses: courses ?? this.courses,
      loading: loading ?? this.loading,
    );
  }

  @override
  List<Object?> get props => [courses, loading];
}
