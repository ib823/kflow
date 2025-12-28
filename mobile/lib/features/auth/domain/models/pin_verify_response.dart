import 'package:freezed_annotation/freezed_annotation.dart';

part 'pin_verify_response.freezed.dart';
part 'pin_verify_response.g.dart';

/// PIN verification response from POST /api/v1/auth/pin/verify
@freezed
class PinVerifyResponse with _$PinVerifyResponse {
  const factory PinVerifyResponse({
    required bool success,
    /// Remaining attempts before lockout (5 max, then 15-min lockout)
    int? remainingAttempts,
    /// Lockout end time if account is locked
    DateTime? lockoutUntil,
    /// Short-lived verification token for sensitive operations
    String? verificationToken,
  }) = _PinVerifyResponse;

  factory PinVerifyResponse.fromJson(Map<String, dynamic> json) =>
      _$PinVerifyResponseFromJson(json);
}

/// Lockout status for PIN attempts
@freezed
class LockoutStatus with _$LockoutStatus {
  const factory LockoutStatus({
    required bool isLocked,
    DateTime? lockoutUntil,
    required int remainingAttempts,
  }) = _LockoutStatus;

  factory LockoutStatus.fromJson(Map<String, dynamic> json) =>
      _$LockoutStatusFromJson(json);
}
