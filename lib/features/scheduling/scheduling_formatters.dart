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

  static String popularClassMeta(DateTime startsAt, Duration duration) {
    final today = DateTime.now();
    final startDay = DateTime(startsAt.year, startsAt.month, startsAt.day);
    final todayDay = DateTime(today.year, today.month, today.day);
    final dayLabel = startDay == todayDay
        ? "Today"
        : startDay == todayDay.add(const Duration(days: 1))
        ? "Tomorrow"
        : weekdayShort(startsAt);
    return "$dayLabel • ${timeOfDay(startsAt)} • ${durationLabel(duration)}";
  }

  static String heroTimeLabel(DateTime startsAt) {
    final today = DateTime.now();
    final startDay = DateTime(startsAt.year, startsAt.month, startsAt.day);
    final todayDay = DateTime(today.year, today.month, today.day);
    final dayLabel = startDay == todayDay
        ? "Today"
        : startDay == todayDay.add(const Duration(days: 1))
        ? "Tomorrow"
        : "${weekdayShort(startsAt)} ${startsAt.day}";
    return "${timeOfDay(startsAt)} $dayLabel";
  }

  static String greeting(DateTime date) {
    final hour = date.hour;
    if (hour < 12) return "Good morning";
    if (hour < 17) return "Good afternoon";
    return "Good evening";
  }

  static String longDateLabel(DateTime date) {
    return "${_weekdays[date.weekday - 1]}, ${date.day} ${_months[date.month - 1]}";
  }

  static String shortDate(DateTime date) {
    return "${weekdayShort(date)} ${date.day} ${_months[date.month - 1].substring(0, 3)}";
  }

  static String bookingDateLabel(DateTime date) {
    final today = DateTime.now();
    final startDay = DateTime(date.year, date.month, date.day);
    final todayDay = DateTime(today.year, today.month, today.day);
    if (startDay == todayDay) return "Today";
    if (startDay == todayDay.add(const Duration(days: 1))) return "Tomorrow";
    return "${weekdayShort(date)} ${date.day} ${_months[date.month - 1]}";
  }
}
