import "package:flutter_test/flutter_test.dart";

import "package:gravity_mobile/features/profile/models/user_profile.dart";

void main() {
  group("UserProfile", () {
    test("parses member profile from API envelope data", () {
      final profile = UserProfile.fromJson({
        "userId": "eeeeeeee-eeee-eeee-eeee-eeeeeeeeeeee",
        "roles": ["Member"],
        "member": {
          "displayName": "Alex Rivera",
          "phone": "+15551234567",
          "avatarUrl": "/uploads/profiles/avatar.png",
          "emergencyContact": {
            "name": "Sam Rivera",
            "phone": "+15559876543",
          },
        },
      });

      expect(profile.userId, "eeeeeeee-eeee-eeee-eeee-eeeeeeeeeeee");
      expect(profile.roles, ["Member"]);
      expect(profile.member?.displayName, "Alex Rivera");
      expect(profile.member?.phone, "+15551234567");
      expect(profile.member?.emergencyContact?["name"], "Sam Rivera");
    });

    test("update request serializes editable fields", () {
      const request = UpdateProfileRequest(
        displayName: "Alex Rivera",
        phone: "+15551234567",
        emergencyContact: {
          "name": "Sam Rivera",
          "phone": "+15559876543",
        },
      );

      expect(
        request.toJson(),
        {
          "displayName": "Alex Rivera",
          "phone": "+15551234567",
          "emergencyContact": {
            "name": "Sam Rivera",
            "phone": "+15559876543",
          },
        },
      );
    });
  });
}
