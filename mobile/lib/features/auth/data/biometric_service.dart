import 'package:flutter/services.dart';
import 'package:local_auth/local_auth.dart';
import 'package:local_auth/error_codes.dart' as auth_error;
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'biometric_service.g.dart';

/// Biometric authentication types supported
enum BiometricType {
  fingerprint,
  faceId,
  iris,
  none,
}

/// Result of biometric authentication attempt
sealed class BiometricResult {
  const BiometricResult();
}

class BiometricSuccess extends BiometricResult {
  const BiometricSuccess();
}

class BiometricFailure extends BiometricResult {
  final String reason;
  const BiometricFailure(this.reason);
}

class BiometricCancelled extends BiometricResult {
  const BiometricCancelled();
}

class BiometricLockout extends BiometricResult {
  final bool isPermanent;
  const BiometricLockout({this.isPermanent = false});
}

class BiometricNotAvailable extends BiometricResult {
  const BiometricNotAvailable();
}

/// Service for biometric authentication using local_auth package.
///
/// Supports fingerprint, face recognition, and iris scanning.
/// Falls back to PIN if biometric is unavailable or fails.
class BiometricService {
  final LocalAuthentication _auth;

  BiometricService({LocalAuthentication? auth})
      : _auth = auth ?? LocalAuthentication();

  /// Check if device supports biometric authentication
  Future<bool> isAvailable() async {
    try {
      final canAuthenticateWithBiometrics = await _auth.canCheckBiometrics;
      final canAuthenticate = await _auth.isDeviceSupported();
      return canAuthenticateWithBiometrics || canAuthenticate;
    } on PlatformException {
      return false;
    }
  }

  /// Get available biometric types on this device
  Future<List<BiometricType>> getAvailableTypes() async {
    try {
      final biometrics = await _auth.getAvailableBiometrics();
      return biometrics.map((b) {
        switch (b) {
          case BiometricType.fingerprint:
            return BiometricType.fingerprint;
          case BiometricType.face:
            return BiometricType.faceId;
          case BiometricType.iris:
            return BiometricType.iris;
          default:
            return BiometricType.none;
        }
      }).where((t) => t != BiometricType.none).toList();
    } on PlatformException {
      return [];
    }
  }

  /// Get the primary biometric type for display
  Future<BiometricType> getPrimaryType() async {
    final types = await getAvailableTypes();
    if (types.isEmpty) return BiometricType.none;
    // Prefer face > fingerprint > iris
    if (types.contains(BiometricType.faceId)) return BiometricType.faceId;
    if (types.contains(BiometricType.fingerprint)) return BiometricType.fingerprint;
    return types.first;
  }

  /// Authenticate user with biometrics
  ///
  /// [localizedReason] - Message shown to user explaining why auth is needed
  /// [useErrorDialogs] - Show system error dialogs on failure
  Future<BiometricResult> authenticate({
    required String localizedReason,
    bool useErrorDialogs = true,
    bool stickyAuth = true,
    bool biometricOnly = false,
  }) async {
    try {
      final success = await _auth.authenticate(
        localizedReason: localizedReason,
        options: AuthenticationOptions(
          useErrorDialogs: useErrorDialogs,
          stickyAuth: stickyAuth,
          biometricOnly: biometricOnly,
        ),
      );

      return success
          ? const BiometricSuccess()
          : const BiometricFailure('Authentication failed');
    } on PlatformException catch (e) {
      switch (e.code) {
        case auth_error.notAvailable:
        case auth_error.notEnrolled:
          return const BiometricNotAvailable();
        case auth_error.lockedOut:
          return const BiometricLockout();
        case auth_error.permanentlyLockedOut:
          return const BiometricLockout(isPermanent: true);
        case auth_error.passcodeNotSet:
          return const BiometricNotAvailable();
        default:
          return BiometricFailure(e.message ?? 'Unknown error');
      }
    }
  }

  /// Stop any ongoing authentication
  Future<void> stopAuthentication() async {
    await _auth.stopAuthentication();
  }
}

/// Provider for BiometricService
@riverpod
BiometricService biometricService(BiometricServiceRef ref) {
  return BiometricService();
}

/// Provider for checking if biometric is available
@riverpod
Future<bool> biometricAvailable(BiometricAvailableRef ref) async {
  final service = ref.watch(biometricServiceProvider);
  return service.isAvailable();
}

/// Provider for getting primary biometric type
@riverpod
Future<BiometricType> primaryBiometricType(PrimaryBiometricTypeRef ref) async {
  final service = ref.watch(biometricServiceProvider);
  return service.getPrimaryType();
}
