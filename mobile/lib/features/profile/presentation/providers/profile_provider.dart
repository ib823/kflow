import 'dart:typed_data';

import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../data/profile_repository.dart';
import '../../domain/models/profile.dart';

part 'profile_provider.g.dart';

@riverpod
class ProfileNotifier extends _$ProfileNotifier {
  @override
  Future<Profile> build() async {
    return ref.watch(profileRepositoryProvider).getProfile();
  }

  Future<void> refresh() async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(
      () => ref.read(profileRepositoryProvider).getProfile(),
    );
  }

  Future<bool> updateProfile(ProfileUpdateRequest request) async {
    try {
      final updated = await ref.read(profileRepositoryProvider).updateProfile(request);
      state = AsyncData(updated);
      return true;
    } catch (e) {
      return false;
    }
  }

  Future<bool> uploadPhoto(Uint8List photoBytes, String filename) async {
    try {
      final photoUrl = await ref.read(profileRepositoryProvider).uploadProfilePhoto(
        photoBytes,
        filename,
      );
      // Update state with new photo URL
      state.whenData((profile) {
        state = AsyncData(profile.copyWith(photoUrl: photoUrl));
      });
      return true;
    } catch (e) {
      return false;
    }
  }
}
