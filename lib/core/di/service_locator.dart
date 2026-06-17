import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:get_it/get_it.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../analytics/analytics_service.dart';
import '../config/app_config.dart';
import '../storage/onboarding_storage.dart';
import '../../features/auth/presentation/cubit/auth_cubit.dart';
import '../../features/auth/domain/services/auth_service.dart';
import '../../features/paywall/domain/subscription.dart';
import '../../features/paywall/data/purchases_repository_impl.dart';
import '../../features/paywall/paywall_cubit.dart';

final GetIt sl = GetIt.instance;

Future<void> setupServiceLocator() async {
  _registerCore();
  await _registerAuth();
  await _registerPaywall();
  // Features: _registerFeatures();
}

void _registerCore() {
  // Analytics
  if (AppConfig.instance.isDev) {
    sl.registerLazySingleton<AnalyticsService>(() => NoOpAnalyticsService());
  } else {
    sl.registerLazySingleton<AnalyticsService>(
      () => FirebaseAnalyticsService(FirebaseAnalytics.instance),
    );
  }
}

// ── Auth ──────────────────────────────────────────────────────
Future<void> _registerAuth() async {
  // SharedPreferences
  final prefs = await SharedPreferences.getInstance();
  sl.registerLazySingleton<SharedPreferences>(() => prefs);
  sl.registerLazySingleton<OnboardingStorage>(() => OnboardingStorage(sl()));

  // Auth service
  sl.registerLazySingleton<AuthService>(() => FirebaseAuthService());

  // AuthCubit — lazy singleton (shared across router + UI).
  sl.registerLazySingleton<AuthCubit>(() => AuthCubit(sl<AuthService>()));
}

// ── Paywall / RevenueCat ──────────────────────────────────────
Future<void> _registerPaywall() async {
  sl.registerLazySingleton<PurchasesRepository>(
    () => RevenueCatRepository(),
  );
  sl.registerFactory(() => PaywallCubit(sl<PurchasesRepository>()));

  // Initialize RC after auth so the user ID is available.
  await sl<PurchasesRepository>().init(sl<AuthCubit>().currentUser?.uid);
}

// ── Uncomment and fill as you add phases ──────────────────────
//
// void _registerFeatures() {
//   sl.registerFactory(() => HomeCubit());
// }