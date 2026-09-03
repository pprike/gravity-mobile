/// Short "how long ago" label, e.g. "just now", "12m", "3d".
String relativeTimeLabel(DateTime timestamp, {DateTime? now}) {
  final elapsed = (now ?? DateTime.now()).difference(timestamp);
  if (elapsed.isNegative || elapsed.inMinutes < 1) return "just now";
  if (elapsed.inMinutes < 60) return "${elapsed.inMinutes}m";
  if (elapsed.inHours < 24) return "${elapsed.inHours}h";
  if (elapsed.inDays < 7) return "${elapsed.inDays}d";
  if (elapsed.inDays < 365) return "${elapsed.inDays ~/ 7}w";
  return "${elapsed.inDays ~/ 365}y";
}
