import "package:flutter_riverpod/flutter_riverpod.dart";
import "package:local_auth/local_auth.dart";
import "package:shared_preferences/shared_preferences.dart";

import "../theme/theme_mode_controller.dart";

const _kBiometricEnabledKey = "biometric_enabled";

/// Wraps [LocalAuthentication] so callers can authenticate with biometrics
/// and toggle the feature on/off.
class BiometricService {
  BiometricService(this._auth, this._prefs);

  final LocalAuthentication _auth;
  final SharedPreferences? _prefs;

  bool get isEnabled => _prefs?.getBool(_kBiometricEnabledKey) ?? false;

  Future<bool> get isAvailable async {
    try {
      return await _auth.canCheckBiometrics || await _auth.isDeviceSupported();
    } catch (_) {
      return false;
    }
  }

  Future<List<BiometricType>> get availableTypes async {
    try {
      return _auth.getAvailableBiometrics();
    } catch (_) {
      return const [];
    }
  }

  Future<void> setEnabled(bool value) async =>
      _prefs?.setBool(_kBiometricEnabledKey, value);

  /// Returns true when biometric authentication succeeds.
  Future<bool> authenticate() async {
    try {
      return await _auth.authenticate(
        localizedReason: "Confirm it's you to open Gravity",
        persistAcrossBackgrounding: true,
      );
    } catch (_) {
      return false;
    }
  }
}

final biometricServiceProvider = Provider<BiometricService>((ref) {
  return BiometricService(
    LocalAuthentication(),
    ref.watch(sharedPreferencesProvider),
  );
});

/// Whether biometric auth is both available and enabled by this user.
final biometricReadyProvider = FutureProvider<bool>((ref) async {
  final service = ref.watch(biometricServiceProvider);
  if (!service.isEnabled) return false;
  return service.isAvailable;
});
