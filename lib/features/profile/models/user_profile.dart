class MemberProfileData {
  const MemberProfileData({
    this.displayName,
    this.phone,
    this.avatarUrl,
    this.emergencyContact,
  });

  final String? displayName;
  final String? phone;
  final String? avatarUrl;
  final Map<String, String>? emergencyContact;

  factory MemberProfileData.fromJson(Map<String, dynamic>? json) {
    if (json == null) return const MemberProfileData();
    return MemberProfileData(
      displayName: json["displayName"] as String?,
      phone: json["phone"] as String?,
      avatarUrl: json["avatarUrl"] as String?,
      emergencyContact: (json["emergencyContact"] as Map<String, dynamic>?)
          ?.map((key, value) => MapEntry(key, value as String)),
    );
  }
}

class UserProfile {
  const UserProfile({required this.userId, required this.roles, this.member});

  final String userId;
  final List<String> roles;
  final MemberProfileData? member;

  factory UserProfile.fromJson(Map<String, dynamic> json) {
    return UserProfile(
      userId: json["userId"] as String,
      roles: (json["roles"] as List<dynamic>).map((e) => e as String).toList(),
      member: MemberProfileData.fromJson(
        json["member"] as Map<String, dynamic>?,
      ),
    );
  }
}

class UpdateProfileRequest {
  const UpdateProfileRequest({
    this.displayName,
    this.phone,
    this.emergencyContact,
  });

  final String? displayName;
  final String? phone;
  final Map<String, String>? emergencyContact;

  Map<String, dynamic> toJson() {
    return {
      if (displayName != null) "displayName": displayName,
      if (phone != null) "phone": phone,
      if (emergencyContact != null) "emergencyContact": emergencyContact,
    };
  }
}
