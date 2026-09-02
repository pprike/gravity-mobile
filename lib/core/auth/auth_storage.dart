import "dart:convert";

import "package:flutter_secure_storage/flutter_secure_storage.dart";

import "auth_session.dart";

class AuthStorage {
  AuthStorage({
    FlutterSecureStorage? storage,
    this.persistToSecureStorage = true,
  }) : _storage = storage ?? const FlutterSecureStorage();

  static const _sessionKey = "gravity_auth_session";
  final FlutterSecureStorage _storage;
  final bool persistToSecureStorage;
  String? _memoryFallback;

  Future<AuthSession?> readSession() async {
    final raw = await _readRaw();
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
    return _writeRaw(jsonEncode(session.toJson()));
  }

  Future<void> clearSession() async {
    _memoryFallback = null;
    if (!persistToSecureStorage) return;
    try {
      await _storage.delete(key: _sessionKey);
    } catch (_) {
      // In-memory fallback is already cleared.
    }
  }

  Future<String?> _readRaw() async {
    if (!persistToSecureStorage) return _memoryFallback;
    try {
      return await _storage.read(key: _sessionKey) ?? _memoryFallback;
    } catch (_) {
      return _memoryFallback;
    }
  }

  Future<void> _writeRaw(String value) async {
    _memoryFallback = value;
    if (!persistToSecureStorage) return;
    try {
      await _storage.write(key: _sessionKey, value: value);
    } catch (_) {
      // Tests and some desktop/web targets cannot use secure storage.
    }
  }
}
