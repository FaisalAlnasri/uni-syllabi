abstract final class AppRoutes {
  // ── Shell tabs ──────────────────────────────────────────────
  static const String home = '/'; // Timeline (first tab)
  static const String calendar = '/calendar';
  static const String courses = '/courses';
  static const String profile = '/profile';

  // ── Courses push routes (no bottom nav) ─────────────────────
  static const String courseDetail = '/course-detail';
  static const String courseConfirmation = '/course-confirmation';

  // ── Auth ────────────────────────────────────────────────────
  static const String splash = '/splash';
  static const String login = '/login';

  // ── Onboarding ──────────────────────────────────────────────
  static const String onboarding = '/onboarding';

  // ── Debug (dev only) ────────────────────────────────────────
  static const String themePage = '/theme';

  // ── Paywall (Phase 3) ───────────────────────────────────────
  static const String paywall = '/paywall';
}
