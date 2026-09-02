import "../../core/api/api_client.dart";
import "../../core/demo/demo_catalog.dart";
import "models/member_subscription.dart";
import "models/user_profile.dart";

class ProfileRepository {
  ProfileRepository(this._apiClient, {this.demoCatalog, this.demoMode = false});

  final ApiClient _apiClient;
  final DemoCatalog? demoCatalog;
  final bool demoMode;

  bool get _demo => demoMode && demoCatalog != null;

  Future<UserProfile> getProfile(String userId) {
    if (_demo) return Future.value(demoCatalog!.profile);
    return _apiClient.get(
      "/api/v1/users/$userId/profile",
      fromJson: (json) => UserProfile.fromJson(json as Map<String, dynamic>),
    );
  }

  Future<UserProfile> updateProfile(
    String userId,
    UpdateProfileRequest request,
  ) {
    if (_demo) return Future.value(demoCatalog!.updateProfile(request));
    return _apiClient.put(
      "/api/v1/users/$userId/profile",
      data: request.toJson(),
      fromJson: (json) => UserProfile.fromJson(json as Map<String, dynamic>),
    );
  }

  Future<UserProfile> uploadAvatar(String userId, String filePath) {
    if (_demo) return Future.value(demoCatalog!.profile);
    return _apiClient.upload(
      "/api/v1/users/$userId/profile/avatar",
      fieldName: "file",
      filePath: filePath,
      fromJson: (json) => UserProfile.fromJson(json as Map<String, dynamic>),
    );
  }

  Future<MemberSubscription?> getSubscription(String userId) async {
    if (_demo) return demoCatalog!.subscription;
    try {
      return await _apiClient.get(
        "/api/v1/users/$userId/subscription",
        fromJson: (json) =>
            MemberSubscription.fromJson(json as Map<String, dynamic>),
      );
    } catch (_) {
      return null;
    }
  }
}
