import "../../core/api/api_client.dart";
import "models/check_in_qr.dart";

class CheckInRepository {
  CheckInRepository(this._apiClient);

  final ApiClient _apiClient;

  Future<CheckInQr> getCheckInQr() {
    return _apiClient.get(
      "/api/v1/me/check-in-qr",
      fromJson: (json) => CheckInQr.fromJson(json as Map<String, dynamic>),
    );
  }
}
