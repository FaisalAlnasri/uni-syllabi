enum Env { dev, prod }

class AppConfig {
  AppConfig._();

  static late final AppConfig _instance;
  static AppConfig get instance => _instance;

  late final Env env;
  late final String appName;
  late final String revenueCatApiKey;
  late final String revenueCatEntitlementId;
  late final bool requiresAuth;
  late final bool hasOnboarding;

  /// Call once at the top of main_dev.dart / main_prod.dart
  /// before runApp().
  static void setup({
    required Env env,
    required String revenueCatApiKey,
    required String revenueCatEntitlementId,
    required bool requiresAuth,
    required bool hasOnboarding,
  }) {
    _instance = AppConfig._()
      ..env = env
      ..appName = env == Env.dev ? 'جدول جامعي (Dev)' : 'جدول جامعي'
      ..revenueCatApiKey = revenueCatApiKey
      ..revenueCatEntitlementId = revenueCatEntitlementId
      ..requiresAuth = requiresAuth
      ..hasOnboarding = hasOnboarding;
  }

  bool get isDev => env == Env.dev;
  bool get isProd => env == Env.prod;
}