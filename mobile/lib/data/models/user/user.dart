import 'package:freezed_annotation/freezed_annotation.dart';

part 'user.freezed.dart';
part 'user.g.dart';

/// User role enumeration
enum UserRole {
  @JsonValue('employee')
  employee,
  @JsonValue('supervisor')
  supervisor,
  @JsonValue('hr')
  hr,
  @JsonValue('admin')
  admin,
}

/// User profile model
@freezed
class User with _$User {
  const factory User({
    required String id,
    required String employeeId,
    required String name,
    required String email,
    String? phone,
    String? avatarUrl,
    required String department,
    required String position,
    required DateTime joinDate,
    @Default(UserRole.employee) UserRole role,
    @Default(false) bool isSupervisor,
  }) = _User;

  factory User.fromJson(Map<String, dynamic> json) => _$UserFromJson(json);
}

/// User settings model
@freezed
class UserSettings with _$UserSettings {
  const factory UserSettings({
    @Default('en') String languageCode,
    @Default('system') String themeMode,
    @Default(true) bool biometricsEnabled,
    @Default(true) bool notificationsEnabled,
    @Default(true) bool autoLockEnabled,
    @Default(5) int autoLockMinutes,
  }) = _UserSettings;

  factory UserSettings.fromJson(Map<String, dynamic> json) =>
      _$UserSettingsFromJson(json);
}
