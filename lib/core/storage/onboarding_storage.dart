import 'package:shared_preferences/shared_preferences.dart';

/// Minimal persistence for whether the user has finished onboarding.
class OnboardingStorage {
  static const _key = 'onboarding_complete';

  final SharedPreferences _prefs;
  OnboardingStorage(this._prefs);

  bool isComplete() => _prefs.getBool(_key) ?? false;

  Future<void> setComplete() => _prefs.setBool(_key, true);
}
