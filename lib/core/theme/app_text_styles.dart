import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

/// Typographic scale for the app, tuned for the **Cairo** Arabic typeface.
///
/// Add the font to pubspec.yaml:
///
/// flutter:
///   fonts:
///     - family: Cairo
///       fonts:
///         - asset: assets/fonts/Cairo-Regular.ttf
///         - asset: assets/fonts/Cairo-Medium.ttf    weight: 500
///         - asset: assets/fonts/Cairo-SemiBold.ttf  weight: 600
///         - asset: assets/fonts/Cairo-Bold.ttf      weight: 700
///         - asset: assets/fonts/Cairo-Black.ttf     weight: 800
///
/// Notes for Arabic / RTL:
/// * **No positive `letterSpacing`.** Adding tracking between Arabic glyphs
///   visually disconnects letters that should join, so every style pins it to
///   zero — a small but important correctness fix for an Arabic-first app.
/// * Line heights stay generous so stacked diacritics and tall letterforms
///   never collide.
///
/// Colors are intentionally omitted; [AppTheme] paints the whole scale with the
/// active color scheme's `onSurface`, which keeps light/dark always correct.
abstract final class AppTextStyles {
  static const String _fontFamily = 'Cairo';

  static TextStyle _style(double size, FontWeight weight, double height) =>
      TextStyle(
        fontFamily: _fontFamily,
        fontSize: size.sp,
        fontWeight: weight,
        height: height,
        letterSpacing: 0,
      );

  // ── Display — hero numbers, splash, big moments ──────────
  static TextStyle get displayLarge => _style(34, FontWeight.w800, 1.18);
  static TextStyle get displayMedium => _style(28, FontWeight.w800, 1.22);
  static TextStyle get displaySmall => _style(24, FontWeight.w700, 1.28);

  // ── Headline — screen & section titles ───────────────────
  static TextStyle get headlineLarge => _style(22, FontWeight.w700, 1.34);
  static TextStyle get headlineMedium => _style(19, FontWeight.w700, 1.36);
  static TextStyle get headlineSmall => _style(17, FontWeight.w600, 1.4);

  // ── Title — cards, list headers, dialog titles ───────────
  static TextStyle get titleLarge => _style(16, FontWeight.w700, 1.4);
  static TextStyle get titleMedium => _style(15, FontWeight.w600, 1.45);
  static TextStyle get titleSmall => _style(13, FontWeight.w600, 1.45);

  // ── Body — running text ──────────────────────────────────
  static TextStyle get bodyLarge => _style(16, FontWeight.w400, 1.6);
  static TextStyle get bodyMedium => _style(14, FontWeight.w400, 1.6);
  static TextStyle get bodySmall => _style(12.5, FontWeight.w400, 1.55);

  // ── Label — buttons, chips, captions ─────────────────────
  static TextStyle get labelLarge => _style(14.5, FontWeight.w700, 1.2);
  static TextStyle get labelMedium => _style(12.5, FontWeight.w600, 1.3);
  static TextStyle get labelSmall => _style(11, FontWeight.w600, 1.3);

  /// The complete [TextTheme], colored with [color] (the scheme's `onSurface`).
  /// `.apply` paints body + display groups so every role is set in one place.
  static TextTheme textTheme(Color color) => TextTheme(
        displayLarge: displayLarge,
        displayMedium: displayMedium,
        displaySmall: displaySmall,
        headlineLarge: headlineLarge,
        headlineMedium: headlineMedium,
        headlineSmall: headlineSmall,
        titleLarge: titleLarge,
        titleMedium: titleMedium,
        titleSmall: titleSmall,
        bodyLarge: bodyLarge,
        bodyMedium: bodyMedium,
        bodySmall: bodySmall,
        labelLarge: labelLarge,
        labelMedium: labelMedium,
        labelSmall: labelSmall,
      ).apply(bodyColor: color, displayColor: color);
}
