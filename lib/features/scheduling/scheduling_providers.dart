import "package:flutter_riverpod/flutter_riverpod.dart";

import "../../core/providers/app_providers.dart";
import "models/scheduling_models.dart";
import "scheduling_repository.dart";

final schedulingRepositoryProvider = Provider<SchedulingRepository>((ref) {
  return SchedulingRepository(
    ref.watch(apiClientProvider),
    demoCatalog: ref.watch(demoCatalogProvider),
    demoMode: ref.watch(isDemoModeProvider),
  );
});

final scheduleDayProvider = StateProvider<DateTime>((ref) {
  final now = DateTime.now();
  return DateTime(now.year, now.month, now.day);
});

final scheduleLocationIdProvider = StateProvider<String?>((ref) => null);

final studioLocationsProvider =
    FutureProvider.autoDispose<List<StudioLocation>>((ref) async {
      ref.watch(demoCatalogProvider);
      try {
        return await ref.watch(schedulingRepositoryProvider).listLocations();
      } catch (_) {
        return const [];
      }
    });

final classSessionsProvider = FutureProvider.autoDispose<List<ClassSession>>((
  ref,
) async {
  ref.watch(demoCatalogProvider);
  final selectedDay = ref.watch(scheduleDayProvider);
  final locationId = ref.watch(scheduleLocationIdProvider);
  final repository = ref.watch(schedulingRepositoryProvider);
  final start = DateTime(selectedDay.year, selectedDay.month, selectedDay.day);
  final end = start.add(const Duration(days: 1));
  return repository.listSessions(from: start, to: end, locationId: locationId);
});

final upcomingBookingsProvider =
    FutureProvider.autoDispose<List<UpcomingBooking>>((ref) {
      ref.watch(demoCatalogProvider);
      return ref.watch(schedulingRepositoryProvider).listUpcomingBookings();
    });

final weekSessionsProvider = FutureProvider.autoDispose<List<ClassSession>>((
  ref,
) {
  ref.watch(demoCatalogProvider);
  final now = DateTime.now();
  final start = DateTime(now.year, now.month, now.day);
  return ref
      .watch(schedulingRepositoryProvider)
      .listSessions(from: start, to: start.add(const Duration(days: 7)));
});
