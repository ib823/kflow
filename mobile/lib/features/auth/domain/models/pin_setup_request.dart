import 'package:freezed_annotation/freezed_annotation.dart';

part 'pin_setup_request.freezed.dart';
part 'pin_setup_request.g.dart';

/// PIN setup request for POST /api/v1/auth/pin/setup
///
/// Used during first login to configure 6-digit PIN.
/// PIN is hashed with bcrypt (cost 10) on the server.
@freezed
class PinSetupRequest with _$PinSetupRequest {
  const factory PinSetupRequest({
    /// 6-digit PIN (validated client-side before sending)
    required String pin,
    /// PIN confirmation (must match [pin])
    required String confirmPin,
    /// Whether to enable biometric authentication
    @Default(false) bool enableBiometric,
  }) = _PinSetupRequest;

  factory PinSetupRequest.fromJson(Map<String, dynamic> json) =>
      _$PinSetupRequestFromJson(json);
}

/// PIN setup response
@freezed
class PinSetupResponse with _$PinSetupResponse {
  const factory PinSetupResponse({
    required bool success,
    String? message,
  }) = _PinSetupResponse;

  factory PinSetupResponse.fromJson(Map<String, dynamic> json) =>
      _$PinSetupResponseFromJson(json);
}
