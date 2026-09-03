class AuthUser {
  const AuthUser({
    required this.id,
    required this.email,
    this.firstName,
    this.lastName,
    required this.roles,
  });

  final String id;
  final String email;
  final String? firstName;
  final String? lastName;
  final List<String> roles;

  String get displayName {
    final name = [
      firstName,
      lastName,
    ].where((part) => part?.isNotEmpty == true);
    if (name.isNotEmpty) return name.join(" ");
    return email;
  }

  factory AuthUser.fromJson(Map<String, dynamic> json) {
    return AuthUser(
      id: json["id"].toString(),
      email: json["email"] as String,
      firstName: json["firstName"] as String?,
      lastName: json["lastName"] as String?,
      roles: (json["roles"] as List<dynamic>? ?? const [])
          .map((item) => item.toString())
          .toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      "id": id,
      "email": email,
      "firstName": firstName,
      "lastName": lastName,
      "roles": roles,
    };
  }
}

class AuthSession {
  const AuthSession({
    required this.accessToken,
    required this.refreshToken,
    required this.expiresIn,
    required this.user,
    required this.expiresAt,
    this.isDemo = false,
  });

  final String accessToken;
  final String refreshToken;
  final int expiresIn;
  final AuthUser user;
  final DateTime expiresAt;
  final bool isDemo;

  bool get isExpired => DateTime.now().isAfter(expiresAt);

  factory AuthSession.fromAuthTokens(Map<String, dynamic> json) {
    final expiresIn = (json["expiresIn"] as num).toInt();
    return AuthSession(
      accessToken: json["accessToken"] as String,
      refreshToken: json["refreshToken"] as String,
      expiresIn: expiresIn,
      user: AuthUser.fromJson(json["user"] as Map<String, dynamic>),
      expiresAt: DateTime.now().add(Duration(seconds: expiresIn)),
    );
  }

  factory AuthSession.fromLoginData(Map<String, dynamic> data) {
    if (data["tenantSelectionRequired"] == true) {
      throw const FormatException(
        "This email is in more than one studio. Open studio ID and enter tenant-a.",
      );
    }
    final auth = data["auth"];
    if (auth is Map<String, dynamic>) {
      return AuthSession.fromAuthTokens(auth);
    }
    if (data["accessToken"] is String) {
      return AuthSession.fromAuthTokens(data);
    }
    throw const FormatException("Sign-in did not return a session.");
  }

  factory AuthSession.fromJson(Map<String, dynamic> json) {
    return AuthSession(
      accessToken: json["accessToken"] as String,
      refreshToken: json["refreshToken"] as String,
      expiresIn: json["expiresIn"] as int,
      user: AuthUser.fromJson(json["user"] as Map<String, dynamic>),
      expiresAt: DateTime.parse(json["expiresAt"] as String),
      isDemo: json["isDemo"] as bool? ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      "accessToken": accessToken,
      "refreshToken": refreshToken,
      "expiresIn": expiresIn,
      "user": user.toJson(),
      "expiresAt": expiresAt.toIso8601String(),
      "isDemo": isDemo,
    };
  }
}
