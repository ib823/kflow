import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mocktail/mocktail.dart';
import 'mock_data.dart';

// Mock classes for repositories
class MockAuthRepository extends Mock {
  Future<Map<String, dynamic>> login({
    required String employeeId,
    required String password,
  }) async {
    if (employeeId == MockData.employeeId && password == MockData.password) {
      return {
        'user': MockData.mockUser,
        'access_token': MockData.accessToken,
        'refresh_token': MockData.refreshToken,
        'expires_in': 900,
      };
    }
    throw Exception('Invalid credentials');
  }

  Future<void> logout() async {}

  Future<bool> verifyPin(String pin) async {
    return pin == MockData.validPin;
  }
}

class MockPayslipRepository extends Mock {
  Future<List<Map<String, dynamic>>> getPayslips({required int year}) async {
    return MockData.mockPayslipList;
  }

  Future<Map<String, dynamic>> getPayslip(String id) async {
    return MockData.mockPayslip;
  }
}

class MockLeaveRepository extends Mock {
  Future<List<Map<String, dynamic>>> getBalances() async {
    return MockData.mockLeaveBalances;
  }

  Future<List<Map<String, dynamic>>> getRequests() async {
    return [MockData.mockLeaveRequest];
  }
}

// State notifiers for testing
class MockAuthNotifier extends StateNotifier<AsyncValue<Map<String, dynamic>?>> {
  MockAuthNotifier() : super(const AsyncValue.data(null));

  Future<void> login(String employeeId, String password) async {
    state = const AsyncValue.loading();
    await Future.delayed(const Duration(milliseconds: 100));
    if (employeeId == MockData.employeeId && password == MockData.password) {
      state = AsyncValue.data(MockData.mockUser);
    } else {
      state = AsyncValue.error('Invalid credentials', StackTrace.current);
    }
  }

  Future<void> logout() async {
    state = const AsyncValue.data(null);
  }
}

class MockPayslipNotifier extends StateNotifier<AsyncValue<List<Map<String, dynamic>>>> {
  MockPayslipNotifier() : super(const AsyncValue.loading());

  Future<void> fetchPayslips({int? year}) async {
    state = const AsyncValue.loading();
    await Future.delayed(const Duration(milliseconds: 100));
    state = AsyncValue.data(MockData.mockPayslipList);
  }
}

class MockLeaveNotifier extends StateNotifier<AsyncValue<List<Map<String, dynamic>>>> {
  MockLeaveNotifier() : super(const AsyncValue.loading());

  Future<void> fetchBalances() async {
    state = const AsyncValue.loading();
    await Future.delayed(const Duration(milliseconds: 100));
    state = AsyncValue.data(MockData.mockLeaveBalances);
  }
}

// Provider overrides for testing
class MockProviders {
  // Auth state provider
  static final authStateProvider =
      StateNotifierProvider<MockAuthNotifier, AsyncValue<Map<String, dynamic>?>>((ref) {
    return MockAuthNotifier();
  });

  // Payslip state provider
  static final payslipStateProvider =
      StateNotifierProvider<MockPayslipNotifier, AsyncValue<List<Map<String, dynamic>>>>((ref) {
    return MockPayslipNotifier();
  });

  // Leave state provider
  static final leaveStateProvider =
      StateNotifierProvider<MockLeaveNotifier, AsyncValue<List<Map<String, dynamic>>>>((ref) {
    return MockLeaveNotifier();
  });

  // Connectivity provider - always online in tests
  static final connectivityProvider = Provider<bool>((ref) => true);

  // Get all overrides for testing
  static List<Override> get allOverrides => [
        authStateProvider.overrideWith((ref) => MockAuthNotifier()),
        payslipStateProvider.overrideWith((ref) => MockPayslipNotifier()),
        leaveStateProvider.overrideWith((ref) => MockLeaveNotifier()),
        connectivityProvider.overrideWithValue(true),
      ];
}
