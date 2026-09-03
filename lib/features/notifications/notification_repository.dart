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

  Future<NotificationInbox> listInbox() async {
    if (_demo) {
      return NotificationInbox(
        items: demoCatalog!.notifications,
        unreadCount: demoCatalog!.notifications
            .where((item) => !item.read)
            .length,
      );
    }
    return _apiClient.get(
      "/api/v1/notifications",
      fromJson: NotificationInbox.fromJson,
    );
  }

  Future<void> markRead(String id) async {
    if (_demo) {
      demoCatalog!.markNotificationRead(id);
      return;
    }
    await _apiClient.postVoid("/api/v1/notifications/$id/read");
  }

  Future<void> markAllRead() async {
    if (_demo) {
      demoCatalog!.markAllNotificationsRead();
      return;
    }
    await _apiClient.postVoid("/api/v1/notifications/read-all");
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
    await _apiClient.postVoid(
      "/api/v1/notifications/register-device",
      data: {"token": token, "platform": platform.toLowerCase()},
    );
  }
}
