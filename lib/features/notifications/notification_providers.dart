import "package:flutter/foundation.dart";
import "package:flutter_riverpod/flutter_riverpod.dart";

import "../../core/providers/app_providers.dart";
import "models/notification_models.dart";
import "notification_repository.dart";

final notificationRepositoryProvider = Provider<NotificationRepository>((ref) {
  return NotificationRepository(
    ref.watch(apiClientProvider),
    demoCatalog: ref.watch(demoCatalogProvider),
    demoMode: ref.watch(isDemoModeProvider),
  );
});

final inboxProvider = FutureProvider.autoDispose<List<InboxNotification>>((
  ref,
) {
  ref.watch(demoCatalogProvider);
  return ref.watch(notificationRepositoryProvider).listInbox();
});

final unreadNotificationCountProvider = Provider<int>((ref) {
  return ref
      .watch(inboxProvider)
      .maybeWhen(
        data: (items) => items.where((item) => !item.read).length,
        orElse: () => 0,
      );
});

final notificationPreferencesProvider =
    FutureProvider.autoDispose<NotificationPreferences>((ref) {
      ref.watch(demoCatalogProvider);
      return ref.watch(notificationRepositoryProvider).getPreferences();
    });

String notificationPlatformLabel() {
  if (kIsWeb) return "WEB";
  return switch (defaultTargetPlatform) {
    TargetPlatform.iOS => "IOS",
    TargetPlatform.android => "ANDROID",
    _ => "WEB",
  };
}
