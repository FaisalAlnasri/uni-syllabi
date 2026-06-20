import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/router/app_routes.dart';
import '../../../../core/theme/app_colors.dart';
import '../../data/services/syllabus_parser_service.dart';
import '../../domain/entities/course.dart';
import '../courses_strings.dart';

enum _Phase { idle, loading, error }

class SyllabusUploadDialog extends StatefulWidget {
  final SyllabusParserService service;

  const SyllabusUploadDialog({super.key, required this.service});

  @override
  State<SyllabusUploadDialog> createState() => _SyllabusUploadDialogState();
}

class _SyllabusUploadDialogState extends State<SyllabusUploadDialog> {
  _Phase _phase = _Phase.idle;
  String? _errorMessage;

  Future<void> _pickAndParse() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['pdf', 'doc', 'docx', 'txt'],
    );

    if (result == null || result.files.single.path == null) return;

    setState(() {
      _phase = _Phase.loading;
      _errorMessage = null;
    });

    try {
      final file = File(result.files.single.path!);
      final List<Course> courses = await widget.service.parseSyllabus(file);

      if (!mounted) return;
      final router = GoRouter.of(context);
      Navigator.of(context).pop(); // close the dialog
      router.push(AppRoutes.courseConfirmation, extra: courses);
    } on SyllabusParserException catch (e) {
      setState(() {
        _phase = _Phase.error;
        _errorMessage = e.message;
      });
    } catch (e) {
      setState(() {
        _phase = _Phase.error;
        _errorMessage = CoursesStrings.genericError;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final c = context.c;
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      insetPadding: const EdgeInsets.symmetric(horizontal: 24),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(24, 28, 24, 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 60,
              height: 60,
              decoration: BoxDecoration(
                color: c.accent.withValues(alpha: 0.14),
                borderRadius: BorderRadius.circular(18),
              ),
              child: Icon(
                Icons.auto_awesome_rounded,
                size: 28,
                color: c.accent,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              CoursesStrings.addACourse,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: c.textPrimary,
                letterSpacing: -0.3,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              CoursesStrings.uploadSubtitle,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 13.5,
                color: c.textSecondary,
                height: 1.4,
              ),
            ),
            const SizedBox(height: 24),
            if (_phase == _Phase.error) ...[
              Container(
                padding: const EdgeInsets.fromLTRB(12, 10, 12, 10),
                decoration: BoxDecoration(
                  color: c.warningBg,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Row(
                  children: [
                    Icon(Icons.error_outline, size: 16, color: c.warningFg),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        _errorMessage ?? CoursesStrings.unknownError,
                        style: TextStyle(
                          fontSize: 12.5,
                          color: c.warningFg,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
            ],
            _phase == _Phase.loading
                ? const _LoadingIndicator()
                : _ChooseFileButton(onTap: _pickAndParse),
            const SizedBox(height: 12),
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text(
                CoursesStrings.cancel,
                style: TextStyle(
                  color: c.textMuted,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _LoadingIndicator extends StatelessWidget {
  const _LoadingIndicator();

  @override
  Widget build(BuildContext context) {
    final c = context.c;
    return Column(
      children: [
        SizedBox(
          width: 26,
          height: 26,
          child: CircularProgressIndicator(strokeWidth: 2.5, color: c.accent),
        ),
        const SizedBox(height: 12),
        Text(
          CoursesStrings.parsingSyllabus,
          style: TextStyle(
            fontSize: 13,
            color: c.textSecondary,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }
}

class _ChooseFileButton extends StatelessWidget {
  final VoidCallback onTap;
  const _ChooseFileButton({required this.onTap});

  @override
  Widget build(BuildContext context) {
    final c = context.c;
    return SizedBox(
      width: double.infinity,
      child: Material(
        color: c.accent,
        borderRadius: BorderRadius.circular(14),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(14),
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 14),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.folder_open_outlined,
                    size: 18, color: Colors.white),
                const SizedBox(width: 8),
                Text(
                  CoursesStrings.openFile,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w700,
                    fontSize: 15,
                    letterSpacing: -0.1,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
