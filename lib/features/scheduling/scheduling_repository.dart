import "../../../core/api/api_client.dart";
import "../../../core/demo/demo_catalog.dart";
import "models/scheduling_models.dart";

class SchedulingRepository {
  SchedulingRepository(this._apiClient, {this.demoCatalog, this.demoMode = false});

  final ApiClient _apiClient;
  final DemoCatalog? demoCatalog;
  final bool demoMode;

  bool get _demo => demoMode && demoCatalog != null;

  Future<List<ClassSession>> listSessions({
    required DateTime from,
    required DateTime to,
    String? locationId,
  }) {
    if (_demo) {
      return Future.value(
        demoCatalog!.listSessions(from: from, to: to, locationId: locationId),
      );
    }
    return _apiClient.getList(
      "/api/v1/class-sessions",
      queryParameters: {
        "from": from.toUtc().toIso8601String(),
        "to": to.toUtc().toIso8601String(),
        if (locationId != null) "locationId": locationId,
      },
      fromJson: (json) => ClassSession.fromJson(json as Map<String, dynamic>),
    );
  }

  Future<List<StudioLocation>> listLocations() {
    if (_demo) return Future.value(demoCatalog!.locations);
    return _apiClient.getList(
      "/api/v1/locations",
      fromJson: (json) => StudioLocation.fromJson(json as Map<String, dynamic>),
    );
  }

  Future<ClassBooking> bookSession(String sessionId) {
    if (_demo) return Future.value(demoCatalog!.bookSession(sessionId));
    return _apiClient.post(
      "/api/v1/class-sessions/$sessionId/bookings",
      fromJson: (json) => ClassBooking.fromJson(json as Map<String, dynamic>),
    );
  }

  Future<List<UpcomingBooking>> listUpcomingBookings() {
    if (_demo) return Future.value(demoCatalog!.listUpcomingBookings());
    return _apiClient.getList(
      "/api/v1/class-bookings/upcoming",
      fromJson: (json) =>
          UpcomingBooking.fromJson(json as Map<String, dynamic>),
    );
  }

  Future<ClassBooking> cancelBooking(String bookingId) {
    if (_demo) return Future.value(demoCatalog!.cancelBooking(bookingId));
    return _apiClient.delete(
      "/api/v1/class-bookings/$bookingId",
      fromJson: (json) => ClassBooking.fromJson(json as Map<String, dynamic>),
    );
  }

  Future<WaitlistStatus> joinWaitlist(String sessionId) {
    if (_demo) return Future.value(demoCatalog!.joinWaitlist(sessionId));
    return _apiClient.post(
      "/api/v1/class-sessions/$sessionId/waitlist",
      fromJson: (json) => WaitlistStatus.fromJson(json as Map<String, dynamic>),
    );
  }

  Future<void> leaveWaitlist(String sessionId) {
    if (_demo) {
      demoCatalog!.leaveWaitlist(sessionId);
      return Future.value();
    }
    return _apiClient.deleteVoid("/api/v1/class-sessions/$sessionId/waitlist");
  }
}
