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
import '../../features/courses/domain/entities/course.dart';
import '../../features/courses/presentation/pages/calendar_page.dart';
import '../../features/courses/presentation/pages/course_confirmation_page.dart';
import '../../features/courses/presentation/pages/course_detail_page.dart';
import '../../features/courses/presentation/pages/courses_page.dart';
import '../../features/courses/presentation/pages/timeline_page.dart';
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
      builder: (context, state) => LoginPage(
        fromOnboarding: state.uri.queryParameters['from'] == 'onboarding',
      ),
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
          builder: (context, state) => const TimelinePage(),
        ),
        GoRoute(
          path: AppRoutes.calendar,
          builder: (context, state) => const CalendarPage(),
        ),
        GoRoute(
          path: AppRoutes.courses,
          builder: (context, state) => const CoursesPage(),
        ),
        GoRoute(
          path: AppRoutes.profile,
          builder: (context, state) => const ProfilePage(),
        ),
      ],
    ),

    // â”€â”€ Push routes (no bottom nav) â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
    GoRoute(
      path: AppRoutes.courseDetail,
      builder: (context, state) =>
          CourseDetailPage(course: state.extra as Course),
    ),
    GoRoute(
      path: AppRoutes.courseConfirmation,
      builder: (context, state) =>
          CourseConfirmationPage(courses: state.extra as List<Course>),
    ),
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
      // Leaving the splash screen: route into onboarding or the app.
      if (location == AppRoutes.splash) {
        if (AppConfig.instance.hasOnboarding &&
            !sl<OnboardingStorage>().isComplete()) {
          return AppRoutes.onboarding;
        }
        return AppRoutes.home;
      }

      // A real authenticated user has no reason to see login; guests may stay
      // there (optional auth) so they can sign in after signing out.
      if (location == AppRoutes.login && authState is AuthAuthenticated) {
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