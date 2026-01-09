import 'dart:async';
import 'dart:io';
import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'api_config.dart';

/// Custom exception for API errors
class ApiException implements Exception {
  final String message;
  final int? statusCode;
  final String? code;
  final Map<String, dynamic>? details;

  const ApiException({
    required this.message,
    this.statusCode,
    this.code,
    this.details,
  });

  @override
  String toString() => 'ApiException: $message (code: $code, status: $statusCode)';

  /// Check if error is due to network issues
  bool get isNetworkError =>
      code == 'network_error' || code == 'connection_timeout';

  /// Check if error is due to authentication
  bool get isAuthError =>
      statusCode == 401 || code == 'token_expired' || code == 'unauthorized';

  /// Check if error is server error
  bool get isServerError => statusCode != null && statusCode! >= 500;
}

/// Odoo API client with interceptors
class OdooClient {
  late final Dio _dio;
  final FlutterSecureStorage _storage;

  // Token keys
  static const String _accessTokenKey = 'access_token';
  static const String _refreshTokenKey = 'refresh_token';
  static const String _tokenExpiryKey = 'token_expiry';

  // Callbacks
  Function()? onTokenExpired;
  Function(String)? onTokenRefreshed;

  OdooClient({
    FlutterSecureStorage? storage,
  }) : _storage = storage ?? const FlutterSecureStorage() {
    _dio = Dio(BaseOptions(
      baseUrl: ApiConfig.apiUrl,
      connectTimeout: ApiConfig.connectTimeout,
      receiveTimeout: ApiConfig.receiveTimeout,
      sendTimeout: ApiConfig.sendTimeout,
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      },
    ));

    // Add interceptors
    _dio.interceptors.addAll([
      _AuthInterceptor(this),
      _ErrorInterceptor(),
      _LoggingInterceptor(),
    ]);
  }

  /// Get current access token
  Future<String?> getAccessToken() async {
    return await _storage.read(key: _accessTokenKey);
  }

  /// Get refresh token
  Future<String?> getRefreshToken() async {
    return await _storage.read(key: _refreshTokenKey);
  }

  /// Save tokens
  Future<void> saveTokens({
    required String accessToken,
    required String refreshToken,
    required DateTime expiry,
  }) async {
    await _storage.write(key: _accessTokenKey, value: accessToken);
    await _storage.write(key: _refreshTokenKey, value: refreshToken);
    await _storage.write(
      key: _tokenExpiryKey,
      value: expiry.toIso8601String(),
    );
  }

  /// Clear tokens (logout)
  Future<void> clearTokens() async {
    await _storage.delete(key: _accessTokenKey);
    await _storage.delete(key: _refreshTokenKey);
    await _storage.delete(key: _tokenExpiryKey);
  }

  /// Check if token needs refresh
  Future<bool> needsTokenRefresh() async {
    final expiryStr = await _storage.read(key: _tokenExpiryKey);
    if (expiryStr == null) return false;

    final expiry = DateTime.parse(expiryStr);
    final threshold = DateTime.now().add(
      Duration(seconds: ApiConfig.tokenRefreshThreshold),
    );

    return expiry.isBefore(threshold);
  }

  /// Refresh access token
  Future<bool> refreshAccessToken() async {
    final refreshToken = await getRefreshToken();
    if (refreshToken == null) return false;

    try {
      final response = await _dio.post(
        ApiEndpoints.refreshToken,
        data: {'refresh_token': refreshToken},
        options: Options(
          headers: {'Authorization': null}, // Skip auth for refresh
        ),
      );

      final newAccessToken = response.data['access_token'] as String;
      final newRefreshToken = response.data['refresh_token'] as String;
      final expiresIn = response.data['expires_in'] as int;

      await saveTokens(
        accessToken: newAccessToken,
        refreshToken: newRefreshToken,
        expiry: DateTime.now().add(Duration(seconds: expiresIn)),
      );

      onTokenRefreshed?.call(newAccessToken);
      return true;
    } catch (e) {
      await clearTokens();
      onTokenExpired?.call();
      return false;
    }
  }

  // HTTP methods
  Future<Response<T>> get<T>(
    String path, {
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) {
    return _dio.get<T>(
      path,
      queryParameters: queryParameters,
      options: options,
    );
  }

  Future<Response<T>> post<T>(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) {
    return _dio.post<T>(
      path,
      data: data,
      queryParameters: queryParameters,
      options: options,
    );
  }

  Future<Response<T>> put<T>(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) {
    return _dio.put<T>(
      path,
      data: data,
      queryParameters: queryParameters,
      options: options,
    );
  }

  Future<Response<T>> delete<T>(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) {
    return _dio.delete<T>(
      path,
      data: data,
      queryParameters: queryParameters,
      options: options,
    );
  }

  Future<Response> download(
    String path,
    String savePath, {
    Map<String, dynamic>? queryParameters,
    ProgressCallback? onReceiveProgress,
  }) {
    return _dio.download(
      path,
      savePath,
      queryParameters: queryParameters,
      onReceiveProgress: onReceiveProgress,
    );
  }
}

/// Auth interceptor for adding token to requests
class _AuthInterceptor extends Interceptor {
  final OdooClient _client;

  _AuthInterceptor(this._client);

  @override
  Future<void> onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) async {
    // Skip auth for certain endpoints
    if (_isPublicEndpoint(options.path)) {
      return handler.next(options);
    }

    // Check if token needs refresh
    if (await _client.needsTokenRefresh()) {
      await _client.refreshAccessToken();
    }

    // Add token to request
    final token = await _client.getAccessToken();
    if (token != null) {
      options.headers['Authorization'] = 'Bearer $token';
    }

    handler.next(options);
  }

  @override
  Future<void> onError(
    DioException err,
    ErrorInterceptorHandler handler,
  ) async {
    // Handle 401 by refreshing token
    if (err.response?.statusCode == 401) {
      if (await _client.refreshAccessToken()) {
        // Retry the request
        try {
          final token = await _client.getAccessToken();
          err.requestOptions.headers['Authorization'] = 'Bearer $token';

          final response = await Dio().fetch(err.requestOptions);
          return handler.resolve(response);
        } catch (e) {
          return handler.next(err);
        }
      }
    }

    handler.next(err);
  }

  bool _isPublicEndpoint(String path) {
    return path == ApiEndpoints.login ||
        path == ApiEndpoints.refreshToken;
  }
}

/// Error interceptor for mapping errors
class _ErrorInterceptor extends Interceptor {
  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    final exception = _mapError(err);
    handler.reject(
      DioException(
        requestOptions: err.requestOptions,
        response: err.response,
        type: err.type,
        error: exception,
      ),
    );
  }

  ApiException _mapError(DioException err) {
    switch (err.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
        return const ApiException(
          message: 'Connection timeout. Please check your internet.',
          code: 'connection_timeout',
        );

      case DioExceptionType.connectionError:
        return const ApiException(
          message: 'No internet connection.',
          code: 'network_error',
        );

      case DioExceptionType.badResponse:
        return _mapResponseError(err.response);

      case DioExceptionType.cancel:
        return const ApiException(
          message: 'Request cancelled.',
          code: 'cancelled',
        );

      default:
        if (err.error is SocketException) {
          return const ApiException(
            message: 'No internet connection.',
            code: 'network_error',
          );
        }
        return ApiException(
          message: err.message ?? 'Unknown error occurred.',
          code: 'unknown',
        );
    }
  }

  ApiException _mapResponseError(Response? response) {
    final statusCode = response?.statusCode;
    final data = response?.data;

    String message = 'An error occurred.';
    String? code;
    Map<String, dynamic>? details;

    if (data is Map<String, dynamic>) {
      message = data['message'] as String? ?? message;
      code = data['code'] as String?;
      details = data['details'] as Map<String, dynamic>?;
    }

    switch (statusCode) {
      case 400:
        return ApiException(
          message: message,
          statusCode: statusCode,
          code: code ?? 'bad_request',
          details: details,
        );
      case 401:
        return ApiException(
          message: 'Session expired. Please login again.',
          statusCode: statusCode,
          code: 'unauthorized',
        );
      case 403:
        return ApiException(
          message: 'You do not have permission to perform this action.',
          statusCode: statusCode,
          code: 'forbidden',
        );
      case 404:
        return ApiException(
          message: 'Resource not found.',
          statusCode: statusCode,
          code: 'not_found',
        );
      case 422:
        return ApiException(
          message: message,
          statusCode: statusCode,
          code: code ?? 'validation_error',
          details: details,
        );
      case 429:
        return ApiException(
          message: 'Too many requests. Please try again later.',
          statusCode: statusCode,
          code: 'rate_limited',
        );
      case 500:
      case 502:
      case 503:
        return ApiException(
          message: 'Server error. Please try again later.',
          statusCode: statusCode,
          code: 'server_error',
        );
      default:
        return ApiException(
          message: message,
          statusCode: statusCode,
          code: code ?? 'unknown',
          details: details,
        );
    }
  }
}

/// Logging interceptor for debugging
class _LoggingInterceptor extends Interceptor {
  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    // ignore: avoid_print
    print('[API] ${options.method} ${options.uri}');
    handler.next(options);
  }

  @override
  void onResponse(Response response, ResponseInterceptorHandler handler) {
    // ignore: avoid_print
    print('[API] ${response.statusCode} ${response.requestOptions.uri}');
    handler.next(response);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    // ignore: avoid_print
    print('[API] ERROR ${err.response?.statusCode} ${err.requestOptions.uri}');
    handler.next(err);
  }
}
