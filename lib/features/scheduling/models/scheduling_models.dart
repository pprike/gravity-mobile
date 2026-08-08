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
    this.coachUserId,
    this.locationId,
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
  final String? coachUserId;
  final String? locationId;

  int get spotsLeft => (capacity - bookedCount).clamp(0, capacity);

  bool get isFull => bookedCount >= capacity;

  Duration get duration => endsAt.difference(startsAt);

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
      coachUserId: json["coachUserId"] as String?,
      locationId: json["locationId"] as String?,
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
    this.coachUserId,
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
  final String? coachUserId;

  Duration get duration => endsAt.difference(startsAt);

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
      coachUserId: json["coachUserId"] as String?,
    );
  }
}
