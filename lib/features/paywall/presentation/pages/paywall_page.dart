import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:purchases_flutter/purchases_flutter.dart' show Package;
import 'package:url_launcher/url_launcher.dart';

import '../../../../core/config/app_config.dart';
import '../../../../core/di/service_locator.dart';
import '../../../../core/utils/extensions/context_extensions.dart';
import '../../domain/subscription.dart';
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
              case PaywallActionError(:final message):
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

            // ── Fatal load failure (no offering) ─────────────────
            if (state is PaywallError) {
              return _LoadError(message: state.message, onRetry: cubit.loadOffering);
            }

            // ── Ready / purchasing / transient error ─────────────
            final (offering, selected, isBusy) = switch (state) {
              PaywallReady(:final offering, :final selected) =>
                (offering, selected, false),
              PaywallPurchasing(:final offering, :final selected) =>
                (offering, selected, true),
              PaywallActionError(:final offering, :final selected) =>
                (offering, selected, false),
              _ => (null, null, false),
            };
            if (offering == null || selected == null) {
              return const SizedBox.shrink();
            }

            return _PaywallContent(
              offering: offering,
              selected: selected,
              isBusy: isBusy,
              onSelect: cubit.selectPackage,
              onPurchase: cubit.purchase,
              onRestore: cubit.restorePurchases,
            );
          },
        ),
      ),
    );
  }
}

// ── Content ──────────────────────────────────────────────────────────────────

class _PaywallContent extends StatelessWidget {
  final PaywallOffering offering;
  final Package selected;
  final bool isBusy;
  final ValueChanged<Package> onSelect;
  final VoidCallback onPurchase;
  final VoidCallback onRestore;

  const _PaywallContent({
    required this.offering,
    required this.selected,
    required this.isBusy,
    required this.onSelect,
    required this.onPurchase,
    required this.onRestore,
  });

  bool get _lifetimeSelected =>
      offering.lifetime != null && identical(selected, offering.lifetime);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: context.pagePadding,
      child: Column(
        children: [
          Align(
            alignment: Alignment.topRight,
            child: IconButton(
              icon: Icon(Icons.close, color: context.colors.onSurface),
              onPressed: () => context.pop(),
            ),
          ),
          const Spacer(),
          _AppIcon(),
          SizedBox(height: 12.h),
          Text(
            PaywallStrings.title,
            style: context.textTheme.headlineSmall,
            textAlign: TextAlign.center,
          ),
          SizedBox(height: 6.h),
          Text(
            PaywallStrings.subtitle,
            style: context.textTheme.bodySmall
                ?.copyWith(color: context.colors.outline),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: 20.h),
          const _BenefitRow(PaywallStrings.benefitParser),
          const _BenefitRow(PaywallStrings.benefitCalendar),
          const _BenefitRow(PaywallStrings.benefitUnlimited),
          const Spacer(),

          // ── Tiers ──────────────────────────────────────────
          if (offering.annual case final annual?) ...[
            PackageCard(
              package: annual,
              tierTitle: PaywallStrings.annualTitle,
              badge: PaywallStrings.annualBadge,
              period: PaywallStrings.annualPeriod,
              isSelected: identical(selected, annual),
              onTap: isBusy ? () {} : () => onSelect(annual),
            ),
            SizedBox(height: 12.h),
          ],
          if (offering.lifetime case final lifetime?) ...[
            PackageCard(
              package: lifetime,
              tierTitle: PaywallStrings.lifetimeTitle,
              badge: PaywallStrings.lifetimeBadge,
              footnote: PaywallStrings.lifetimeNote,
              isSelected: identical(selected, lifetime),
              onTap: isBusy ? () {} : () => onSelect(lifetime),
            ),
            SizedBox(height: 16.h),
          ],

          // ── CTA ────────────────────────────────────────────
          SizedBox(
            width: double.infinity,
            child: FilledButton(
              onPressed: isBusy ? null : onPurchase,
              child: isBusy
                  ? SizedBox(
                      width: 22.r,
                      height: 22.r,
                      child: CircularProgressIndicator(
                        strokeWidth: 2.5,
                        color: context.colors.onPrimary,
                      ),
                    )
                  : Text(
                      _lifetimeSelected
                          ? PaywallStrings.buyButton
                          : PaywallStrings.subscribeButton,
                    ),
            ),
          ),
          SizedBox(height: 8.h),
          TextButton(
            onPressed: isBusy ? null : onRestore,
            child: const Text(PaywallStrings.restoreButton),
          ),
          SizedBox(height: 4.h),
          Text(
            PaywallStrings.termsNote,
            style: context.textTheme.labelMedium
                ?.copyWith(color: context.colors.outline, fontSize: 10.sp),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: 8.h),
          const _LegalLinks(),
          SizedBox(height: 24.h),
        ],
      ),
    );
  }
}

// ── Load error ───────────────────────────────────────────────────────────────

class _LoadError extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;

  const _LoadError({required this.message, required this.onRetry});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: context.pagePadding,
      child: Column(
        children: [
          Align(
            alignment: Alignment.topRight,
            child: IconButton(
              icon: Icon(Icons.close, color: context.colors.onSurface),
              onPressed: () => context.pop(),
            ),
          ),
          Expanded(
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    message,
                    style: context.textTheme.bodyLarge
                        ?.copyWith(color: context.colors.error),
                    textAlign: TextAlign.center,
                  ),
                  SizedBox(height: 12.h),
                  TextButton(
                    onPressed: onRetry,
                    child: const Text(PaywallStrings.retryButton),
                  ),
                ],
              ),
            ),
          ),
        ],
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
      padding: EdgeInsets.symmetric(vertical: 4.h),
      child: Row(
        children: [
          Icon(
            Icons.check_circle_outline,
            size: 20.r,
            color: context.colors.primary,
          ),
          SizedBox(width: 8.w),
          Expanded(
            child: Text(label, style: context.textTheme.bodyMedium),
          ),
        ],
      ),
    );
  }
}

// ── Legal links ──────────────────────────────────────────────────────────────

class _LegalLinks extends StatelessWidget {
  const _LegalLinks();

  Future<void> _open(String url) async {
    final uri = Uri.parse(url);
    await launchUrl(uri, mode: LaunchMode.externalApplication);
  }

  @override
  Widget build(BuildContext context) {
    final style = context.textTheme.labelMedium?.copyWith(
      color: context.colors.outline,
      decoration: TextDecoration.underline,
      decorationColor: context.colors.outline,
    );

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        _LegalLink(
          label: PaywallStrings.privacyPolicyLabel,
          style: style,
          onTap: () => _open(PaywallStrings.privacyPolicyUrl),
        ),
        Text(
          ' • ',
          style: context.textTheme.labelMedium
              ?.copyWith(color: context.colors.outline),
        ),
        _LegalLink(
          label: PaywallStrings.termsOfUseLabel,
          style: style,
          onTap: () => _open(PaywallStrings.termsOfUseUrl),
        ),
      ],
    );
  }
}

class _LegalLink extends StatelessWidget {
  final String label;
  final TextStyle? style;
  final VoidCallback onTap;

  const _LegalLink({
    required this.label,
    required this.style,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Text(label, style: style),
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
      width: 72.r,
      height: 72.r,
      decoration: BoxDecoration(
        color: context.colors.primary,
        shape: BoxShape.circle,
      ),
      alignment: Alignment.center,
      child: Text(
        initial,
        style: context.textTheme.displaySmall
            ?.copyWith(color: context.colors.onPrimary),
      ),
    );
  }
}
