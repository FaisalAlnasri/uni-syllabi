import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:purchases_flutter/purchases_flutter.dart' show Package;

import '../../core/error/result.dart';
import 'domain/subscription.dart';
import 'paywall_state.dart';

class PaywallCubit extends Cubit<PaywallState> {
  final PurchasesRepository _repository;

  PaywallCubit(this._repository) : super(const PaywallInitial()) {
    loadOffering();
  }

  // ── Offering ───────────────────────────────────────────────────────────────

  Future<void> loadOffering() async {
    emit(const PaywallLoading());
    final result = await _repository.fetchOffering();
    result.when(
      onSuccess: (package) => emit(PaywallReady(package)),
      onFailure: (error) => emit(PaywallError(error.message)),
    );
  }

  // ── Purchase ───────────────────────────────────────────────────────────────

  Future<void> purchase(Package package) async {
    emit(PaywallPurchasing(package));
    final result = await _repository.purchase(package);
    result.when(
      onSuccess: (_) => emit(const PaywallSuccess()),
      onFailure: (error) => emit(PaywallError(error.message)),
    );
  }

  // ── Restore ────────────────────────────────────────────────────────────────

  Future<void> restorePurchases() async {
    emit(const PaywallLoading());
    final result = await _repository.restorePurchases();
    result.when(
      onSuccess: (_) => emit(const PaywallSuccess()),
      onFailure: (error) => emit(PaywallError(error.message)),
    );
  }
}
