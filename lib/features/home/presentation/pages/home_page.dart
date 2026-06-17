import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../core/utils/extensions/context_extensions.dart';
import '../../../../core/widgets/premium_card.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('الرئيسية'),
      ),
      body: ListView(
        padding: context.pagePadding.copyWith(top: 24.h, bottom: 40.h),
        children: [

          // ── Free content ──────────────────────────────────
          _SectionLabel('محتوى مجاني'),
          Card(
            child: Padding(
              padding: EdgeInsets.all(16.r),
              child: Row(
                children: [
                  Icon(Icons.check_circle_outline,
                      color: context.colors.primary),
                  SizedBox(width: 12.w),
                  Text('هذا محتوى متاح للجميع',
                      style: context.textTheme.bodyLarge),
                ],
              ),
            ),
          ),

          SizedBox(height: 24.h),

          // ── Premium content ───────────────────────────────
          _SectionLabel('محتوى مميز'),
          PremiumCard(
            title: 'تحليلات متقدمة',
            description: 'اشترك للوصول',
            icon: Icons.analytics_outlined,
            // child: shown when subscribed — replace with real content
            child: Text(
              'هنا تظهر التحليلات المتقدمة للمشتركين',
              style: context.textTheme.bodyMedium,
            ),
          ),

          SizedBox(height: 12.h),

          PremiumCard(
            title: 'تقارير أسبوعية',
            description: 'اشترك للوصول',
            icon: Icons.bar_chart_outlined,
            child: Text(
              'هنا تظهر التقارير الأسبوعية للمشتركين',
              style: context.textTheme.bodyMedium,
            ),
          ),

        ],
      ),
    );
  }
}

// ── Section label ─────────────────────────────────────────────────────────────

class _SectionLabel extends StatelessWidget {
  final String label;
  const _SectionLabel(this.label);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(bottom: 12.h),
      child: Text(
        label,
        style: context.textTheme.labelMedium?.copyWith(
          color: context.colors.outline,
        ),
      ),
    );
  }
}