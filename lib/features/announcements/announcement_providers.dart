import "package:flutter_riverpod/flutter_riverpod.dart";

import "../../core/providers/app_providers.dart";
import "announcement_repository.dart";
import "models/announcement.dart";

final announcementRepositoryProvider = Provider<AnnouncementRepository>((ref) {
  return AnnouncementRepository(
    ref.watch(apiClientProvider),
    demoCatalog: ref.watch(demoCatalogProvider),
    demoMode: ref.watch(isDemoModeProvider),
  );
});

final announcementsProvider = FutureProvider.autoDispose<List<Announcement>>((
  ref,
) {
  ref.watch(demoCatalogProvider);
  return ref.watch(announcementRepositoryProvider).listAnnouncements();
});
