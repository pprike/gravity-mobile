import "../../core/api/api_client.dart";
import "../../core/demo/demo_catalog.dart";
import "models/check_in_qr.dart";

class CheckInRepository {
  CheckInRepository(
    this._apiClient, {
    this.demoCatalog,
    this.demoMode = false,
  });

  final ApiClient _apiClient;
  final DemoCatalog? demoCatalog;
  final bool demoMode;

  Future<CheckInQr> getCheckInQr() {
    if (demoMode && demoCatalog != null) {
      return Future.value(demoCatalog!.checkInQr());
    }
    return _apiClient.get(
      "/api/v1/me/check-in-qr",
      fromJson: (json) => CheckInQr.fromJson(json as Map<String, dynamic>),
    );
  }
}
