import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

/// Uses Tajawal — add to pubspec.yaml:
///
/// flutter:
///   fonts:
///     - family: Tajawal
///       fonts:
///         - asset: assets/fonts/Tajawal-Regular.ttf
///         - asset: assets/fonts/Tajawal-Medium.ttf   weight: 500
///         - asset: assets/fonts/Tajawal-Bold.ttf     weight: 700
///
/// Or use google_fonts package: GoogleFonts.tajawalTextTheme()
abstract final class AppTextStyles {
  static const String _fontFamily = 'Cairo';

  static TextStyle get displayLarge => TextStyle(
        fontFamily: _fontFamily,
        fontSize: 32.sp,
        fontWeight: FontWeight.w700,
        height: 1.3,
      );

  static TextStyle get displayMedium => TextStyle(
        fontFamily: _fontFamily,
        fontSize: 26.sp,
        fontWeight: FontWeight.w700,
        height: 1.3,
      );

  static TextStyle get headlineLarge => TextStyle(
        fontFamily: _fontFamily,
        fontSize: 22.sp,
        fontWeight: FontWeight.w700,
        height: 1.4,
      );

  static TextStyle get headlineMedium => TextStyle(
        fontFamily: _fontFamily,
        fontSize: 18.sp,
        fontWeight: FontWeight.w600,
        height: 1.4,
      );

  static TextStyle get bodyLarge => TextStyle(
        fontFamily: _fontFamily,
        fontSize: 16.sp,
        fontWeight: FontWeight.w400,
        height: 1.6,
      );

  static TextStyle get bodyMedium => TextStyle(
        fontFamily: _fontFamily,
        fontSize: 14.sp,
        fontWeight: FontWeight.w400,
        height: 1.6,
      );

  static TextStyle get labelLarge => TextStyle(
        fontFamily: _fontFamily,
        fontSize: 14.sp,
        fontWeight: FontWeight.w600,
        letterSpacing: 0.1,
      );

  static TextStyle get labelMedium => TextStyle(
        fontFamily: _fontFamily,
        fontSize: 12.sp,
        fontWeight: FontWeight.w500,
        letterSpacing: 0.1,
      );
}