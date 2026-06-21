import 'dart:convert';
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import '../entities/course.dart';
import '../entities/deliverable.dart';

class CalendarExportService {
  static const _domain = 'uni-syllabi.faisalalnasri.com';

  /// Exports one course's deliverables (that have a date) to an .ics file
  /// and opens the share sheet. Returns the number of deliverables skipped
  /// because they had no date — surface this in the UI.
  Future<int> exportCourse(Course course) async {
    final dated = course.deliverables.where((d) => d.date != null).toList();
    final skipped = course.deliverables.length - dated.length;

    final ics = _buildCalendar([(course, dated)]);
    await _writeAndShare(ics, course.title);
    return skipped;
  }

  /// Export the whole semester (many courses) into a single .ics.
  Future<int> exportCourses(List<Course> courses) async {
    var skipped = 0;
    final groups = <(Course, List<Deliverable>)>[];
    for (final c in courses) {
      final dated = c.deliverables.where((d) => d.date != null).toList();
      skipped += c.deliverables.length - dated.length;
      groups.add((c, dated));
    }
    await _writeAndShare(_buildCalendar(groups), 'الفصل الدراسي');
    return skipped;
  }

  // --- ICS construction -----------------------------------------------------

  String _buildCalendar(List<(Course, List<Deliverable>)> groups) {
    final lines = <String>[
      'BEGIN:VCALENDAR',
      'VERSION:2.0',
      'PRODID:-//uni-syllabi//Syllabus Export//AR',
      'CALSCALE:GREGORIAN',
    ];
    final stamp = _utcStamp(DateTime.now());
    for (final (course, deliverables) in groups) {
      for (final d in deliverables) {
        lines.addAll(_event(course, d, stamp));
      }
    }
    lines.add('END:VCALENDAR');

    // Fold each line to <=75 octets, join with CRLF as the spec requires.
    return lines.map(_foldLine).join('\r\n');
  }

  List<String> _event(Course course, Deliverable d, String stamp) {
    final date = d.date!;
    // Heuristic: midnight = all-day deadline; otherwise a timed event.
    final isAllDay = date.hour == 0 && date.minute == 0;

    final start = isAllDay
        ? 'DTSTART;VALUE=DATE:${_dateOnly(date)}'
        : 'DTSTART:${_floatingLocal(date)}';
    final end = isAllDay
        ? 'DTEND;VALUE=DATE:${_dateOnly(date.add(const Duration(days: 1)))}'
        : 'DTEND:${_floatingLocal(date.add(const Duration(hours: 1)))}';

    return [
      'BEGIN:VEVENT',
      'UID:${d.id}@$_domain', // stable UID -> re-import updates, no dupes
      'DTSTAMP:$stamp',
      start,
      end,
      'SUMMARY:${_escape('${_typeLabel(d.type)}: ${d.title}')}',
      'DESCRIPTION:${_escape(_description(course, d))}',
      // Reminder one day before. Tune to taste (e.g. -PT9H).
      'BEGIN:VALARM',
      'ACTION:DISPLAY',
      'DESCRIPTION:${_escape(d.title)}',
      'TRIGGER:-P1D',
      'END:VALARM',
      'END:VEVENT',
    ];
  }

  String _description(Course course, Deliverable d) {
    final parts = <String>['المقرر: ${course.title}'];
    if (d.weight != null) parts.add('الوزن: ${d.weightPercentage}');
    if (d.rawDateText != null) parts.add('الموعد كما ورد: ${d.rawDateText}');
    if (!d.isClear) parts.add('⚠️ يحتاج مراجعة');
    if (d.confidenceNotes != null) parts.add('ملاحظات: ${d.confidenceNotes}');
    return parts.join('\n');
  }

  String _typeLabel(DeliverableType t) => switch (t) {
    DeliverableType.exam => 'اختبار',
    DeliverableType.quiz => 'اختبار قصير',
    DeliverableType.assignment => 'واجب',
    DeliverableType.project => 'مشروع',
    DeliverableType.other => 'مهمة',
  };

  // --- Formatting helpers ---------------------------------------------------

  String _two(int n) => n.toString().padLeft(2, '0');

  String _dateOnly(DateTime d) => '${d.year}${_two(d.month)}${_two(d.day)}';

  String _floatingLocal(DateTime d) =>
      '${_dateOnly(d)}T${_two(d.hour)}${_two(d.minute)}${_two(d.second)}';

  String _utcStamp(DateTime d) {
    final u = d.toUtc();
    return '${_dateOnly(u)}T${_two(u.hour)}${_two(u.minute)}${_two(u.second)}Z';
  }

  /// RFC 5545 text escaping. Backslash first.
  String _escape(String s) => s
      .replaceAll('\\', '\\\\')
      .replaceAll('\n', '\\n')
      .replaceAll(',', '\\,')
      .replaceAll(';', '\\;');

  /// Fold to <=75 octets per line. UTF-8 aware so Arabic characters are
  /// never split across a fold (which would corrupt the file).
  String _foldLine(String line) {
    final out = StringBuffer();
    var octets = 0;
    for (final rune in line.runes) {
      final ch = String.fromCharCode(rune);
      final size = utf8.encode(ch).length;
      if (octets + size > 75) {
        out.write('\r\n '); // continuation line; leading space = 1 octet
        octets = 1;
      }
      out.write(ch);
      octets += size;
    }
    return out.toString();
  }

  // --- Output ---------------------------------------------------------------

  Future<void> _writeAndShare(String ics, String name) async {
    final dir = await getTemporaryDirectory();
    final safe = name.replaceAll(RegExp(r'[^\w\u0600-\u06FF]+'), '_');
    final file = File('${dir.path}/$safe.ics');
    await file.writeAsString(ics);

    await SharePlus.instance.share(
      ShareParams(
        files: [XFile(file.path, mimeType: 'text/calendar')],
        subject: name,
      ),
    );
  }
}
