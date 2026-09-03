import "../api/api_client.dart";
import "../api/api_exception.dart";
import "../demo/demo_catalog.dart";
import "auth_session.dart";
import "auth_storage.dart";

class LoginRequest {
  const LoginRequest({
    required this.tenantSlug,
    required this.email,
    required this.password,
  });

  final String tenantSlug;
  final String email;
  final String password;

  Map<String, dynamic> toJson() => {
    "tenantSlug": tenantSlug,
    "email": email,
    "password": password,
  };
}

class AuthRepository {
  AuthRepository({
    required this._apiClient,
    required this._authStorage,
    required this._demoCatalog,
  });

  final ApiClient _apiClient;
  final AuthStorage _authStorage;
  final DemoCatalog _demoCatalog;

  Future<AuthSession?> currentSession() => _authStorage.readSession();

  Future<AuthSession> login(LoginRequest request) async {
    try {
      final data = await _apiClient.post<Map<String, dynamic>>(
        "/api/v1/auth/login",
        data: request.toJson(),
        fromJson: (json) => json as Map<String, dynamic>,
      );
      final session = AuthSession.fromLoginData(data);
      await _authStorage.saveSession(session);
      return session;
    } on FormatException catch (error) {
      throw ApiException(message: error.message, code: "LOGIN_FAILED");
    }
  }

  Future<AuthSession> loginDemo() async {
    _demoCatalog.reset();
    final session = _demoCatalog.session;
    await _authStorage.saveSession(session);
    return session;
  }

  Future<void> forgotPassword({
    required String email,
    required String tenantSlug,
  }) {
    return _apiClient.postVoid(
      "/api/v1/auth/forgot-password",
      data: {"email": email, "tenantSlug": tenantSlug},
    );
  }

  Future<void> changePassword({
    required String currentPassword,
    required String newPassword,
  }) {
    return _apiClient.postVoid(
      "/api/v1/me/password",
      data: {"currentPassword": currentPassword, "newPassword": newPassword},
    );
  }

  Future<void> logout() async {
    final session = await _authStorage.readSession();
    if (session != null && !session.isDemo) {
      try {
        await _apiClient.postVoid(
          "/api/v1/auth/logout",
          data: {"refreshToken": session.refreshToken},
        );
      } catch (_) {
        // Best-effort server logout.
      }
    }
    await _authStorage.clearSession();
  }
}
