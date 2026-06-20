import 'package:unicalendar/features/courses/domain/entities/deliverable.dart';

class Course {
  final String id;
  final String title;
  final List<Deliverable> deliverables;
  final String? color;

  Course({
    required this.id,
    required this.title,
    required this.deliverables,
    this.color,
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
