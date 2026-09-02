import "../../core/api/api_client.dart";
import "../../core/demo/demo_catalog.dart";
import "models/notification_models.dart";

class NotificationRepository {
  NotificationRepository(
    this._apiClient, {
    this.demoCatalog,
    this.demoMode = false,
  });

  final ApiClient _apiClient;
  final DemoCatalog? demoCatalog;
  final bool demoMode;

  bool get _demo => demoMode && demoCatalog != null;

  Future<List<InboxNotification>> listInbox() async {
    if (_demo) return demoCatalog!.notifications;
    try {
      return await _apiClient.getList(
        "/api/v1/notifications",
        fromJson: (json) =>
            InboxNotification.fromJson(json as Map<String, dynamic>),
      );
    } catch (_) {
      return const [];
    }
  }

  Future<void> markRead(String id) async {
    if (_demo) {
      demoCatalog!.markNotificationRead(id);
      return;
    }
    try {
      await _apiClient.post(
        "/api/v1/notifications/$id/read",
        fromJson: (json) => json,
      );
    } catch (_) {
      // Inbox still works locally even if the mark-read endpoint is missing.
    }
  }

  Future<void> markAllRead() async {
    if (_demo) {
      demoCatalog!.markAllNotificationsRead();
      return;
    }
    try {
      await _apiClient.post(
        "/api/v1/notifications/read-all",
        fromJson: (json) => json,
      );
    } catch (_) {}
  }

  Future<NotificationPreferences> getPreferences() async {
    if (_demo) return demoCatalog!.preferences;
    return _apiClient.get(
      "/api/v1/notifications/preferences",
      fromJson: (json) =>
          NotificationPreferences.fromJson(json as Map<String, dynamic>),
    );
  }

  Future<NotificationPreferences> updatePreferences(
    NotificationPreferences preferences,
  ) async {
    if (_demo) return demoCatalog!.updatePreferences(preferences);
    return _apiClient.put(
      "/api/v1/notifications/preferences",
      data: preferences.toJson(),
      fromJson: (json) =>
          NotificationPreferences.fromJson(json as Map<String, dynamic>),
    );
  }

  Future<void> registerDevice({
    required String token,
    required String platform,
  }) async {
    if (_demo) return;
    try {
      await _apiClient.post(
        "/api/v1/notifications/register-device",
        data: {"token": token, "platform": platform},
        fromJson: (json) => json,
      );
    } catch (_) {
      // FCM is optional until native projects ship a Firebase config.
    }
  }
}
