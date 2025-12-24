import 'package:freezed_annotation/freezed_annotation.dart';

part 'leave.freezed.dart';
part 'leave.g.dart';

@freezed
class LeaveType with _$LeaveType {
  const factory LeaveType({
    required int id,
    required String code,
    required String name,
    @JsonKey(name: 'name_ms') String? nameMs,
    String? description,
    String? color,
    String? icon,
    @JsonKey(name: 'default_entitlement') @Default(0) double defaultEntitlement,
    @JsonKey(name: 'allow_half_day') @Default(false) bool allowHalfDay,
    @JsonKey(name: 'requires_attachment') @Default(false) bool requiresAttachment,
    @JsonKey(name: 'min_days_notice') @Default(0) int minDaysNotice,
    @JsonKey(name: 'max_days_per_request') int? maxDaysPerRequest,
  }) = _LeaveType;

  factory LeaveType.fromJson(Map<String, dynamic> json) =>
      _$LeaveTypeFromJson(json);
}

@freezed
class LeaveBalance with _$LeaveBalance {
  const factory LeaveBalance({
    @JsonKey(name: 'leave_type') required LeaveType leaveType,
    required int year,
    @Default(0) double entitled,
    @Default(0) double carried,
    @Default(0) double adjustment,
    @Default(0) double taken,
    @Default(0) double pending,
    @Default(0) double balance,
    @Default(0) double available,
  }) = _LeaveBalance;

  factory LeaveBalance.fromJson(Map<String, dynamic> json) =>
      _$LeaveBalanceFromJson(json);
}

@freezed
class LeaveRequest with _$LeaveRequest {
  const factory LeaveRequest({
    required int id,
    @JsonKey(name: 'leave_type') required LeaveType leaveType,
    @JsonKey(name: 'date_from') required String dateFrom,
    @JsonKey(name: 'date_to') required String dateTo,
    @JsonKey(name: 'half_day_type') String? halfDayType,
    @JsonKey(name: 'total_days') required double totalDays,
    String? reason,
    required String status,
    @JsonKey(name: 'can_cancel') @Default(false) bool canCancel,
    LeaveApprover? approver,
    @JsonKey(name: 'approved_at') String? approvedAt,
    @JsonKey(name: 'rejection_reason') String? rejectionReason,
    @JsonKey(name: 'created_at') String? createdAt,
  }) = _LeaveRequest;

  factory LeaveRequest.fromJson(Map<String, dynamic> json) =>
      _$LeaveRequestFromJson(json);
}

@freezed
class LeaveApprover with _$LeaveApprover {
  const factory LeaveApprover({
    int? id,
    String? name,
  }) = _LeaveApprover;

  factory LeaveApprover.fromJson(Map<String, dynamic> json) =>
      _$LeaveApproverFromJson(json);
}

@freezed
class PublicHoliday with _$PublicHoliday {
  const factory PublicHoliday({
    required int id,
    required String name,
    @JsonKey(name: 'name_ms') String? nameMs,
    required String date,
    String? state,
    @JsonKey(name: 'holiday_type') required String holidayType,
  }) = _PublicHoliday;

  factory PublicHoliday.fromJson(Map<String, dynamic> json) =>
      _$PublicHolidayFromJson(json);
}

@freezed
class CreateLeaveRequest with _$CreateLeaveRequest {
  const factory CreateLeaveRequest({
    @JsonKey(name: 'leave_type_id') required int leaveTypeId,
    @JsonKey(name: 'date_from') required String dateFrom,
    @JsonKey(name: 'date_to') required String dateTo,
    @JsonKey(name: 'half_day_type') String? halfDayType,
    String? reason,
    @JsonKey(name: 'attachment_id') int? attachmentId,
  }) = _CreateLeaveRequest;

  factory CreateLeaveRequest.fromJson(Map<String, dynamic> json) =>
      _$CreateLeaveRequestFromJson(json);
}
