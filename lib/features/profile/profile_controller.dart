import "package:flutter_riverpod/flutter_riverpod.dart";

import "../../core/providers/app_providers.dart";
import "models/member_subscription.dart";
import "models/user_profile.dart";
import "profile_repository.dart";

final profileProvider = FutureProvider.autoDispose.family<UserProfile, String>((
  ref,
  userId,
) {
  ref.watch(demoCatalogProvider);
  return ref.watch(profileRepositoryProvider).getProfile(userId);
});

final memberSubscriptionProvider = FutureProvider.autoDispose
    .family<MemberSubscription?, String>((ref, userId) {
      ref.watch(demoCatalogProvider);
      return ref.watch(profileRepositoryProvider).getSubscription(userId);
    });

final profileControllerProvider = StateNotifierProvider.autoDispose
    .family<ProfileController, AsyncValue<UserProfile?>, String>((ref, userId) {
      return ProfileController(
        repository: ref.watch(profileRepositoryProvider),
        userId: userId,
      );
    });

class ProfileController extends StateNotifier<AsyncValue<UserProfile?>> {
  ProfileController({required this._repository, required this._userId})
    : super(const AsyncValue.loading()) {
    load();
  }

  final ProfileRepository _repository;
  final String _userId;

  Future<void> load() async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() => _repository.getProfile(_userId));
  }

  Future<void> save(UpdateProfileRequest request) async {
    final next = await _repository.updateProfile(_userId, request);
    state = AsyncValue.data(next);
  }

  Future<void> uploadAvatar(String filePath) async {
    final next = await _repository.uploadAvatar(_userId, filePath);
    state = AsyncValue.data(next);
  }

  Future<void> deleteAccount() => _repository.deleteAccount();
}
