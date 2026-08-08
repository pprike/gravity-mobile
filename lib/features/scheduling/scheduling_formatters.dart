class SchedulingFormatters {
  static const _weekdays = ["Mon", "Tue", "Wed", "Thu", "Fri", "Sat", "Sun"];
  static const _months = [
    "January",
    "February",
    "March",
    "April",
    "May",
    "June",
    "July",
    "August",
    "September",
    "October",
    "November",
    "December",
  ];

  static String weekdayShort(DateTime date) => _weekdays[date.weekday - 1];

  static String dayNumber(DateTime date) => "${date.day}";

  static String timeOfDay(DateTime date) {
    final hour = date.hour % 12 == 0 ? 12 : date.hour % 12;
    final minute = date.minute.toString().padLeft(2, "0");
    final period = date.hour >= 12 ? "PM" : "AM";
    return "$hour:$minute $period";
  }

  static String durationLabel(Duration duration) {
    final minutes = duration.inMinutes;
    if (minutes < 60) return "${minutes}m";
    final hours = minutes ~/ 60;
    final remainder = minutes % 60;
    if (remainder == 0) return "${hours}h";
    return "${hours}h ${remainder}m";
  }

  static String daySectionTitle(DateTime date) {
    final today = DateTime.now();
    final normalizedToday = DateTime(today.year, today.month, today.day);
    final normalizedDate = DateTime(date.year, date.month, date.day);
    if (normalizedDate == normalizedToday) {
      return "Today's Classes";
    }
    return "${_weekdays[date.weekday - 1]} ${date.day} ${_months[date.month - 1]}";
  }

  static String bookingDateLabel(DateTime date) {
    return "${weekdayShort(date)}, ${_months[date.month - 1]} ${date.day}";
  }
}
