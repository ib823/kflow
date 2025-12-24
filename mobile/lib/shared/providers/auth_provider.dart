import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:dio/dio.dart';

import '../../core/network/dio_client.dart';
import '../../core/storage/secure_storage.dart';
import '../../core/config/app_config.dart';
import '../models/user.dart';

part 'auth_provider.g.dart';

class AuthState {
  final User? user;
  final bool isLoggedIn;
  final bool isLoading;
  final String? error;

  const AuthState({
    this.user,
    this.isLoggedIn = false,
    this.isLoading = false,
    this.error,
  });

  AuthState copyWith({
    User? user,
    bool? isLoggedIn,
    bool? isLoading,
    String? error,
  }) {
    return AuthState(
      user: user ?? this.user,
      isLoggedIn: isLoggedIn ?? this.isLoggedIn,
      isLoading: isLoading ?? this.isLoading,
      error: error,
    );
  }
}

@riverpod
class AuthStateNotifier extends _$AuthStateNotifier {
  @override
  Future<AuthState> build() async {
    final storage = ref.read(secureStorageProvider);
    final isValid = await storage.isTokenValid();

    if (isValid) {
      try {
        final user = await _fetchCurrentUser();
        return AuthState(user: user, isLoggedIn: true);
      } catch (e) {
        await storage.clearTokens();
        return const AuthState(isLoggedIn: false);
      }
    }

    return const AuthState(isLoggedIn: false);
  }

  Future<User> _fetchCurrentUser() async {
    final dio = ref.read(dioClientProvider);
    final response = await dio.get('/profile');
    return User.fromJson(response.data);
  }

  Future<void> login(String email, String password) async {
    state = const AsyncValue.loading();

    try {
      final dio = ref.read(dioClientProvider);
      final storage = ref.read(secureStorageProvider);

      final response = await dio.post('/auth/login', data: {
        'email': email,
        'password': password,
      });

      final loginResponse = LoginResponse.fromJson(response.data);

      await storage.saveTokens(
        accessToken: loginResponse.tokens.accessToken,
        refreshToken: loginResponse.tokens.refreshToken,
        expiresIn: loginResponse.tokens.expiresIn,
      );

      await storage.saveUserInfo(
        userId: loginResponse.user.id,
        email: loginResponse.user.email,
        role: loginResponse.user.role,
      );

      state = AsyncValue.data(AuthState(
        user: loginResponse.user,
        isLoggedIn: true,
      ));
    } on DioException catch (e) {
      final message = e.response?.data?['message'] ?? 'Login failed';
      state = AsyncValue.error(message, StackTrace.current);
    } catch (e) {
      state = AsyncValue.error(e.toString(), StackTrace.current);
    }
  }

  Future<void> logout() async {
    try {
      final dio = ref.read(dioClientProvider);
      await dio.post('/auth/logout');
    } catch (e) {
      // Ignore errors during logout
    } finally {
      final storage = ref.read(secureStorageProvider);
      await storage.clearAll();
      state = const AsyncValue.data(AuthState(isLoggedIn: false));
    }
  }

  Future<void> refreshToken() async {
    try {
      final storage = ref.read(secureStorageProvider);
      final refreshToken = await storage.getRefreshToken();

      if (refreshToken == null) {
        throw Exception('No refresh token available');
      }

      final dio = Dio(BaseOptions(
        baseUrl: AppConfig.apiBaseUrl,
        headers: {'Content-Type': 'application/json'},
      ));

      final response = await dio.post('/auth/refresh', data: {
        'refresh_token': refreshToken,
      });

      final tokens = AuthTokens.fromJson(response.data);

      await storage.saveTokens(
        accessToken: tokens.accessToken,
        refreshToken: tokens.refreshToken,
        expiresIn: tokens.expiresIn,
      );
    } catch (e) {
      await logout();
      rethrow;
    }
  }

  Future<bool> setupPin(String pin) async {
    try {
      final dio = ref.read(dioClientProvider);
      await dio.post('/auth/pin/setup', data: {'pin': pin});

      // Update user state
      final currentState = state.valueOrNull;
      if (currentState?.user != null) {
        final updatedUser = User(
          id: currentState!.user!.id,
          email: currentState.user!.email,
          role: currentState.user!.role,
          status: currentState.user!.status,
          hasPin: true,
          employee: currentState.user!.employee,
        );
        state = AsyncValue.data(currentState.copyWith(user: updatedUser));
      }

      return true;
    } catch (e) {
      return false;
    }
  }

  Future<String?> verifyPin(String pin) async {
    try {
      final dio = ref.read(dioClientProvider);
      final storage = ref.read(secureStorageProvider);

      final response = await dio.post('/auth/pin/verify', data: {'pin': pin});

      final token = response.data['verification_token'] as String;
      final expiresIn = response.data['expires_in'] as int? ?? 300;

      await storage.savePinVerification(token, expiresIn);

      return token;
    } catch (e) {
      return null;
    }
  }

  Future<bool> changePassword(String currentPassword, String newPassword) async {
    try {
      final dio = ref.read(dioClientProvider);
      await dio.post('/auth/password/change', data: {
        'current_password': currentPassword,
        'new_password': newPassword,
      });
      return true;
    } catch (e) {
      return false;
    }
  }
}

@riverpod
Future<AuthState> authState(AuthStateRef ref) async {
  return ref.watch(authStateNotifierProvider.future);
}
