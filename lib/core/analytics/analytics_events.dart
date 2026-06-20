/// All analytics event names live here.
/// Add app-specific events below the common ones.
abstract final class AnalyticsEvents {
  // ── App lifecycle ──────────────────────────────────────────
  static const String appOpen = 'app_open';

  // ── Auth ───────────────────────────────────────────────────
  static const String signInStarted = 'sign_in_started';
  static const String signInSuccess = 'sign_in_success';
  static const String signInFailed = 'sign_in_failed';
  static const String signOut = 'sign_out';

  // ── Onboarding ─────────────────────────────────────────────
  static const String onboardingStarted = 'onboarding_started';
  static const String onboardingCompleted = 'onboarding_completed';
  static const String onboardingStepViewed = 'onboarding_step_viewed';

  // ── Notification opt-in ────────────────────────────────────
  static const String notificationShown = 'notification_shown';
  static const String notificationAccepted = 'notification_accepted';
  static const String notificationSkipped = 'notification_skipped';

  // ── Paywall ────────────────────────────────────────────────
  static const String paywallViewed = 'paywall_viewed';
  static const String paywallDismissed = 'paywall_dismissed';
  static const String purchaseStarted = 'purchase_started';
  static const String purchaseSuccess = 'purchase_success';
  static const String purchaseFailed = 'purchase_failed';
  static const String purchaseRestored = 'purchase_restored';

  // ── Add app-specific events below ──────────────────────────
}