import 'package:unicalendar/features/courses/domain/entities/deliverable.dart';

class DeliverableModel {
  final String id;
  final String title;
  final String type;
  final String? date;
  final String? rawDateText;
  final double? weight;
  final bool isClear;
  final String? confidenceNotes;

  const DeliverableModel({
    required this.id,
    required this.title,
    required this.type,
    this.date,
    this.rawDateText,
    this.weight,
    required this.isClear,
    this.confidenceNotes,
  });

  factory DeliverableModel.fromJson(Map<String, dynamic> json) =>
      DeliverableModel(
        id: json['id'] as String,
        title: json['title'] as String,
        type: json['type'] as String,
        date: json['date'] as String?,
        rawDateText: json['rawDateText'] as String?,
        weight: (json['weight'] as num?)?.toDouble(),
        isClear: json['isClear'] as bool,
        confidenceNotes: json['confidenceNotes'] as String?,
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'title': title,
        'type': type,
        'date': date,
        'rawDateText': rawDateText,
        'weight': weight,
        'isClear': isClear,
        'confidenceNotes': confidenceNotes,
      };

  factory DeliverableModel.fromEntity(Deliverable entity) => DeliverableModel(
        id: entity.id,
        title: entity.title,
        type: entity.type.name,
        date: entity.date?.toIso8601String(),
        rawDateText: entity.rawDateText,
        weight: entity.weight,
        isClear: entity.isClear,
        confidenceNotes: entity.confidenceNotes,
      );

  Deliverable toEntity() => Deliverable(
        id: id,
        title: title,
        type: DeliverableType.values.firstWhere((e) => e.name == type),
        date: date != null ? DateTime.parse(date!) : null,
        rawDateText: rawDateText,
        weight: weight,
        isClear: isClear,
        confidenceNotes: confidenceNotes,
      );
}
