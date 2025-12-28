import 'package:freezed_annotation/freezed_annotation.dart';

part 'pin_verify_request.freezed.dart';
part 'pin_verify_request.g.dart';

/// PIN verification request for POST /api/v1/auth/pin/verify
///
/// Used for:
/// - App unlock after background/timeout
/// - Sensitive operations (payslip view, document download)
@freezed
class PinVerifyRequest with _$PinVerifyRequest {
  const factory PinVerifyRequest({
    /// 6-digit PIN to verify
    required String pin,
    /// Purpose of verification for audit logging
    @Default('app_unlock') String purpose,
  }) = _PinVerifyRequest;

  factory PinVerifyRequest.fromJson(Map<String, dynamic> json) =>
      _$PinVerifyRequestFromJson(json);
}
