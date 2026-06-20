import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Holds the active [ThemeMode], persisted in [SharedPreferences].
///
/// Replaces the source app's Hive-backed `ThemeProvider`; we reuse the
/// SharedPreferences instance already registered in the service locator.
class ThemeCubit extends Cubit<ThemeMode> {
  static const _key = 'themeMode';

  final SharedPreferences _prefs;

  ThemeCubit(this._prefs) : super(ThemeMode.system) {
    final saved = _prefs.getString(_key);
    emit(switch (saved) {
      'light' => ThemeMode.light,
      'dark' => ThemeMode.dark,
      _ => ThemeMode.system,
    });
  }

  Future<void> setMode(ThemeMode mode) async {
    emit(mode);
    await _prefs.setString(_key, mode.name);
  }
}
