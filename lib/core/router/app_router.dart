import 'dart:async';

import 'package:unicalendar/features/auth/domain/entities/auth_state.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../config/app_config.dart';
import '../di/service_locator.dart';
import '../storage/onboarding_storage.dart';
import '../widgets/scaffold_with_bottom_nav.dart';
import '../../features/auth/presentation/cubit/auth_cubit.dart';
import '../../features/auth/presentation/pages/login_page.dart';
import '../../features/auth/presentation/pages/splash_page.dart';
import '../../features/home/presentation/pages/home_page.dart';
import '../../features/home/presentation/pages/theme_page.dart';
import '../../features/onboarding/presentation/pages/onboarding_page.dart';
import '../../features/home/presentation/pages/profile_page.dart';
import '../../features/paywall/presentation/pages/paywall_page.dart';
import 'app_routes.dart';

final GoRouter appRouter = GoRouter(
  initialLocation: AppRoutes.splash,
  debugLogDiagnostics: AppConfig.instance.isDev,
  refreshListenable: GoRouterRefreshStream(sl<AuthCubit>().stream),

  routes: [

    // â”€â”€ Unauthenticated routes â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
    GoRoute(
      path: AppRoutes.splash,
      builder: (context, state) => const SplashPage(),
    ),
    GoRoute(
      path: AppRoutes.login,
      builder: (context, state) => const LoginPage(),
    ),
    GoRoute(
      path: AppRoutes.onboarding,
      builder: (context, state) => const OnboardingPage(),
    ),

    // â”€â”€ Shell (bottom nav) â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
    ShellRoute(
      builder: (context, state, child) =>
          ScaffoldWithBottomNav(child: child),
      routes: [
        GoRoute(
          path: AppRoutes.home,
          builder: (context, state) => const HomePage(),
        ),
        GoRoute(
          path: AppRoutes.profile,
          builder: (context, state) => const ProfilePage(),
        ),
      ],
    ),

    // â”€â”€ Push routes (no bottom nav) â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
    GoRoute(
      path: AppRoutes.themePage,
      builder: (context, state) => const ThemePage(),
    ),

    // â”€â”€ Paywall (Phase 3) â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
    GoRoute(
      path: AppRoutes.paywall,
      builder: (context, state) => const PaywallPage(),
    ),
  ],

  // â”€â”€ Auth redirect guard â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
  redirect: (context, state) {
    final authState = sl<AuthCubit>().state;
    final location = state.matchedLocation;

    if (authState is AuthUnknown) return AppRoutes.splash;

    if (authState is AuthUnauthenticated) return AppRoutes.login;

    if (authState is AuthAuthenticated || authState is AuthGuest) {
      if (location == AppRoutes.splash || location == AppRoutes.login) {
        if (AppConfig.instance.hasOnboarding &&
            !sl<OnboardingStorage>().isComplete()) {
          return AppRoutes.onboarding;
        }
        return AppRoutes.home;
      }
    }

    return null;
  },
);

// â”€â”€ Refresh helper â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€

class GoRouterRefreshStream extends ChangeNotifier {
  late final StreamSubscription<dynamic> _subscription;

  GoRouterRefreshStream(Stream<dynamic> stream) {
    notifyListeners();
    _subscription = stream.asBroadcastStream().listen((_) => notifyListeners());
  }

  @override
  void dispose() {
    _subscription.cancel();
    super.dispose();
  }
}