import "package:flutter_riverpod/flutter_riverpod.dart";

import "../../core/api/api_client.dart";
import "../../core/auth/auth_repository.dart";
import "../../core/auth/auth_session.dart";
import "../../core/auth/auth_storage.dart";
import "../../core/config/app_config.dart";
import "../../core/demo/demo_catalog.dart";
import "../../features/profile/profile_repository.dart";

final appConfigProvider = Provider<AppConfig>((ref) {
  return AppConfig.fromEnvironment();
});

final authStorageProvider = Provider<AuthStorage>((ref) {
  return AuthStorage();
});

final demoCatalogProvider = ChangeNotifierProvider<DemoCatalog>((ref) {
  return DemoCatalog();
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
    demoCatalog: ref.watch(demoCatalogProvider),
  );
});

final profileRepositoryProvider = Provider<ProfileRepository>((ref) {
  return ProfileRepository(
    ref.watch(apiClientProvider),
    demoCatalog: ref.watch(demoCatalogProvider),
    demoMode: ref.watch(isDemoModeProvider),
  );
});

final authSessionProvider =
    StateNotifierProvider<AuthSessionController, AsyncValue<AuthSession?>>((
      ref,
    ) {
      return AuthSessionController(ref.watch(authRepositoryProvider));
    });

final isDemoModeProvider = Provider<bool>((ref) {
  return ref.watch(authSessionProvider).valueOrNull?.isDemo ?? false;
});

class AuthSessionController extends StateNotifier<AsyncValue<AuthSession?>> {
  AuthSessionController(this._repository) : super(const AsyncValue.loading()) {
    restore();
  }

  final AuthRepository _repository;

  Future<void> restore() async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(_repository.currentSession);
  }

  Future<void> login(LoginRequest request) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() => _repository.login(request));
  }

  Future<void> loginDemo() async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(_repository.loginDemo);
  }

  Future<void> logout() async {
    await _repository.logout();
    state = const AsyncValue.data(null);
  }
}
