import 'dart:convert';
import 'dart:math';

import 'package:unicalendar/features/courses/data/models/deliverable_model.dart';
import 'package:unicalendar/features/courses/domain/entities/course.dart';

class CourseModel {
  final String id;
  final String title;
  final List<DeliverableModel> deliverables;
  final String? color;
  final String? iconKey;

  const CourseModel({
    required this.id,
    required this.title,
    required this.deliverables,
    this.color,
    this.iconKey,
  });

  factory CourseModel.fromJson(Map<String, dynamic> json) => CourseModel(
        id: json['id'] as String? ?? _generateId(),
        title: json['title'] as String,
        color: json['color'] as String?,
        iconKey: json['iconKey'] as String?,
        deliverables: (json['deliverables'] as List<dynamic>)
            .map((d) => DeliverableModel.fromJson(d as Map<String, dynamic>))
            .toList(),
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'title': title,
        'color': color,
        'iconKey': iconKey,
        'deliverables': deliverables.map((d) => d.toJson()).toList(),
      };

  factory CourseModel.fromJsonString(String jsonString) =>
      CourseModel.fromJson(jsonDecode(jsonString) as Map<String, dynamic>);

  String toJsonString() => jsonEncode(toJson());

  factory CourseModel.fromEntity(Course entity) => CourseModel(
        id: entity.id,
        title: entity.title,
        color: entity.color,
        iconKey: entity.iconKey,
        deliverables:
            entity.deliverables.map(DeliverableModel.fromEntity).toList(),
      );

  Course toEntity() => Course(
        id: id,
        title: title,
        color: color,
        iconKey: iconKey,
        deliverables: deliverables.map((d) => d.toEntity()).toList(),
      );

  static String _generateId() {
    final rand = Random.secure();
    final bytes = List<int>.generate(16, (_) => rand.nextInt(256));
    String hex(int b) => b.toRadixString(16).padLeft(2, '0');
    return bytes.map(hex).join();
  }
}
