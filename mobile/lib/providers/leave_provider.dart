import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/models/models.dart';

/// Leave balance notifier
class LeaveBalanceNotifier extends StateNotifier<AsyncValue<List<LeaveBalance>>> {
  LeaveBalanceNotifier() : super(const AsyncValue.loading());

  /// Fetch leave balances
  Future<void> fetchBalances() async {
    state = const AsyncValue.loading();

    try {
      // TODO: Call API
      await Future.delayed(const Duration(seconds: 1));

      // Mock data for development
      state = const AsyncValue.data([
        LeaveBalance(
          leaveTypeId: 'annual',
          leaveTypeName: 'Annual Leave',
          colorValue: 0xFF4CAF50,
          iconName: 'beach_access',
          entitled: 16,
          taken: 4,
          pending: 0,
          balance: 12,
        ),
        LeaveBalance(
          leaveTypeId: 'medical',
          leaveTypeName: 'Medical Leave',
          colorValue: 0xFFE91E63,
          iconName: 'local_hospital',
          entitled: 14,
          taken: 4,
          pending: 0,
          balance: 10,
        ),
        LeaveBalance(
          leaveTypeId: 'emergency',
          leaveTypeName: 'Emergency Leave',
          colorValue: 0xFFFF9800,
          iconName: 'warning_amber',
          entitled: 3,
          taken: 1,
          pending: 0,
          balance: 2,
        ),
        LeaveBalance(
          leaveTypeId: 'compassionate',
          leaveTypeName: 'Compassionate',
          colorValue: 0xFF9C27B0,
          iconName: 'favorite_border',
          entitled: 3,
          taken: 0,
          pending: 0,
          balance: 3,
        ),
      ]);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  /// Refresh balances
  Future<void> refresh() => fetchBalances();
}

/// Leave balance provider
final leaveBalanceProvider =
    StateNotifierProvider<LeaveBalanceNotifier, AsyncValue<List<LeaveBalance>>>((ref) {
  final notifier = LeaveBalanceNotifier();
  notifier.fetchBalances();
  return notifier;
});

/// Leave requests notifier
class LeaveRequestsNotifier extends StateNotifier<AsyncValue<List<LeaveRequest>>> {
  LeaveRequestsNotifier() : super(const AsyncValue.loading());

  LeaveStatus? _statusFilter;

  /// Get current filter
  LeaveStatus? get statusFilter => _statusFilter;

  /// Fetch leave requests
  Future<void> fetchRequests({LeaveStatus? status}) async {
    _statusFilter = status;
    state = const AsyncValue.loading();

    try {
      // TODO: Call API
      await Future.delayed(const Duration(seconds: 1));

      // Mock data for development
      final requests = <LeaveRequest>[
        LeaveRequest(
          id: 'leave-1',
          leaveTypeId: 'annual',
          leaveTypeName: 'Annual Leave',
          leaveTypeColor: 0xFF4CAF50,
          startDate: DateTime(2026, 1, 15),
          endDate: DateTime(2026, 1, 17),
          days: 3,
          reason: 'Family vacation to Langkawi',
          status: LeaveStatus.pending,
          createdAt: DateTime(2026, 1, 5),
          updatedAt: DateTime(2026, 1, 5),
        ),
        LeaveRequest(
          id: 'leave-2',
          leaveTypeId: 'medical',
          leaveTypeName: 'Medical Leave',
          leaveTypeColor: 0xFFE91E63,
          startDate: DateTime(2026, 1, 2),
          endDate: DateTime(2026, 1, 2),
          days: 1,
          reason: 'Fever',
          attachmentUrl: 'https://example.com/mc.pdf',
          status: LeaveStatus.approved,
          approverId: 'supervisor-1',
          approverName: 'Ahmad Razak',
          respondedAt: DateTime(2026, 1, 2),
          createdAt: DateTime(2026, 1, 2),
          updatedAt: DateTime(2026, 1, 2),
        ),
        LeaveRequest(
          id: 'leave-3',
          leaveTypeId: 'emergency',
          leaveTypeName: 'Emergency Leave',
          leaveTypeColor: 0xFFFF9800,
          startDate: DateTime(2025, 12, 20),
          endDate: DateTime(2025, 12, 20),
          days: 1,
          reason: 'Family emergency',
          status: LeaveStatus.approved,
          approverId: 'supervisor-1',
          approverName: 'Ahmad Razak',
          respondedAt: DateTime(2025, 12, 20),
          createdAt: DateTime(2025, 12, 20),
          updatedAt: DateTime(2025, 12, 20),
        ),
      ];

      // Apply filter
      final filtered = status == null
          ? requests
          : requests.where((r) => r.status == status).toList();

      state = AsyncValue.data(filtered);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  /// Set status filter
  void setFilter(LeaveStatus? status) {
    fetchRequests(status: status);
  }

  /// Apply for leave
  Future<bool> applyLeave({
    required String leaveTypeId,
    required DateTime startDate,
    required DateTime endDate,
    required String reason,
    String? attachmentUrl,
  }) async {
    try {
      // TODO: Call API
      await Future.delayed(const Duration(seconds: 2));

      // Refresh list
      await fetchRequests(status: _statusFilter);
      return true;
    } catch (e) {
      return false;
    }
  }

  /// Cancel leave request
  Future<bool> cancelRequest(String id) async {
    try {
      // TODO: Call API
      await Future.delayed(const Duration(seconds: 1));

      // Refresh list
      await fetchRequests(status: _statusFilter);
      return true;
    } catch (e) {
      return false;
    }
  }

  /// Refresh requests
  Future<void> refresh() => fetchRequests(status: _statusFilter);
}

/// Leave requests provider
final leaveRequestsProvider =
    StateNotifierProvider<LeaveRequestsNotifier, AsyncValue<List<LeaveRequest>>>((ref) {
  final notifier = LeaveRequestsNotifier();
  notifier.fetchRequests();
  return notifier;
});

/// Single leave request provider (by ID)
final leaveRequestProvider =
    FutureProvider.family<LeaveRequest?, String>((ref, id) async {
  final requests = ref.watch(leaveRequestsProvider);

  return requests.whenOrNull(
    data: (list) {
      try {
        return list.firstWhere((r) => r.id == id);
      } catch (_) {
        return null;
      }
    },
  );
});

/// Pending leave count provider (for badge)
final pendingLeaveCountProvider = Provider<int>((ref) {
  final requests = ref.watch(leaveRequestsProvider);
  return requests.maybeWhen(
    data: (list) => list.where((r) => r.status == LeaveStatus.pending).length,
    orElse: () => 0,
  );
});

/// Total leave days taken this year
final totalLeaveTakenProvider = Provider<double>((ref) {
  final balances = ref.watch(leaveBalanceProvider);
  return balances.maybeWhen(
    data: (list) => list.fold<double>(0, (sum, b) => sum + b.taken),
    orElse: () => 0,
  );
});
