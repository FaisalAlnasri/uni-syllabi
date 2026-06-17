import 'package:firebase_analytics/firebase_analytics.dart';
import '../logging/app_logger.dart';

abstract interface class AnalyticsService {
  Future<void> logEvent(String name, {Map<String, Object>? params});
  Future<void> setScreen(String screenName);
  Future<void> setUserId(String? userId);
}

class FirebaseAnalyticsService implements AnalyticsService {
  final FirebaseAnalytics _analytics;

  FirebaseAnalyticsService(this._analytics);

  @override
  Future<void> logEvent(String name, {Map<String, Object>? params}) async {
    try {
      await _analytics.logEvent(name: name, parameters: params);
      AppLogger.debug('[Analytics] $name ${params ?? ''}');
    } catch (e, st) {
      AppLogger.warning('[Analytics] Failed to log event: $name', e, st);
    }
  }

  @override
  Future<void> setScreen(String screenName) async {
    try {
      await _analytics.logScreenView(screenName: screenName);
      AppLogger.debug('[Analytics] Screen: $screenName');
    } catch (e, st) {
      AppLogger.warning('[Analytics] Failed to set screen: $screenName', e, st);
    }
  }

  @override
  Future<void> setUserId(String? userId) async {
    try {
      await _analytics.setUserId(id: userId);
    } catch (e, st) {
      AppLogger.warning('[Analytics] Failed to set userId', e, st);
    }
  }
}

/// No-op implementation — used in dev if you want to silence analytics.
class NoOpAnalyticsService implements AnalyticsService {
  @override
  Future<void> logEvent(String name, {Map<String, Object>? params}) async {
    AppLogger.debug('[Analytics][NoOp] $name ${params ?? ''}');
  }

  @override
  Future<void> setScreen(String screenName) async {
    AppLogger.debug('[Analytics][NoOp] Screen: $screenName');
  }

  @override
  Future<void> setUserId(String? userId) async {}
}