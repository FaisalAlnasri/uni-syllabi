import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/config/app_config.dart';
import '../../../../core/error/result.dart';
import '../../domain/entities/app_user.dart';
import '../../domain/services/auth_service.dart';
import '../../domain/entities/auth_state.dart';

class AuthCubit extends Cubit<AuthState> {
  final AuthService _authService;

  /// Called with a localized message whenever a sign-in/out action fails.
  /// Mutable so the active page (e.g. login) can capture errors inline.
  void Function(String message)? onAuthError;

  StreamSubscription<AppUser?>? _subscription;

  AuthCubit(this._authService, {this.onAuthError}) : super(const AuthUnknown()) {
    _subscription = _authService.authStateChanges.listen(_onAuthChanged);
  }

  // ── Stream handling ──────────────────────────────────────────────────────────

  void _onAuthChanged(AppUser? user) {
    if (user != null) {
      emit(AuthAuthenticated(user));
    } else {
      emit(
        AppConfig.instance.requiresAuth
            ? const AuthUnauthenticated()
            : const AuthGuest(),
      );
    }
  }

  // ── Derived getters ──────────────────────────────────────────────────────────

  bool get isGuest => state is AuthGuest;

  AppUser? get currentUser =>
      state is AuthAuthenticated ? (state as AuthAuthenticated).user : null;

  // ── Actions ──────────────────────────────────────────────────────────────────

  Future<void> signInWithGoogle() async {
    final result = await _authService.signInWithGoogle();
    result.when(
      onSuccess: (_) {}, // authStateChanges drives the state transition
      onFailure: (error) => onAuthError?.call(error.message),
    );
  }

  Future<void> signInWithApple() async {
    final result = await _authService.signInWithApple();
    result.when(
      onSuccess: (_) {},
      onFailure: (error) => onAuthError?.call(error.message),
    );
  }

  Future<void> signOut() async {
    final result = await _authService.signOut();
    result.when(
      onSuccess: (_) {},
      onFailure: (error) => onAuthError?.call(error.message),
    );
  }

  @override
  Future<void> close() {
    _subscription?.cancel();
    return super.close();
  }
}
