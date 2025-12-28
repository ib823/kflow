import 'package:freezed_annotation/freezed_annotation.dart';

part 'profile.freezed.dart';
part 'profile.g.dart';

/// Employee profile from GET /api/v1/profile
@freezed
class Profile with _$Profile {
  const factory Profile({
    required int id,
    required String employeeNumber,
    required String fullName,
    required String email,
    String? phone,
    String? photoUrl,
    required String jobTitle,
    required String department,
    String? location,
    required String countryCode,
    required DateTime hireDate,
    String? managerName,
    required String employmentType,
    required String employmentStatus,
    // Editable fields
    String? emergencyContactName,
    String? emergencyContactPhone,
    String? personalEmail,
    String? address,
  }) = _Profile;

  factory Profile.fromJson(Map<String, dynamic> json) =>
      _$ProfileFromJson(json);
}

/// Profile update request for PATCH /api/v1/profile
@freezed
class ProfileUpdateRequest with _$ProfileUpdateRequest {
  const factory ProfileUpdateRequest({
    String? phone,
    String? emergencyContactName,
    String? emergencyContactPhone,
    String? personalEmail,
    String? address,
  }) = _ProfileUpdateRequest;

  factory ProfileUpdateRequest.fromJson(Map<String, dynamic> json) =>
      _$ProfileUpdateRequestFromJson(json);
}
