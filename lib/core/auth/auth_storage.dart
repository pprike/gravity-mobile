import "dart:convert";

import "package:flutter_secure_storage/flutter_secure_storage.dart";

import "auth_session.dart";

class AuthStorage {
  AuthStorage({FlutterSecureStorage? storage})
    : _storage = storage ?? const FlutterSecureStorage();

  static const _sessionKey = "gravity_auth_session";
  final FlutterSecureStorage _storage;

  Future<AuthSession?> readSession() async {
    final raw = await _storage.read(key: _sessionKey);
    if (raw == null || raw.isEmpty) return null;

    try {
      final session = AuthSession.fromJson(
        jsonDecode(raw) as Map<String, dynamic>,
      );
      if (session.isExpired) {
        await clearSession();
        return null;
      }
      return session;
    } catch (_) {
      await clearSession();
      return null;
    }
  }

  Future<void> saveSession(AuthSession session) {
    return _storage.write(
      key: _sessionKey,
      value: jsonEncode(session.toJson()),
    );
  }

  Future<void> clearSession() {
    return _storage.delete(key: _sessionKey);
  }
}
