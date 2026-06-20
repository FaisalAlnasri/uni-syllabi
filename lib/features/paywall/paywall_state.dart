import 'package:equatable/equatable.dart';
import 'package:purchases_flutter/purchases_flutter.dart' show Package;

import 'domain/subscription.dart';

sealed class PaywallState extends Equatable {
  const PaywallState();

  @override
  List<Object?> get props => [];
}

final class PaywallInitial extends PaywallState {
  const PaywallInitial();
}

final class PaywallLoading extends PaywallState {
  const PaywallLoading();
}

/// Offering loaded; [selected] is the tier the user is about to buy.
final class PaywallReady extends PaywallState {
  final PaywallOffering offering;
  final Package selected;
  const PaywallReady(this.offering, this.selected);

  @override
  List<Object?> get props => [offering, selected];
}

/// A purchase (or restore) is in flight. Keeps [offering]/[selected] so the
/// paywall stays on screen with its buttons disabled.
final class PaywallPurchasing extends PaywallState {
  final PaywallOffering offering;
  final Package selected;
  const PaywallPurchasing(this.offering, this.selected);

  @override
  List<Object?> get props => [offering, selected];
}

final class PaywallSuccess extends PaywallState {
  const PaywallSuccess();
}

/// Fatal: the offering could not be loaded. The page shows a full-screen retry.
final class PaywallError extends PaywallState {
  final String message;
  const PaywallError(this.message);

  @override
  List<Object?> get props => [message];
}

/// Transient: a purchase/restore failed (e.g. the user cancelled) but we still
/// have a loaded offering. The page surfaces [message] as a snackbar and keeps
/// the paywall visible.
final class PaywallActionError extends PaywallState {
  final PaywallOffering offering;
  final Package selected;
  final String message;
  const PaywallActionError(this.offering, this.selected, this.message);

  @override
  List<Object?> get props => [offering, selected, message];
}
