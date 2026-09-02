import "../../../core/api/api_client.dart";
import "models/scheduling_models.dart";

class SchedulingRepository {
  SchedulingRepository(this._apiClient);

  final ApiClient _apiClient;

  Future<List<ClassSession>> listSessions({
    required DateTime from,
    required DateTime to,
  }) {
    return _apiClient.getList(
      "/api/v1/class-sessions",
      queryParameters: {
        "from": from.toUtc().toIso8601String(),
        "to": to.toUtc().toIso8601String(),
      },
      fromJson: (json) => ClassSession.fromJson(json as Map<String, dynamic>),
    );
  }

  Future<ClassBooking> bookSession(String sessionId) {
    return _apiClient.post(
      "/api/v1/class-sessions/$sessionId/bookings",
      fromJson: (json) => ClassBooking.fromJson(json as Map<String, dynamic>),
    );
  }

  Future<List<UpcomingBooking>> listUpcomingBookings() {
    return _apiClient.getList(
      "/api/v1/class-bookings/upcoming",
      fromJson: (json) =>
          UpcomingBooking.fromJson(json as Map<String, dynamic>),
    );
  }

  Future<ClassBooking> cancelBooking(String bookingId) {
    return _apiClient.delete(
      "/api/v1/class-bookings/$bookingId",
      fromJson: (json) => ClassBooking.fromJson(json as Map<String, dynamic>),
    );
  }

  Future<WaitlistStatus> joinWaitlist(String sessionId) {
    return _apiClient.post(
      "/api/v1/class-sessions/$sessionId/waitlist",
      fromJson: (json) => WaitlistStatus.fromJson(json as Map<String, dynamic>),
    );
  }

  Future<void> leaveWaitlist(String sessionId) {
    return _apiClient.deleteVoid("/api/v1/class-sessions/$sessionId/waitlist");
  }
}
