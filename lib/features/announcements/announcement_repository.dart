import "../../core/api/api_client.dart";
import "models/announcement.dart";

class AnnouncementRepository {
  AnnouncementRepository(this._apiClient);

  final ApiClient _apiClient;

  Future<List<Announcement>> listAnnouncements() {
    return _apiClient.getList(
      "/api/v1/announcements",
      fromJson: (json) => Announcement.fromJson(json as Map<String, dynamic>),
    );
  }
}
