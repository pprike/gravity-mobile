import "../../core/api/api_client.dart";
import "../../core/demo/demo_catalog.dart";
import "models/announcement.dart";

class AnnouncementRepository {
  AnnouncementRepository(
    this._apiClient, {
    this.demoCatalog,
    this.demoMode = false,
  });

  final ApiClient _apiClient;
  final DemoCatalog? demoCatalog;
  final bool demoMode;

  Future<List<Announcement>> listAnnouncements() {
    if (demoMode && demoCatalog != null) {
      return Future.value(demoCatalog!.announcements);
    }
    return _apiClient.getList(
      "/api/v1/announcements",
      fromJson: (json) => Announcement.fromJson(json as Map<String, dynamic>),
    );
  }
}
