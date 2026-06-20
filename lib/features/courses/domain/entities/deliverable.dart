enum DeliverableType {
  exam,
  quiz,
  assignment,
  project,
  other,
}

class Deliverable {
  final String id;
  final String title;
  final DeliverableType type;

  // Nullable because the syllabus might not specify an exact date
  final DateTime? date;

  // Crucial for MVP: What the AI actually read (e.g., "Week 6" or "End of October")
  final String? rawDateText;

  // Nullable grade weight (e.g., 0.15 for 15%)
  final double? weight;

  // AI flags for your review screen
  final bool isClear;
  final String? confidenceNotes;

  const Deliverable({
    required this.id,
    required this.title,
    required this.type,
    this.date,
    this.rawDateText,
    this.weight,
    required this.isClear,
    this.confidenceNotes,
  });

  // Helper getter to easily format weights in the UI (e.g., "15%")
  String get weightPercentage =>
      weight != null ? '${(weight! * 100).toStringAsFixed(0)}%' : 'N/A';
}
