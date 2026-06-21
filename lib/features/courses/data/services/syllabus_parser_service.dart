import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';
import 'package:unicalendar/core/logging/app_logger.dart';
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
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      AppLogger.warning('[SyllabusParser] parseSyllabus called with no user');
      throw const UnauthenticatedException(
          'يُرجى تسجيل الدخول لاستخدام هذه الميزة.');
    }

    AppLogger.info('[SyllabusParser] parsing ${file.path}');

    var token = await user.getIdToken();
    var streamed = await _send(file, token!);

    // Token may have expired between issuance and now — refresh once and retry.
    if (streamed.statusCode == 401) {
      AppLogger.warning(
          '[SyllabusParser] got 401, refreshing token and retrying');
      token = await user.getIdToken(true);
      streamed = await _send(file, token!);
    }

    final body = await streamed.stream.bytesToString();

    if (streamed.statusCode != 200) {
      AppLogger.error(
          '[SyllabusParser] request failed (${streamed.statusCode}): $body');
      _throwForStatus(streamed.statusCode, body);
    }

    try {
      final json = jsonDecode(body) as Map<String, dynamic>;
      return (json['courses'] as List<dynamic>)
          .map((c) => CourseModel.fromJson(c as Map<String, dynamic>).toEntity())
          .toList();
    } catch (e, st) {
      AppLogger.error('[SyllabusParser] failed to parse response body', e, st);
      throw const SyllabusParserException(
          'تعذّر قراءة استجابة الخادم. يُرجى المحاولة مرة أخرى.');
    }
  }

  Future<http.StreamedResponse> _send(File file, String token) async {
    final uri = Uri.parse('$_baseUrl/api/schedule');
    final request = http.MultipartRequest('POST', uri)
      ..headers['Authorization'] = 'Bearer $token';

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

    try {
      return await request.send().timeout(const Duration(seconds: 30));
    } on TimeoutException catch (e, st) {
      AppLogger.error('[SyllabusParser] request to $uri timed out', e, st);
      throw const SyllabusParserException(
          'انتهت مهلة الطلب. يُرجى التحقق من اتصالك والمحاولة مرة أخرى.');
    } on SocketException catch (e, st) {
      AppLogger.error('[SyllabusParser] network error sending to $uri', e, st);
      throw const SyllabusParserException(
          'لا يوجد اتصال بالشبكة. يُرجى المحاولة مرة أخرى.');
    }
  }

  Never _throwForStatus(int statusCode, String body) {
    Map<String, dynamic>? decoded;
    try {
      decoded = jsonDecode(body) as Map<String, dynamic>;
    } catch (_) {
      decoded = null;
    }
    final serverMessage = decoded?['error'] as String?;

    switch (statusCode) {
      case 401:
        throw const SessionExpiredException(
            'انتهت صلاحية الجلسة. يُرجى تسجيل الدخول مرة أخرى.');
      case 403:
        throw const PremiumRequiredException(
            'هذه الميزة متاحة فقط لمشتركي نور.');
      case 429:
        final limit = decoded?['limit'];
        throw MonthlyLimitReachedException(
          limit != null
              ? 'لقد استخدمت الحد الأقصى لهذا الشهر ($limit طلبًا). حاول مرة أخرى الشهر القادم.'
              : 'لقد استخدمت الحد الأقصى لهذا الشهر. حاول مرة أخرى الشهر القادم.',
        );
      default:
        throw SyllabusParserException(serverMessage ?? 'خطأ غير معروف');
    }
  }
}

class SyllabusParserException implements Exception {
  final String message;
  const SyllabusParserException(this.message);

  @override
  String toString() => 'SyllabusParserException: $message';
}

/// No Firebase user is signed in. Show a sign-in prompt before retrying.
class UnauthenticatedException extends SyllabusParserException {
  const UnauthenticatedException(super.message);
}

/// The ID token was rejected even after a forced refresh — user likely needs
/// to sign in again (token revoked, account deleted, etc.).
class SessionExpiredException extends SyllabusParserException {
  const SessionExpiredException(super.message);
}

/// The signed-in user doesn't have the Noor entitlement. Show the paywall.
class PremiumRequiredException extends SyllabusParserException {
  const PremiumRequiredException(super.message);
}

/// The user has hit their monthly request cap.
class MonthlyLimitReachedException extends SyllabusParserException {
  const MonthlyLimitReachedException(super.message);
}