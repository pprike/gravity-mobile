class ClassSession {
  const ClassSession({
    required this.id,
    required this.name,
    this.description,
    required this.startsAt,
    required this.endsAt,
    required this.capacity,
    required this.bookedCount,
    required this.status,
    required this.bookedByMe,
    this.waitlistedByMe = false,
    this.waitlistCount = 0,
    this.coachUserId,
    this.coachName,
    this.locationId,
    this.locationName,
  });

  final String id;
  final String name;
  final String? description;
  final DateTime startsAt;
  final DateTime endsAt;
  final int capacity;
  final int bookedCount;
  final String status;
  final bool bookedByMe;
  final bool waitlistedByMe;
  final int waitlistCount;
  final String? coachUserId;
  final String? coachName;
  final String? locationId;
  final String? locationName;

  int get spotsLeft => (capacity - bookedCount).clamp(0, capacity);

  bool get isFull => bookedCount >= capacity;

  bool get isCancelled => status.toLowerCase() == "cancelled";

  Duration get duration => endsAt.difference(startsAt);

  String get coachLabel =>
      coachName == null || coachName!.isEmpty ? "Studio class" : coachName!;

  String get locationLabel =>
      locationName == null || locationName!.isEmpty ? "Studio" : locationName!;

  ClassSession copyWith({
    int? bookedCount,
    bool? bookedByMe,
    bool? waitlistedByMe,
    int? waitlistCount,
    String? status,
  }) {
    return ClassSession(
      id: id,
      name: name,
      description: description,
      startsAt: startsAt,
      endsAt: endsAt,
      capacity: capacity,
      bookedCount: bookedCount ?? this.bookedCount,
      status: status ?? this.status,
      bookedByMe: bookedByMe ?? this.bookedByMe,
      waitlistedByMe: waitlistedByMe ?? this.waitlistedByMe,
      waitlistCount: waitlistCount ?? this.waitlistCount,
      coachUserId: coachUserId,
      coachName: coachName,
      locationId: locationId,
      locationName: locationName,
    );
  }

  factory ClassSession.fromJson(Map<String, dynamic> json) {
    return ClassSession(
      id: json["id"] as String,
      name: json["name"] as String,
      description: json["description"] as String?,
      startsAt: DateTime.parse(json["startsAt"] as String).toLocal(),
      endsAt: DateTime.parse(json["endsAt"] as String).toLocal(),
      capacity: json["capacity"] as int,
      bookedCount: json["bookedCount"] as int,
      status: json["status"] as String,
      bookedByMe: json["bookedByMe"] as bool? ?? false,
      waitlistedByMe: json["waitlistedByMe"] as bool? ?? false,
      waitlistCount: json["waitlistCount"] as int? ?? 0,
      coachUserId: json["coachUserId"] as String?,
      coachName: json["coachName"] as String?,
      locationId: json["locationId"] as String?,
      locationName: json["locationName"] as String?,
    );
  }
}

class ClassBooking {
  const ClassBooking({
    required this.id,
    required this.sessionId,
    required this.status,
  });

  final String id;
  final String sessionId;
  final String status;

  factory ClassBooking.fromJson(Map<String, dynamic> json) {
    return ClassBooking(
      id: json["id"] as String,
      sessionId: json["sessionId"] as String,
      status: json["status"] as String,
    );
  }
}

class UpcomingBooking {
  const UpcomingBooking({
    required this.bookingId,
    required this.sessionId,
    required this.className,
    this.description,
    required this.startsAt,
    required this.endsAt,
    required this.bookingStatus,
    required this.sessionStatus,
    this.locationId,
    this.locationName,
    this.coachUserId,
    this.coachName,
  });

  final String bookingId;
  final String sessionId;
  final String className;
  final String? description;
  final DateTime startsAt;
  final DateTime endsAt;
  final String bookingStatus;
  final String sessionStatus;
  final String? locationId;
  final String? locationName;
  final String? coachUserId;
  final String? coachName;

  Duration get duration => endsAt.difference(startsAt);

  bool get isCancelledSession => sessionStatus.toLowerCase() == "cancelled";

  factory UpcomingBooking.fromJson(Map<String, dynamic> json) {
    return UpcomingBooking(
      bookingId: json["bookingId"] as String,
      sessionId: json["sessionId"] as String,
      className: json["className"] as String,
      description: json["description"] as String?,
      startsAt: DateTime.parse(json["startsAt"] as String).toLocal(),
      endsAt: DateTime.parse(json["endsAt"] as String).toLocal(),
      bookingStatus: json["bookingStatus"] as String,
      sessionStatus: json["sessionStatus"] as String,
      locationId: json["locationId"] as String?,
      locationName: json["locationName"] as String?,
      coachUserId: json["coachUserId"] as String?,
      coachName: json["coachName"] as String?,
    );
  }
}

class WaitlistStatus {
  const WaitlistStatus({
    required this.sessionId,
    required this.userId,
    required this.status,
    required this.position,
  });

  final String sessionId;
  final String userId;
  final String status;
  final int position;

  factory WaitlistStatus.fromJson(Map<String, dynamic> json) {
    return WaitlistStatus(
      sessionId: json["sessionId"] as String,
      userId: json["userId"] as String,
      status: json["status"] as String,
      position: json["position"] as int? ?? 0,
    );
  }
}

class StudioLocation {
  const StudioLocation({required this.id, required this.name});

  final String id;
  final String name;

  factory StudioLocation.fromJson(Map<String, dynamic> json) {
    return StudioLocation(
      id: json["id"] as String,
      name: json["name"] as String,
    );
  }
}
