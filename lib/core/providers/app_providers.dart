import "package:flutter_riverpod/flutter_riverpod.dart";

import "../../core/api/api_client.dart";
import "../../core/api/response_cache.dart";
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

/// Overridden in `main()` once the on-disk cache is open. Tests and the demo
/// flow can leave it unset, which simply disables offline replay.
final responseCacheProvider = Provider<ResponseCache?>((ref) => null);

final apiClientProvider = Provider<ApiClient>((ref) {
  return ApiClient(
    config: ref.watch(appConfigProvider),
    authStorage: ref.watch(authStorageProvider),
    responseCache: ref.watch(responseCacheProvider),
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
      return AuthSessionController(
        ref.watch(authRepositoryProvider),
        ref.watch(authStorageProvider),
        ref.watch(responseCacheProvider),
      );
    });

final isDemoModeProvider = Provider<bool>((ref) {
  return ref.watch(authSessionProvider).valueOrNull?.isDemo ?? false;
});

class AuthSessionController extends StateNotifier<AsyncValue<AuthSession?>> {
  AuthSessionController(this._repository, this._storage, this._responseCache)
    : super(const AsyncValue.loading()) {
    _storage.onSessionCleared = _handleExternalClear;
    restore();
  }

  final AuthRepository _repository;
  final AuthStorage _storage;
  final ResponseCache? _responseCache;

  void _handleExternalClear() {
    if (state.valueOrNull != null) {
      state = const AsyncValue.data(null);
    }
  }

  Future<void> restore() async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(_repository.currentSession);
  }

  Future<void> login(LoginRequest request) async {
    final previous = state.valueOrNull;
    try {
      state = const AsyncValue.loading();
      final session = await _repository.login(request);
      state = AsyncValue.data(session);
    } catch (error, stackTrace) {
      state = AsyncValue.data(previous);
      Error.throwWithStackTrace(error, stackTrace);
    }
  }

  Future<void> loginDemo() async {
    final previous = state.valueOrNull;
    try {
      state = const AsyncValue.loading();
      final session = await _repository.loginDemo();
      state = AsyncValue.data(session);
    } catch (error, stackTrace) {
      state = AsyncValue.data(previous);
      Error.throwWithStackTrace(error, stackTrace);
    }
  }

  Future<void> changePassword({
    required String currentPassword,
    required String newPassword,
  }) {
    return _repository.changePassword(
      currentPassword: currentPassword,
      newPassword: newPassword,
    );
  }

  Future<void> logout() async {
    await _repository.logout();
    // Cached responses belong to the member who just left the device.
    await _responseCache?.clear();
    state = const AsyncValue.data(null);
  }

  @override
  void dispose() {
    if (_storage.onSessionCleared == _handleExternalClear) {
      _storage.onSessionCleared = null;
    }
    super.dispose();
  }
}
