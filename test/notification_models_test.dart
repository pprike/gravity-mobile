import "package:flutter_test/flutter_test.dart";

import "package:gravity_mobile/features/notifications/models/notification_models.dart";

void main() {
  test("parses inbox envelope from gravity-service", () {
    final inbox = NotificationInbox.fromJson({
      "items": [
        {
          "id": "11111111-1111-1111-1111-111111111111",
          "type": "ANNOUNCEMENT",
          "title": "Holiday hours",
          "body": "We close at 4pm.",
          "createdAt": "2026-09-02T15:00:00Z",
          "readAt": null,
        },
        {
          "id": "22222222-2222-2222-2222-222222222222",
          "type": "WAITLIST",
          "title": "You're in",
          "body": "A spot opened in Power Hour.",
          "createdAt": "2026-09-02T16:00:00Z",
          "readAt": "2026-09-02T16:05:00Z",
        },
      ],
      "unreadCount": 1,
    });

    expect(inbox.items, hasLength(2));
    expect(inbox.unreadCount, 1);
    expect(inbox.items.first.read, isFalse);
    expect(inbox.items.last.read, isTrue);
    expect(inbox.items.first.title, "Holiday hours");
  });

  test("parses a bare notification list", () {
    final inbox = NotificationInbox.fromJson([
      {
        "id": "33333333-3333-3333-3333-333333333333",
        "title": "Studio update",
        "message": "New class added",
        "createdAt": "2026-09-02T15:00:00Z",
        "read": true,
      },
    ]);

    expect(inbox.items.single.read, isTrue);
    expect(inbox.items.single.body, "New class added");
    expect(inbox.unreadCount, 0);
  });
}
