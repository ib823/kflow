import 'package:freezed_annotation/freezed_annotation.dart';

part 'user.freezed.dart';
part 'user.g.dart';

@freezed
class User with _$User {
  const factory User({
    required int id,
    required String email,
    required String role,
    required String status,
    @JsonKey(name: 'is_email_verified') @Default(false) bool isEmailVerified,
    @JsonKey(name: 'is_phone_verified') @Default(false) bool isPhoneVerified,
    @JsonKey(name: 'has_pin') @Default(false) bool hasPin,
    @JsonKey(name: 'force_password_change') @Default(false) bool forcePasswordChange,
    Employee? employee,
  }) = _User;

  factory User.fromJson(Map<String, dynamic> json) => _$UserFromJson(json);
}

@freezed
class Employee with _$Employee {
  const factory Employee({
    required int id,
    @JsonKey(name: 'employee_no') required String employeeNo,
    @JsonKey(name: 'full_name') required String fullName,
    @JsonKey(name: 'first_name') String? firstName,
    @JsonKey(name: 'last_name') String? lastName,
    String? email,
    String? phone,
    @JsonKey(name: 'photo_url') String? photoUrl,
    @JsonKey(name: 'department_name') String? departmentName,
    @JsonKey(name: 'job_title') String? jobTitle,
    @JsonKey(name: 'hire_date') String? hireDate,
    String? status,
    @JsonKey(name: 'years_of_service') int? yearsOfService,
  }) = _Employee;

  factory Employee.fromJson(Map<String, dynamic> json) => _$EmployeeFromJson(json);
}

@freezed
class AuthTokens with _$AuthTokens {
  const factory AuthTokens({
    @JsonKey(name: 'access_token') required String accessToken,
    @JsonKey(name: 'refresh_token') required String refreshToken,
    @JsonKey(name: 'expires_in') required int expiresIn,
    @JsonKey(name: 'token_type') @Default('Bearer') String tokenType,
  }) = _AuthTokens;

  factory AuthTokens.fromJson(Map<String, dynamic> json) =>
      _$AuthTokensFromJson(json);
}

@freezed
class LoginResponse with _$LoginResponse {
  const factory LoginResponse({
    required User user,
    required AuthTokens tokens,
  }) = _LoginResponse;

  factory LoginResponse.fromJson(Map<String, dynamic> json) =>
      _$LoginResponseFromJson(json);
}
