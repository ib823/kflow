import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'secure_storage.g.dart';

class SecureStorageKeys {
  static const accessToken = 'access_token';
  static const refreshToken = 'refresh_token';
  static const tokenExpiry = 'token_expiry';
  static const userId = 'user_id';
  static const userEmail = 'user_email';
  static const userRole = 'user_role';
  static const pinVerificationToken = 'pin_verification_token';
  static const pinVerificationExpiry = 'pin_verification_expiry';
  static const fcmToken = 'fcm_token';
  static const preferredLanguage = 'preferred_language';
  static const biometricEnabled = 'biometric_enabled';
}

class SecureStorageService {
  final FlutterSecureStorage _storage;

  SecureStorageService()
      : _storage = const FlutterSecureStorage(
          aOptions: AndroidOptions(
            encryptedSharedPreferences: true,
          ),
          iOptions: IOSOptions(
            accessibility: KeychainAccessibility.first_unlock_this_device,
          ),
        );

  Future<void> write(String key, String value) async {
    await _storage.write(key: key, value: value);
  }

  Future<String?> read(String key) async {
    return await _storage.read(key: key);
  }

  Future<void> delete(String key) async {
    await _storage.delete(key: key);
  }

  Future<void> deleteAll() async {
    await _storage.deleteAll();
  }

  Future<bool> containsKey(String key) async {
    return await _storage.containsKey(key: key);
  }

  // Token management
  Future<void> saveTokens({
    required String accessToken,
    required String refreshToken,
    required int expiresIn,
  }) async {
    final expiry = DateTime.now().add(Duration(seconds: expiresIn));
    await Future.wait([
      write(SecureStorageKeys.accessToken, accessToken),
      write(SecureStorageKeys.refreshToken, refreshToken),
      write(SecureStorageKeys.tokenExpiry, expiry.toIso8601String()),
    ]);
  }

  Future<String?> getAccessToken() async {
    return await read(SecureStorageKeys.accessToken);
  }

  Future<String?> getRefreshToken() async {
    return await read(SecureStorageKeys.refreshToken);
  }

  Future<bool> isTokenValid() async {
    final expiryStr = await read(SecureStorageKeys.tokenExpiry);
    if (expiryStr == null) return false;

    final expiry = DateTime.parse(expiryStr);
    // Consider token invalid if it expires within 5 minutes
    return expiry.isAfter(DateTime.now().add(const Duration(minutes: 5)));
  }

  Future<void> clearTokens() async {
    await Future.wait([
      delete(SecureStorageKeys.accessToken),
      delete(SecureStorageKeys.refreshToken),
      delete(SecureStorageKeys.tokenExpiry),
    ]);
  }

  // User info
  Future<void> saveUserInfo({
    required int userId,
    required String email,
    required String role,
  }) async {
    await Future.wait([
      write(SecureStorageKeys.userId, userId.toString()),
      write(SecureStorageKeys.userEmail, email),
      write(SecureStorageKeys.userRole, role),
    ]);
  }

  Future<void> clearUserInfo() async {
    await Future.wait([
      delete(SecureStorageKeys.userId),
      delete(SecureStorageKeys.userEmail),
      delete(SecureStorageKeys.userRole),
    ]);
  }

  // PIN verification
  Future<void> savePinVerification(String token, int expiresInSeconds) async {
    final expiry = DateTime.now().add(Duration(seconds: expiresInSeconds));
    await Future.wait([
      write(SecureStorageKeys.pinVerificationToken, token),
      write(SecureStorageKeys.pinVerificationExpiry, expiry.toIso8601String()),
    ]);
  }

  Future<String?> getPinVerificationToken() async {
    final expiryStr = await read(SecureStorageKeys.pinVerificationExpiry);
    if (expiryStr == null) return null;

    final expiry = DateTime.parse(expiryStr);
    if (expiry.isBefore(DateTime.now())) {
      await clearPinVerification();
      return null;
    }

    return await read(SecureStorageKeys.pinVerificationToken);
  }

  Future<void> clearPinVerification() async {
    await Future.wait([
      delete(SecureStorageKeys.pinVerificationToken),
      delete(SecureStorageKeys.pinVerificationExpiry),
    ]);
  }

  /// Check if PIN verification is still valid (not expired)
  Future<bool> isPinVerificationValid() async {
    final expiryStr = await read(SecureStorageKeys.pinVerificationExpiry);
    if (expiryStr == null) return false;

    try {
      final expiry = DateTime.parse(expiryStr);
      return expiry.isAfter(DateTime.now());
    } catch (_) {
      return false;
    }
  }

  // Full logout
  Future<void> clearAll() async {
    await deleteAll();
  }
}

@riverpod
SecureStorageService secureStorage(SecureStorageRef ref) {
  return SecureStorageService();
}
