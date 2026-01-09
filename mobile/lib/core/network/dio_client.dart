import 'dart:io';

import 'package:dio/dio.dart';
import 'package:dio/io.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../config/app_config.dart';
import '../security/certificate_pins.dart';
import 'interceptors/auth_interceptor.dart';
import 'interceptors/error_interceptor.dart';
import 'interceptors/logging_interceptor.dart';

/// Provider for the Dio HTTP client
final dioClientProvider = Provider<Dio>((ref) {
  return DioClient.instance;
});

/// Singleton Dio HTTP client for API communication
class DioClient {
  static late Dio _dio;
  static bool _initialized = false;

  static Dio get instance {
    if (!_initialized) {
      throw Exception('DioClient not initialized. Call DioClient.initialize() first.');
    }
    return _dio;
  }

  static Future<void> initialize() async {
    if (_initialized) return;

    _dio = Dio(
      BaseOptions(
        baseUrl: AppConfig.instance.apiBaseUrl,
        connectTimeout: const Duration(milliseconds: ApiConfig.connectTimeout),
        receiveTimeout: const Duration(milliseconds: ApiConfig.receiveTimeout),
        sendTimeout: const Duration(milliseconds: ApiConfig.sendTimeout),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        validateStatus: (status) => status != null && status < 500,
      ),
    );

    // Add interceptors
    _dio.interceptors.addAll([
      AuthInterceptor(),
      ErrorInterceptor(),
      if (kDebugMode) LoggingInterceptor(),
    ]);

    // Configure certificate pinning (mobile platforms only)
    if (!kIsWeb) {
      _configureCertificatePinning();
    }

    _initialized = true;
  }

  /// Configure certificate pinning for MITM prevention
  /// Per CLAUDE.md: SHA-256 fingerprint validation required
  static void _configureCertificatePinning() {
    (_dio.httpClientAdapter as IOHttpClientAdapter).createHttpClient = () {
      final client = CertificatePins.createSecureClient();

      // Additional security settings
      client.findProxy = HttpClient.findProxyFromEnvironment;

      if (kDebugMode) {
        debugPrint('[DioClient] Certificate pinning configured');
      }

      return client;
    };
  }

  /// Reset client (useful for testing)
  static void reset() {
    _initialized = false;
  }
}

/// Extension methods for Dio
extension DioExtensions on Dio {
  /// Make a request with retry support
  Future<Response<T>> requestWithRetry<T>(
    String path, {
    required String method,
    Object? data,
    Map<String, dynamic>? queryParameters,
    Options? options,
    int maxRetries = ApiConfig.maxRetries,
  }) async {
    int retryCount = 0;

    while (true) {
      try {
        return await request<T>(
          path,
          data: data,
          queryParameters: queryParameters,
          options: (options ?? Options()).copyWith(method: method),
        );
      } on DioException catch (e) {
        if (retryCount >= maxRetries ||
            e.type == DioExceptionType.badResponse) {
          rethrow;
        }

        retryCount++;
        await Future.delayed(
          Duration(milliseconds: ApiConfig.retryDelay * retryCount),
        );
      }
    }
  }
}
