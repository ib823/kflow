import 'package:freezed_annotation/freezed_annotation.dart';

part 'leave_models.freezed.dart';
part 'leave_models.g.dart';

/// Leave type definition from GET /api/v1/leave/types
@freezed
class LeaveType with _$LeaveType {
  const factory LeaveType({
    required int id,
    required String code,
    required String name,
    required String color,
    required bool requiresAttachment,
    required bool allowsHalfDay,
    required bool allowsNegative,
    required int minDaysNotice,
    required int maxConsecutiveDays,
  }) = _LeaveType;

  factory LeaveType.fromJson(Map<String, dynamic> json) =>
      _$LeaveTypeFromJson(json);
}

/// Leave balance from GET /api/v1/leave/balances
@freezed
class LeaveBalance with _$LeaveBalance {
  const factory LeaveBalance({
    required int leaveTypeId,
    required String leaveTypeName,
    required String leaveTypeCode,
    required String leaveTypeColor,
    required double entitled,
    required double taken,
    required double pending,
    required double balance,
    required double carryForward,
    required DateTime periodStart,
    required DateTime periodEnd,
  }) = _LeaveBalance;

  factory LeaveBalance.fromJson(Map<String, dynamic> json) =>
      _$LeaveBalanceFromJson(json);
}

/// Leave request from GET /api/v1/leave/requests
@freezed
class LeaveRequest with _$LeaveRequest {
  const factory LeaveRequest({
    required int id,
    required int leaveTypeId,
    required String leaveTypeName,
    required String leaveTypeColor,
    required DateTime dateFrom,
    required DateTime dateTo,
    required bool isHalfDay,
    String? halfDayType,
    required double workingDays,
    String? reason,
    int? attachmentId,
    required String status,
    String? approverName,
    DateTime? approvedAt,
    String? rejectionReason,
    required DateTime createdAt,
  }) = _LeaveRequest;

  factory LeaveRequest.fromJson(Map<String, dynamic> json) =>
      _$LeaveRequestFromJson(json);
}

/// Leave apply request for POST /api/v1/leave/requests
@freezed
class LeaveApplyRequest with _$LeaveApplyRequest {
  const factory LeaveApplyRequest({
    required int leaveTypeId,
    required DateTime dateFrom,
    required DateTime dateTo,
    @Default(false) bool isHalfDay,
    String? halfDayType,
    String? reason,
    int? attachmentId,
  }) = _LeaveApplyRequest;

  factory LeaveApplyRequest.fromJson(Map<String, dynamic> json) =>
      _$LeaveApplyRequestFromJson(json);
}

/// Public holiday from GET /api/v1/leave/holidays
@freezed
class PublicHoliday with _$PublicHoliday {
  const factory PublicHoliday({
    required int id,
    required String name,
    required DateTime date,
    required String countryCode,
    String? stateCode,
    required bool isNational,
  }) = _PublicHoliday;

  factory PublicHoliday.fromJson(Map<String, dynamic> json) =>
      _$PublicHolidayFromJson(json);
}

/// Leave approval item for supervisors from GET /api/v1/approvals
@freezed
class LeaveApprovalItem with _$LeaveApprovalItem {
  const factory LeaveApprovalItem({
    required int id,
    required int employeeId,
    required String employeeName,
    String? employeePhoto,
    required String department,
    required String leaveTypeName,
    required String leaveTypeColor,
    required DateTime dateFrom,
    required DateTime dateTo,
    required double workingDays,
    required bool isHalfDay,
    String? halfDayType,
    String? reason,
    required DateTime submittedAt,
  }) = _LeaveApprovalItem;

  factory LeaveApprovalItem.fromJson(Map<String, dynamic> json) =>
      _$LeaveApprovalItemFromJson(json);
}

/// Calendar day data for leave calendar view
@freezed
class CalendarDay with _$CalendarDay {
  const factory CalendarDay({
    required DateTime date,
    required bool isWeekend,
    required bool isHoliday,
    String? holidayName,
    List<LeaveRequest>? leaveRequests,
  }) = _CalendarDay;

  factory CalendarDay.fromJson(Map<String, dynamic> json) =>
      _$CalendarDayFromJson(json);
}

/// Leave request status enum
enum LeaveStatus {
  draft,
  pending,
  approved,
  rejected,
  cancelled,
}

extension LeaveStatusX on LeaveStatus {
  String get displayName {
    switch (this) {
      case LeaveStatus.draft:
        return 'Draft';
      case LeaveStatus.pending:
        return 'Pending';
      case LeaveStatus.approved:
        return 'Approved';
      case LeaveStatus.rejected:
        return 'Rejected';
      case LeaveStatus.cancelled:
        return 'Cancelled';
    }
  }

  bool get isEditable => this == LeaveStatus.draft;
  bool get isCancellable => this == LeaveStatus.pending;
}
