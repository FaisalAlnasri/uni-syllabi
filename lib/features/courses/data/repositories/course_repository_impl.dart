import 'package:unicalendar/features/courses/data/datasources/local/course_local_datasource.dart';
import 'package:unicalendar/features/courses/data/models/course_model.dart';
import 'package:unicalendar/features/courses/data/models/deliverable_model.dart';
import 'package:unicalendar/features/courses/domain/entities/course.dart';
import 'package:unicalendar/features/courses/domain/repositories/course_repository.dart';

class CourseRepositoryImpl implements CourseRepository {
  final CourseLocalDatasource _local;

  CourseRepositoryImpl(this._local);

  @override
  Future<List<Course>> getCourses() async {
    final models = await _local.getAllCourses();
    return models.map((m) => m.toEntity()).toList();
  }

  @override
  Future<void> saveCourse(Course course) async {
    await _local.saveCourse(CourseModel.fromEntity(course));
  }

  @override
  Future<void> updateDeliverableDate(
      String courseId, String deliverableId, DateTime date) async {
    final models = await _local.getAllCourses();
    final index = models.indexWhere((m) => m.id == courseId);
    if (index == -1) return;

    final old = models[index];
    final updated = CourseModel(
      id: old.id,
      title: old.title,
      color: old.color,
      deliverables: [
        for (final d in old.deliverables)
          d.id == deliverableId
              ? DeliverableModel(
                  id: d.id,
                  title: d.title,
                  type: d.type,
                  date: date.toIso8601String(),
                  rawDateText: d.rawDateText,
                  weight: d.weight,
                  isClear: true,
                  confidenceNotes: d.confidenceNotes,
                )
              : d,
      ],
    );
    await _local.saveCourse(updated);
  }

  @override
  Future<void> deleteCourse(String courseId) async {
    await _local.deleteCourse(courseId);
  }
}
