import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';

import '../di/service_locator.dart';
import '../router/app_routes.dart';
import '../utils/extensions/context_extensions.dart';
import '../../features/paywall/domain/subscription.dart';

/// A card that shows premium content when subscribed,
/// or a locked state that opens the paywall on tap.
///
/// Usage:
/// ```dart
/// PremiumCard(
///   title: 'تحليلات متقدمة',
///   description: 'احصل على تقارير مفصّلة عن أدائك',
///   icon: Icons.analytics_outlined,
///   child: YourPremiumContent(),
/// )
/// ```
class PremiumCard extends StatelessWidget {
  final String title;
  final String description;
  final IconData icon;

  /// Shown when the user is subscribed. If null, a placeholder is shown.
  final Widget? child;

  const PremiumCard({
    super.key,
    required this.title,
    required this.description,
    required this.icon,
    this.child,
  });

  @override
  Widget build(BuildContext context) {
    final isSubscriber = sl<PurchasesRepository>().isSubscriber;

    return isSubscriber
        ? _UnlockedCard(
            title: title,
            icon: icon,
            child: child,
          )
        : _LockedCard(
            title: title,
            description: description,
            icon: icon,
          );
  }
}

// ── Locked state ──────────────────────────────────────────────────────────────

class _LockedCard extends StatelessWidget {
  final String title;
  final String description;
  final IconData icon;

  const _LockedCard({
    required this.title,
    required this.description,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => context.push(AppRoutes.paywall),
      child: Card(
        child: Padding(
          padding: EdgeInsets.all(16.r),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ── Header ────────────────────────────────────
              Row(
                children: [
                  Icon(icon, color: context.colors.outline, size: 20.r),
                  SizedBox(width: 8.w),
                  Expanded(
                    child: Text(
                      title,
                      style: context.textTheme.headlineMedium?.copyWith(
                        color: context.colors.outline,
                      ),
                    ),
                  ),
                  _PremiumBadge(),
                ],
              ),

              SizedBox(height: 12.h),

              // ── Blurred content placeholder ───────────────
              Stack(
                children: [
                  // Fake blurred rows
                  Column(
                    children: List.generate(
                      3,
                      (i) => Padding(
                        padding: EdgeInsets.only(bottom: 8.h),
                        child: Container(
                          height: 12.h,
                          width: double.infinity,
                          decoration: BoxDecoration(
                            color: context.colors.outlineVariant.withOpacity(0.4),
                            borderRadius: BorderRadius.circular(6.r),
                          ),
                        ),
                      ),
                    ),
                  ),

                  // Lock overlay
                  Positioned.fill(
                    child: Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.lock_outline,
                            color: context.colors.primary,
                            size: 24.r,
                          ),
                          SizedBox(height: 4.h),
                          Text(
                            description,
                            style: context.textTheme.labelMedium?.copyWith(
                              color: context.colors.primary,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ── Unlocked state ────────────────────────────────────────────────────────────

class _UnlockedCard extends StatelessWidget {
  final String title;
  final IconData icon;
  final Widget? child;

  const _UnlockedCard({
    required this.title,
    required this.icon,
    this.child,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: EdgeInsets.all(16.r),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, color: context.colors.primary, size: 20.r),
                SizedBox(width: 8.w),
                Expanded(
                  child: Text(title, style: context.textTheme.headlineMedium),
                ),
              ],
            ),
            if (child != null) ...[
              SizedBox(height: 12.h),
              child!,
            ],
          ],
        ),
      ),
    );
  }
}

// ── Premium badge ─────────────────────────────────────────────────────────────

class _PremiumBadge extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
      decoration: BoxDecoration(
        color: context.colors.primaryContainer,
        borderRadius: BorderRadius.circular(20.r),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.star, size: 12.r, color: context.colors.primary),
          SizedBox(width: 4.w),
          Text(
            'مميز',
            style: context.textTheme.labelMedium?.copyWith(
              color: context.colors.primary,
              fontSize: 11.sp,
            ),
          ),
        ],
      ),
    );
  }
}