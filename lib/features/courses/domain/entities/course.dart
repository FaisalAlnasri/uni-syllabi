import 'package:unicalendar/features/courses/domain/entities/deliverable.dart';

class Course {
  final String id;
  final String title;
  final List<Deliverable> deliverables;
  final String? color;

  // Optional user-chosen icon key (see [kCourseIcons]). Null falls back to the
  // default course icon.
  final String? iconKey;

  Course({
    required this.id,
    required this.title,
    required this.deliverables,
    this.color,
    this.iconKey,
  });

  Deliverable? get nextDeliverable {
    try {
      return deliverables.firstWhere(
        (d) => d.date != null && d.date!.isAfter(DateTime.now()),
      );
    } catch (e) {
      return null;
    }
  }
}
