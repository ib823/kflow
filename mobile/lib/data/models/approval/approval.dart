import 'package:freezed_annotation/freezed_annotation.dart';

part 'approval.freezed.dart';
part 'approval.g.dart';

/// Approval type
enum ApprovalType {
  @JsonValue('leave')
  leave,
  @JsonValue('expense')
  expense,
  @JsonValue('overtime')
  overtime,
  @JsonValue('timesheet')
  timesheet,
}

/// Approval status
enum ApprovalStatus {
  @JsonValue('pending')
  pending,
  @JsonValue('approved')
  approved,
  @JsonValue('rejected')
  rejected,
}

/// Approval model
@freezed
class Approval with _$Approval {
  const factory Approval({
    required String id,
    required String employeeId,
    required String employeeName,
    String? employeeAvatarUrl,
    required String employeeDepartment,
    required ApprovalType type,
    required String title,
    required String description,
    required ApprovalStatus status,
    required DateTime submittedAt,
    required Map<String, dynamic> details,
    String? comment,
    DateTime? respondedAt,
  }) = _Approval;

  factory Approval.fromJson(Map<String, dynamic> json) =>
      _$ApprovalFromJson(json);
}
