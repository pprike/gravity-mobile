import "package:flutter_riverpod/flutter_riverpod.dart";

/// Where a tapped push should land the member.
enum PushDestination { inbox, bookings, schedule, community }

/// A push the member tapped, waiting for the shell to navigate.
class PushOpenIntent {
  const PushOpenIntent({required this.destination, this.resourceId});

  final PushDestination destination;
  final String? resourceId;

  /// Maps the backend's FCM data payload (`type`, `resourceType`, `resourceId`).
  static PushOpenIntent? fromData(Map<String, dynamic> data) {
    final resourceId = data["resourceId"] as String?;
    switch (data["type"]) {
      case "class_message":
        return PushOpenIntent(
          destination: PushDestination.community,
          resourceId: resourceId,
        );
      case "announcement":
        return PushOpenIntent(
          destination: PushDestination.community,
          resourceId: resourceId,
        );
      case "booking":
        return const PushOpenIntent(destination: PushDestination.bookings);
      case "schedule":
        return const PushOpenIntent(destination: PushDestination.schedule);
      case null:
        return null;
      default:
        return const PushOpenIntent(destination: PushDestination.inbox);
    }
  }
}

/// Set when a push is tapped; the shell consumes it and resets to `null`.
final pushOpenIntentProvider = StateProvider<PushOpenIntent?>((ref) => null);

/// Title/body of a push that arrived while the app was in the foreground.
class ForegroundPush {
  const ForegroundPush({required this.title, required this.body, this.intent});

  final String title;
  final String body;
  final PushOpenIntent? intent;
}

final foregroundPushProvider = StateProvider<ForegroundPush?>((ref) => null);
