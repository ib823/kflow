import '../datasources/remote/odoo_client.dart';
import '../datasources/remote/api_config.dart';
import '../datasources/local/local_storage.dart';
import '../models/models.dart';
import '../sync/sync_manager.dart';
import 'base_repository.dart';

/// Authentication repository
class AuthRepository extends BaseRepository {
  AuthRepository({
    required super.client,
    required super.storage,
    required super.syncManager,
  });

  /// Login with credentials
  Future<User> login({
    required String employeeId,
    required String password,
  }) async {
    final response = await client.post(
      ApiEndpoints.login,
      data: {
        'employee_id': employeeId,
        'password': password,
      },
    );

    final data = response.data as Map<String, dynamic>;

    // Save tokens
    await client.saveTokens(
      accessToken: data['access_token'] as String,
      refreshToken: data['refresh_token'] as String,
      expiry: DateTime.now().add(
        Duration(seconds: data['expires_in'] as int),
      ),
    );

    // Parse and save user
    final user = User.fromJson(data['user'] as Map<String, dynamic>);
    await storage.saveUser(user);

    return user;
  }

  /// Logout
  Future<void> logout() async {
    try {
      await client.post(ApiEndpoints.logout);
    } finally {
      await client.clearTokens();
      await LocalStorage.clearAll();
    }
  }

  /// Verify PIN
  Future<bool> verifyPin(String pin) async {
    final response = await client.post(
      ApiEndpoints.verifyPin,
      data: {'pin': pin},
    );

    return response.data['valid'] as bool;
  }

  /// Set PIN
  Future<void> setPin(String pin) async {
    await client.post(
      ApiEndpoints.setPin,
      data: {'pin': pin},
    );
  }

  /// Register biometric
  Future<void> registerBiometric({
    required String deviceId,
    required String biometricToken,
  }) async {
    await client.post(
      ApiEndpoints.registerBiometric,
      data: {
        'device_id': deviceId,
        'biometric_token': biometricToken,
      },
    );
  }

  /// Get current user from cache
  User? getCachedUser() => storage.getUser();

  /// Check if user is logged in
  Future<bool> isLoggedIn() async {
    final token = await client.getAccessToken();
    return token != null;
  }
}
