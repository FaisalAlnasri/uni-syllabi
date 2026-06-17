import 'package:flutter/services.dart' show PlatformException;
import 'package:purchases_flutter/purchases_flutter.dart';

import '../../../core/config/app_config.dart';
import '../../../core/error/app_error.dart';
import '../../../core/error/result.dart';
import '../../../core/logging/app_logger.dart';
import '../domain/subscription.dart';

/// The only file in this feature that imports `purchases_flutter`.
class RevenueCatRepository implements PurchasesRepository {
  bool _isSubscriber = false;

  @override
  bool get isSubscriber => _isSubscriber;

  // ── Init ───────────────────────────────────────────────────────────────────

  @override
  Future<void> init(String? userId) async {
    try {
      await Purchases.configure(
        PurchasesConfiguration(AppConfig.instance.revenueCatApiKey),
      );
      if (userId != null) {
        await Purchases.logIn(userId);
      }
      await _refreshSubscriberStatus();
      AppLogger.info('RevenueCat configured (subscriber: $_isSubscriber)');
    } catch (e, st) {
      AppLogger.warning('RevenueCat init failed', e, st);
    }
  }

  // ── Offering ───────────────────────────────────────────────────────────────

  @override
  Future<Result<Package, AppError>> fetchOffering() async {
    try {
      final offerings = await Purchases.getOfferings();
      final package = offerings.current?.availablePackages.firstOrNull;
      if (package == null) {
        return const Failure(UnknownError(message: 'لا توجد عروض متاحة'));
      }
      return Success(package);
    } catch (e, st) {
      AppLogger.warning('fetchOffering failed', e, st);
      return Failure(UnknownError(message: 'تعذّر تحميل العروض', originalException: e));
    }
  }

  // ── Purchase ───────────────────────────────────────────────────────────────

  @override
  Future<Result<Subscription, AppError>> purchase(Package package) async {
    try {
      final info = await Purchases.purchasePackage(package);
      await _refreshSubscriberStatus();
      return Success(_mapCustomerInfo(info));
    } on PlatformException catch (e, st) {
      final code = PurchasesErrorHelper.getErrorCode(e);
      if (code == PurchasesErrorCode.purchaseCancelledError) {
        return const Failure(UnknownError(message: 'تم إلغاء عملية الشراء'));
      }
      AppLogger.warning('purchase failed', e, st);
      return Failure(UnknownError(message: 'تعذّر إتمام عملية الشراء', originalException: e));
    } catch (e, st) {
      AppLogger.warning('purchase failed', e, st);
      return Failure(UnknownError(message: 'تعذّر إتمام عملية الشراء', originalException: e));
    }
  }

  // ── Restore ────────────────────────────────────────────────────────────────

  @override
  Future<Result<Subscription, AppError>> restorePurchases() async {
    try {
      final info = await Purchases.restorePurchases();
      await _refreshSubscriberStatus();
      return Success(_mapCustomerInfo(info));
    } catch (e, st) {
      AppLogger.warning('restorePurchases failed', e, st);
      return Failure(UnknownError(message: 'تعذّر استعادة المشتريات', originalException: e));
    }
  }

  // ── Internals ──────────────────────────────────────────────────────────────

  Future<void> _refreshSubscriberStatus() async {
    final info = await Purchases.getCustomerInfo();
    _isSubscriber = info.entitlements.active
        .containsKey(AppConfig.instance.revenueCatEntitlementId);
  }

  Subscription _mapCustomerInfo(CustomerInfo info) {
    final entitlement =
        info.entitlements.active[AppConfig.instance.revenueCatEntitlementId];
    final expiry = entitlement?.expirationDate;
    return Subscription(
      isActive: entitlement != null,
      productId: entitlement?.productIdentifier,
      expiryDate: expiry != null ? DateTime.tryParse(expiry) : null,
    );
  }
}
