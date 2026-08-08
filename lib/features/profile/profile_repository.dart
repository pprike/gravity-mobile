import "../../../core/api/api_client.dart";
import "models/user_profile.dart";

class ProfileRepository {
  ProfileRepository(this._apiClient);

  final ApiClient _apiClient;

  Future<UserProfile> getProfile(String userId) {
    return _apiClient.get(
      "/api/v1/users/$userId/profile",
      fromJson: (json) => UserProfile.fromJson(json as Map<String, dynamic>),
    );
  }

  Future<UserProfile> updateProfile(
    String userId,
    UpdateProfileRequest request,
  ) {
    return _apiClient.put(
      "/api/v1/users/$userId/profile",
      data: request.toJson(),
      fromJson: (json) => UserProfile.fromJson(json as Map<String, dynamic>),
    );
  }

  Future<UserProfile> uploadAvatar(String userId, String filePath) {
    return _apiClient.upload(
      "/api/v1/users/$userId/profile/avatar",
      fieldName: "file",
      filePath: filePath,
      fromJson: (json) => UserProfile.fromJson(json as Map<String, dynamic>),
    );
  }
}
