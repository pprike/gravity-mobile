import "api_exception.dart";

/// Human-readable copy for anything we surface to a member.
///
/// Raw `toString()` output leaks Dio/stack details, so every user-facing error
/// path goes through here.
String friendlyErrorMessage(
  Object? error, {
  String fallback = "Something went wrong. Please try again.",
}) {
  if (error is ApiException) {
    if (error.code == "NETWORK_ERROR") {
      return "Can’t reach your studio right now. Check your connection and try again.";
    }
    if (error.code == "INVALID_RESPONSE" || error.code == "EMPTY_RESPONSE") {
      return fallback;
    }

    final status = error.statusCode;
    if (status == 401) return "Your session expired. Please sign in again.";
    if (status == 403) {
      return "Your studio hasn’t enabled this for members yet.";
    }
    if (status == 404) return "That’s no longer available.";
    if (status == 429) {
      return "Too many attempts. Please wait a moment and try again.";
    }
    if (status != null && status >= 500) {
      return "Your studio’s system is having trouble. Please try again shortly.";
    }

    final message = error.message.trim();
    if (message.isNotEmpty) return message;
  }

  return fallback;
}
