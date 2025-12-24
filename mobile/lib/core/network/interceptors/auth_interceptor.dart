import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import '../../config/app_config.dart';

/// Interceptor for handling JWT authentication
class AuthInterceptor extends Interceptor {
  final FlutterSecureStorage _storage = const FlutterSecureStorage();

  @override
  void onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) async {
    // Skip auth for login and refresh endpoints
    if (_isPublicEndpoint(options.path)) {
      return handler.next(options);
    }

    final accessToken = await _storage.read(key: StorageKeys.accessToken);

    if (accessToken != null) {
      options.headers['Authorization'] = 'Bearer $accessToken';
    }

    handler.next(options);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) async {
    if (err.response?.statusCode == 401) {
      // Token expired or invalid
      final errorCode = err.response?.data?['code'];

      if (errorCode == 'TOKEN_EXPIRED') {
        // Try to refresh the token
        final refreshed = await _refreshToken();

        if (refreshed) {
          // Retry the original request
          final response = await _retryRequest(err.requestOptions);
          return handler.resolve(response);
        }
      }

      // If refresh failed or other auth error, clear tokens
      await _clearTokens();
    }

    handler.next(err);
  }

  bool _isPublicEndpoint(String path) {
    final publicEndpoints = [
      '/auth/login',
      '/auth/refresh',
      '/auth/password/forgot',
      '/auth/password/reset',
      '/health',
    ];

    return publicEndpoints.any((endpoint) => path.contains(endpoint));
  }

  Future<bool> _refreshToken() async {
    try {
      final refreshToken = await _storage.read(key: StorageKeys.refreshToken);

      if (refreshToken == null) return false;

      final dio = Dio(BaseOptions(
        baseUrl: AppConfig.instance.apiBaseUrl,
        headers: {'Content-Type': 'application/json'},
      ));

      final response = await dio.post(
        '/auth/refresh',
        data: {'refresh_token': refreshToken},
      );

      if (response.statusCode == 200) {
        final newAccessToken = response.data['access_token'];
        final expiresAt = response.data['expires_at'];

        await _storage.write(
          key: StorageKeys.accessToken,
          value: newAccessToken,
        );
        await _storage.write(
          key: StorageKeys.tokenExpiry,
          value: expiresAt,
        );

        return true;
      }
    } catch (e) {
      // Refresh failed
    }

    return false;
  }

  Future<Response> _retryRequest(RequestOptions options) async {
    final accessToken = await _storage.read(key: StorageKeys.accessToken);

    final retryOptions = Options(
      method: options.method,
      headers: {
        ...options.headers,
        'Authorization': 'Bearer $accessToken',
      },
    );

    return Dio().request(
      options.path,
      data: options.data,
      queryParameters: options.queryParameters,
      options: retryOptions,
    );
  }

  Future<void> _clearTokens() async {
    await _storage.delete(key: StorageKeys.accessToken);
    await _storage.delete(key: StorageKeys.refreshToken);
    await _storage.delete(key: StorageKeys.tokenExpiry);
  }
}
