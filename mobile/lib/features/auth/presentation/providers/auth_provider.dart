import 'package:flutter/material.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../data/auth_repository.dart';
import '../../data/biometric_service.dart';
import '../../domain/models/models.dart';

part 'auth_provider.g.dart';

/// Authentication state
sealed class AuthState {
  const AuthState();
}

/// Initial state - checking stored auth
class AuthInitial extends AuthState {
  const AuthInitial();
}

/// Not authenticated
class AuthUnauthenticated extends AuthState {
  const AuthUnauthenticated();
}

/// Authenticated but PIN required
class AuthPinRequired extends AuthState {
  final Employee employee;
  final bool biometricAvailable;
  const AuthPinRequired({
    required this.employee,
    required this.biometricAvailable,
  });
}

/// First login - PIN setup required
class AuthPinSetupRequired extends AuthState {
  final Employee employee;
  const AuthPinSetupRequired({required this.employee});
}

/// Fully authenticated
class AuthAuthenticated extends AuthState {
  final Employee employee;
  const AuthAuthenticated({required this.employee});
}

/// Authentication error
class AuthError extends AuthState {
  final String message;
  final String? code;
  const AuthError({required this.message, this.code});
}

/// Main auth state provider
@riverpod
class AuthNotifier extends _$AuthNotifier {
  @override
  AuthState build() {
    _checkAuthState();
    return const AuthInitial();
  }

  AuthRepository get _repo => ref.read(authRepositoryProvider);

  /// Check initial auth state on app launch
  Future<void> _checkAuthState() async {
    final isLoggedIn = await _repo.isLoggedIn();
    if (!isLoggedIn) {
      state = const AuthUnauthenticated();
      return;
    }

    // User is logged in, check if PIN verification needed
    final biometricEnabled = await _repo.isBiometricEnabled();
    // For now, assume PIN verification is always required on app launch
    // Employee data would be loaded from storage
    state = const AuthUnauthenticated(); // Simplified for now
  }

  /// Login with email and password
  Future<void> login({
    required String email,
    required String password,
  }) async {
    try {
      final response = await _repo.login(
        email: email,
        password: password,
      );

      if (response.requiresPinSetup) {
        state = AuthPinSetupRequired(employee: response.employee);
      } else {
        // Require PIN verification after login
        final biometricAvailable = await _repo.isBiometricEnabled();
        state = AuthPinRequired(
          employee: response.employee,
          biometricAvailable: biometricAvailable,
        );
      }
    } on AuthException catch (e) {
      state = AuthError(message: e.message, code: e.code);
    } catch (e) {
      state = AuthError(message: e.toString());
    }
  }

  /// Setup PIN after first login
  Future<void> setupPin({
    required String pin,
    required String confirmPin,
    bool enableBiometric = false,
  }) async {
    try {
      final response = await _repo.setupPin(
        pin: pin,
        confirmPin: confirmPin,
        enableBiometric: enableBiometric,
      );

      if (response.success) {
        // Get current employee from state
        final currentState = state;
        if (currentState is AuthPinSetupRequired) {
          state = AuthAuthenticated(employee: currentState.employee);
        }
      } else {
        state = AuthError(message: response.message ?? 'PIN setup failed');
      }
    } catch (e) {
      state = AuthError(message: e.toString());
    }
  }

  /// Verify PIN
  Future<bool> verifyPin(String pin, {String purpose = 'app_unlock'}) async {
    try {
      final response = await _repo.verifyPin(pin: pin, purpose: purpose);

      if (response.success) {
        final currentState = state;
        if (currentState is AuthPinRequired) {
          state = AuthAuthenticated(employee: currentState.employee);
        }
        return true;
      }
      return false;
    } catch (e) {
      return false;
    }
  }

  /// Authenticate with biometrics
  Future<bool> authenticateWithBiometric() async {
    try {
      final result = await _repo.authenticateWithBiometric(
        localizedReason: 'Authenticate to access KerjaFlow',
      );

      if (result is BiometricSuccess) {
        final currentState = state;
        if (currentState is AuthPinRequired) {
          state = AuthAuthenticated(employee: currentState.employee);
        }
        return true;
      }
      return false;
    } catch (e) {
      return false;
    }
  }

  /// Logout
  Future<void> logout() async {
    await _repo.logout();
    state = const AuthUnauthenticated();
  }

  /// Clear error state
  void clearError() {
    if (state is AuthError) {
      state = const AuthUnauthenticated();
    }
  }
}

/// Login form state
@riverpod
class LoginForm extends _$LoginForm {
  @override
  LoginFormState build() => const LoginFormState();

  void setEmail(String email) {
    state = state.copyWith(email: email);
  }

  void setPassword(String password) {
    state = state.copyWith(password: password);
  }

  void setPasswordVisible(bool visible) {
    state = state.copyWith(passwordVisible: visible);
  }

  void setLoading(bool loading) {
    state = state.copyWith(isLoading: loading);
  }

  void setError(String? error) {
    state = state.copyWith(error: error);
  }

  void clearForm() {
    state = const LoginFormState();
  }

  bool get isValid =>
      state.email.isNotEmpty &&
      state.email.contains('@') &&
      state.password.length >= 8;
}

/// Login form data
class LoginFormState {
  final String email;
  final String password;
  final bool passwordVisible;
  final bool isLoading;
  final String? error;

  const LoginFormState({
    this.email = '',
    this.password = '',
    this.passwordVisible = false,
    this.isLoading = false,
    this.error,
  });

  LoginFormState copyWith({
    String? email,
    String? password,
    bool? passwordVisible,
    bool? isLoading,
    String? error,
  }) {
    return LoginFormState(
      email: email ?? this.email,
      password: password ?? this.password,
      passwordVisible: passwordVisible ?? this.passwordVisible,
      isLoading: isLoading ?? this.isLoading,
      error: error,
    );
  }
}

/// PIN entry state
@riverpod
class PinEntry extends _$PinEntry {
  @override
  PinEntryState build() => const PinEntryState();

  void addDigit(String digit) {
    if (state.pin.length < 6) {
      state = state.copyWith(pin: state.pin + digit);
    }
  }

  void removeDigit() {
    if (state.pin.isNotEmpty) {
      state = state.copyWith(pin: state.pin.substring(0, state.pin.length - 1));
    }
  }

  void clear() {
    state = const PinEntryState();
  }

  void setError(String? error) {
    state = state.copyWith(error: error, pin: '');
  }

  void setLoading(bool loading) {
    state = state.copyWith(isLoading: loading);
  }

  void incrementAttempts() {
    state = state.copyWith(attempts: state.attempts + 1);
  }

  bool get isComplete => state.pin.length == 6;
}

/// PIN entry data
class PinEntryState {
  final String pin;
  final bool isLoading;
  final String? error;
  final int attempts;

  const PinEntryState({
    this.pin = '',
    this.isLoading = false,
    this.error,
    this.attempts = 0,
  });

  PinEntryState copyWith({
    String? pin,
    bool? isLoading,
    String? error,
    int? attempts,
  }) {
    return PinEntryState(
      pin: pin ?? this.pin,
      isLoading: isLoading ?? this.isLoading,
      error: error,
      attempts: attempts ?? this.attempts,
    );
  }

  int get remainingAttempts => 5 - attempts;
  bool get isLockedOut => attempts >= 5;
}

/// PIN setup state for first-time configuration
@riverpod
class PinSetup extends _$PinSetup {
  @override
  PinSetupState build() => const PinSetupState();

  void setPin(String pin) {
    state = state.copyWith(pin: pin);
  }

  void setConfirmPin(String confirmPin) {
    state = state.copyWith(confirmPin: confirmPin);
  }

  void setStep(PinSetupStep step) {
    state = state.copyWith(step: step);
  }

  void setEnableBiometric(bool enable) {
    state = state.copyWith(enableBiometric: enable);
  }

  void setLoading(bool loading) {
    state = state.copyWith(isLoading: loading);
  }

  void setError(String? error) {
    state = state.copyWith(error: error);
  }

  void addDigit(String digit) {
    if (state.step == PinSetupStep.enterPin && state.pin.length < 6) {
      state = state.copyWith(pin: state.pin + digit);
    } else if (state.step == PinSetupStep.confirmPin && state.confirmPin.length < 6) {
      state = state.copyWith(confirmPin: state.confirmPin + digit);
    }
  }

  void removeDigit() {
    if (state.step == PinSetupStep.enterPin && state.pin.isNotEmpty) {
      state = state.copyWith(pin: state.pin.substring(0, state.pin.length - 1));
    } else if (state.step == PinSetupStep.confirmPin && state.confirmPin.isNotEmpty) {
      state = state.copyWith(
        confirmPin: state.confirmPin.substring(0, state.confirmPin.length - 1),
      );
    }
  }

  void clear() {
    state = const PinSetupState();
  }

  bool get isPinComplete => state.pin.length == 6;
  bool get isConfirmComplete => state.confirmPin.length == 6;
  bool get pinsMatch => state.pin == state.confirmPin;
}

enum PinSetupStep { enterPin, confirmPin, enableBiometric }

class PinSetupState {
  final String pin;
  final String confirmPin;
  final PinSetupStep step;
  final bool enableBiometric;
  final bool isLoading;
  final String? error;

  const PinSetupState({
    this.pin = '',
    this.confirmPin = '',
    this.step = PinSetupStep.enterPin,
    this.enableBiometric = false,
    this.isLoading = false,
    this.error,
  });

  PinSetupState copyWith({
    String? pin,
    String? confirmPin,
    PinSetupStep? step,
    bool? enableBiometric,
    bool? isLoading,
    String? error,
  }) {
    return PinSetupState(
      pin: pin ?? this.pin,
      confirmPin: confirmPin ?? this.confirmPin,
      step: step ?? this.step,
      enableBiometric: enableBiometric ?? this.enableBiometric,
      isLoading: isLoading ?? this.isLoading,
      error: error,
    );
  }
}
