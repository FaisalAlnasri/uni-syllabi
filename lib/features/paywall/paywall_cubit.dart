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

  /// The offering + current selection, available whenever the paywall is shown
  /// (ready, after a transient action error, etc.). Null while loading/failed.
  ({PaywallOffering offering, Package selected})? get _current {
    final s = state;
    return switch (s) {
      PaywallReady() => (offering: s.offering, selected: s.selected),
      PaywallActionError() => (offering: s.offering, selected: s.selected),
      _ => null,
    };
  }

  // ── Offering ───────────────────────────────────────────────────────────────

  Future<void> loadOffering() async {
    emit(const PaywallLoading());
    final result = await _repository.fetchOffering();
    result.when(
      onSuccess: (offering) {
        final selected = offering.defaultPackage;
        if (selected == null) {
          emit(const PaywallError('لا توجد عروض متاحة'));
          return;
        }
        emit(PaywallReady(offering, selected));
      },
      onFailure: (error) => emit(PaywallError(error.message)),
    );
  }

  // ── Selection ──────────────────────────────────────────────────────────────

  void selectPackage(Package package) {
    final current = _current;
    if (current != null) {
      emit(PaywallReady(current.offering, package));
    }
  }

  // ── Purchase ───────────────────────────────────────────────────────────────

  Future<void> purchase() async {
    final current = _current;
    if (current == null) return;

    emit(PaywallPurchasing(current.offering, current.selected));
    final result = await _repository.purchase(current.selected);
    result.when(
      onSuccess: (_) => emit(const PaywallSuccess()),
      onFailure: (error) => emit(
        PaywallActionError(current.offering, current.selected, error.message),
      ),
    );
  }

  // ── Restore ────────────────────────────────────────────────────────────────

  Future<void> restorePurchases() async {
    final current = _current;
    if (current != null) {
      emit(PaywallPurchasing(current.offering, current.selected));
    } else {
      emit(const PaywallLoading());
    }

    final result = await _repository.restorePurchases();
    result.when(
      onSuccess: (subscription) {
        if (subscription.isActive) {
          emit(const PaywallSuccess());
        } else if (current != null) {
          emit(PaywallActionError(
            current.offering,
            current.selected,
            'لم يتم العثور على مشتريات سابقة',
          ));
        } else {
          emit(const PaywallError('لم يتم العثور على مشتريات سابقة'));
        }
      },
      onFailure: (error) {
        if (current != null) {
          emit(PaywallActionError(
            current.offering,
            current.selected,
            error.message,
          ));
        } else {
          emit(PaywallError(error.message));
        }
      },
    );
  }
}
