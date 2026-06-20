/// Centralized user-facing strings for the courses feature.
///
/// Modern Standard Arabic (فصحى). Counts use correct Arabic number agreement
/// (مفرد/مثنى/جمع) via the private `_courseNoun` / `_itemNoun` / `_dayNoun`
/// helpers.
abstract final class CoursesStrings {
  // ── Bottom-nav tabs ─────────────────────────────────────────
  static const String tabTimeline = 'الجدول الزمني';
  static const String tabCalendar = 'التقويم';
  static const String tabCourses = 'المقررات';
  static const String tabProfile = 'الملف الشخصي';

  // ── Timeline ────────────────────────────────────────────────
  static const String goodMorning = 'صباح الخير';
  static const String goodAfternoon = 'طاب يومك';
  static const String goodEvening = 'مساء الخير';
  static const String calendarExportComingSoon = 'تصدير التقويم قادم قريبًا';
  static const String aiNeedsHelp =
      'يحتاج الذكاء الاصطناعي إلى مساعدتك في هذا العنصر.';
  static const String itemsNeedingReview = 'عناصر بحاجة إلى مراجعة';
  static const String tapToSetExactDate =
      'انقر على كل عنصر لتحديد تاريخه بدقة.';
  static const String setDate = 'تحديد التاريخ';
  static const String dateTba = 'التاريخ غير محدد';

  static String coursesTracked(int count) =>
      '${_courseNoun(count)} قيد المتابعة';

  static String uncertainBanner(int count) =>
      'هناك ${_itemNoun(count)} بحاجة إلى مراجعتك، '
      'تعذّر على الذكاء الاصطناعي تحديد التاريخ.';

  // ── Relative day labels ─────────────────────────────────────
  static const String today = 'اليوم';
  static const String tomorrow = 'غدًا';
  static const String yesterday = 'أمس';

  static String inDays(int days) => 'خلال ${_dayNoun(days)}';

  // ── Calendar ────────────────────────────────────────────────
  static const String nothingDueThisDay = 'لا توجد متطلبات في هذا اليوم';

  // ── Courses list ────────────────────────────────────────────
  static const String coursesTitle = 'المقررات';
  static const String noCoursesYet = 'لا توجد مقررات بعد';
  static const String addFirstSyllabus = 'انقر على + لإضافة أول خطة دراسية.';
  static const String removeCourseTitle = 'حذف المقرر؟';
  static const String cancel = 'إلغاء';
  static const String remove = 'حذف';

  static String removeCourseBody(String title) =>
      'سيؤدي هذا إلى حذف "$title" وجميع متطلباته نهائيًا.';

  static String nextLabel(String title) => 'التالي: $title';

  static String itemCount(int count) => _itemNoun(count);

  // ── Course detail ───────────────────────────────────────────
  static const String deliverablesSection = 'المتطلبات';
  static const String deliverables = 'المتطلبات';
  static const String gradedWeight = 'وزن الدرجات';
  static const String deleteCourse = 'حذف المقرر';
  static const String courseDeleted = 'تم حذف المقرر';
  static const String removeDeliverableTitle = 'حذف المتطلب؟';
  static const String deliverableDeleted = 'تم حذف المتطلب';

  static String removeDeliverableBody(String title) =>
      'سيؤدي هذا إلى حذف "$title" نهائيًا.';

  // ── Course confirmation ─────────────────────────────────────
  static const String reviewCourses = 'مراجعة المقررات';
  static const String courseAdded = 'تمت إضافة المقرر';
  static const String dateNeedsReview = 'التاريخ بحاجة إلى مراجعة';

  static String coursesAdded(int count) => 'تمت إضافة ${_courseNoun(count)}';

  static String courseCountLabel(int count) => _courseNoun(count);

  static String addCourses(String label) => 'إضافة $label';

  static String itemsBadge(int count) => _itemNoun(count);

  // ── Timeline sections / badges ──────────────────────────────
  static const String past = 'السابقة';
  static const String upcoming = 'القادمة';
  static const String todaySection = 'اليوم';
  static const String overdue = 'متأخر';
  static const String nothingScheduled = 'لا توجد مواعيد بعد';
  static const String addSyllabusHint =
      'انقر على + لإضافة خطة دراسية\nوسنستخرج مواعيدك النهائية.';

  // ── Deliverable detail sheet ────────────────────────────────
  static const String title = 'العنوان';
  static const String type = 'النوع';
  static const String weightPercentLabel = 'الوزن (٪)';
  static const String dueDate = 'الموعد النهائي';
  static const String tapToSet = 'انقر للتحديد';
  static const String saveChanges = 'حفظ التغييرات';
  static const String changeDate = 'تغيير التاريخ';
  static const String setADate = 'تحديد تاريخ';
  static const String weight = 'الوزن';
  static const String notSpecified = 'غير محدد';

  // ── Syllabus upload dialog ──────────────────────────────────
  static const String addACourse = 'إضافة مقرر';
  static const String uploadSubtitle =
      'اختر خطتك الدراسية وسنستخرج جميع مواعيدك النهائية تلقائيًا.';
  static const String openFile = 'فتح ملف';
  static const String parsingSyllabus = 'جارٍ تحليل خطتك الدراسية…';
  static const String unknownError = 'خطأ غير معروف';
  static const String genericError = 'حدث خطأ ما. يُرجى المحاولة مرة أخرى.';

  // ── Add menu (FAB) ──────────────────────────────────────────
  static const String addMenuTitle = 'ماذا تريد أن تضيف؟';
  static const String addSyllabusOption = 'رفع خطة دراسية';
  static const String addSyllabusOptionSubtitle =
      'استخرج جميع المواعيد تلقائيًا من ملف';
  static const String addDeliverableOption = 'إضافة متطلب';
  static const String addDeliverableOptionSubtitle =
      'أضف واجبًا أو اختبارًا إلى مقرر موجود';
  static const String addCourseOption = 'إنشاء مقرر';
  static const String addCourseOptionSubtitle =
      'أنشئ مقررًا جديدًا مع متطلباته';

  // ── New deliverable form ────────────────────────────────────
  static const String newDeliverable = 'متطلب جديد';
  static const String courseField = 'المقرر';
  static const String chooseCourse = 'اختر المقرر';
  static const String deliverableTitleHint = 'مثال: الاختبار النصفي';
  static const String addAction = 'إضافة';
  static const String enterDeliverableTitle = 'يُرجى إدخال عنوان المتطلب';
  static const String chooseCourseFirst = 'يُرجى اختيار المقرر';
  static const String noCoursesToAddTo =
      'لا توجد مقررات بعد، أنشئ مقررًا أولًا.';
  static const String deliverableAdded = 'تمت إضافة المتطلب';

  // ── New course form ─────────────────────────────────────────
  static const String newCourse = 'مقرر جديد';
  static const String courseTitleField = 'اسم المقرر';
  static const String courseTitleHint = 'مثال: الرياضيات 101';
  static const String courseColorField = 'اللون';
  static const String optionalDeliverables = 'المتطلبات (اختياري)';
  static const String noDeliverablesYet =
      'لم تُضف أي متطلبات بعد، يمكنك إضافتها لاحقًا.';
  static const String createCourse = 'إنشاء المقرر';
  static const String enterCourseTitle = 'يُرجى إدخال اسم المقرر';
  static const String courseCreated = 'تم إنشاء المقرر';

  // ── Deliverable type labels ─────────────────────────────────
  static const String typeExam = 'اختبار';
  static const String typeQuiz = 'اختبار قصير';
  static const String typeAssignment = 'واجب';
  static const String typeProject = 'مشروع';
  static const String typeTask = 'مهمة';

  // ── Arabic number agreement helpers ─────────────────────────

  /// "مقرر" with correct singular/dual/plural agreement.
  static String _courseNoun(int n) {
    if (n == 0) return 'لا مقررات';
    if (n == 1) return 'مقرر واحد';
    if (n == 2) return 'مقرران';
    if (n >= 3 && n <= 10) return '$n مقررات';
    return '$n مقررًا';
  }

  /// "عنصر" with correct singular/dual/plural agreement.
  static String _itemNoun(int n) {
    if (n == 0) return 'لا عناصر';
    if (n == 1) return 'عنصر واحد';
    if (n == 2) return 'عنصران';
    if (n >= 3 && n <= 10) return '$n عناصر';
    return '$n عنصرًا';
  }

  /// "يوم" with correct singular/dual/plural agreement.
  static String _dayNoun(int n) {
    if (n == 1) return 'يوم واحد';
    if (n == 2) return 'يومين';
    if (n >= 3 && n <= 10) return '$n أيام';
    return '$n يومًا';
  }

  static const String todayGroup = 'اليوم';
  static const String thisWeekGroup = 'هذا الأسبوع';
  static const String laterGroup = 'لاحقًا';
  static const String unscheduledGroup = 'بدون تاريخ';
  static const String pastGroup = 'السابقة';
  static const String needsReview = 'بحاجة لمراجعة';
  static const String setDateHint = 'حدد تاريخًا';
}
