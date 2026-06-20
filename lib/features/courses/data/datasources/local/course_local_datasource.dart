import 'package:hive_flutter/hive_flutter.dart';
import 'package:unicalendar/features/courses/data/models/course_model.dart';

/// Persists [CourseModel] objects as JSON strings in a Hive box.
/// Each entry is keyed by the course id.
class CourseLocalDatasource {
  static const _boxName = 'courses';

  Future<Box<String>> get _box async => Hive.openBox<String>(_boxName);

  Future<List<CourseModel>> getAllCourses() async {
    final box = await _box;
    return box.values.map(CourseModel.fromJsonString).toList();
  }

  Future<void> saveCourse(CourseModel model) async {
    final box = await _box;
    await box.put(model.id, model.toJsonString());
  }

  Future<void> deleteCourse(String id) async {
    final box = await _box;
    await box.delete(id);
  }
}
