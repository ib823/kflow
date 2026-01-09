import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

/// Device Security Assessment for Enterprise Security
///
/// Per CLAUDE.md Security Requirements:
/// - Root/jailbreak detection
/// - Block rooted/jailbroken devices in release mode
/// - Developer mode detection (optional)
/// - Emulator detection (optional)
///
/// IMPORTANT: Users on compromised devices see warning before blocking
class DeviceSecurity {
  DeviceSecurity._();

  static const _channel = MethodChannel('kerjaflow/device_security');

  /// Assessment result cache
  static DeviceSecurityStatus? _cachedStatus;

  /// Perform comprehensive device security assessment
  /// Call this at app startup before allowing sensitive operations
  static Future<DeviceSecurityStatus> assess() async {
    // Return cached result if available
    if (_cachedStatus != null) {
      return _cachedStatus!;
    }

    final status = await _performAssessment();
    _cachedStatus = status;

    if (kDebugMode) {
      debugPrint('[DeviceSecurity] Assessment complete: $status');
    }

    return status;
  }

  /// Clear cached assessment (useful for re-checking)
  static void clearCache() {
    _cachedStatus = null;
  }

  /// Perform the actual security assessment
  static Future<DeviceSecurityStatus> _performAssessment() async {
    // In debug mode, allow all devices for development
    if (kDebugMode) {
      return DeviceSecurityStatus(
        isSecure: true,
        isRooted: false,
        isJailbroken: false,
        isEmulator: false,
        isDeveloperModeEnabled: false,
        securityIssues: [],
        riskLevel: SecurityRiskLevel.none,
      );
    }

    try {
      // Try native assessment first
      final nativeResult = await _nativeAssessment();
      if (nativeResult != null) {
        return nativeResult;
      }

      // Fall back to Dart-based checks
      return _dartAssessment();
    } catch (e) {
      debugPrint('[DeviceSecurity] Assessment error: $e');
      // On error, assume potentially compromised for security
      return DeviceSecurityStatus(
        isSecure: false,
        isRooted: false,
        isJailbroken: false,
        isEmulator: false,
        isDeveloperModeEnabled: false,
        securityIssues: ['Security assessment failed: $e'],
        riskLevel: SecurityRiskLevel.unknown,
      );
    }
  }

  /// Native platform assessment via MethodChannel
  static Future<DeviceSecurityStatus?> _nativeAssessment() async {
    try {
      final result = await _channel.invokeMethod<Map<dynamic, dynamic>>('assessDevice');

      if (result == null) return null;

      return DeviceSecurityStatus(
        isSecure: result['isSecure'] as bool? ?? false,
        isRooted: result['isRooted'] as bool? ?? false,
        isJailbroken: result['isJailbroken'] as bool? ?? false,
        isEmulator: result['isEmulator'] as bool? ?? false,
        isDeveloperModeEnabled: result['isDeveloperMode'] as bool? ?? false,
        securityIssues: (result['securityIssues'] as List<dynamic>?)
                ?.map((e) => e.toString())
                .toList() ??
            [],
        riskLevel: _parseRiskLevel(result['riskLevel'] as String?),
      );
    } on PlatformException catch (e) {
      debugPrint('[DeviceSecurity] Native assessment failed: ${e.message}');
      return null;
    } on MissingPluginException {
      debugPrint('[DeviceSecurity] Native plugin not available');
      return null;
    }
  }

  /// Dart-based security checks (fallback)
  static Future<DeviceSecurityStatus> _dartAssessment() async {
    final issues = <String>[];
    bool isRooted = false;
    bool isJailbroken = false;
    bool isEmulator = false;

    if (Platform.isAndroid) {
      // Android-specific checks
      isRooted = await _checkAndroidRoot();
      isEmulator = _checkAndroidEmulator();

      if (isRooted) issues.add('Device is rooted');
      if (isEmulator) issues.add('Running on emulator');
    } else if (Platform.isIOS) {
      // iOS-specific checks
      isJailbroken = await _checkIosJailbreak();
      isEmulator = _checkIosSimulator();

      if (isJailbroken) issues.add('Device is jailbroken');
      if (isEmulator) issues.add('Running on simulator');
    }

    final isSecure = !isRooted && !isJailbroken;
    final riskLevel = _calculateRiskLevel(isRooted, isJailbroken, isEmulator);

    return DeviceSecurityStatus(
      isSecure: isSecure,
      isRooted: isRooted,
      isJailbroken: isJailbroken,
      isEmulator: isEmulator,
      isDeveloperModeEnabled: false, // Can't check from Dart
      securityIssues: issues,
      riskLevel: riskLevel,
    );
  }

  /// Check for Android root indicators
  static Future<bool> _checkAndroidRoot() async {
    // Common root indicators
    final rootPaths = [
      '/system/app/Superuser.apk',
      '/sbin/su',
      '/system/bin/su',
      '/system/xbin/su',
      '/data/local/xbin/su',
      '/data/local/bin/su',
      '/system/sd/xbin/su',
      '/system/bin/failsafe/su',
      '/data/local/su',
      '/su/bin/su',
      '/system/xbin/daemonsu',
      '/system/etc/init.d/99telekineto',
      '/system/app/Magisk.apk',
    ];

    for (final path in rootPaths) {
      try {
        if (File(path).existsSync()) {
          return true;
        }
      } catch (_) {
        // Ignore access errors
      }
    }

    // Check for root management apps
    final rootApps = [
      'com.topjohnwu.magisk',
      'com.koushikdutta.superuser',
      'com.noshufou.android.su',
      'eu.chainfire.supersu',
      'com.thirdparty.superuser',
    ];

    // We can't check installed apps from Dart without native code
    // This is handled in the native plugin

    return false;
  }

  /// Check for iOS jailbreak indicators
  static Future<bool> _checkIosJailbreak() async {
    // Common jailbreak paths
    final jailbreakPaths = [
      '/Applications/Cydia.app',
      '/Library/MobileSubstrate/MobileSubstrate.dylib',
      '/bin/bash',
      '/usr/sbin/sshd',
      '/etc/apt',
      '/private/var/lib/apt/',
      '/usr/bin/ssh',
      '/var/cache/apt',
      '/var/lib/cydia',
      '/var/log/syslog',
      '/bin/sh',
      '/private/var/stash',
      '/private/var/lib/apt',
      '/private/var/tmp/cydia.log',
      '/Applications/Sileo.app',
      '/var/jb',
      '/private/var/jb',
    ];

    for (final path in jailbreakPaths) {
      try {
        if (File(path).existsSync()) {
          return true;
        }
      } catch (_) {
        // Ignore access errors
      }
    }

    // Check if we can write to restricted paths
    try {
      final testFile = File('/private/jailbreak_test.txt');
      await testFile.writeAsString('test');
      await testFile.delete();
      return true; // If we can write here, device is jailbroken
    } catch (_) {
      // Expected on non-jailbroken devices
    }

    return false;
  }

  /// Check if running on Android emulator
  static bool _checkAndroidEmulator() {
    // Check common emulator indicators via environment
    // This is limited from Dart; native check is more comprehensive
    return Platform.environment.containsKey('ANDROID_EMULATOR') ||
        Platform.environment.containsKey('QEMU_AUDIO_DRV');
  }

  /// Check if running on iOS simulator
  static bool _checkIosSimulator() {
    // Check for simulator architecture
    // Limited from Dart; native check is more reliable
    return Platform.environment.containsKey('SIMULATOR_DEVICE_NAME');
  }

  /// Calculate risk level based on findings
  static SecurityRiskLevel _calculateRiskLevel(
    bool isRooted,
    bool isJailbroken,
    bool isEmulator,
  ) {
    if (isRooted || isJailbroken) {
      return SecurityRiskLevel.critical;
    }
    if (isEmulator) {
      return SecurityRiskLevel.high;
    }
    return SecurityRiskLevel.none;
  }

  /// Parse risk level from string
  static SecurityRiskLevel _parseRiskLevel(String? level) {
    switch (level?.toLowerCase()) {
      case 'critical':
        return SecurityRiskLevel.critical;
      case 'high':
        return SecurityRiskLevel.high;
      case 'medium':
        return SecurityRiskLevel.medium;
      case 'low':
        return SecurityRiskLevel.low;
      case 'none':
        return SecurityRiskLevel.none;
      default:
        return SecurityRiskLevel.unknown;
    }
  }

  /// Check if the app should be blocked from running
  /// In production, we block rooted/jailbroken devices
  static Future<bool> shouldBlockApp() async {
    if (kDebugMode) {
      return false; // Allow in debug
    }

    final status = await assess();
    return status.isRooted || status.isJailbroken;
  }
}

/// Security status of the device
class DeviceSecurityStatus {
  final bool isSecure;
  final bool isRooted;
  final bool isJailbroken;
  final bool isEmulator;
  final bool isDeveloperModeEnabled;
  final List<String> securityIssues;
  final SecurityRiskLevel riskLevel;

  const DeviceSecurityStatus({
    required this.isSecure,
    required this.isRooted,
    required this.isJailbroken,
    required this.isEmulator,
    required this.isDeveloperModeEnabled,
    required this.securityIssues,
    required this.riskLevel,
  });

  bool get isCompromised => isRooted || isJailbroken;

  @override
  String toString() {
    return 'DeviceSecurityStatus('
        'isSecure: $isSecure, '
        'isRooted: $isRooted, '
        'isJailbroken: $isJailbroken, '
        'isEmulator: $isEmulator, '
        'riskLevel: ${riskLevel.name}, '
        'issues: $securityIssues)';
  }
}

/// Security risk levels
enum SecurityRiskLevel {
  none,
  low,
  medium,
  high,
  critical,
  unknown,
}
