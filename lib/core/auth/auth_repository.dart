import "../api/api_client.dart";
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
    required ApiClient apiClient,
    required AuthStorage authStorage,
  })  : _apiClient = apiClient,
        _authStorage = authStorage;

  final ApiClient _apiClient;
  final AuthStorage _authStorage;

  Future<AuthSession?> currentSession() => _authStorage.readSession();

  Future<AuthSession> login(LoginRequest request) async {
    final data = await _apiClient.post<Map<String, dynamic>>(
      "/api/v1/auth/login",
      data: request.toJson(),
      fromJson: (json) => json as Map<String, dynamic>,
    );

    final session = AuthSession(
      accessToken: data["accessToken"] as String,
      refreshToken: data["refreshToken"] as String,
      expiresIn: data["expiresIn"] as int,
      user: AuthUser.fromJson(data["user"] as Map<String, dynamic>),
      expiresAt: DateTime.now().add(Duration(seconds: data["expiresIn"] as int)),
    );
    await _authStorage.saveSession(session);
    return session;
  }

  Future<void> logout() async {
    final session = await _authStorage.readSession();
    if (session != null) {
      try {
        await _apiClient.post<dynamic>(
          "/api/v1/auth/logout",
          data: {"refreshToken": session.refreshToken},
          fromJson: (json) => json,
        );
      } catch (_) {
        // Best-effort server logout.
      }
    }
    await _authStorage.clearSession();
  }
}
