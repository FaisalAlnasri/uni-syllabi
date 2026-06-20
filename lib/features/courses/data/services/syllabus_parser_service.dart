import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';
import 'package:unicalendar/features/courses/data/models/course_model.dart';
import 'package:unicalendar/features/courses/domain/entities/course.dart';

abstract class SyllabusParserService {
  /// Parse [file] (PDF or DOCX) and return the extracted [Course] list.
  Future<List<Course>> parseSyllabus(File file);
}

class SyllabusParserServiceImpl implements SyllabusParserService {
  final String _baseUrl;

  /// [_baseUrl] is supplied from `AppConfig.instance.syllabusApiBaseUrl`
  /// (set per flavor in main_dev / main_prod).
  SyllabusParserServiceImpl(this._baseUrl);

  @override
  Future<List<Course>> parseSyllabus(File file) async {
    final uri = Uri.parse('$_baseUrl/api/schedule');
    final request = http.MultipartRequest('POST', uri);

    // Detect MIME type from extension since mobile often sends octet-stream
    final ext = file.path.split('.').last.toLowerCase();
    final mimeType = switch (ext) {
      'pdf' => 'application/pdf',
      'docx' =>
        'application/vnd.openxmlformats-officedocument.wordprocessingml.document',
      'txt' => 'text/plain',
      'md' => 'text/markdown',
      'html' => 'text/html',
      _ => 'application/octet-stream',
    };

    request.files.add(
      await http.MultipartFile.fromPath(
        'syllabus',
        file.path,
        contentType: MediaType.parse(mimeType),
      ),
    );

    final http.StreamedResponse streamed;
    try {
      streamed = await request.send().timeout(const Duration(seconds: 30));
    } on TimeoutException {
      throw const SyllabusParserException(
          'انتهت مهلة الطلب. يُرجى التحقق من اتصالك والمحاولة مرة أخرى.');
    } on SocketException {
      throw const SyllabusParserException(
          'لا يوجد اتصال بالشبكة. يُرجى المحاولة مرة أخرى.');
    }
    final body = await streamed.stream.bytesToString();

    if (streamed.statusCode != 200) {
      final decoded = jsonDecode(body);
      final error =
          (decoded is Map ? decoded['error'] : null) ?? 'خطأ غير معروف';
      throw SyllabusParserException(error as String);
    }

    final json = jsonDecode(body) as Map<String, dynamic>;
    return (json['courses'] as List<dynamic>)
        .map((c) => CourseModel.fromJson(c as Map<String, dynamic>).toEntity())
        .toList();
  }
}

class SyllabusParserException implements Exception {
  final String message;
  const SyllabusParserException(this.message);

  @override
  String toString() => 'SyllabusParserException: $message';
}
