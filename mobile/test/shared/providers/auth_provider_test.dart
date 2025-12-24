import 'package:flutter_test/flutter_test.dart';
import 'package:kerjaflow/shared/providers/auth_provider.dart';
import 'package:kerjaflow/shared/models/user.dart';

void main() {
  group('AuthState', () {
    test('default state is not logged in', () {
      const state = AuthState();

      expect(state.isLoggedIn, isFalse);
      expect(state.user, isNull);
      expect(state.error, isNull);
      expect(state.isLoading, isFalse);
    });

    test('loading state has isLoading true', () {
      const state = AuthState(isLoading: true);

      expect(state.isLoading, isTrue);
      expect(state.isLoggedIn, isFalse);
    });

    test('authenticated state contains user', () {
      const employee = Employee(
        id: 1,
        employeeNo: 'EMP001',
        fullName: 'Test User',
        email: 'test@example.com',
        status: 'active',
      );

      final user = User(
        id: 1,
        email: 'test@example.com',
        role: 'EMPLOYEE',
        status: 'ACTIVE',
        employee: employee,
      );

      final state = AuthState(
        user: user,
        isLoggedIn: true,
      );

      expect(state.isLoggedIn, isTrue);
      expect(state.user, equals(user));
      expect(state.user?.employee?.fullName, 'Test User');
    });

    test('error state contains error message', () {
      const state = AuthState(error: 'Invalid credentials');

      expect(state.error, 'Invalid credentials');
      expect(state.isLoggedIn, isFalse);
    });

    test('copyWith creates new state with updated values', () {
      const initial = AuthState();
      final updated = initial.copyWith(
        isLoading: true,
      );

      expect(updated.isLoading, isTrue);
      expect(initial.isLoading, isFalse);
    });

    test('copyWith preserves existing values when not specified', () {
      const employee = Employee(
        id: 1,
        employeeNo: 'EMP001',
        fullName: 'Test User',
        email: 'test@example.com',
        status: 'active',
      );

      final user = User(
        id: 1,
        email: 'test@example.com',
        role: 'EMPLOYEE',
        status: 'ACTIVE',
        employee: employee,
      );

      final state = AuthState(user: user, isLoggedIn: true);
      final updated = state.copyWith(isLoading: true);

      expect(updated.user, equals(user));
      expect(updated.isLoggedIn, isTrue);
      expect(updated.isLoading, isTrue);
    });

    test('copyWith can clear error', () {
      const state = AuthState(error: 'Some error');
      final updated = state.copyWith(error: null);

      expect(updated.error, isNull);
    });
  });

  group('PIN Validation', () {
    test('valid 6-digit PIN is accepted', () {
      expect(isValidPin('123456'), isTrue);
      expect(isValidPin('000000'), isTrue);
      expect(isValidPin('999999'), isTrue);
    });

    test('invalid PIN formats are rejected', () {
      expect(isValidPin('12345'), isFalse); // Too short
      expect(isValidPin('1234567'), isFalse); // Too long
      expect(isValidPin('abcdef'), isFalse); // Not digits
      expect(isValidPin('12 345'), isFalse); // Contains space
      expect(isValidPin(''), isFalse); // Empty
    });

    test('PIN with leading zeros is valid', () {
      expect(isValidPin('012345'), isTrue);
      expect(isValidPin('001234'), isTrue);
    });
  });
}

/// Helper function to validate PIN format
bool isValidPin(String pin) {
  if (pin.length != 6) return false;
  return RegExp(r'^\d{6}$').hasMatch(pin);
}
