import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../data/leave_repository.dart';
import '../../domain/models/leave_models.dart';

part 'leave_provider.g.dart';

// =============================================================================
// Leave Types Provider
// =============================================================================

@riverpod
Future<List<LeaveType>> leaveTypes(LeaveTypesRef ref) async {
  return ref.watch(leaveRepositoryProvider).getLeaveTypes();
}

// =============================================================================
// Leave Balances Provider
// =============================================================================

@riverpod
class LeaveBalancesNotifier extends _$LeaveBalancesNotifier {
  @override
  Future<List<LeaveBalance>> build() async {
    return ref.watch(leaveRepositoryProvider).getLeaveBalances();
  }

  Future<void> refresh() async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(
      () => ref.read(leaveRepositoryProvider).getLeaveBalances(),
    );
  }
}

// =============================================================================
// Leave Requests Provider
// =============================================================================

@riverpod
class LeaveRequestsNotifier extends _$LeaveRequestsNotifier {
  String? _statusFilter;

  @override
  Future<List<LeaveRequest>> build() async {
    return ref.watch(leaveRepositoryProvider).getLeaveRequests(status: _statusFilter);
  }

  void setStatusFilter(String? status) {
    _statusFilter = status;
    ref.invalidateSelf();
  }

  Future<void> refresh() async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(
      () => ref.read(leaveRepositoryProvider).getLeaveRequests(status: _statusFilter),
    );
  }
}

/// Provider for single leave request detail.
@riverpod
Future<LeaveRequest> leaveRequestDetail(LeaveRequestDetailRef ref, int id) async {
  return ref.watch(leaveRepositoryProvider).getLeaveRequestDetail(id);
}

// =============================================================================
// Leave Apply State
// =============================================================================

@riverpod
class LeaveApplyNotifier extends _$LeaveApplyNotifier {
  @override
  LeaveApplyState build() => const LeaveApplyState();

  void setLeaveType(LeaveType type) {
    state = state.copyWith(selectedType: type, errors: []);
  }

  void setDateFrom(DateTime date) {
    state = state.copyWith(dateFrom: date, errors: []);
  }

  void setDateTo(DateTime date) {
    state = state.copyWith(dateTo: date, errors: []);
  }

  void setHalfDay(bool isHalfDay, {String? halfDayType}) {
    state = state.copyWith(
      isHalfDay: isHalfDay,
      halfDayType: halfDayType,
      errors: [],
    );
  }

  void setReason(String? reason) {
    state = state.copyWith(reason: reason);
  }

  void setAttachment(int? attachmentId) {
    state = state.copyWith(attachmentId: attachmentId);
  }

  Future<bool> submit() async {
    if (state.selectedType == null || state.dateFrom == null || state.dateTo == null) {
      state = state.copyWith(errors: ['Please fill all required fields']);
      return false;
    }

    state = state.copyWith(isSubmitting: true, errors: []);

    try {
      final request = LeaveApplyRequest(
        leaveTypeId: state.selectedType!.id,
        dateFrom: state.dateFrom!,
        dateTo: state.dateTo!,
        isHalfDay: state.isHalfDay,
        halfDayType: state.halfDayType,
        reason: state.reason,
        attachmentId: state.attachmentId,
      );

      await ref.read(leaveRepositoryProvider).submitLeaveRequest(request);

      // Invalidate related providers
      ref.invalidate(leaveRequestsNotifierProvider);
      ref.invalidate(leaveBalancesNotifierProvider);

      return true;
    } catch (e) {
      state = state.copyWith(errors: [e.toString()]);
      return false;
    } finally {
      state = state.copyWith(isSubmitting: false);
    }
  }

  void reset() {
    state = const LeaveApplyState();
  }
}

class LeaveApplyState {
  final LeaveType? selectedType;
  final DateTime? dateFrom;
  final DateTime? dateTo;
  final bool isHalfDay;
  final String? halfDayType;
  final String? reason;
  final int? attachmentId;
  final bool isSubmitting;
  final List<String> errors;

  const LeaveApplyState({
    this.selectedType,
    this.dateFrom,
    this.dateTo,
    this.isHalfDay = false,
    this.halfDayType,
    this.reason,
    this.attachmentId,
    this.isSubmitting = false,
    this.errors = const [],
  });

  LeaveApplyState copyWith({
    LeaveType? selectedType,
    DateTime? dateFrom,
    DateTime? dateTo,
    bool? isHalfDay,
    String? halfDayType,
    String? reason,
    int? attachmentId,
    bool? isSubmitting,
    List<String>? errors,
  }) {
    return LeaveApplyState(
      selectedType: selectedType ?? this.selectedType,
      dateFrom: dateFrom ?? this.dateFrom,
      dateTo: dateTo ?? this.dateTo,
      isHalfDay: isHalfDay ?? this.isHalfDay,
      halfDayType: halfDayType ?? this.halfDayType,
      reason: reason ?? this.reason,
      attachmentId: attachmentId ?? this.attachmentId,
      isSubmitting: isSubmitting ?? this.isSubmitting,
      errors: errors ?? this.errors,
    );
  }
}

// =============================================================================
// Public Holidays Provider
// =============================================================================

@riverpod
Future<List<PublicHoliday>> publicHolidays(
  PublicHolidaysRef ref, {
  required int year,
  String? countryCode,
}) async {
  return ref.watch(leaveRepositoryProvider).getPublicHolidays(
    year: year,
    countryCode: countryCode,
  );
}

// =============================================================================
// Approvals Provider (Supervisor)
// =============================================================================

@riverpod
class LeaveApprovalsNotifier extends _$LeaveApprovalsNotifier {
  @override
  Future<List<LeaveApprovalItem>> build() async {
    return ref.watch(leaveRepositoryProvider).getPendingApprovals();
  }

  Future<void> refresh() async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(
      () => ref.read(leaveRepositoryProvider).getPendingApprovals(),
    );
  }

  Future<bool> approve(int id, {String? comment}) async {
    try {
      await ref.read(leaveRepositoryProvider).approveLeaveRequest(id, comment: comment);
      await refresh();
      return true;
    } catch (e) {
      return false;
    }
  }

  Future<bool> reject(int id, {required String reason}) async {
    try {
      await ref.read(leaveRepositoryProvider).rejectLeaveRequest(id, reason: reason);
      await refresh();
      return true;
    } catch (e) {
      return false;
    }
  }
}
