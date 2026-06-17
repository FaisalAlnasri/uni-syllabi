import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/config/app_config.dart';
import '../../../../core/di/service_locator.dart';
import '../../../../core/utils/extensions/context_extensions.dart';
import '../../paywall_cubit.dart';
import '../../paywall_state.dart';
import '../paywall_strings.dart';
import '../widgets/package_card.dart';

class PaywallPage extends StatelessWidget {
  const PaywallPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => sl<PaywallCubit>(),
      child: const _PaywallView(),
    );
  }
}

class _PaywallView extends StatelessWidget {
  const _PaywallView();

  @override
  Widget build(BuildContext context) {
    final cubit = context.read<PaywallCubit>();

    return Scaffold(
      backgroundColor: context.colors.surface,
      body: SafeArea(
        child: BlocConsumer<PaywallCubit, PaywallState>(
          listener: (context, state) {
            switch (state) {
              case PaywallSuccess():
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text(PaywallStrings.successMessage)),
                );
                context.pop();
              case PaywallError(:final message):
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(message),
                    backgroundColor: context.colors.error,
                  ),
                );
              default:
                break;
            }
          },
          builder: (context, state) {
            // ── Loading / initial ────────────────────────────────
            if (state is PaywallInitial || state is PaywallLoading) {
              return Center(
                child: CircularProgressIndicator(color: context.colors.primary),
              );
            }

            // ── Load failure (no package yet) ────────────────────
            if (state is PaywallError) {
              return Padding(
                padding: context.pagePadding,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      state.message,
                      style: context.textTheme.bodyLarge
                          ?.copyWith(color: context.colors.error),
                      textAlign: TextAlign.center,
                    ),
                    SizedBox(height: 12.h),
                    TextButton(
                      onPressed: cubit.loadOffering,
                      child: const Text('إعادة المحاولة'),
                    ),
                  ],
                ),
              );
            }

            // ── Ready / purchasing ───────────────────────────────
            final package = switch (state) {
              PaywallReady(:final package) => package,
              PaywallPurchasing(:final package) => package,
              _ => null,
            };
            final isPurchasing = state is PaywallPurchasing;

            return Padding(
              padding: context.pagePadding,
              child: Column(
                children: [
                  Align(
                    alignment: Alignment.topRight,
                    child: IconButton(
                      icon: const Icon(Icons.close),
                      onPressed: () => context.pop(),
                    ),
                  ),
                  const Spacer(),
                  _AppIcon(),
                  SizedBox(height: 16.h),
                  Text(
                    PaywallStrings.title,
                    style: context.textTheme.headlineLarge,
                    textAlign: TextAlign.center,
                  ),
                  SizedBox(height: 8.h),
                  Text(
                    PaywallStrings.subtitle,
                    style: context.textTheme.bodyMedium
                        ?.copyWith(color: context.colors.outline),
                    textAlign: TextAlign.center,
                  ),
                  SizedBox(height: 24.h),
                  const _BenefitRow(PaywallStrings.benefit1),
                  const _BenefitRow(PaywallStrings.benefit2),
                  const _BenefitRow(PaywallStrings.benefit3),
                  const Spacer(),
                  if (package != null) PackageCard(package: package),
                  SizedBox(height: 12.h),
                  SizedBox(
                    width: double.infinity,
                    child: FilledButton(
                      onPressed: (package == null || isPurchasing)
                          ? null
                          : () => cubit.purchase(package),
                      child: isPurchasing
                          ? SizedBox(
                              width: 22.r,
                              height: 22.r,
                              child: CircularProgressIndicator(
                                strokeWidth: 2.5,
                                color: context.colors.onPrimary,
                              ),
                            )
                          : const Text(PaywallStrings.purchaseButton),
                    ),
                  ),
                  SizedBox(height: 8.h),
                  TextButton(
                    onPressed: isPurchasing ? null : cubit.restorePurchases,
                    child: const Text(PaywallStrings.restoreButton),
                  ),
                  SizedBox(height: 8.h),
                  Text(
                    PaywallStrings.termsNote,
                    style: context.textTheme.labelMedium
                        ?.copyWith(color: context.colors.outline),
                    textAlign: TextAlign.center,
                  ),
                  SizedBox(height: 24.h),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}

// ── Benefit row ──────────────────────────────────────────────────────────────

class _BenefitRow extends StatelessWidget {
  final String label;
  const _BenefitRow(this.label);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 6.h),
      child: Row(
        children: [
          Icon(Icons.check_circle_outline, color: context.colors.primary),
          SizedBox(width: 8.w),
          Expanded(
            child: Text(label, style: context.textTheme.bodyLarge),
          ),
        ],
      ),
    );
  }
}

// ── App icon placeholder ─────────────────────────────────────────────────────

class _AppIcon extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final name = AppConfig.instance.appName.trim();
    final initial = name.isNotEmpty ? name.characters.first : '?';

    return Container(
      width: 96.r,
      height: 96.r,
      decoration: BoxDecoration(
        color: context.colors.primary,
        shape: BoxShape.circle,
      ),
      alignment: Alignment.center,
      child: Text(
        initial,
        style: context.textTheme.displayLarge
            ?.copyWith(color: context.colors.onPrimary),
      ),
    );
  }
}
