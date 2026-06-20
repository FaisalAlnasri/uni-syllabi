import 'package:flutter/material.dart';

import '../../domain/entities/deliverable.dart';
import '../courses_strings.dart';

IconData typeIcon(DeliverableType t) => switch (t) {
      DeliverableType.exam => Icons.edit_document,
      DeliverableType.quiz => Icons.checklist_rtl,
      DeliverableType.assignment => Icons.description_outlined,
      DeliverableType.project => Icons.lightbulb_outline_rounded,
      DeliverableType.other => Icons.event_note_outlined,
    };

String typeLabel(DeliverableType t) => switch (t) {
      DeliverableType.exam => CoursesStrings.typeExam,
      DeliverableType.quiz => CoursesStrings.typeQuiz,
      DeliverableType.assignment => CoursesStrings.typeAssignment,
      DeliverableType.project => CoursesStrings.typeProject,
      DeliverableType.other => CoursesStrings.typeTask,
    };
