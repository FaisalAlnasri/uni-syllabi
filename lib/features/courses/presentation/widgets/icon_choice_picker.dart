import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../core/theme/app_colors.dart';

/// A wrap of selectable icons, led by an "auto" cell (shown with a sparkle
/// badge) that clears the selection back to `null` — i.e. "use the default".
///
/// Generic over what's being iconified: pass the [icons] to choose from and the
/// [autoIcon] to preview in the auto cell. [selectedKey] is the current choice
/// (`null` = auto); [onSelected] reports the new key (`null` when auto is
/// tapped).
class IconChoicePicker extends StatelessWidget {
  final IconData autoIcon;
  final Map<String, IconData> icons;
  final String? selectedKey;
  final ValueChanged<String?> onSelected;

  const IconChoicePicker({
    super.key,
    required this.autoIcon,
    required this.icons,
    required this.selectedKey,
    required this.onSelected,
  });

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 8.w,
      runSpacing: 8.w,
      children: [
        _IconCell(
          icon: autoIcon,
          selected: selectedKey == null,
          isAuto: true,
          onTap: () => onSelected(null),
        ),
        for (final entry in icons.entries)
          _IconCell(
            icon: entry.value,
            selected: selectedKey == entry.key,
            onTap: () => onSelected(entry.key),
          ),
      ],
    );
  }
}

class _IconCell extends StatelessWidget {
  final IconData icon;
  final bool selected;
  final bool isAuto;
  final VoidCallback onTap;

  const _IconCell({
    required this.icon,
    required this.selected,
    required this.onTap,
    this.isAuto = false,
  });

  @override
  Widget build(BuildContext context) {
    final c = context.c;
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 46.r,
        height: 46.r,
        decoration: BoxDecoration(
          color: selected ? c.accent.withValues(alpha: 0.14) : c.surfaceAlt,
          borderRadius: BorderRadius.circular(12.r),
          border: Border.all(
            color: selected ? c.accent : c.border,
            width: selected ? 1.5 : 1,
          ),
        ),
        child: Stack(
          children: [
            Center(
              child: Icon(
                icon,
                size: 20.sp,
                color: selected ? c.accent : c.textSecondary,
              ),
            ),
            if (isAuto)
              Positioned(
                top: 3.r,
                right: 3.r,
                child: Icon(
                  Icons.auto_awesome,
                  size: 9.sp,
                  color: selected ? c.accent : c.textMuted,
                ),
              ),
          ],
        ),
      ),
    );
  }
}
