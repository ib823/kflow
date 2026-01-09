import 'dart:io';
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

/// Certificate Pinning Implementation for MITM Prevention
///
/// Per CLAUDE.md Security Requirements:
/// - SHA-256 fingerprint validation
/// - Primary + backup certificate support
/// - Pinning bypass for debug builds (configurable)
///
/// IMPORTANT: Update these pins before certificate renewal!
/// Certificate renewal dates should be tracked in infrastructure docs.
class CertificatePins {
  CertificatePins._();

  /// SHA-256 fingerprints of trusted certificates
  /// Format: Base64-encoded SHA-256 hash of the certificate's public key
  ///
  /// To generate a pin from a certificate:
  /// ```bash
  /// openssl x509 -in cert.pem -pubkey -noout | \
  ///   openssl pkey -pubin -outform DER | \
  ///   openssl dgst -sha256 -binary | \
  ///   openssl enc -base64
  /// ```
  static const List<String> _productionPins = [
    // Primary certificate (api.kerjaflow.com)
    // Expiry: Track in infrastructure docs
    'sha256/AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA=', // Replace with actual pin

    // Backup certificate (intermediate/root CA)
    'sha256/BBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBB=', // Replace with actual pin

    // Emergency backup (different CA)
    'sha256/CCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCC=', // Replace with actual pin
  ];

  /// Staging/development environment pins (less strict)
  static const List<String> _stagingPins = [
    // Staging certificate
    'sha256/DDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDD=', // Replace with actual pin
  ];

  /// Get appropriate pins based on environment
  static List<String> get pins {
    // In debug mode, we can optionally disable pinning
    // Set this via environment variable or build config
    if (kDebugMode && _bypassPinningInDebug) {
      return [];
    }

    if (kReleaseMode) {
      return _productionPins;
    }

    return _stagingPins;
  }

  /// Whether to bypass pinning in debug builds
  /// WARNING: Set to false for security testing
  static const bool _bypassPinningInDebug = true;

  /// Validate a certificate against pinned values
  /// Returns true if the certificate is trusted
  static bool validateCertificate(X509Certificate cert, String host) {
    // Skip validation in debug mode if bypass is enabled
    if (kDebugMode && _bypassPinningInDebug) {
      debugPrint('[CertPin] Bypassing certificate pinning in debug mode');
      return true;
    }

    // Only pin our API domains
    if (!_isPinnedHost(host)) {
      debugPrint('[CertPin] Host $host is not pinned, allowing');
      return true;
    }

    // Get the certificate's SHA-256 fingerprint
    final certPin = _getCertificatePin(cert);
    if (certPin == null) {
      debugPrint('[CertPin] Failed to extract certificate pin');
      return false;
    }

    // Check against our pinned values
    final isValid = pins.any((pin) => pin.endsWith(certPin));

    if (!isValid) {
      debugPrint('[CertPin] Certificate validation FAILED for $host');
      debugPrint('[CertPin] Expected one of: $pins');
      debugPrint('[CertPin] Got: sha256/$certPin');
    } else {
      debugPrint('[CertPin] Certificate validated successfully for $host');
    }

    return isValid;
  }

  /// Extract SHA-256 pin from certificate
  static String? _getCertificatePin(X509Certificate cert) {
    try {
      // The der property gives us the DER-encoded certificate
      final der = cert.der;

      // Calculate SHA-256 hash
      // Note: In production, you'd extract the public key (SPKI) first
      // This is a simplified version for demonstration
      final hash = _sha256(der);

      return base64Encode(hash);
    } catch (e) {
      debugPrint('[CertPin] Error extracting pin: $e');
      return null;
    }
  }

  /// Simple SHA-256 implementation placeholder
  /// In production, use a proper crypto library
  static List<int> _sha256(List<int> data) {
    // This would use dart:crypto or crypto package in production
    // For now, return a placeholder that will always fail validation
    // This forces proper implementation before production use
    return List.filled(32, 0);
  }

  /// Check if a host should have certificate pinning applied
  static bool _isPinnedHost(String host) {
    const pinnedDomains = [
      'api.kerjaflow.com',
      'kerjaflow.com',
      'api.staging.kerjaflow.com',
    ];

    return pinnedDomains.any((domain) =>
        host == domain || host.endsWith('.$domain'));
  }

  /// Create an HttpClient with certificate pinning enabled
  static HttpClient createSecureClient() {
    final client = HttpClient();

    client.badCertificateCallback = (X509Certificate cert, String host, int port) {
      // Return true to accept, false to reject
      // Our validateCertificate returns true for valid certs
      final isValid = validateCertificate(cert, host);

      if (!isValid && kReleaseMode) {
        // In release mode, strict rejection
        return false;
      }

      // In debug mode with bypass, we may allow invalid certs
      return isValid || (kDebugMode && _bypassPinningInDebug);
    };

    return client;
  }

  /// Platform channel for native certificate pinning (optional enhancement)
  static const _channel = MethodChannel('kerjaflow/certificate_pinning');

  /// Check if native pinning is available
  static Future<bool> isNativePinningAvailable() async {
    try {
      final result = await _channel.invokeMethod<bool>('isAvailable');
      return result ?? false;
    } catch (e) {
      return false;
    }
  }

  /// Verify certificate using native implementation
  static Future<bool> verifyWithNative(String host, List<int> certDer) async {
    try {
      final result = await _channel.invokeMethod<bool>('verifyCertificate', {
        'host': host,
        'certDer': certDer,
        'pins': pins,
      });
      return result ?? false;
    } catch (e) {
      debugPrint('[CertPin] Native verification failed: $e');
      // Fall back to Dart implementation
      return false;
    }
  }
}

/// Extension on Dio to add certificate pinning
extension DioSecurityExtension on HttpClient {
  /// Configure this client for certificate pinning
  void enableCertificatePinning() {
    badCertificateCallback = (X509Certificate cert, String host, int port) {
      return CertificatePins.validateCertificate(cert, host);
    };
  }
}
