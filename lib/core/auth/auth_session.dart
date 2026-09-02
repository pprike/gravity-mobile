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
      id: json["id"] as String,
      email: json["email"] as String,
      firstName: json["firstName"] as String?,
      lastName: json["lastName"] as String?,
      roles: (json["roles"] as List<dynamic>).map((e) => e as String).toList(),
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
