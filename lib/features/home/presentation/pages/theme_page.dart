import 'package:unicalendar/features/auth/presentation/cubit/auth_cubit.dart';
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
        title: Text('Ù…Ø±Ø­Ø¨Ø§Ù‹ ${currentUser?.displayName ?? 'Ø¨Ùƒ'}!'),
        leading: BackButton(onPressed: () => context.pop()),
      ),
      body: ListView(
        padding: context.pagePadding.copyWith(top: 24.h, bottom: 40.h),
        children: [
          _SectionLabel('Ø§Ù„Ø£Ù„ÙˆØ§Ù†'),
          _ColorRow(),
          SizedBox(height: 28.h),

          _SectionLabel('Ø§Ù„Ø®Ø·ÙˆØ·'),
          _TypographyShowcase(),
          SizedBox(height: 28.h),

          _SectionLabel('Ø§Ù„Ø£Ø²Ø±Ø§Ø±'),
          _ButtonShowcase(),
          SizedBox(height: 28.h),

          _SectionLabel('Ø§Ù„Ø¨Ø·Ø§Ù‚Ø§Øª'),
          _CardShowcase(),
          SizedBox(height: 28.h),

          _SectionLabel('Ø­Ù‚Ù„ Ø§Ù„Ø¥Ø¯Ø®Ø§Ù„'),
          _InputShowcase(),
          SizedBox(height: 28.h),

          _SectionLabel('Ø§Ù„Ø¥Ø´Ø¹Ø§Ø± Ø§Ù„Ø³Ø±ÙŠØ¹'),
          _SnackbarShowcase(),
        ],
      ),
    );
  }
}

// â”€â”€ Section label â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€

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

// â”€â”€ Colors â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€

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

// â”€â”€ Typography â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€

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
                        child: Text('Ù†Øµ ØªØ¬Ø±ÙŠØ¨ÙŠ', style: s.$1),
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

// â”€â”€ Buttons â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€

class _ButtonShowcase extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        FilledButton(onPressed: () {}, child: const Text('Ø²Ø± Ø£Ø³Ø§Ø³ÙŠ')),
        SizedBox(height: 10.h),
        OutlinedButton(onPressed: () {}, child: const Text('Ø²Ø± Ø«Ø§Ù†ÙˆÙŠ')),
        SizedBox(height: 10.h),
        TextButton(onPressed: () {}, child: const Text('Ø²Ø± Ù†ØµÙŠ')),
        SizedBox(height: 10.h),
        FilledButton(onPressed: null, child: const Text('Ù…Ø¹Ø·Ù‘Ù„')),
      ],
    );
  }
}

// â”€â”€ Cards â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€

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
                      Text('Ø¹Ù†ÙˆØ§Ù† Ø§Ù„Ø¨Ø·Ø§Ù‚Ø©', style: context.textTheme.headlineMedium),
                      SizedBox(height: 4.h),
                      Text(
                        'Ù‡Ø°Ø§ Ù†Øµ ØªÙˆØ¶ÙŠØ­ÙŠ Ø¯Ø§Ø®Ù„ Ø§Ù„Ø¨Ø·Ø§Ù‚Ø© Ù„Ù…Ø¹Ø§ÙŠÙ†Ø© Ø§Ù„ØªØµÙ…ÙŠÙ…',
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
                  'Ø¨Ø·Ø§Ù‚Ø© Ø¨Ù„ÙˆÙ† Ù…Ù…ÙŠØ²',
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

// â”€â”€ Input â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€

class _InputShowcase extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        TextField(
          decoration: const InputDecoration(
            hintText: 'Ø§ÙƒØªØ¨ Ù‡Ù†Ø§...',
            prefixIcon: Icon(Icons.search),
          ),
        ),
        SizedBox(height: 10.h),
        TextField(
          decoration: InputDecoration(
            hintText: 'Ø­Ù‚Ù„ Ø¨Ø®Ø·Ø£',
            errorText: 'Ù‡Ø°Ø§ Ø§Ù„Ø­Ù‚Ù„ Ù…Ø·Ù„ÙˆØ¨',
            prefixIcon: const Icon(Icons.lock_outline),
          ),
          obscureText: true,
        ),
      ],
    );
  }
}

// â”€â”€ Snackbar â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€

class _SnackbarShowcase extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: FilledButton.tonal(
            onPressed: () => ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Ù‡Ø°Ø§ Ø¥Ø´Ø¹Ø§Ø± Ø¹Ø§Ø¯ÙŠ')),
            ),
            child: const Text('Ø¹Ø§Ø¯ÙŠ'),
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
                content: const Text('Ø­Ø¯Ø« Ø®Ø·Ø£ Ù…Ø§'),
                backgroundColor: context.colors.error,
              ),
            ),
            child: const Text('Ø®Ø·Ø£'),
          ),
        ),
      ],
    );
  }
}