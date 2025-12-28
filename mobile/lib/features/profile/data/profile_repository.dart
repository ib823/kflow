import 'dart:typed_data';

import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../domain/models/profile.dart';
import 'profile_api.dart';

part 'profile_repository.g.dart';

/// Repository for profile data.
class ProfileRepository {
  final ProfileApi _api;

  ProfileRepository(this._api);

  Future<Profile> getProfile() => _api.getProfile();

  Future<Profile> updateProfile(ProfileUpdateRequest request) =>
      _api.updateProfile(request);

  Future<String> uploadProfilePhoto(Uint8List photoBytes, String filename) =>
      _api.uploadProfilePhoto(photoBytes, filename);
}

@riverpod
ProfileRepository profileRepository(ProfileRepositoryRef ref) {
  return ProfileRepository(ref.watch(profileApiProvider));
}
