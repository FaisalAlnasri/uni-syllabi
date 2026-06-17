import 'package:equatable/equatable.dart';

import 'app_user.dart';

sealed class AuthState extends Equatable {
  const AuthState();

  @override
  List<Object?> get props => [];
}

/// Initial state — we haven't heard from the auth backend yet.
final class AuthUnknown extends AuthState {
  const AuthUnknown();
}

/// A signed-in user.
final class AuthAuthenticated extends AuthState {
  final AppUser user;
  const AuthAuthenticated(this.user);

  @override
  List<Object?> get props => [user];
}

/// No user, and the app requires auth.
final class AuthUnauthenticated extends AuthState {
  const AuthUnauthenticated();
}

/// No user, but the app allows anonymous/guest usage.
final class AuthGuest extends AuthState {
  const AuthGuest();
}
