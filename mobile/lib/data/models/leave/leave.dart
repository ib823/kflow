import 'package:freezed_annotation/freezed_annotation.dart';

part 'leave.freezed.dart';
part 'leave.g.dart';

/// Leave status
enum LeaveStatus {
  @JsonValue('draft')
  draft,
  @JsonValue('pending')
  pending,
  @JsonValue('approved')
  approved,
  @JsonValue('rejected')
  rejected,
  @JsonValue('cancelled')
  cancelled,
}

/// Leave type model
@freezed
class LeaveType with _$LeaveType {
  const factory LeaveType({
    required String id,
    required String code,
    required String name,
    required int colorValue,
    required String iconName,
    @Default(true) bool isPaid,
    @Default(false) bool requiresAttachment,
  }) = _LeaveType;

  factory LeaveType.fromJson(Map<String, dynamic> json) =>
      _$LeaveTypeFromJson(json);
}

/// Leave balance model
@freezed
class LeaveBalance with _$LeaveBalance {
  const LeaveBalance._();

  const factory LeaveBalance({
    required String leaveTypeId,
    required String leaveTypeName,
    required int colorValue,
    required String iconName,
    required double entitled,
    required double taken,
    required double pending,
    required double balance,
  }) = _LeaveBalance;

  factory LeaveBalance.fromJson(Map<String, dynamic> json) =>
      _$LeaveBalanceFromJson(json);

  /// Calculate progress (0.0 to 1.0)
  double get progress => entitled > 0 ? (entitled - balance) / entitled : 0.0;
}

/// Leave request model
@freezed
class LeaveRequest with _$LeaveRequest {
  const LeaveRequest._();

  const factory LeaveRequest({
    required String id,
    required String leaveTypeId,
    required String leaveTypeName,
    required int leaveTypeColor,
    required DateTime startDate,
    required DateTime endDate,
    required double days,
    required String reason,
    String? attachmentUrl,
    required LeaveStatus status,
    String? approverComment,
    String? approverId,
    String? approverName,
    DateTime? respondedAt,
    required DateTime createdAt,
    required DateTime updatedAt,
  }) = _LeaveRequest;

  factory LeaveRequest.fromJson(Map<String, dynamic> json) =>
      _$LeaveRequestFromJson(json);

  /// Get date range display
  String get dateRange {
    if (startDate == endDate) {
      return '${startDate.day} ${_monthAbbr(startDate.month)} ${startDate.year}';
    }
    if (startDate.year == endDate.year) {
      if (startDate.month == endDate.month) {
        return '${startDate.day} - ${endDate.day} ${_monthAbbr(startDate.month)} ${startDate.year}';
      }
      return '${startDate.day} ${_monthAbbr(startDate.month)} - ${endDate.day} ${_monthAbbr(endDate.month)} ${endDate.year}';
    }
    return '${startDate.day} ${_monthAbbr(startDate.month)} ${startDate.year} - ${endDate.day} ${_monthAbbr(endDate.month)} ${endDate.year}';
  }

  String _monthAbbr(int month) {
    const abbrs = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
    return abbrs[month - 1];
  }
}
