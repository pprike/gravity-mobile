import "package:flutter_riverpod/flutter_riverpod.dart";

import "../../core/api/api_client.dart";
import "../../core/auth/auth_repository.dart";
import "../../core/auth/auth_session.dart";
import "../../core/auth/auth_storage.dart";
import "../../core/config/app_config.dart";
import "../../features/profile/profile_repository.dart";

final appConfigProvider = Provider<AppConfig>((ref) {
  return AppConfig.fromEnvironment();
});

final authStorageProvider = Provider<AuthStorage>((ref) {
  return AuthStorage();
});

final apiClientProvider = Provider<ApiClient>((ref) {
  return ApiClient(
    config: ref.watch(appConfigProvider),
    authStorage: ref.watch(authStorageProvider),
  );
});

final authRepositoryProvider = Provider<AuthRepository>((ref) {
  return AuthRepository(
    apiClient: ref.watch(apiClientProvider),
    authStorage: ref.watch(authStorageProvider),
  );
});

final profileRepositoryProvider = Provider<ProfileRepository>((ref) {
  return ProfileRepository(ref.watch(apiClientProvider));
});

final authSessionProvider = FutureProvider<AuthSession?>((ref) {
  return ref.watch(authRepositoryProvider).currentSession();
});
