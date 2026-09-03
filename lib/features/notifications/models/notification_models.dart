class InboxNotification {
  const InboxNotification({
    required this.id,
    required this.title,
    required this.body,
    required this.createdAt,
    this.read = false,
    this.category = "announcements",
  });

  final String id;
  final String title;
  final String body;
  final DateTime createdAt;
  final bool read;
  final String category;

  InboxNotification copyWith({bool? read}) {
    return InboxNotification(
      id: id,
      title: title,
      body: body,
      createdAt: createdAt,
      read: read ?? this.read,
      category: category,
    );
  }

  factory InboxNotification.fromJson(Map<String, dynamic> json) {
    return InboxNotification(
      id: json["id"] as String,
      title: json["title"] as String? ?? "Update",
      body: json["body"] as String? ?? json["message"] as String? ?? "",
      createdAt: DateTime.parse(
        (json["createdAt"] as String?) ??
            (json["sentAt"] as String?) ??
            DateTime.now().toIso8601String(),
      ).toLocal(),
      read:
          json["read"] as bool? ??
          json["isRead"] as bool? ??
          json["readAt"] != null,
      category:
          json["category"] as String? ??
          json["type"] as String? ??
          "announcements",
    );
  }
}

class NotificationPreferences {
  const NotificationPreferences({
    this.announcements = true,
    this.classMessages = true,
    this.marketing = false,
  });

  final bool announcements;
  final bool classMessages;
  final bool marketing;

  NotificationPreferences copyWith({
    bool? announcements,
    bool? classMessages,
    bool? marketing,
  }) {
    return NotificationPreferences(
      announcements: announcements ?? this.announcements,
      classMessages: classMessages ?? this.classMessages,
      marketing: marketing ?? this.marketing,
    );
  }

  Map<String, dynamic> toJson() => {
    "announcements": announcements,
    "classMessages": classMessages,
    "marketing": marketing,
  };

  factory NotificationPreferences.fromJson(Map<String, dynamic> json) {
    return NotificationPreferences(
      announcements: json["announcements"] as bool? ?? true,
      classMessages: json["classMessages"] as bool? ?? true,
      marketing: json["marketing"] as bool? ?? false,
    );
  }
}

class NotificationInbox {
  const NotificationInbox({required this.items, this.unreadCount = 0});

  final List<InboxNotification> items;
  final int unreadCount;

  factory NotificationInbox.fromJson(Object? json) {
    if (json is List<dynamic>) {
      final items = json
          .map(
            (item) => InboxNotification.fromJson(item as Map<String, dynamic>),
          )
          .toList();
      return NotificationInbox(
        items: items,
        unreadCount: items.where((item) => !item.read).length,
      );
    }

    final map = json as Map<String, dynamic>;
    final rawItems = map["items"] as List<dynamic>? ?? const [];
    final items = rawItems
        .map((item) => InboxNotification.fromJson(item as Map<String, dynamic>))
        .toList();
    return NotificationInbox(
      items: items,
      unreadCount:
          (map["unreadCount"] as num?)?.toInt() ??
          items.where((item) => !item.read).length,
    );
  }
}
