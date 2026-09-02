import "package:flutter_riverpod/flutter_riverpod.dart";

import "../../core/providers/app_providers.dart";
import "chat_repository.dart";
import "models/chat_models.dart";

final chatRepositoryProvider = Provider<ChatRepository>((ref) {
  return ChatRepository(
    ref.watch(apiClientProvider),
    demoCatalog: ref.watch(demoCatalogProvider),
    demoMode: ref.watch(isDemoModeProvider),
  );
});

final chatGroupsProvider = FutureProvider.autoDispose<List<ChatGroup>>((ref) {
  ref.watch(demoCatalogProvider);
  return ref.watch(chatRepositoryProvider).listGroups();
});

final chatMessagesProvider = FutureProvider.autoDispose
    .family<List<ChatMessage>, String>((ref, groupId) {
      ref.watch(demoCatalogProvider);
      return ref.watch(chatRepositoryProvider).listMessages(groupId);
    });
