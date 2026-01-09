import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/models/models.dart';

/// Approval list notifier
class ApprovalListNotifier extends StateNotifier<AsyncValue<List<Approval>>> {
  ApprovalListNotifier() : super(const AsyncValue.loading());

  ApprovalStatus? _statusFilter;

  /// Get current filter
  ApprovalStatus? get statusFilter => _statusFilter;

  /// Fetch approvals
  Future<void> fetchApprovals({ApprovalStatus? status}) async {
    _statusFilter = status;
    state = const AsyncValue.loading();

    try {
      // TODO: Call API
      await Future.delayed(const Duration(seconds: 1));

      // Mock data for development
      final approvals = <Approval>[
        Approval(
          id: 'apr-001',
          employeeId: 'EMP-0042',
          employeeName: 'Sarah Abdullah',
          employeeDepartment: 'Production',
          type: ApprovalType.leave,
          title: 'Annual Leave',
          description: '15 Jan - 17 Jan 2026 (3 days)',
          status: ApprovalStatus.pending,
          submittedAt: DateTime(2026, 1, 5),
          details: {
            'leaveType': 'Annual Leave',
            'startDate': '2026-01-15',
            'endDate': '2026-01-17',
            'days': 3,
            'reason': 'Family vacation',
            'balanceAfter': 9,
          },
        ),
        Approval(
          id: 'apr-002',
          employeeId: 'EMP-0087',
          employeeName: 'Mohammad Ali',
          employeeDepartment: 'Production',
          type: ApprovalType.leave,
          title: 'Medical Leave',
          description: '10 Jan 2026 (1 day)',
          status: ApprovalStatus.pending,
          submittedAt: DateTime(2026, 1, 10),
          details: {
            'leaveType': 'Medical Leave',
            'startDate': '2026-01-10',
            'endDate': '2026-01-10',
            'days': 1,
            'reason': 'Unwell',
            'hasAttachment': true,
          },
        ),
        Approval(
          id: 'apr-003',
          employeeId: 'EMP-0055',
          employeeName: 'Siti Aminah',
          employeeDepartment: 'Quality',
          type: ApprovalType.leave,
          title: 'Emergency Leave',
          description: '8 Jan 2026 (1 day)',
          status: ApprovalStatus.approved,
          submittedAt: DateTime(2026, 1, 8),
          respondedAt: DateTime(2026, 1, 8),
          details: {
            'leaveType': 'Emergency Leave',
            'startDate': '2026-01-08',
            'endDate': '2026-01-08',
            'days': 1,
            'reason': 'Family emergency',
          },
        ),
      ];

      // Apply filter
      final filtered = status == null
          ? approvals
          : approvals.where((a) => a.status == status).toList();

      state = AsyncValue.data(filtered);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  /// Set status filter
  void setFilter(ApprovalStatus? status) {
    fetchApprovals(status: status);
  }

  /// Approve request
  Future<bool> approve(String id, {String? comment}) async {
    try {
      // TODO: Call API
      await Future.delayed(const Duration(seconds: 1));

      // Update local state
      state.whenData((approvals) {
        state = AsyncValue.data(
          approvals.map((a) {
            if (a.id == id) {
              return Approval(
                id: a.id,
                employeeId: a.employeeId,
                employeeName: a.employeeName,
                employeeAvatarUrl: a.employeeAvatarUrl,
                employeeDepartment: a.employeeDepartment,
                type: a.type,
                title: a.title,
                description: a.description,
                status: ApprovalStatus.approved,
                submittedAt: a.submittedAt,
                details: a.details,
                comment: comment,
                respondedAt: DateTime.now(),
              );
            }
            return a;
          }).toList(),
        );
      });

      return true;
    } catch (e) {
      return false;
    }
  }

  /// Reject request
  Future<bool> reject(String id, {required String comment}) async {
    try {
      // TODO: Call API
      await Future.delayed(const Duration(seconds: 1));

      // Update local state
      state.whenData((approvals) {
        state = AsyncValue.data(
          approvals.map((a) {
            if (a.id == id) {
              return Approval(
                id: a.id,
                employeeId: a.employeeId,
                employeeName: a.employeeName,
                employeeAvatarUrl: a.employeeAvatarUrl,
                employeeDepartment: a.employeeDepartment,
                type: a.type,
                title: a.title,
                description: a.description,
                status: ApprovalStatus.rejected,
                submittedAt: a.submittedAt,
                details: a.details,
                comment: comment,
                respondedAt: DateTime.now(),
              );
            }
            return a;
          }).toList(),
        );
      });

      return true;
    } catch (e) {
      return false;
    }
  }

  /// Refresh approvals
  Future<void> refresh() => fetchApprovals(status: _statusFilter);
}

/// Approval list provider
final approvalListProvider =
    StateNotifierProvider<ApprovalListNotifier, AsyncValue<List<Approval>>>((ref) {
  final notifier = ApprovalListNotifier();
  notifier.fetchApprovals();
  return notifier;
});

/// Single approval provider (by ID)
final approvalProvider =
    FutureProvider.family<Approval?, String>((ref, id) async {
  final approvals = ref.watch(approvalListProvider);

  return approvals.whenOrNull(
    data: (list) {
      try {
        return list.firstWhere((a) => a.id == id);
      } catch (_) {
        return null;
      }
    },
  );
});

/// Pending approval count provider (for badge)
final pendingApprovalCountProvider = Provider<int>((ref) {
  final approvals = ref.watch(approvalListProvider);
  return approvals.maybeWhen(
    data: (list) => list.where((a) => a.status == ApprovalStatus.pending).length,
    orElse: () => 0,
  );
});
