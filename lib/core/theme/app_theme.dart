import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'app_colors.dart';
import 'app_text_styles.dart';

/// Builds the app's Material 3 themes.
///
/// Light and dark are produced by a single [_build] so the two can never drift:
/// every component is colored from the [ColorScheme] for the requested
/// brightness. (The previous design built dark by patching the light theme,
/// which left framework widgets — cards, inputs, text — stuck on light colors.)
///
/// Usage:
///   MaterialApp(theme: AppTheme.build(), darkTheme: AppTheme.buildDark())
/// Override the brand color:
///   AppTheme.build(seedColor: Color(0xFFXXXXXX))
abstract final class AppTheme {
  static ThemeData build({Color seedColor = AppColors.seed}) =>
      _build(AppColors.light, Brightness.light, seedColor);

  static ThemeData buildDark({Color seedColor = AppColors.seed}) =>
      _build(AppColors.dark, Brightness.dark, seedColor);

  // ── Shared shape tokens ─────────────────────────────────────
  static const double _rButton = 14;
  static const double _rField = 14;
  static const double _rCard = 20;
  static const double _rSheet = 24;
  static const double _rChip = 10;

  static ThemeData _build(AppColors c, Brightness brightness, Color seed) {
    final scheme = c.toColorScheme(brightness, seed: seed);
    final isDark = brightness == Brightness.dark;
    final text = AppTextStyles.textTheme(scheme.onSurface);

    // Transparent status bar with brightness-correct icons; nav bar tracks the
    // scaffold so the system chrome blends into the app.
    final overlay = (isDark ? SystemUiOverlayStyle.light : SystemUiOverlayStyle.dark)
        .copyWith(
      statusBarColor: Colors.transparent,
      systemNavigationBarColor: c.background,
      systemNavigationBarIconBrightness:
          isDark ? Brightness.light : Brightness.dark,
    );

    OutlineInputBorder fieldBorder(Color color, double width) =>
        OutlineInputBorder(
          borderRadius: BorderRadius.circular(_rField.r),
          borderSide: width == 0
              ? BorderSide.none
              : BorderSide(color: color, width: width),
        );

    return ThemeData(
      useMaterial3: true,
      brightness: brightness,
      colorScheme: scheme,
      fontFamily: 'Cairo',
      textTheme: text,
      extensions: <ThemeExtension<dynamic>>[c],

      // ── Canvas ──────────────────────────────────────────────
      scaffoldBackgroundColor: c.background,
      canvasColor: c.background,
      dividerColor: scheme.outlineVariant,

      // Calmer, brand-tinted ink instead of the default grey ripple.
      splashColor: scheme.primary.withValues(alpha: 0.08),
      highlightColor: scheme.primary.withValues(alpha: 0.04),

      // ── Icons ───────────────────────────────────────────────
      iconTheme: IconThemeData(color: scheme.onSurfaceVariant, size: 24.r),
      primaryIconTheme: IconThemeData(color: scheme.onPrimary, size: 24.r),

      // ── AppBar — seamless with the body, flat while scrolling ─
      appBarTheme: AppBarTheme(
        backgroundColor: c.background,
        foregroundColor: scheme.onSurface,
        surfaceTintColor: Colors.transparent,
        shadowColor: Colors.transparent,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: true,
        systemOverlayStyle: overlay,
        titleTextStyle: text.titleLarge,
        iconTheme: IconThemeData(color: scheme.onSurface, size: 24.r),
        actionsIconTheme: IconThemeData(color: scheme.onSurface, size: 24.r),
      ),

      // ── Buttons ─────────────────────────────────────────────
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          backgroundColor: scheme.primary,
          foregroundColor: scheme.onPrimary,
          disabledBackgroundColor: scheme.onSurface.withValues(alpha: 0.12),
          disabledForegroundColor: scheme.onSurface.withValues(alpha: 0.38),
          minimumSize: Size.fromHeight(54.h),
          elevation: 0,
          textStyle: AppTextStyles.labelLarge,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(_rButton.r),
          ),
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: scheme.primary,
          foregroundColor: scheme.onPrimary,
          minimumSize: Size.fromHeight(54.h),
          elevation: 0,
          textStyle: AppTextStyles.labelLarge,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(_rButton.r),
          ),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: scheme.primary,
          minimumSize: Size.fromHeight(54.h),
          side: BorderSide(color: scheme.outline, width: 1.4),
          textStyle: AppTextStyles.labelLarge,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(_rButton.r),
          ),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: scheme.primary,
          textStyle: AppTextStyles.labelLarge,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10.r),
          ),
        ),
      ),
      iconButtonTheme: IconButtonThemeData(
        style: IconButton.styleFrom(foregroundColor: scheme.onSurfaceVariant),
      ),
      floatingActionButtonTheme: FloatingActionButtonThemeData(
        backgroundColor: scheme.primary,
        foregroundColor: scheme.onPrimary,
        elevation: 2,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(18.r),
        ),
      ),

      // ── Card — hairline-bordered surface, no muddy tint ──────
      cardTheme: CardThemeData(
        elevation: 0,
        color: scheme.surfaceContainerLow,
        surfaceTintColor: Colors.transparent,
        shadowColor: c.shadow,
        margin: EdgeInsets.zero,
        clipBehavior: Clip.antiAlias,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(_rCard.r),
          side: BorderSide(color: scheme.outlineVariant, width: 1),
        ),
      ),

      // ── List tiles ──────────────────────────────────────────
      listTileTheme: ListTileThemeData(
        iconColor: scheme.onSurfaceVariant,
        textColor: scheme.onSurface,
        selectedColor: scheme.primary,
        selectedTileColor: scheme.primary.withValues(alpha: 0.08),
        contentPadding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 4.h),
        minVerticalPadding: 12.h,
        titleTextStyle: text.bodyLarge,
        subtitleTextStyle:
            text.bodySmall?.copyWith(color: scheme.onSurfaceVariant),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16.r),
        ),
      ),

      // ── Dividers ────────────────────────────────────────────
      dividerTheme: DividerThemeData(
        color: scheme.outlineVariant,
        thickness: 1,
        space: 1,
      ),

      // ── Inputs ──────────────────────────────────────────────
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: scheme.surfaceContainerHighest,
        hintStyle: text.bodyMedium?.copyWith(color: scheme.onSurfaceVariant),
        labelStyle: text.bodyMedium?.copyWith(color: scheme.onSurfaceVariant),
        prefixIconColor: scheme.onSurfaceVariant,
        suffixIconColor: scheme.onSurfaceVariant,
        contentPadding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 16.h),
        border: fieldBorder(Colors.transparent, 0),
        enabledBorder: fieldBorder(Colors.transparent, 0),
        focusedBorder: fieldBorder(scheme.primary, 1.6),
        errorBorder: fieldBorder(scheme.error, 1.4),
        focusedErrorBorder: fieldBorder(scheme.error, 1.6),
      ),

      // ── Chips ───────────────────────────────────────────────
      chipTheme: ChipThemeData(
        backgroundColor: scheme.surfaceContainerHigh,
        selectedColor: scheme.primary.withValues(alpha: isDark ? 0.26 : 0.12),
        side: BorderSide.none,
        showCheckmark: false,
        labelStyle: text.labelMedium?.copyWith(color: scheme.onSurface),
        secondaryLabelStyle:
            text.labelMedium?.copyWith(color: scheme.primary),
        padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(_rChip.r),
        ),
      ),

      // ── Selection controls ──────────────────────────────────
      switchTheme: SwitchThemeData(
        thumbColor: WidgetStateProperty.resolveWith(
          (s) => s.contains(WidgetState.selected)
              ? scheme.onPrimary
              : scheme.outline,
        ),
        trackColor: WidgetStateProperty.resolveWith(
          (s) => s.contains(WidgetState.selected)
              ? scheme.primary
              : scheme.surfaceContainerHighest,
        ),
        trackOutlineColor: WidgetStateProperty.all(Colors.transparent),
      ),
      checkboxTheme: CheckboxThemeData(
        fillColor: WidgetStateProperty.resolveWith(
          (s) => s.contains(WidgetState.selected)
              ? scheme.primary
              : Colors.transparent,
        ),
        checkColor: WidgetStateProperty.all(scheme.onPrimary),
        side: BorderSide(color: scheme.outline, width: 1.5),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(6.r),
        ),
      ),
      radioTheme: RadioThemeData(
        fillColor: WidgetStateProperty.resolveWith(
          (s) => s.contains(WidgetState.selected)
              ? scheme.primary
              : scheme.outline,
        ),
      ),

      // ── Progress ────────────────────────────────────────────
      progressIndicatorTheme: ProgressIndicatorThemeData(
        color: scheme.primary,
        linearTrackColor: scheme.surfaceContainerHighest,
        circularTrackColor: scheme.surfaceContainerHighest,
      ),

      // ── Bottom navigation (both M3 and M2 widgets) ──────────
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: scheme.surface,
        surfaceTintColor: Colors.transparent,
        indicatorColor: scheme.primary.withValues(alpha: isDark ? 0.24 : 0.12),
        elevation: 0,
        height: 64.h,
        labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
        iconTheme: WidgetStateProperty.resolveWith(
          (s) => IconThemeData(
            size: 24.r,
            color: s.contains(WidgetState.selected)
                ? scheme.primary
                : scheme.onSurfaceVariant,
          ),
        ),
        labelTextStyle: WidgetStateProperty.resolveWith(
          (s) => text.labelMedium?.copyWith(
            color: s.contains(WidgetState.selected)
                ? scheme.primary
                : scheme.onSurfaceVariant,
          ),
        ),
      ),
      bottomNavigationBarTheme: BottomNavigationBarThemeData(
        backgroundColor: scheme.surface,
        selectedItemColor: scheme.primary,
        unselectedItemColor: scheme.onSurfaceVariant,
        type: BottomNavigationBarType.fixed,
        elevation: 0,
        selectedLabelStyle: text.labelSmall,
        unselectedLabelStyle: text.labelSmall,
      ),

      // ── Dialog ──────────────────────────────────────────────
      dialogTheme: DialogThemeData(
        backgroundColor: scheme.surface,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        titleTextStyle: text.headlineSmall,
        contentTextStyle:
            text.bodyMedium?.copyWith(color: scheme.onSurfaceVariant),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(_rSheet.r),
        ),
      ),

      // ── Bottom sheet ────────────────────────────────────────
      bottomSheetTheme: BottomSheetThemeData(
        backgroundColor: scheme.surface,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        // No `showDragHandle` — the app's sheets draw their own grab handle, so
        // enabling the framework one too would stack a second line on top.
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(_rSheet.r)),
        ),
      ),

      // ── Snackbar — dark pill in light, raised surface in dark ─
      snackBarTheme: SnackBarThemeData(
        behavior: SnackBarBehavior.floating,
        backgroundColor:
            isDark ? scheme.surfaceContainerHighest : scheme.onSurface,
        contentTextStyle: text.bodyMedium?.copyWith(
          color: isDark ? scheme.onSurface : scheme.surface,
          fontWeight: FontWeight.w500,
        ),
        actionTextColor: scheme.primary,
        elevation: 4,
        insetPadding: EdgeInsets.all(16.w),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(_rButton.r),
        ),
      ),

      // ── Tooltip ─────────────────────────────────────────────
      tooltipTheme: TooltipThemeData(
        decoration: BoxDecoration(
          color: scheme.inverseSurface,
          borderRadius: BorderRadius.circular(8.r),
        ),
        textStyle:
            text.labelMedium?.copyWith(color: scheme.onInverseSurface),
      ),
    );
  }
}
