import 'package:flutter_bloc/flutter_bloc.dart';

import '../../domain/entities/course.dart';
import '../../domain/entities/deliverable.dart';
import '../../domain/repositories/course_repository.dart';
import '../../domain/services/calendar_export_service.dart';
import 'course_state.dart';

class CourseCubit extends Cubit<CourseState> {
  final CourseRepository _repository;
  final CalendarExportService _calendarExport;

  CourseCubit(this._repository, this._calendarExport)
      : super(const CourseState());

  // ── Getters (mirror the old CourseProvider API) ───────────────────────────

  List<Course> get courses => List.unmodifiable(state.courses);

  List<({Deliverable deliverable, Course course})> get sortedDeliverables {
    final items = [
      for (final course in state.courses)
        for (final d in course.deliverables) (deliverable: d, course: course),
    ];
    items.sort((a, b) {
      final da = a.deliverable.date;
      final db = b.deliverable.date;
      if (da == null && db == null) return 0;
      if (da == null) return 1;
      if (db == null) return -1;
      return da.compareTo(db);
    });
    return items;
  }

  ({Deliverable deliverable, Course course})? get upcomingItem {
    final now = DateTime.now();
    return sortedDeliverables
        .where((i) =>
            i.deliverable.date != null && i.deliverable.date!.isAfter(now))
        .firstOrNull;
  }

  int get uncertainCount =>
      sortedDeliverables.where((i) => !i.deliverable.isClear).length;

  // ── Initialisation ────────────────────────────────────────────────────────

  /// Load courses from the cache. Falls back to seed data on first launch
  /// and persists it so subsequent launches hit the cache.
  Future<void> load() async {
    emit(state.copyWith(loading: true));
    final saved = await _repository.getCourses();
    if (saved.isNotEmpty) {
      emit(state.copyWith(courses: saved, loading: false));
    } else {
      final seeded = _seedData();
      for (final c in seeded) {
        await _repository.saveCourse(c);
      }
      emit(state.copyWith(courses: seeded, loading: false));
    }
  }

  // ── Mutations ─────────────────────────────────────────────────────────────

  Future<void> addCourse(Course course) async {
    await _repository.saveCourse(course);
    emit(state.copyWith(courses: [...state.courses, course]));
  }

  /// Replaces the stored course that shares [course]'s id (title/color/icon
  /// edits) and persists it.
  Future<void> updateCourse(Course course) async {
    await _repository.saveCourse(course);
    emit(state.copyWith(
      courses: [
        for (final c in state.courses) c.id == course.id ? course : c,
      ],
    ));
  }

  /// Appends a new [deliverable] to the course identified by [courseId] and
  /// persists the updated course.
  Future<void> addDeliverable(String courseId, Deliverable deliverable) async {
    final next = [
      for (final course in state.courses)
        course.id == courseId
            ? Course(
                id: course.id,
                title: course.title,
                color: course.color,
                iconKey: course.iconKey,
                deliverables: [...course.deliverables, deliverable],
              )
            : course,
    ];
    emit(state.copyWith(courses: next));
    await _repository.saveCourse(next.firstWhere((c) => c.id == courseId));
  }

  Future<void> updateDeliverable(String courseId, Deliverable updated) async {
    final next = [
      for (final course in state.courses)
        course.id == courseId
            ? Course(
                id: course.id,
                title: course.title,
                color: course.color,
                iconKey: course.iconKey,
                deliverables: [
                  for (final d in course.deliverables)
                    d.id == updated.id ? updated : d,
                ],
              )
            : course,
    ];
    emit(state.copyWith(courses: next));
    await _repository.saveCourse(next.firstWhere((c) => c.id == courseId));
  }

  Future<void> updateDeliverableDate(
      String courseId, String deliverableId, DateTime date) async {
    await _repository.updateDeliverableDate(courseId, deliverableId, date);
    final next = [
      for (final course in state.courses)
        course.id == courseId
            ? Course(
                id: course.id,
                title: course.title,
                color: course.color,
                iconKey: course.iconKey,
                deliverables: [
                  for (final d in course.deliverables)
                    d.id == deliverableId
                        ? Deliverable(
                            id: d.id,
                            title: d.title,
                            type: d.type,
                            date: date,
                            rawDateText: d.rawDateText,
                            weight: d.weight,
                            isClear: true,
                            confidenceNotes: d.confidenceNotes,
                          )
                        : d,
                ],
              )
            : course,
    ];
    emit(state.copyWith(courses: next));
  }

  Future<void> deleteCourse(String courseId) async {
    await _repository.deleteCourse(courseId);
    emit(state.copyWith(
        courses: state.courses.where((c) => c.id != courseId).toList()));
  }

  /// Removes the deliverable identified by [deliverableId] from its course and
  /// persists the updated course.
  Future<void> deleteDeliverable(String courseId, String deliverableId) async {
    final next = [
      for (final course in state.courses)
        course.id == courseId
            ? Course(
                id: course.id,
                title: course.title,
                color: course.color,
                iconKey: course.iconKey,
                deliverables: [
                  for (final d in course.deliverables)
                    if (d.id != deliverableId) d,
                ],
              )
            : course,
    ];
    emit(state.copyWith(courses: next));
    await _repository.saveCourse(next.firstWhere((c) => c.id == courseId));
  }

  // ── Button stubs ──────────────────────────────────────────────────────────

  void submitSyllabus() {
    // TODO: navigate to syllabus upload flow.
  }

  /// Exports every course's dated deliverables to a single `.ics` file and
  /// opens the share sheet. Returns the number of deliverables skipped because
  /// they had no date, or `null` when there is nothing dated to export.
  Future<int?> exportToCalendar() async {
    final hasDated =
        state.courses.any((c) => c.deliverables.any((d) => d.date != null));
    if (!hasDated) return null;
    return _calendarExport.exportCourses(courses);
  }

  // ── Seed data ─────────────────────────────────────────────────────────────

  static List<Course> _seedData() {
    final now = DateTime.now();
    return [
      Course(
        id: 'seed-math101',
        title: 'الرياضيات 101',
        color: '#1D4ED8',
        deliverables: [
          Deliverable(
            id: 'd1',
            title: 'الاختبار النصفي للتفاضل والتكامل',
            type: DeliverableType.exam,
            date: now.add(const Duration(days: 3)),
            weight: 0.25,
            isClear: true,
          ),
          Deliverable(
            id: 'd2',
            title: 'مجموعة المسائل 7',
            type: DeliverableType.assignment,
            date: now.add(const Duration(days: 6)),
            weight: 0.05,
            isClear: true,
          ),
        ],
      ),
      Course(
        id: 'seed-phys102',
        title: 'الفيزياء 102',
        color: '#6D28D9',
        deliverables: [
          Deliverable(
            id: 'd3',
            title: 'تقرير المختبر 3، البندول',
            type: DeliverableType.assignment,
            date: now.add(const Duration(days: 2)),
            weight: 0.10,
            isClear: true,
          ),
        ],
      ),
      Course(
        id: 'seed-hist210',
        title: 'التاريخ 210',
        color: '#B45309',
        deliverables: [
          Deliverable(
            id: 'd4',
            title: 'اختبار القراءة القصير، الفصل 4–5',
            type: DeliverableType.quiz,
            date: now.add(const Duration(days: 5)),
            weight: 0.05,
            isClear: true,
          ),
          Deliverable(
            id: 'd5',
            title: 'موضوع المقال النهائي',
            type: DeliverableType.other,
            rawDateText: 'قبل الأسبوع 10',
            isClear: false,
            confidenceNotes: 'فترة التسليم غير واضحة، يُرجى التحقق.',
          ),
        ],
      ),
      Course(
        id: 'seed-cs211',
        title: 'علوم الحاسب 211',
        color: '#0F766E',
        deliverables: [
          Deliverable(
            id: 'd6',
            title: 'مقترح المشروع الجماعي',
            type: DeliverableType.project,
            date: now.add(const Duration(days: 9)),
            weight: 0.15,
            isClear: true,
          ),
        ],
      ),
    ];
  }
}
