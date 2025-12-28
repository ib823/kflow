import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../core/network/dio_client.dart';
import '../domain/models/profile.dart';

part 'profile_api.g.dart';

/// Profile API client.
class ProfileApi {
  final Dio _dio;

  ProfileApi(this._dio);

  /// GET /api/v1/profile
  Future<Profile> getProfile() async {
    final response = await _dio.get('/api/v1/profile');
    return Profile.fromJson(response.data['data']);
  }

  /// PATCH /api/v1/profile
  Future<Profile> updateProfile(ProfileUpdateRequest request) async {
    final data = <String, dynamic>{};
    if (request.phone != null) data['phone'] = request.phone;
    if (request.emergencyContactName != null) {
      data['emergency_contact_name'] = request.emergencyContactName;
    }
    if (request.emergencyContactPhone != null) {
      data['emergency_contact_phone'] = request.emergencyContactPhone;
    }
    if (request.personalEmail != null) data['personal_email'] = request.personalEmail;
    if (request.address != null) data['address'] = request.address;

    final response = await _dio.patch('/api/v1/profile', data: data);
    return Profile.fromJson(response.data['data']);
  }

  /// POST /api/v1/profile/photo
  Future<String> uploadProfilePhoto(Uint8List photoBytes, String filename) async {
    final formData = FormData.fromMap({
      'photo': MultipartFile.fromBytes(photoBytes, filename: filename),
    });
    final response = await _dio.post('/api/v1/profile/photo', data: formData);
    return response.data['data']['photo_url'];
  }
}

@riverpod
ProfileApi profileApi(ProfileApiRef ref) {
  final dio = ref.watch(dioClientProvider);
  return ProfileApi(dio);
}
