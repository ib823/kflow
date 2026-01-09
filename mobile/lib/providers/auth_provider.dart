import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/models/models.dart';
import 'states/states.dart';

/// Auth state notifier
class AuthNotifier extends StateNotifier<AuthState> {
  AuthNotifier() : super(const AuthState.initial());

  /// Check authentication status on app start
  Future<void> checkAuthStatus() async {
    state = const AuthState.loading();

    try {
      // TODO: Check stored tokens from secure storage
      await Future.delayed(const Duration(milliseconds: 500));

      // For now, return unauthenticated
      state = const AuthState.unauthenticated();
    } catch (e) {
      state = AuthState.error(message: e.toString());
    }
  }

  /// Login with employee ID and password
  Future<void> login({
    required String employeeId,
    required String password,
  }) async {
    state = const AuthState.loading();

    try {
      // TODO: Call API
      await Future.delayed(const Duration(seconds: 2));

      // Mock user for development
      final user = User(
        id: '1',
        employeeId: employeeId,
        name: 'Ahmad Razak',
        email: 'ahmad.razak@company.com',
        department: 'Production',
        position: 'Senior Supervisor',
        joinDate: DateTime(2018, 1, 1),
        role: UserRole.supervisor,
        isSupervisor: true,
      );

      state = AuthState.authenticated(
        user: user,
        accessToken: 'mock_access_token',
        refreshToken: 'mock_refresh_token',
      );
    } catch (e) {
      state = AuthState.error(message: e.toString());
    }
  }

  /// Logout
  Future<void> logout() async {
    state = const AuthState.loading();

    try {
      // TODO: Clear tokens from secure storage
      await Future.delayed(const Duration(milliseconds: 500));
      state = const AuthState.unauthenticated();
    } catch (e) {
      state = AuthState.error(message: e.toString());
    }
  }

  /// Refresh token
  Future<void> refreshToken() async {
    final currentState = state;
    if (currentState is! AuthStateAuthenticated) return;

    try {
      // TODO: Call refresh token API
      await Future.delayed(const Duration(milliseconds: 500));

      // Mock refresh
      state = AuthState.authenticated(
        user: currentState.user,
        accessToken: 'new_access_token',
        refreshToken: currentState.refreshToken,
      );
    } catch (e) {
      state = const AuthState.unauthenticated(
        message: 'Session expired. Please login again.',
      );
    }
  }
}

/// Auth provider
final authProvider = StateNotifierProvider<AuthNotifier, AuthState>((ref) {
  return AuthNotifier();
});

/// Current user provider (derived from auth state)
final currentUserProvider = Provider<User?>((ref) {
  final authState = ref.watch(authProvider);
  return authState.maybeWhen(
    authenticated: (user, _, __) => user,
    orElse: () => null,
  );
});

/// Is authenticated provider (derived from auth state)
final isAuthenticatedProvider = Provider<bool>((ref) {
  final authState = ref.watch(authProvider);
  return authState.maybeWhen(
    authenticated: (_, __, ___) => true,
    orElse: () => false,
  );
});

/// Access token provider
final accessTokenProvider = Provider<String?>((ref) {
  final authState = ref.watch(authProvider);
  return authState.maybeWhen(
    authenticated: (_, accessToken, __) => accessToken,
    orElse: () => null,
  );
});
