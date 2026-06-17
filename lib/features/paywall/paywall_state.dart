import 'package:equatable/equatable.dart';
import 'package:purchases_flutter/purchases_flutter.dart' show Package;

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

final class PaywallReady extends PaywallState {
  final Package package;
  const PaywallReady(this.package);

  @override
  List<Object?> get props => [package];
}

final class PaywallPurchasing extends PaywallState {
  final Package package;
  const PaywallPurchasing(this.package);

  @override
  List<Object?> get props => [package];
}

final class PaywallSuccess extends PaywallState {
  const PaywallSuccess();
}

final class PaywallError extends PaywallState {
  final String message;
  const PaywallError(this.message);

  @override
  List<Object?> get props => [message];
}
