import "package:flutter_riverpod/flutter_riverpod.dart";

import "../../core/providers/app_providers.dart";
import "models/user_profile.dart";
import "profile_repository.dart";

final profileProvider =
    FutureProvider.autoDispose.family<UserProfile, String>((ref, userId) {
  return ref.watch(profileRepositoryProvider).getProfile(userId);
});

final profileControllerProvider = StateNotifierProvider.autoDispose
    .family<ProfileController, AsyncValue<UserProfile?>, String>((ref, userId) {
  return ProfileController(
    repository: ref.watch(profileRepositoryProvider),
    userId: userId,
  );
});

class ProfileController extends StateNotifier<AsyncValue<UserProfile?>> {
  ProfileController({
    required ProfileRepository repository,
    required String userId,
  })  : _repository = repository,
        _userId = userId,
        super(const AsyncValue.loading()) {
    load();
  }

  final ProfileRepository _repository;
  final String _userId;

  Future<void> load() async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() => _repository.getProfile(_userId));
  }

  Future<void> save(UpdateProfileRequest request) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(
      () => _repository.updateProfile(_userId, request),
    );
  }

  Future<void> uploadAvatar(String filePath) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(
      () => _repository.uploadAvatar(_userId, filePath),
    );
  }
}
