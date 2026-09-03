import "package:flutter/foundation.dart";

import "../auth/auth_session.dart";
import "../../features/announcements/models/announcement.dart";
import "../../features/check_in/models/check_in_qr.dart";
import "../../features/community/models/chat_models.dart";
import "../../features/notifications/models/notification_models.dart";
import "../../features/profile/models/member_subscription.dart";
import "../../features/profile/models/user_profile.dart";
import "../../features/scheduling/models/scheduling_models.dart";

/// In-memory member studio used when exploring the app without gravity-service.
class DemoCatalog extends ChangeNotifier {
  DemoCatalog() {
    reset();
  }

  static const memberId = "demo-member-1";
  static const memberEmail = "member@ironpeak.demo";

  late UserProfile profile;
  late MemberSubscription subscription;
  late List<StudioLocation> locations;
  late List<ClassSession> sessions;
  late List<UpcomingBooking> bookings;
  late List<Announcement> announcements;
  late List<InboxNotification> notifications;
  late NotificationPreferences preferences;
  late List<ChatGroup> chatGroups;
  late Map<String, List<ChatMessage>> messagesByGroup;
  late List<BookingHistoryEntry> history;
  late Set<DateTime> _visitDays;
  int _bookingSeq = 0;
  int _messageSeq = 0;

  AuthSession get session {
    return AuthSession(
      accessToken: "demo-access-token",
      refreshToken: "demo-refresh-token",
      expiresIn: 60 * 60 * 24 * 7,
      isDemo: true,
      user: const AuthUser(
        id: memberId,
        email: memberEmail,
        firstName: "Alex",
        lastName: "Rivera",
        roles: ["Member"],
      ),
      expiresAt: DateTime.now().add(const Duration(days: 7)),
    );
  }

  void reset() {
    _bookingSeq = 0;
    _messageSeq = 0;
    locations = const [
      StudioLocation(id: "loc-1", name: "Peak Studio 1"),
      StudioLocation(id: "loc-2", name: "Downtown Studio A"),
    ];
    profile = const UserProfile(
      userId: memberId,
      roles: ["Member"],
      member: MemberProfileData(
        displayName: "Alex Rivera",
        phone: "+1 (555) 214-0192",
        emergencyContact: {"name": "Sam Rivera", "phone": "+1 (555) 882-4410"},
      ),
    );
    subscription = const MemberSubscription(
      planName: "All Access Elite",
      status: "active",
      priceLabel: "\$189 / month",
      renewalLabel: "Renews Oct 1",
      remainingCredits: null,
      features: ["Unlimited classes", "Guest pass each month", "Sauna access"],
    );
    sessions = _seedSessions();
    bookings = [];
    history = _seedHistory();
    _visitDays = history
        .where((entry) => entry.isCompleted)
        .map((entry) => _dayOf(entry.startsAt))
        .toSet();
    announcements = [
      Announcement(
        id: "ann-1",
        title: "Holiday hours this weekend",
        body:
            "Saturday classes run on a condensed schedule. Front desk opens at 7:00 AM and the last class starts at 4:30 PM.",
        authorName: "Studio desk",
        publishedAt: DateTime.now().subtract(const Duration(hours: 5)),
      ),
      Announcement(
        id: "ann-2",
        title: "New reformer beds arrive Monday",
        body:
            "Peak Studio 1 will have two extra reformers starting Monday. Book early — the 6:00 PM slots fill fast.",
        authorName: "Coach Elena",
        publishedAt: DateTime.now().subtract(const Duration(days: 1, hours: 3)),
      ),
    ];
    notifications = [
      InboxNotification(
        id: "n-1",
        title: "You're booked for Power Hour",
        body: "See you tonight at 6:00 PM in Peak Studio 1.",
        createdAt: DateTime.now().subtract(const Duration(hours: 2)),
        category: "classMessages",
      ),
      InboxNotification(
        id: "n-2",
        title: "Holiday hours this weekend",
        body: "Saturday classes run on a condensed schedule.",
        createdAt: DateTime.now().subtract(const Duration(hours: 5)),
        category: "announcements",
      ),
      InboxNotification(
        id: "n-3",
        title: "Waitlist moved up",
        body: "A spot opened in Olympic Weightlifting. Book now to claim it.",
        createdAt: DateTime.now().subtract(const Duration(days: 1)),
        read: true,
        category: "classMessages",
      ),
    ];
    preferences = const NotificationPreferences();
    chatGroups = const [
      ChatGroup(
        id: "chat-studio",
        name: "Iron Peak Lounge",
        subtitle: "Everyone at the studio",
        type: "organization",
      ),
      ChatGroup(
        id: "chat-morning",
        name: "Sunrise crew",
        subtitle: "Morning class regulars",
        type: "class",
      ),
    ];
    messagesByGroup = {
      "chat-studio": [
        ChatMessage(
          id: "m-1",
          groupId: "chat-studio",
          senderId: "coach-marcus",
          senderName: "Marcus Vance",
          body:
              "Who's coming through for Power Hour tonight? Bring a towel — it's a heater.",
          createdAt: DateTime.now().subtract(const Duration(hours: 3)),
        ),
        ChatMessage(
          id: "m-2",
          groupId: "chat-studio",
          senderId: "member-priya",
          senderName: "Priya Shah",
          body: "I'll be in the back row. First class back after vacation 👋",
          createdAt: DateTime.now().subtract(
            const Duration(hours: 2, minutes: 40),
          ),
        ),
      ],
      "chat-morning": [
        ChatMessage(
          id: "m-3",
          groupId: "chat-morning",
          senderId: "coach-elena",
          senderName: "Elena Rostova",
          body: "Sunrise flow is candlelit tomorrow. Arrive 5 minutes early.",
          createdAt: DateTime.now().subtract(const Duration(minutes: 50)),
        ),
      ],
    };

    final hero = sessions.firstWhere(
      (session) =>
          session.name.contains("Power Hour") &&
          session.startsAt.isAfter(DateTime.now()),
      orElse: () => sessions.firstWhere(
        (session) =>
            session.startsAt.isAfter(DateTime.now()) && !session.isFull,
        orElse: () => sessions.first,
      ),
    );
    bookSession(hero.id, notify: false);
  }

  List<ClassSession> listSessions({
    required DateTime from,
    required DateTime to,
    String? locationId,
  }) {
    return sessions.where((session) {
      final inRange =
          !session.startsAt.isBefore(from) && session.startsAt.isBefore(to);
      final matchesLocation =
          locationId == null || session.locationId == locationId;
      return inRange && matchesLocation;
    }).toList()..sort((a, b) => a.startsAt.compareTo(b.startsAt));
  }

  List<UpcomingBooking> listUpcomingBookings() {
    return bookings
        .where((booking) => booking.endsAt.isAfter(DateTime.now()))
        .toList()
      ..sort((a, b) => a.startsAt.compareTo(b.startsAt));
  }

  BookingHistoryPage listBookingHistory({
    String? status,
    int page = 0,
    int size = 20,
  }) {
    final matching = history.where((entry) {
      return switch (status) {
        "completed" => entry.isCompleted,
        "cancelled" => entry.isCancelled,
        "confirmed" => !entry.isCompleted && !entry.isCancelled,
        _ => true,
      };
    }).toList()..sort((a, b) => b.startsAt.compareTo(a.startsAt));

    final start = (page * size).clamp(0, matching.length);
    final end = (start + size).clamp(0, matching.length);
    return BookingHistoryPage(
      items: matching.sublist(start, end),
      page: page,
      size: size,
      totalElements: matching.length,
    );
  }

  AttendanceSummary attendanceSummary() {
    if (_visitDays.isEmpty) return const AttendanceSummary();
    final now = DateTime.now();
    final visitsThisMonth = _visitDays
        .where((day) => day.year == now.year && day.month == now.month)
        .length;
    final sorted = _visitDays.toList()..sort();
    final spanWeeks = (sorted.last.difference(sorted.first).inDays / 7)
        .ceil()
        .clamp(1, 520);

    var longest = 1;
    var current = 1;
    for (var i = 1; i < sorted.length; i++) {
      if (sorted[i].difference(sorted[i - 1]).inDays == 1) {
        current += 1;
      } else {
        current = 1;
      }
      if (current > longest) longest = current;
    }

    return AttendanceSummary(
      totalVisits: _visitDays.length,
      visitsThisMonth: visitsThisMonth,
      averagePerWeek: double.parse(
        (_visitDays.length / spanWeeks).toStringAsFixed(1),
      ),
      longestStreakDays: longest,
    );
  }

  static DateTime _dayOf(DateTime value) =>
      DateTime(value.year, value.month, value.day);

  List<BookingHistoryEntry> _seedHistory() {
    final now = DateTime.now();
    BookingHistoryEntry past(
      int daysAgo,
      int hour,
      String name,
      String coach, {
      String status = "completed",
    }) {
      final day = now.subtract(Duration(days: daysAgo));
      return BookingHistoryEntry(
        id: "history-$daysAgo-$hour",
        className: name,
        startsAt: DateTime(day.year, day.month, day.day, hour),
        status: status,
        coachName: coach,
      );
    }

    return [
      past(1, 6, "Sunrise Flow", "Elena Rostova"),
      past(2, 18, "Power Hour", "Marcus Vance"),
      past(3, 6, "Sunrise Flow", "Elena Rostova"),
      past(5, 19, "Olympic Weightlifting", "Marcus Vance"),
      past(6, 9, "Reformer Pilates", "Nina Patel"),
      past(8, 18, "Power Hour", "Marcus Vance", status: "cancelled"),
      past(9, 6, "Sunrise Flow", "Elena Rostova"),
      past(12, 19, "Conditioning Circuit", "Dre Coleman"),
    ];
  }

  ClassBooking bookSession(String sessionId, {bool notify = true}) {
    final index = sessions.indexWhere((session) => session.id == sessionId);
    if (index < 0) {
      throw StateError("Class not found");
    }
    var session = sessions[index];
    if (session.bookedByMe) {
      throw StateError("You're already booked for this class.");
    }
    if (session.isCancelled) {
      throw StateError("This class was cancelled.");
    }
    if (session.isFull) {
      throw StateError("This class is full. Join the waitlist instead.");
    }
    session = session.copyWith(
      bookedCount: session.bookedCount + 1,
      bookedByMe: true,
      waitlistedByMe: false,
      waitlistCount: session.waitlistedByMe
          ? (session.waitlistCount - 1).clamp(0, 999)
          : session.waitlistCount,
    );
    sessions[index] = session;
    _bookingSeq += 1;
    final booking = UpcomingBooking(
      bookingId: "booking-$_bookingSeq",
      sessionId: session.id,
      className: session.name,
      description: session.description,
      startsAt: session.startsAt,
      endsAt: session.endsAt,
      bookingStatus: "confirmed",
      sessionStatus: session.status,
      locationId: session.locationId,
      locationName: session.locationName,
      coachUserId: session.coachUserId,
      coachName: session.coachName,
    );
    bookings.add(booking);
    history.add(
      BookingHistoryEntry(
        id: booking.bookingId,
        className: session.name,
        startsAt: session.startsAt,
        status: "confirmed",
        coachName: session.coachName,
      ),
    );
    if (notify) notifyListeners();
    return ClassBooking(
      id: booking.bookingId,
      sessionId: session.id,
      status: "confirmed",
    );
  }

  ClassBooking cancelBooking(String bookingId) {
    final bookingIndex = bookings.indexWhere(
      (item) => item.bookingId == bookingId,
    );
    if (bookingIndex < 0) {
      throw StateError("Booking not found");
    }
    final booking = bookings.removeAt(bookingIndex);
    final historyIndex = history.indexWhere(
      (item) => item.id == booking.bookingId,
    );
    if (historyIndex >= 0) {
      final entry = history[historyIndex];
      history[historyIndex] = BookingHistoryEntry(
        id: entry.id,
        className: entry.className,
        startsAt: entry.startsAt,
        status: "cancelled",
        coachName: entry.coachName,
      );
    }
    final sessionIndex = sessions.indexWhere(
      (session) => session.id == booking.sessionId,
    );
    if (sessionIndex >= 0) {
      final session = sessions[sessionIndex];
      sessions[sessionIndex] = session.copyWith(
        bookedCount: (session.bookedCount - 1).clamp(0, session.capacity),
        bookedByMe: false,
      );
    }
    notifyListeners();
    return ClassBooking(
      id: booking.bookingId,
      sessionId: booking.sessionId,
      status: "cancelled",
    );
  }

  WaitlistStatus joinWaitlist(String sessionId) {
    final index = sessions.indexWhere((session) => session.id == sessionId);
    if (index < 0) throw StateError("Class not found");
    final session = sessions[index];
    if (!session.isFull && !session.waitlistedByMe) {
      throw StateError("This class still has open spots.");
    }
    sessions[index] = session.copyWith(
      waitlistedByMe: true,
      waitlistCount: session.waitlistedByMe
          ? session.waitlistCount
          : session.waitlistCount + 1,
    );
    notifyListeners();
    return WaitlistStatus(
      sessionId: sessionId,
      userId: memberId,
      status: "waiting",
      position: sessions[index].waitlistCount,
    );
  }

  void leaveWaitlist(String sessionId) {
    final index = sessions.indexWhere((session) => session.id == sessionId);
    if (index < 0) return;
    final session = sessions[index];
    sessions[index] = session.copyWith(
      waitlistedByMe: false,
      waitlistCount: session.waitlistedByMe
          ? (session.waitlistCount - 1).clamp(0, 999)
          : session.waitlistCount,
    );
    notifyListeners();
  }

  UserProfile updateProfile(UpdateProfileRequest request) {
    final current = profile.member ?? const MemberProfileData();
    profile = UserProfile(
      userId: profile.userId,
      roles: profile.roles,
      member: MemberProfileData(
        displayName: request.displayName ?? current.displayName,
        phone: request.phone ?? current.phone,
        avatarUrl: current.avatarUrl,
        emergencyContact: request.emergencyContact ?? current.emergencyContact,
      ),
    );
    notifyListeners();
    return profile;
  }

  UserProfile uploadAvatar(String filePath) {
    final current = profile.member ?? const MemberProfileData();
    profile = UserProfile(
      userId: profile.userId,
      roles: profile.roles,
      member: MemberProfileData(
        displayName: current.displayName,
        phone: current.phone,
        avatarUrl: filePath,
        emergencyContact: current.emergencyContact,
      ),
    );
    notifyListeners();
    return profile;
  }

  CheckInQr checkInQr() {
    final expires = DateTime.now().add(const Duration(seconds: 45));
    final token = "demo-${expires.millisecondsSinceEpoch}";
    return CheckInQr(
      token: token,
      qrPayload: "gravity://check-in?member=$memberId&token=$token",
      expiresAt: expires,
    );
  }

  int get unreadCount => notifications.where((item) => !item.read).length;

  void markNotificationRead(String id) {
    notifications = [
      for (final item in notifications)
        if (item.id == id) item.copyWith(read: true) else item,
    ];
    notifyListeners();
  }

  void markAllNotificationsRead() {
    notifications = [
      for (final item in notifications) item.copyWith(read: true),
    ];
    notifyListeners();
  }

  NotificationPreferences updatePreferences(NotificationPreferences next) {
    preferences = next;
    notifyListeners();
    return preferences;
  }

  ChatMessage sendMessage({required String groupId, required String body}) {
    _messageSeq += 1;
    final message = ChatMessage(
      id: "mine-$_messageSeq",
      groupId: groupId,
      senderId: memberId,
      senderName: profile.member?.displayName ?? "Alex Rivera",
      body: body,
      createdAt: DateTime.now(),
      mine: true,
    );
    messagesByGroup[groupId] = [
      ...(messagesByGroup[groupId] ?? const []),
      message,
    ];
    notifyListeners();
    return message;
  }

  List<ClassSession> _seedSessions() {
    final today = DateTime.now();
    final start = DateTime(today.year, today.month, today.day);
    const templates = <_DemoClass>[
      _DemoClass(
        name: "Peak Pilates Flow",
        description: "Controlled reformer work for core strength and mobility.",
        hour: 7,
        minute: 0,
        minutes: 60,
        coach: "Sarah T.",
        locationId: "loc-1",
        locationName: "Peak Studio 1",
        capacity: 12,
        booked: 9,
      ),
      _DemoClass(
        name: "Olympic Weightlifting",
        description:
            "Snatch and clean & jerk technique with coached progressions.",
        hour: 9,
        minute: 0,
        minutes: 60,
        coach: "Marcus Vance",
        locationId: "loc-2",
        locationName: "Downtown Studio A",
        capacity: 8,
        booked: 8,
        waitlist: 3,
      ),
      _DemoClass(
        name: "Kettlebell Conditioning",
        description:
            "Swings, cleans, and carries built into a metabolic circuit.",
        hour: 12,
        minute: 0,
        minutes: 45,
        coach: "Dave K.",
        locationId: "loc-1",
        locationName: "Peak Studio 1",
        capacity: 16,
        booked: 11,
      ),
      _DemoClass(
        name: "Power Hour: Strength & Conditioning",
        description: "Full-body strength work with a conditioning finisher.",
        hour: 18,
        minute: 0,
        minutes: 60,
        coach: "Marcus Vance",
        locationId: "loc-1",
        locationName: "Peak Studio 1",
        capacity: 20,
        booked: 14,
      ),
      _DemoClass(
        name: "Evening Yoga",
        description: "Wind-down flow with long holds and guided breathing.",
        hour: 19,
        minute: 30,
        minutes: 60,
        coach: "Elena Rostova",
        locationId: "loc-2",
        locationName: "Downtown Studio A",
        capacity: 18,
        booked: 6,
      ),
    ];

    final seeded = <ClassSession>[];
    for (var day = 0; day < 7; day++) {
      final date = start.add(Duration(days: day));
      for (var i = 0; i < templates.length; i++) {
        final template = templates[i];
        var booked = template.booked;
        if (day == 2 && i == 1) booked = template.capacity;
        if (day == 5 && i == 3) booked = 18;
        final starts = DateTime(
          date.year,
          date.month,
          date.day,
          template.hour,
          template.minute,
        );
        seeded.add(
          ClassSession(
            id: "session-$day-$i",
            name: template.name,
            description: template.description,
            startsAt: starts,
            endsAt: starts.add(Duration(minutes: template.minutes)),
            capacity: template.capacity,
            bookedCount: booked,
            status: day == 6 && i == 4 ? "cancelled" : "scheduled",
            bookedByMe: false,
            waitlistCount: booked >= template.capacity ? template.waitlist : 0,
            coachName: template.coach,
            locationId: template.locationId,
            locationName: template.locationName,
          ),
        );
      }
    }
    return seeded;
  }
}

class _DemoClass {
  const _DemoClass({
    required this.name,
    required this.description,
    required this.hour,
    required this.minute,
    required this.minutes,
    required this.coach,
    required this.locationId,
    required this.locationName,
    required this.capacity,
    required this.booked,
    this.waitlist = 0,
  });

  final String name;
  final String description;
  final int hour;
  final int minute;
  final int minutes;
  final String coach;
  final String locationId;
  final String locationName;
  final int capacity;
  final int booked;
  final int waitlist;
}
