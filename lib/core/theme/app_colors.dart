import 'package:flutter/material.dart';

/// Semantic color tokens for the app, themeable across light & dark.
///
/// Registered as a [ThemeExtension] through [AppTheme], so screens read tokens
/// via `context.c.textPrimary`, `context.c.surface`, etc. (see [AppColorsX]).
@immutable
class AppColors extends ThemeExtension<AppColors> {
  /// Seed color for `ColorScheme.fromSeed` — matches [light]'s accent so the
  /// Material color scheme stays consistent with the semantic tokens.
  static const Color seed = Color(0xFF378ADD);

  final Color background;
  final Color surface;
  final Color surfaceAlt;
  final Color surfaceMuted;
  final Color border;
  final Color borderSubtle;
  final Color textPrimary;
  final Color textSecondary;
  final Color textMuted;
  final Color accent;
  final Color warning;
  final Color warningBg;
  final Color warningFg;
  final Color spineLine;
  final Color shadow;

  const AppColors({
    required this.background,
    required this.surface,
    required this.surfaceAlt,
    required this.surfaceMuted,
    required this.border,
    required this.borderSubtle,
    required this.textPrimary,
    required this.textSecondary,
    required this.textMuted,
    required this.accent,
    required this.warning,
    required this.warningBg,
    required this.warningFg,
    required this.spineLine,
    required this.shadow,
  });

  static const light = AppColors(
    background: Color(0xFFF6F7FB),
    surface: Color(0xFFFFFFFF),
    surfaceAlt: Color(0xFFFBFCFE),
    surfaceMuted: Color(0xFFF1F5F9),
    border: Color(0xFFE5E7EB),
    borderSubtle: Color(0xFFE2E8F0),
    textPrimary: Color(0xFF0F172A),
    textSecondary: Color(0xFF64748B),
    textMuted: Color(0xFF94A3B8),
    accent: Color(0xFF378ADD),
    warning: Color(0xFFEF9F27),
    warningBg: Color(0xFFFFF8EE),
    warningFg: Color(0xFF854F0B),
    spineLine: Color(0xFFE2E8F0),
    shadow: Color(0x140F172A),
  );

  static const dark = AppColors(
    background: Color(0xFF0B1120),
    surface: Color(0xFF151C2C),
    surfaceAlt: Color(0xFF1B2333),
    surfaceMuted: Color(0xFF1E2A3F),
    border: Color(0xFF273349),
    borderSubtle: Color(0xFF222D40),
    textPrimary: Color(0xFFF1F5F9),
    textSecondary: Color(0xFF94A3B8),
    textMuted: Color(0xFF64748B),
    accent: Color(0xFF60A5FA),
    warning: Color(0xFFF2B24C),
    warningBg: Color(0xFF2A2616),
    warningFg: Color(0xFFF2C879),
    spineLine: Color(0xFF2A3650),
    shadow: Color(0x40000000),
  );

  @override
  AppColors copyWith({
    Color? background,
    Color? surface,
    Color? surfaceAlt,
    Color? surfaceMuted,
    Color? border,
    Color? borderSubtle,
    Color? textPrimary,
    Color? textSecondary,
    Color? textMuted,
    Color? accent,
    Color? warning,
    Color? warningBg,
    Color? warningFg,
    Color? spineLine,
    Color? shadow,
  }) {
    return AppColors(
      background: background ?? this.background,
      surface: surface ?? this.surface,
      surfaceAlt: surfaceAlt ?? this.surfaceAlt,
      surfaceMuted: surfaceMuted ?? this.surfaceMuted,
      border: border ?? this.border,
      borderSubtle: borderSubtle ?? this.borderSubtle,
      textPrimary: textPrimary ?? this.textPrimary,
      textSecondary: textSecondary ?? this.textSecondary,
      textMuted: textMuted ?? this.textMuted,
      accent: accent ?? this.accent,
      warning: warning ?? this.warning,
      warningBg: warningBg ?? this.warningBg,
      warningFg: warningFg ?? this.warningFg,
      spineLine: spineLine ?? this.spineLine,
      shadow: shadow ?? this.shadow,
    );
  }

  /// Builds a Material 3 [ColorScheme] whose surface ramp is aligned to these
  /// semantic tokens, so framework widgets (Card, inputs, chips, sheets) and
  /// custom widgets that read `context.c.*` share one cohesive palette instead
  /// of drifting apart. Tonal roles (primary/secondary/tertiary, error) still
  /// come from a seeded scheme so they stay in harmony.
  ColorScheme toColorScheme(Brightness brightness, {Color? seed}) {
    final isDark = brightness == Brightness.dark;
    final base = ColorScheme.fromSeed(
      seedColor: seed ?? accent,
      brightness: brightness,
    );

    return base.copyWith(
      primary: seed ?? accent,
      onPrimary: isDark ? const Color(0xFF06122A) : const Color(0xFFFFFFFF),
      // Surface ramp — low → high elevation, drawn straight from the tokens
      // (with a couple of in-between steps for inputs and pressed states).
      surface: surface,
      onSurface: textPrimary,
      onSurfaceVariant: textSecondary,
      surfaceContainerLowest: isDark ? const Color(0xFF0E1422) : const Color(0xFFFFFFFF),
      surfaceContainerLow: surface,
      surfaceContainer: isDark ? const Color(0xFF1A2233) : const Color(0xFFF4F6FA),
      surfaceContainerHigh: isDark ? const Color(0xFF1F283B) : const Color(0xFFEEF1F7),
      surfaceContainerHighest: isDark ? const Color(0xFF273245) : const Color(0xFFE7ECF3),
      // `outline` is M3's *visible* border / medium-emphasis tone — screens also
      // use it for muted text (section labels, captions), so it must stay
      // readable. `outlineVariant` carries the faint hairlines (cards, dividers).
      outline: textSecondary,
      outlineVariant: borderSubtle,
      surfaceTint: seed ?? accent,
      shadow: shadow,
    );
  }

  @override
  AppColors lerp(ThemeExtension<AppColors>? other, double t) {
    if (other is! AppColors) return this;
    return AppColors(
      background: Color.lerp(background, other.background, t)!,
      surface: Color.lerp(surface, other.surface, t)!,
      surfaceAlt: Color.lerp(surfaceAlt, other.surfaceAlt, t)!,
      surfaceMuted: Color.lerp(surfaceMuted, other.surfaceMuted, t)!,
      border: Color.lerp(border, other.border, t)!,
      borderSubtle: Color.lerp(borderSubtle, other.borderSubtle, t)!,
      textPrimary: Color.lerp(textPrimary, other.textPrimary, t)!,
      textSecondary: Color.lerp(textSecondary, other.textSecondary, t)!,
      textMuted: Color.lerp(textMuted, other.textMuted, t)!,
      accent: Color.lerp(accent, other.accent, t)!,
      warning: Color.lerp(warning, other.warning, t)!,
      warningBg: Color.lerp(warningBg, other.warningBg, t)!,
      warningFg: Color.lerp(warningFg, other.warningFg, t)!,
      spineLine: Color.lerp(spineLine, other.spineLine, t)!,
      shadow: Color.lerp(shadow, other.shadow, t)!,
    );
  }
}

extension AppColorsX on BuildContext {
  /// Shorthand: `context.c.textPrimary`
  AppColors get c => Theme.of(this).extension<AppColors>()!;

  bool get isDark => Theme.of(this).brightness == Brightness.dark;
}

/// Parses a course hex string (e.g. "#1D4ED8") into a Color, brightening it
/// for dark backgrounds so accents stay legible.
Color courseColor(BuildContext context, String? hex) {
  final base = _parseHex(hex);
  if (context.isDark) {
    return Color.lerp(base, Colors.white, 0.32)!;
  }
  return base;
}

/// Raw parse with no theme adjustment (for colored surfaces that always use
/// white foreground, like the upcoming hero card).
Color courseColorRaw(String? hex) => _parseHex(hex);

Color _parseHex(String? hex) {
  const fallback = Color(0xFF378ADD);
  if (hex == null || hex.trim().isEmpty) return fallback;
  var v = hex.trim();
  if (v.startsWith('#')) v = v.substring(1);
  if (v.length == 6) v = 'FF$v';
  if (v.length != 8) return fallback;
  final n = int.tryParse(v, radix: 16);
  return n == null ? fallback : Color(n);
}
