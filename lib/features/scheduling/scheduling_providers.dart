import "package:flutter_riverpod/flutter_riverpod.dart";

import "../../core/providers/app_providers.dart";
import "models/scheduling_models.dart";
import "scheduling_repository.dart";

final schedulingRepositoryProvider = Provider<SchedulingRepository>((ref) {
  return SchedulingRepository(ref.watch(apiClientProvider));
});

final scheduleDayProvider = StateProvider<DateTime>((ref) {
  final now = DateTime.now();
  return DateTime(now.year, now.month, now.day);
});

final classSessionsProvider =
    FutureProvider.autoDispose<List<ClassSession>>((ref) async {
  final selectedDay = ref.watch(scheduleDayProvider);
  final repository = ref.watch(schedulingRepositoryProvider);
  final start = DateTime(
    selectedDay.year,
    selectedDay.month,
    selectedDay.day,
  );
  final end = start.add(const Duration(days: 1));
  return repository.listSessions(from: start, to: end);
});

final upcomingBookingsProvider =
    FutureProvider.autoDispose<List<UpcomingBooking>>((ref) {
  return ref.watch(schedulingRepositoryProvider).listUpcomingBookings();
});
