import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../domain/models/leave_models.dart';
import 'leave_api.dart';

part 'leave_repository.g.dart';

/// Repository for leave management with business logic.
class LeaveRepository {
  final LeaveApi _api;

  LeaveRepository(this._api);

  // ===========================================================================
  // Leave Types & Balances
  // ===========================================================================

  Future<List<LeaveType>> getLeaveTypes() => _api.getLeaveTypes();

  Future<List<LeaveBalance>> getLeaveBalances() => _api.getLeaveBalances();

  /// Get balance for specific leave type.
  Future<LeaveBalance?> getBalanceForType(int leaveTypeId) async {
    final balances = await getLeaveBalances();
    return balances.where((b) => b.leaveTypeId == leaveTypeId).firstOrNull;
  }

  // ===========================================================================
  // Leave Requests
  // ===========================================================================

  Future<List<LeaveRequest>> getLeaveRequests({String? status}) =>
      _api.getLeaveRequests(status: status);

  Future<LeaveRequest> submitLeaveRequest(LeaveApplyRequest request) =>
      _api.submitLeaveRequest(request);

  Future<LeaveRequest> getLeaveRequestDetail(int id) =>
      _api.getLeaveRequestDetail(id);

  Future<void> cancelLeaveRequest(int id) => _api.cancelLeaveRequest(id);

  // ===========================================================================
  // Calendar & Holidays
  // ===========================================================================

  Future<List<PublicHoliday>> getPublicHolidays({
    required int year,
    String? countryCode,
  }) =>
      _api.getPublicHolidays(year: year, countryCode: countryCode);

  Future<Map<String, dynamic>> getLeaveCalendar({
    required int year,
    required int month,
  }) =>
      _api.getLeaveCalendar(year: year, month: month);

  // ===========================================================================
  // Approvals
  // ===========================================================================

  Future<List<LeaveApprovalItem>> getPendingApprovals() =>
      _api.getPendingApprovals();

  Future<void> approveLeaveRequest(int id, {String? comment}) =>
      _api.approveLeaveRequest(id, comment: comment);

  Future<void> rejectLeaveRequest(int id, {required String reason}) =>
      _api.rejectLeaveRequest(id, reason: reason);

  // ===========================================================================
  // Validation Helpers
  // ===========================================================================

  /// Calculate working days between two dates (excluding weekends and holidays).
  Future<double> calculateWorkingDays({
    required DateTime dateFrom,
    required DateTime dateTo,
    required String countryCode,
    bool isHalfDay = false,
  }) async {
    final holidays = await getPublicHolidays(
      year: dateFrom.year,
      countryCode: countryCode,
    );
    final holidayDates = holidays.map((h) => h.date).toSet();

    double days = 0;
    var current = dateFrom;
    while (!current.isAfter(dateTo)) {
      // Skip weekends (Saturday = 6, Sunday = 7)
      if (current.weekday != 6 && current.weekday != 7) {
        // Skip holidays
        if (!holidayDates.contains(DateTime(current.year, current.month, current.day))) {
          days += 1;
        }
      }
      current = current.add(const Duration(days: 1));
    }

    if (isHalfDay && days == 1) {
      days = 0.5;
    }

    return days;
  }

  /// Validate leave request before submission.
  Future<List<String>> validateLeaveRequest({
    required LeaveApplyRequest request,
    required LeaveType leaveType,
    required LeaveBalance balance,
    required String countryCode,
  }) async {
    final errors = <String>[];

    // Check date order
    if (request.dateTo.isBefore(request.dateFrom)) {
      errors.add('End date must be on or after start date');
    }

    // Check if date_from is in the future (for new requests)
    if (request.dateFrom.isBefore(DateTime.now().subtract(const Duration(days: 1)))) {
      errors.add('Leave cannot start in the past');
    }

    // Calculate working days
    final workingDays = await calculateWorkingDays(
      dateFrom: request.dateFrom,
      dateTo: request.dateTo,
      countryCode: countryCode,
      isHalfDay: request.isHalfDay,
    );

    if (workingDays <= 0) {
      errors.add('No working days in selected range');
    }

    // Check balance (unless allow_negative)
    if (!leaveType.allowsNegative && workingDays > balance.balance) {
      errors.add('Insufficient leave balance');
    }

    // Check half day eligibility
    if (request.isHalfDay && !leaveType.allowsHalfDay) {
      errors.add('Half day not allowed for this leave type');
    }

    // Check notice period
    if (leaveType.minDaysNotice > 0) {
      final daysUntilLeave = request.dateFrom.difference(DateTime.now()).inDays;
      if (daysUntilLeave < leaveType.minDaysNotice) {
        errors.add('Minimum ${leaveType.minDaysNotice} days notice required');
      }
    }

    // Check max consecutive days
    if (leaveType.maxConsecutiveDays > 0 && workingDays > leaveType.maxConsecutiveDays) {
      errors.add('Maximum ${leaveType.maxConsecutiveDays} consecutive days allowed');
    }

    return errors;
  }
}

@riverpod
LeaveRepository leaveRepository(LeaveRepositoryRef ref) {
  return LeaveRepository(ref.watch(leaveApiProvider));
}
