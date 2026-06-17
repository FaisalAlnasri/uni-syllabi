import 'package:aa_template/features/auth/presentation/cubit/auth_cubit.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/utils/extensions/context_extensions.dart';

class ThemePage extends StatelessWidget {
  const ThemePage({super.key});

  @override
  Widget build(BuildContext context) {
    final currentUser = context.read<AuthCubit>().currentUser;

    return Scaffold(
      appBar: AppBar(
        title: Text('مرحباً ${currentUser?.displayName ?? 'بك'}!'),
        leading: BackButton(onPressed: () => context.pop()),
      ),
      body: ListView(
        padding: context.pagePadding.copyWith(top: 24.h, bottom: 40.h),
        children: [
          _SectionLabel('الألوان'),
          _ColorRow(),
          SizedBox(height: 28.h),

          _SectionLabel('الخطوط'),
          _TypographyShowcase(),
          SizedBox(height: 28.h),

          _SectionLabel('الأزرار'),
          _ButtonShowcase(),
          SizedBox(height: 28.h),

          _SectionLabel('البطاقات'),
          _CardShowcase(),
          SizedBox(height: 28.h),

          _SectionLabel('حقل الإدخال'),
          _InputShowcase(),
          SizedBox(height: 28.h),

          _SectionLabel('الإشعار السريع'),
          _SnackbarShowcase(),
        ],
      ),
    );
  }
}

// ── Section label ────────────────────────────────────────────────────────────

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
          letterSpacing: 0.5,
        ),
      ),
    );
  }
}

// ── Colors ───────────────────────────────────────────────────────────────────

class _ColorRow extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final swatches = [
      (colors.primary, 'primary'),
      (colors.secondary, 'secondary'),
      (colors.tertiary, 'tertiary'),
      (colors.error, 'error'),
      (colors.surfaceContainerLow, 'surface'),
    ];

    return Row(
      children: swatches
          .map(
            (s) => Expanded(
              child: Column(
                children: [
                  Container(
                    height: 44.h,
                    decoration: BoxDecoration(
                      color: s.$1,
                      borderRadius: BorderRadius.circular(8.r),
                    ),
                  ),
                  SizedBox(height: 4.h),
                  Text(
                    s.$2,
                    style: context.textTheme.labelMedium
                        ?.copyWith(fontSize: 9, color: colors.outline),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          )
          .toList(),
    );
  }
}

// ── Typography ───────────────────────────────────────────────────────────────

class _TypographyShowcase extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final t = context.textTheme;
    final styles = [
      (t.displayMedium, 'displayMedium'),
      (t.headlineLarge, 'headlineLarge'),
      (t.headlineMedium, 'headlineMedium'),
      (t.bodyLarge, 'bodyLarge'),
      (t.bodyMedium, 'bodyMedium'),
      (t.labelLarge, 'labelLarge'),
      (t.labelMedium, 'labelMedium'),
    ];

    return Card(
      child: Padding(
        padding: EdgeInsets.all(16.r),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: styles
              .map(
                (s) => Padding(
                  padding: EdgeInsets.only(bottom: 8.h),
                  child: Row(
                    children: [
                      Expanded(
                        child: Text('نص تجريبي', style: s.$1),
                      ),
                      Text(
                        s.$2,
                        style: context.textTheme.labelMedium
                            ?.copyWith(color: context.colors.outline, fontSize: 9),
                      ),
                    ],
                  ),
                ),
              )
              .toList(),
        ),
      ),
    );
  }
}

// ── Buttons ──────────────────────────────────────────────────────────────────

class _ButtonShowcase extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        FilledButton(onPressed: () {}, child: const Text('زر أساسي')),
        SizedBox(height: 10.h),
        OutlinedButton(onPressed: () {}, child: const Text('زر ثانوي')),
        SizedBox(height: 10.h),
        TextButton(onPressed: () {}, child: const Text('زر نصي')),
        SizedBox(height: 10.h),
        FilledButton(onPressed: null, child: const Text('معطّل')),
      ],
    );
  }
}

// ── Cards ────────────────────────────────────────────────────────────────────

class _CardShowcase extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Card(
          child: Padding(
            padding: EdgeInsets.all(16.r),
            child: Row(
              children: [
                Icon(Icons.auto_awesome, color: context.colors.primary),
                SizedBox(width: 12.w),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('عنوان البطاقة', style: context.textTheme.headlineMedium),
                      SizedBox(height: 4.h),
                      Text(
                        'هذا نص توضيحي داخل البطاقة لمعاينة التصميم',
                        style: context.textTheme.bodyMedium
                            ?.copyWith(color: context.colors.outline),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
        SizedBox(height: 10.h),
        Card(
          color: context.colors.primaryContainer,
          child: Padding(
            padding: EdgeInsets.all(16.r),
            child: Row(
              children: [
                Icon(Icons.star, color: context.colors.onPrimaryContainer),
                SizedBox(width: 12.w),
                Text(
                  'بطاقة بلون مميز',
                  style: context.textTheme.bodyLarge?.copyWith(
                    color: context.colors.onPrimaryContainer,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

// ── Input ─────────────────────────────────────────────────────────────────────

class _InputShowcase extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        TextField(
          decoration: const InputDecoration(
            hintText: 'اكتب هنا...',
            prefixIcon: Icon(Icons.search),
          ),
        ),
        SizedBox(height: 10.h),
        TextField(
          decoration: InputDecoration(
            hintText: 'حقل بخطأ',
            errorText: 'هذا الحقل مطلوب',
            prefixIcon: const Icon(Icons.lock_outline),
          ),
          obscureText: true,
        ),
      ],
    );
  }
}

// ── Snackbar ─────────────────────────────────────────────────────────────────

class _SnackbarShowcase extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: FilledButton.tonal(
            onPressed: () => ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('هذا إشعار عادي')),
            ),
            child: const Text('عادي'),
          ),
        ),
        SizedBox(width: 10.w),
        Expanded(
          child: FilledButton.tonal(
            style: FilledButton.styleFrom(
              backgroundColor: context.colors.errorContainer,
              foregroundColor: context.colors.onErrorContainer,
            ),
            onPressed: () => ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: const Text('حدث خطأ ما'),
                backgroundColor: context.colors.error,
              ),
            ),
            child: const Text('خطأ'),
          ),
        ),
      ],
    );
  }
}