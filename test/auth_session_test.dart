import "package:flutter_test/flutter_test.dart";

import "package:gravity_mobile/core/auth/auth_session.dart";

void main() {
  test("parses nested login payload from gravity-service", () {
    final session = AuthSession.fromLoginData({
      "tenantSelectionRequired": false,
      "auth": {
        "accessToken": "access-token",
        "refreshToken": "refresh-token",
        "expiresIn": 3600,
        "user": {
          "id": "eeeeeeee-eeee-eeee-eeee-eeeeeeeeeeee",
          "email": "member@tenant-a.com",
          "roles": ["MEMBER"],
        },
      },
    });

    expect(session.accessToken, "access-token");
    expect(session.refreshToken, "refresh-token");
    expect(session.user.email, "member@tenant-a.com");
    expect(session.user.roles, ["MEMBER"]);
    expect(session.isDemo, isFalse);
  });

  test("rejects tenant-selection login payloads", () {
    expect(
      () => AuthSession.fromLoginData({
        "tenantSelectionRequired": true,
        "tenants": [
          {"tenantSlug": "tenant-a", "tenantName": "Iron Peak"},
        ],
      }),
      throwsFormatException,
    );
  });
}
