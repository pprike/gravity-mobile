import "package:flutter/material.dart";
import "package:flutter_riverpod/flutter_riverpod.dart";
import "package:shared_preferences/shared_preferences.dart";

/// Persists the member's appearance choice across launches.
class ThemeModeController extends StateNotifier<ThemeMode> {
  ThemeModeController(this._prefs) : super(_read(_prefs));

  static const _key = "appearance_mode";

  final SharedPreferences? _prefs;

  static ThemeMode _read(SharedPreferences? prefs) {
    return switch (prefs?.getString(_key)) {
      "light" => ThemeMode.light,
      "dark" => ThemeMode.dark,
      _ => ThemeMode.system,
    };
  }

  Future<void> set(ThemeMode mode) async {
    state = mode;
    await _prefs?.setString(_key, mode.name);
  }
}

/// Overridden in `main()`; left null in tests, where the choice isn't persisted.
final sharedPreferencesProvider = Provider<SharedPreferences?>((ref) => null);

final themeModeProvider = StateNotifierProvider<ThemeModeController, ThemeMode>(
  (ref) => ThemeModeController(ref.watch(sharedPreferencesProvider)),
);
