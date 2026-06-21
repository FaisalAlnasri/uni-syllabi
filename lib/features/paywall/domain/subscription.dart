import 'package:equatable/equatable.dart';
import 'package:purchases_flutter/purchases_flutter.dart' show Package;

import '../../../core/error/app_error.dart';
import '../../../core/error/result.dart';

// ── Entity ───────────────────────────────────────────────────────────────────

/// App-level subscription status. Backend-agnostic، no RevenueCat imports.
class Subscription extends Equatable {
  final bool isActive;
  final String? productId;
  final DateTime? expiryDate;

  const Subscription({
    required this.isActive,
    this.productId,
    this.expiryDate,
  });

  @override
  List<Object?> get props => [isActive, productId, expiryDate];
}

// ── Offering ─────────────────────────────────────────────────────────────────

/// The two purchasable tiers shown on the paywall. There is no monthly tier and
/// no free tier — the paywall is a hard gate.
class PaywallOffering extends Equatable {
  /// `PackageType.annual` — positioned as "most popular".
  final Package? annual;

  /// `PackageType.lifetime` — positioned as "save 60%".
  final Package? lifetime;

  const PaywallOffering({this.annual, this.lifetime});

  bool get isEmpty => annual == null && lifetime == null;

  /// What to pre-select: the "most popular" annual tier when available,
  /// otherwise the lifetime tier.
  Package? get defaultPackage => annual ?? lifetime;

  @override
  List<Object?> get props => [annual, lifetime];
}

// ── Repository interface ─────────────────────────────────────────────────────

/// [Package] is a value type from the store SDK; exposing it here avoids a
/// pointless wrapper layer.
abstract interface class PurchasesRepository {
  Future<void> init(String? userId);
  bool get isSubscriber;
  Future<Result<PaywallOffering, AppError>> fetchOffering();
  Future<Result<Subscription, AppError>> purchase(Package package);
  Future<Result<Subscription, AppError>> restorePurchases();

  /// Opens the OS-level subscription manager (App Store / Play Store) so the
  /// user can change or cancel their subscription.
  Future<Result<void, AppError>> manageSubscriptions();
}
