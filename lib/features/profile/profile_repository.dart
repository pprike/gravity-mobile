import "../../core/api/api_client.dart";
import "../../core/api/api_exception.dart";
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
    if (_demo) return Future.value(demoCatalog!.uploadAvatar(filePath));
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
      final subscription = await _apiClient.get(
        "/api/v1/me/subscription",
        fromJson: (json) =>
            MemberSubscription.fromJson(json as Map<String, dynamic>),
      );
      if (subscription.planName == null || subscription.planName!.isEmpty) {
        return null;
      }
      return subscription;
    } catch (_) {
      return null;
    }
  }

  Future<String> createBillingPortalSession() async {
    if (_demo) {
      throw ApiException(
        message: "Billing portal isn’t included in the demo studio.",
        code: "DEMO",
      );
    }
    final data = await _apiClient.post<Map<String, dynamic>>(
      "/api/v1/billing/portal-sessions",
      data: const <String, dynamic>{},
      fromJson: (json) => json as Map<String, dynamic>,
    );
    final url = data["url"] as String?;
    if (url == null || url.isEmpty) {
      throw ApiException(
        message: "Billing portal is not available for this studio.",
        code: "BILLING_UNAVAILABLE",
      );
    }
    return url;
  }
}
