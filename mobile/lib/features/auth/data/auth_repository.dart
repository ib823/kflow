import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../domain/models/models.dart';
import 'auth_api.dart';
import 'biometric_service.dart';

part 'auth_repository.g.dart';

/// Secure storage keys
class StorageKeys {
  static const accessToken = 'access_token';
  static const refreshToken = 'refresh_token';
  static const tokenExpiry = 'token_expiry';
  static const employeeId = 'employee_id';
  static const employeeData = 'employee_data';
  static const biometricEnabled = 'biometric_enabled';
  static const preferredLocale = 'preferred_locale';
  static const deviceId = 'device_id';
}

/// Auth repository handling authentication state and token management.
///
/// Responsibilities:
/// - Token storage/retrieval from secure storage
/// - Login/logout flow
/// - PIN setup and verification
/// - Biometric authentication
/// - Session management
class AuthRepository {
  final AuthApi _api;
  final BiometricService _biometricService;
  final FlutterSecureStorage _storage;

  AuthRepository({
    required AuthApi api,
    required BiometricService biometricService,
    FlutterSecureStorage? storage,
  })  : _api = api,
        _biometricService = biometricService,
        _storage = storage ??
            const FlutterSecureStorage(
              aOptions: AndroidOptions(encryptedSharedPreferences: true),
              iOptions: IOSOptions(accessibility: KeychainAccessibility.first_unlock),
            );

  // ===========================================================================
  // Token Management
  // ===========================================================================

  /// Get current access token
  Future<String?> getAccessToken() async {
    return _storage.read(key: StorageKeys.accessToken);
  }

  /// Get refresh token
  Future<String?> getRefreshToken() async {
    return _storage.read(key: StorageKeys.refreshToken);
  }

  /// Check if access token is expired
  Future<bool> isTokenExpired() async {
    final expiryStr = await _storage.read(key: StorageKeys.tokenExpiry);
    if (expiryStr == null) return true;

    final expiry = DateTime.tryParse(expiryStr);
    if (expiry == null) return true;

    // Consider expired if within 5 minutes of expiry
    return DateTime.now().isAfter(expiry.subtract(const Duration(minutes: 5)));
  }

  /// Check if user is logged in (has valid tokens)
  Future<bool> isLoggedIn() async {
    final token = await getAccessToken();
    if (token == null) return false;

    if (await isTokenExpired()) {
      // Try to refresh
      final refreshToken = await getRefreshToken();
      if (refreshToken == null) return false;

      try {
        await refreshAccessToken();
        return true;
      } catch (_) {
        return false;
      }
    }
    return true;
  }

  /// Store tokens after login
  Future<void> _storeTokens({
    required String accessToken,
    required String refreshToken,
    required int expiresIn,
  }) async {
    final expiry = DateTime.now().add(Duration(seconds: expiresIn));
    await Future.wait([
      _storage.write(key: StorageKeys.accessToken, value: accessToken),
      _storage.write(key: StorageKeys.refreshToken, value: refreshToken),
      _storage.write(key: StorageKeys.tokenExpiry, value: expiry.toIso8601String()),
    ]);
  }

  /// Store employee data
  Future<void> _storeEmployee(Employee employee) async {
    await _storage.write(
      key: StorageKeys.employeeData,
      value: employee.toJson().toString(),
    );
    await _storage.write(
      key: StorageKeys.employeeId,
      value: employee.id.toString(),
    );
  }

  /// Clear all stored auth data on logout
  Future<void> _clearStorage() async {
    await _storage.deleteAll();
  }

  // ===========================================================================
  // Login Flow
  // ===========================================================================

  /// Login with email and password
  ///
  /// Returns [LoginResponse] with tokens and employee data.
  /// Throws [AuthException] on failure.
  Future<LoginResponse> login({
    required String email,
    required String password,
  }) async {
    final deviceId = await _getOrCreateDeviceId();

    final request = LoginRequest(
      email: email,
      password: password,
      deviceId: deviceId,
    );

    final response = await _api.login(request);

    // Store tokens and employee data
    await _storeTokens(
      accessToken: response.accessToken,
      refreshToken: response.refreshToken,
      expiresIn: response.expiresIn,
    );
    await _storeEmployee(response.employee);

    return response;
  }

  /// Refresh access token
  Future<void> refreshAccessToken() async {
    final refreshToken = await getRefreshToken();
    if (refreshToken == null) {
      throw AuthException('No refresh token available');
    }

    final response = await _api.refreshToken(refreshToken);

    await _storage.write(
      key: StorageKeys.accessToken,
      value: response.accessToken,
    );

    final expiry = DateTime.now().add(Duration(seconds: response.expiresIn));
    await _storage.write(
      key: StorageKeys.tokenExpiry,
      value: expiry.toIso8601String(),
    );
  }

  /// Logout and clear session
  Future<void> logout() async {
    try {
      await _api.logout();
    } catch (_) {
      // Ignore API errors, clear local state anyway
    }
    await _clearStorage();
  }

  // ===========================================================================
  // PIN Management
  // ===========================================================================

  /// Setup 6-digit PIN
  Future<PinSetupResponse> setupPin({
    required String pin,
    required String confirmPin,
    bool enableBiometric = false,
  }) async {
    final request = PinSetupRequest(
      pin: pin,
      confirmPin: confirmPin,
      enableBiometric: enableBiometric,
    );

    final response = await _api.setupPin(request);

    if (response.success && enableBiometric) {
      await _storage.write(
        key: StorageKeys.biometricEnabled,
        value: 'true',
      );
    }

    return response;
  }

  /// Verify PIN for unlock or sensitive operations
  Future<PinVerifyResponse> verifyPin({
    required String pin,
    String purpose = 'app_unlock',
  }) async {
    final request = PinVerifyRequest(pin: pin, purpose: purpose);
    return _api.verifyPin(request);
  }

  // ===========================================================================
  // Biometric Authentication
  // ===========================================================================

  /// Check if biometric is enabled for this user
  Future<bool> isBiometricEnabled() async {
    final enabled = await _storage.read(key: StorageKeys.biometricEnabled);
    if (enabled != 'true') return false;
    return _biometricService.isAvailable();
  }

  /// Enable biometric authentication
  Future<void> enableBiometric() async {
    await _storage.write(key: StorageKeys.biometricEnabled, value: 'true');
  }

  /// Disable biometric authentication
  Future<void> disableBiometric() async {
    await _storage.write(key: StorageKeys.biometricEnabled, value: 'false');
  }

  /// Authenticate with biometrics
  Future<BiometricResult> authenticateWithBiometric({
    required String localizedReason,
  }) async {
    return _biometricService.authenticate(
      localizedReason: localizedReason,
      biometricOnly: true,
    );
  }

  // ===========================================================================
  // Device ID
  // ===========================================================================

  /// Get or create unique device ID for session management
  Future<String> _getOrCreateDeviceId() async {
    var deviceId = await _storage.read(key: StorageKeys.deviceId);
    if (deviceId == null) {
      deviceId = DateTime.now().millisecondsSinceEpoch.toString();
      await _storage.write(key: StorageKeys.deviceId, value: deviceId);
    }
    return deviceId;
  }

  // ===========================================================================
  // Locale Preference
  // ===========================================================================

  /// Get preferred locale code
  Future<String?> getPreferredLocale() async {
    return _storage.read(key: StorageKeys.preferredLocale);
  }

  /// Set preferred locale code
  Future<void> setPreferredLocale(String localeCode) async {
    await _storage.write(key: StorageKeys.preferredLocale, value: localeCode);
  }
}

/// Authentication exception
class AuthException implements Exception {
  final String message;
  final String? code;

  AuthException(this.message, {this.code});

  @override
  String toString() => 'AuthException: $message';
}

/// Provider for AuthRepository
@riverpod
AuthRepository authRepository(AuthRepositoryRef ref) {
  return AuthRepository(
    api: ref.watch(authApiProvider),
    biometricService: ref.watch(biometricServiceProvider),
  );
}

/// Provider for checking login status
@riverpod
Future<bool> isLoggedIn(IsLoggedInRef ref) async {
  final repo = ref.watch(authRepositoryProvider);
  return repo.isLoggedIn();
}

/// Provider for biometric enabled status
@riverpod
Future<bool> isBiometricEnabled(IsBiometricEnabledRef ref) async {
  final repo = ref.watch(authRepositoryProvider);
  return repo.isBiometricEnabled();
}
