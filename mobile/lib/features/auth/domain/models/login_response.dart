import 'package:freezed_annotation/freezed_annotation.dart';
import 'employee.dart';

part 'login_response.freezed.dart';
part 'login_response.g.dart';

/// Login response from POST /api/v1/auth/login
@freezed
class LoginResponse with _$LoginResponse {
  const factory LoginResponse({
    required String accessToken,
    required String refreshToken,
    /// Access token expiry in seconds (default: 86400 = 24 hours)
    required int expiresIn,
    required Employee employee,
    /// Indicates if PIN setup is required (first login)
    required bool requiresPinSetup,
  }) = _LoginResponse;

  factory LoginResponse.fromJson(Map<String, dynamic> json) =>
      _$LoginResponseFromJson(json);
}

/// Refresh token response from POST /api/v1/auth/refresh
@freezed
class RefreshTokenResponse with _$RefreshTokenResponse {
  const factory RefreshTokenResponse({
    required String accessToken,
    required int expiresIn,
  }) = _RefreshTokenResponse;

  factory RefreshTokenResponse.fromJson(Map<String, dynamic> json) =>
      _$RefreshTokenResponseFromJson(json);
}
