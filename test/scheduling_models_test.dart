import "package:flutter_test/flutter_test.dart";

import "package:gravity_mobile/features/scheduling/models/scheduling_models.dart";

void main() {
  group("Scheduling models", () {
    test("parses class session with bookedByMe flag", () {
      final session = ClassSession.fromJson({
        "id": "88888888-8888-8888-8888-888888888888",
        "name": "Peak Pilates Flow",
        "startsAt": "2026-08-08T11:00:00Z",
        "endsAt": "2026-08-08T12:00:00Z",
        "capacity": 12,
        "bookedCount": 9,
        "status": "scheduled",
        "bookedByMe": true,
      });

      expect(session.name, "Peak Pilates Flow");
      expect(session.spotsLeft, 3);
      expect(session.bookedByMe, isTrue);
    });

    test("parses coach and location labels from API payloads", () {
      final session = ClassSession.fromJson({
        "id": "88888888-8888-8888-8888-888888888888",
        "name": "Peak Pilates Flow",
        "startsAt": "2026-08-08T11:00:00Z",
        "endsAt": "2026-08-08T12:00:00Z",
        "capacity": 12,
        "bookedCount": 9,
        "status": "scheduled",
        "bookedByMe": false,
        "coachName": "Sarah T.",
        "locationName": "Peak Studio 1",
      });

      expect(session.coachLabel, "Sarah T.");
      expect(session.locationLabel, "Peak Studio 1");
    });

    test("parses waitlist fields on a full class session", () {
      final session = ClassSession.fromJson({
        "id": "88888888-8888-8888-8888-888888888888",
        "name": "HIIT",
        "startsAt": "2026-08-08T11:00:00Z",
        "endsAt": "2026-08-08T12:00:00Z",
        "capacity": 12,
        "bookedCount": 12,
        "status": "scheduled",
        "bookedByMe": false,
        "waitlistedByMe": true,
        "waitlistCount": 3,
      });

      expect(session.isFull, isTrue);
      expect(session.waitlistedByMe, isTrue);
      expect(session.waitlistCount, 3);
    });

    test("parses upcoming booking from API", () {
      final booking = UpcomingBooking.fromJson({
        "bookingId": "aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaaaa",
        "sessionId": "88888888-8888-8888-8888-888888888888",
        "className": "HIIT",
        "startsAt": "2026-08-08T11:00:00Z",
        "endsAt": "2026-08-08T12:00:00Z",
        "bookingStatus": "confirmed",
        "sessionStatus": "scheduled",
      });

      expect(booking.className, "HIIT");
      expect(booking.bookingStatus, "confirmed");
    });
  });
}
