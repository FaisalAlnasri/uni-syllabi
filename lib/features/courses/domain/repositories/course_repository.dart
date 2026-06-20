import 'package:unicalendar/features/courses/domain/entities/course.dart';

abstract class CourseRepository {
  Future<List<Course>> getCourses();
  Future<void> saveCourse(Course course);
  Future<void> updateDeliverableDate(
      String courseId, String deliverableId, DateTime date);
  Future<void> deleteCourse(String courseId);
}
