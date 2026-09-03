import "package:flutter_test/flutter_test.dart";

import "package:gravity_mobile/core/demo/demo_catalog.dart";
import "package:gravity_mobile/features/profile/models/user_profile.dart";

void main() {
  group("DemoCatalog", () {
    test("seeds a booked upcoming class and lets members cancel", () {
      final catalog = DemoCatalog();
      final bookings = catalog.listUpcomingBookings();
      expect(bookings, isNotEmpty);

      final booking = bookings.first;
      catalog.cancelBooking(booking.bookingId);
      expect(
        catalog.listUpcomingBookings().any(
          (item) => item.bookingId == booking.bookingId,
        ),
        isFalse,
      );
      expect(
        catalog.sessions
            .firstWhere((session) => session.id == booking.sessionId)
            .bookedByMe,
        isFalse,
      );
    });

    test("joins and leaves the waitlist on a full class", () {
      final catalog = DemoCatalog();
      final full = catalog.sessions.firstWhere(
        (session) =>
            session.isFull && !session.bookedByMe && !session.isCancelled,
      );

      final status = catalog.joinWaitlist(full.id);
      expect(status.position, greaterThan(0));
      expect(
        catalog.sessions
            .firstWhere((session) => session.id == full.id)
            .waitlistedByMe,
        isTrue,
      );

      catalog.leaveWaitlist(full.id);
      expect(
        catalog.sessions
            .firstWhere((session) => session.id == full.id)
            .waitlistedByMe,
        isFalse,
      );
    });

    test("sends chat messages into the studio lounge", () {
      final catalog = DemoCatalog();
      final before = catalog.messagesByGroup["chat-studio"]!.length;
      catalog.sendMessage(groupId: "chat-studio", body: "See you at 6");
      expect(catalog.messagesByGroup["chat-studio"]!.length, before + 1);
      expect(catalog.messagesByGroup["chat-studio"]!.last.mine, isTrue);
    });

    test("updates profile details and avatar", () {
      final catalog = DemoCatalog();
      catalog.updateProfile(
        const UpdateProfileRequest(
          displayName: "Alex Rivera",
          phone: "+1 555 0100",
        ),
      );
      expect(catalog.profile.member?.phone, "+1 555 0100");

      catalog.uploadAvatar("assets/images/member_avatar.jpg");
      expect(
        catalog.profile.member?.avatarUrl,
        "assets/images/member_avatar.jpg",
      );
    });

    test("updates notification preferences and marks inbox read", () {
      final catalog = DemoCatalog();
      expect(catalog.unreadCount, greaterThan(0));
      catalog.markAllNotificationsRead();
      expect(catalog.unreadCount, 0);

      final next = catalog.preferences.copyWith(marketing: true);
      expect(catalog.updatePreferences(next).marketing, isTrue);
    });
  });
}
