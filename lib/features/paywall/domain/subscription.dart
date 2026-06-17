import 'package:equatable/equatable.dart';
import 'package:purchases_flutter/purchases_flutter.dart' show Package;

import '../../../core/error/app_error.dart';
import '../../../core/error/result.dart';

// ── Entity ───────────────────────────────────────────────────────────────────

/// App-level subscription status. Backend-agnostic — no RevenueCat imports.
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

// ── Repository interface ─────────────────────────────────────────────────────

/// [Package] is a value type from the store SDK; exposing it here avoids a
/// pointless wrapper layer.
abstract interface class PurchasesRepository {
  Future<void> init(String? userId);
  bool get isSubscriber;
  Future<Result<Package, AppError>> fetchOffering();
  Future<Result<Subscription, AppError>> purchase(Package package);
  Future<Result<Subscription, AppError>> restorePurchases();
}
