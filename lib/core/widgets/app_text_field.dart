import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../theme/app_colors.dart';

/// The app's single text-input widget.
///
/// Wraps a borderless [TextField] in a rounded, filled box that lights up with
/// the brand accent on focus. Built for an Arabic-first / RTL app:
///   • text and hint follow the ambient [Directionality] (right-aligned),
///   • numeric inputs flip to LTR so digits read naturally while staying in the
///     same right-hand column,
///   • generous, vertically-centred padding so tall Arabic glyphs never clip,
///   • the caret and selection use the brand accent (set globally in the theme).
class AppTextField extends StatefulWidget {
  final TextEditingController controller;
  final String? hintText;
  final TextInputType? keyboardType;
  final ValueChanged<String>? onChanged;
  final ValueChanged<String>? onSubmitted;
  final int maxLines;
  final bool autofocus;
  final TextInputAction? textInputAction;

  /// When true the field is treated as numeric: digit keyboard, digits-only
  /// input, and LTR rendering so numbers don't reorder under RTL.
  final bool numeric;

  const AppTextField({
    super.key,
    required this.controller,
    this.hintText,
    this.keyboardType,
    this.onChanged,
    this.onSubmitted,
    this.maxLines = 1,
    this.autofocus = false,
    this.textInputAction,
    this.numeric = false,
  });

  @override
  State<AppTextField> createState() => _AppTextFieldState();
}

class _AppTextFieldState extends State<AppTextField> {
  late final FocusNode _focusNode;
  bool _focused = false;

  @override
  void initState() {
    super.initState();
    _focusNode = FocusNode()..addListener(_onFocusChange);
  }

  void _onFocusChange() {
    if (_focused != _focusNode.hasFocus) {
      setState(() => _focused = _focusNode.hasFocus);
    }
  }

  @override
  void dispose() {
    _focusNode
      ..removeListener(_onFocusChange)
      ..dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final c = context.c;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 150),
      curve: Curves.easeOut,
      padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 12.h),
      decoration: BoxDecoration(
        color: _focused ? c.surface : c.surfaceAlt,
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(
          color: _focused ? c.accent : c.border,
          width: _focused ? 1.5 : 1,
        ),
      ),
      child: TextField(
        controller: widget.controller,
        focusNode: _focusNode,
        autofocus: widget.autofocus,
        maxLines: widget.maxLines,
        keyboardType:
            widget.keyboardType ?? (widget.numeric ? TextInputType.number : null),
        textInputAction: widget.textInputAction,
        inputFormatters:
            widget.numeric ? [FilteringTextInputFormatter.digitsOnly] : null,
        // Numbers stay LTR so they don't reorder under the RTL ambient
        // direction; everything else follows the locale (right-aligned Arabic).
        textDirection: widget.numeric ? TextDirection.ltr : null,
        textAlign: widget.numeric ? TextAlign.right : TextAlign.start,
        textAlignVertical: TextAlignVertical.center,
        cursorColor: c.accent,
        cursorRadius: Radius.circular(2.r),
        cursorWidth: 1.6,
        style: TextStyle(
          fontSize: 14.sp,
          color: c.textPrimary,
          height: 1.4,
        ),
        onChanged: widget.onChanged,
        onSubmitted: widget.onSubmitted,
        decoration: InputDecoration(
          isCollapsed: true,
          // The outer AnimatedContainer is the field's surface; turn off the
          // global inputDecorationTheme fill so it doesn't paint a second gray
          // box inside (which also stole the tap target).
          filled: false,
          fillColor: Colors.transparent,
          border: InputBorder.none,
          enabledBorder: InputBorder.none,
          focusedBorder: InputBorder.none,
          hintText: widget.hintText,
          hintStyle: TextStyle(
            fontSize: 14.sp,
            color: c.textMuted,
            height: 1.4,
          ),
        ),
      ),
    );
  }
}
