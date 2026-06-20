import 'package:flutter/material.dart';

/// Default course icon, used when a course has no custom [Course.iconKey].
const IconData kDefaultCourseIcon = Icons.menu_book_rounded;

/// Curated, **limited** set of subject icons a user can assign to a course.
///
/// Keys are stable identifiers persisted in storage — never store the raw
/// [IconData] codepoint. Insertion order is the order shown in the picker.
const Map<String, IconData> kCourseIcons = {
  'calculate': Icons.calculate_rounded,
  'sigma': Icons.functions_rounded,
  'science': Icons.science_rounded,
  'biology': Icons.biotech_rounded,
  'code': Icons.code_rounded,
  'computer': Icons.computer_rounded,
  'language': Icons.translate_rounded,
  'literature': Icons.auto_stories_rounded,
  'history': Icons.account_balance_rounded,
  'geography': Icons.public_rounded,
  'art': Icons.palette_rounded,
  'music': Icons.music_note_rounded,
  'business': Icons.business_center_rounded,
  'economics': Icons.trending_up_rounded,
  'law': Icons.gavel_rounded,
  'engineering': Icons.engineering_rounded,
  'psychology': Icons.psychology_rounded,
  'health': Icons.health_and_safety_rounded,
};

/// Resolves the icon to display for a course: the user's custom [iconKey] when
/// set and recognized, otherwise [kDefaultCourseIcon].
IconData courseIcon(String? iconKey) =>
    (iconKey != null ? kCourseIcons[iconKey] : null) ?? kDefaultCourseIcon;
