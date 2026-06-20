import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:purchases_flutter/purchases_flutter.dart' show Package;

import '../../../../core/utils/extensions/context_extensions.dart';
import '../paywall_strings.dart';

/// A selectable pricing tier (annual or lifetime). The page owns selection;
/// this widget only renders the tier and reports taps.
class PackageCard extends StatelessWidget {
  final Package package;

  /// Localized tier name, e.g. "سنوي" / "مدى الحياة".
  final String tierTitle;

  /// Optional corner badge, e.g. "الأكثر شيوعًا" / "وفّر ٦٠٪".
  final String? badge;

  /// Shown after the price, e.g. "في السنة". Null for one-time tiers.
  final String? period;

  /// Extra line under the price, e.g. the lifetime "one payment" note.
  final String? footnote;

  final bool isSelected;
  final VoidCallback onTap;

  const PackageCard({
    super.key,
    required this.package,
    required this.tierTitle,
    required this.isSelected,
    required this.onTap,
    this.badge,
    this.period,
    this.footnote,
  });

  @override
  Widget build(BuildContext context) {
    final product = package.storeProduct;
    final hasTrial = product.introductoryPrice != null;
    final borderColor =
        isSelected ? context.colors.primary : context.colors.outlineVariant;

    return Material(
      color: isSelected
          ? context.colors.primaryContainer.withOpacity(0.25)
          : context.colors.surfaceContainerLow,
      borderRadius: BorderRadius.circular(16.r),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16.r),
        child: Container(
          padding: EdgeInsets.all(14.r),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16.r),
            border: Border.all(
              color: borderColor,
              width: isSelected ? 2 : 1,
            ),
          ),
          child: Row(
            children: [
              _RadioDot(isSelected: isSelected),
              SizedBox(width: 12.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(tierTitle, style: context.textTheme.titleMedium),
                    SizedBox(height: 4.h),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.baseline,
                      textBaseline: TextBaseline.alphabetic,
                      children: [
                        Text(
                          product.priceString,
                          style: context.textTheme.headlineSmall,
                        ),
                        if (period != null) ...[
                          SizedBox(width: 6.w),
                          Text(
                            period!,
                            style: context.textTheme.bodySmall
                                ?.copyWith(color: context.colors.outline),
                          ),
                        ],
                      ],
                    ),
                    if (footnote != null) ...[
                      SizedBox(height: 4.h),
                      Text(
                        footnote!,
                        style: context.textTheme.bodySmall
                            ?.copyWith(color: context.colors.outline),
                      ),
                    ],
                    if (hasTrial) ...[
                      SizedBox(height: 6.h),
                      Text(
                        PaywallStrings.trialBadge,
                        style: context.textTheme.labelMedium
                            ?.copyWith(color: context.colors.primary),
                      ),
                    ],
                  ],
                ),
              ),
              if (badge != null) ...[
                SizedBox(width: 8.w),
                _Badge(label: badge!),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

// ── Selection indicator ──────────────────────────────────────────────────────

class _RadioDot extends StatelessWidget {
  final bool isSelected;
  const _RadioDot({required this.isSelected});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 22.r,
      height: 22.r,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(
          color: isSelected ? context.colors.primary : context.colors.outline,
          width: 2,
        ),
      ),
      alignment: Alignment.center,
      child: isSelected
          ? Container(
              width: 12.r,
              height: 12.r,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: context.colors.primary,
              ),
            )
          : null,
    );
  }
}

// ── Corner badge ─────────────────────────────────────────────────────────────

class _Badge extends StatelessWidget {
  final String label;
  const _Badge({required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 5.h),
      decoration: BoxDecoration(
        color: context.colors.primary,
        borderRadius: BorderRadius.circular(20.r),
      ),
      child: Text(
        label,
        style: context.textTheme.labelMedium?.copyWith(
          color: context.colors.onPrimary,
          fontSize: 11.sp,
        ),
      ),
    );
  }
}
