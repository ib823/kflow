import 'package:dio/dio.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../core/network/dio_client.dart';
import '../domain/models/models.dart';

part 'auth_api.g.dart';

/// Auth API client for KerjaFlow authentication endpoints.
///
/// All endpoints are under /api/v1/auth/*
/// Rate limited: 10 requests/minute
class AuthApi {
  final Dio _dio;

  AuthApi(this._dio);

  /// POST /api/v1/auth/login
  ///
  /// Authenticates user with email/password.
  /// Returns JWT tokens and employee profile.
  Future<LoginResponse> login(LoginRequest request) async {
    final response = await _dio.post(
      '/api/v1/auth/login',
      data: request.toJson(),
    );
    return LoginResponse.fromJson(response.data['data']);
  }

  /// POST /api/v1/auth/refresh
  ///
  /// Refreshes access token using refresh token.
  Future<RefreshTokenResponse> refreshToken(String refreshToken) async {
    final response = await _dio.post(
      '/api/v1/auth/refresh',
      data: {'refresh_token': refreshToken},
    );
    return RefreshTokenResponse.fromJson(response.data['data']);
  }

  /// POST /api/v1/auth/logout
  ///
  /// Invalidates current session and refresh token.
  Future<void> logout() async {
    await _dio.post('/api/v1/auth/logout');
  }

  /// POST /api/v1/auth/pin/setup
  ///
  /// Sets up 6-digit PIN for first-time login.
  /// PIN is bcrypt hashed server-side.
  Future<PinSetupResponse> setupPin(PinSetupRequest request) async {
    final response = await _dio.post(
      '/api/v1/auth/pin/setup',
      data: request.toJson(),
    );
    return PinSetupResponse.fromJson(response.data['data']);
  }

  /// POST /api/v1/auth/pin/verify
  ///
  /// Verifies PIN for app unlock or sensitive operations.
  /// Returns lockout status after 5 failed attempts.
  Future<PinVerifyResponse> verifyPin(PinVerifyRequest request) async {
    final response = await _dio.post(
      '/api/v1/auth/pin/verify',
      data: request.toJson(),
    );
    return PinVerifyResponse.fromJson(response.data['data']);
  }

  /// POST /api/v1/auth/password/change
  ///
  /// Changes user password. Requires current password.
  Future<void> changePassword({
    required String currentPassword,
    required String newPassword,
  }) async {
    await _dio.post(
      '/api/v1/auth/password/change',
      data: {
        'current_password': currentPassword,
        'new_password': newPassword,
      },
    );
  }
}

/// Provider for AuthApi instance
@riverpod
AuthApi authApi(AuthApiRef ref) {
  final dio = ref.watch(dioClientProvider);
  return AuthApi(dio);
}
